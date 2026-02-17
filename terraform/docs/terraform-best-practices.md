# Terraform Architecture & Platform Standards

## Purpose

This document defines architectural principles, structural conventions, and platform standards for Terraform usage within the platform engineering domain.

It serves as a long-term knowledge base and policy reference.

---

# 1. Environment Structure

Each environment must be isolated and structured as:

```
terraform/
  modules/
  envs/
    dev/
    stage/
    prod/
```

Each environment:

* Own backend configuration
* Own tfvars
* Own state
* Own subscription (recommended)

---

# 2. Variables Design Principles

## 2.1 variables.tf = Contract Only

`variables.tf` must define:

* Type
* Description
* Validation (self-contained only)

It must NOT define:

* Environment defaults
* Policy defaults
* Implicit architecture decisions

Example:

```hcl
variable "location" {
  type        = string
  description = "Azure region where resources will be deployed."
}
```

---

## 2.2 tfvars = Single Source of Truth

All environment-specific values live in:

```
dev.auto.tfvars
```

This includes:

* CIDRs
* VM sizes
* Scaling values
* Retention policies
* Tags
* Feature toggles

No hidden values in locals or modules.

---

# 3. Locals Usage Policy

`locals.tf` may only contain:

* Derived values
* Naming patterns
* Tag merges

It must NOT contain:

* Environment logic
* Business logic
* Policy enforcement
* Hidden defaults

Example:

```hcl
locals {
  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
    },
    var.common_tags
  )
}
```

---

# 4. Tagging Standard

All resources must receive consistent tags.

## Required Tags

* project
* environment
* owner
* managed_by
* cost_center

Tags are merged in locals and passed to all modules.

---

# 5. Backend Strategy

## 5.1 Backend Type

We use:

```
backend "azurerm"
```

## 5.2 State Isolation

* Each environment has its own key
* Storage account can be shared
* Subscription separation is recommended

## 5.3 Authentication

Preferred:

* Azure AD authentication
* RBAC via "Storage Blob Data Contributor"

Avoid:

* Hardcoded keys
* Committing secrets

---

# 6. Git Hygiene

The following must NEVER be committed:

```
.terraform/
*.tfstate
*.tfstate.*
terraform-provider-*
```

`.gitignore` must include:

```
**/.terraform/*
*.tfstate
*.tfstate.*
```

---

# 7. Network Architecture (Azure)

## 7.1 VNet

* /16 per environment
* Predictable naming:
  `{project}-vnet-{env}`

## 7.2 Subnets

* /24 per workload type
* Dedicated AKS subnet
* No CIDR overlap

---

# 8. AKS Network Model

AKS subnet must include:

```hcl
delegation {
  name = "aks_delegation"

  service_delegation {
    name = "Microsoft.ContainerService/managedClusters"
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
    ]
  }
}
```

This allows Azure to manage network interfaces for the cluster.

---

# 9. NAT Design

* One NAT Gateway per workload subnet
* Static Public IP
* Default outbound access disabled when NAT is attached

Avoid dual egress paths.

---

# 10. Route Tables

Do NOT create route tables unless:

* Forced tunneling required
* Azure Firewall used
* Custom next hop needed

Azure system routes cover most dev environments.

---

# 11. Network Security Groups

NSGs must:

* Have explicit ingress rules
* Have explicit egress rules
* Not remain empty

Security rules must reflect environment intent.

---

# 12. Security Module Architecture

## 12.1 Separation of Concerns

Security policy must be separated from network topology.

Network module responsibilities:

* Create VNet, subnets, NSG resources
* Manage subnet associations
* Export NSG IDs

Security module responsibilities:

* Accept NSG IDs as input
* Apply security rules dynamically
* No NSG creation

## 12.2 Policy Layer Ownership

Root module (envs/{env}):

* Defines all security rules in tfvars
* Instantiates security module per NSG
* Passes NSG ID and rule list

Modules:

* MUST NOT hardcode security rules
* MUST NOT contain security policy logic
* MUST accept rules as input variables

## 12.3 Implementation Pattern

```hcl
# In envs/dev/dev.auto.tfvars
security_rules_public = [
  {
    name                       = "allow-vnet-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
]

# In envs/dev/main.tf
module "security_public" {
  source              = "../../modules/security"
  nsg_id              = module.network.public_nsg_id
  resource_group_name = var.resource_group_name
  security_rules      = var.security_rules_public
}
```

This ensures:

* Security policy is visible in tfvars
* Modules remain reusable across environments
* Stage/prod can define different rules without module changes

---

# 13. Azure Naming Governance

## 13.1 Naming Requirements

All Azure resource names must:

* Start with alphanumeric
* End with alphanumeric or underscore
* Contain only: letters, numbers, hyphens, underscores, periods
* Not exceed 80 characters (including suffixes)

## 13.2 Sanitization Strategy

Raw variables (e.g., `var.project_name`) may contain:

* Spaces
* Special characters
* Excessive length

These MUST be sanitized before use in resource names.

## 13.3 Implementation Pattern

Sanitization must occur in `locals.tf`:

```hcl
locals {
  # Deterministic sanitization
  sanitized_project = lower(
    replace(
      replace(
        replace(var.project_name, " ", "-"),
        "/[^a-zA-Z0-9-_.]/", "-"
      ),
      "/--+/", "-"
    )
  )

  # Reserve space for suffixes
  base_name_max_length = 60
  sanitized_base_name = substr(local.sanitized_project, 0, local.base_name_max_length)

  # Use sanitized base in all resource names
  network_policy = {
    vnet_name = "${local.sanitized_base_name}-vnet-${var.environment}"
  }
}
```

## 13.4 Enforcement Rules

* Raw variables MUST NOT be used directly in resource names
* Naming sanitization MUST be deterministic (no random suffixes)
* Modules MUST NOT implement their own naming logic
* All names MUST derive from `sanitized_base_name` in root locals

Example violations:

```hcl
# BAD: Raw variable in resource name
resource "azurerm_nat_gateway" "this" {
  name = "${var.project_name}-nat"  # May fail validation
}

# GOOD: Sanitized base name
resource "azurerm_nat_gateway" "this" {
  name = "${var.vnet_name}-nat"  # vnet_name already sanitized
}
```

This ensures:

* Predictable, stable resource identity
* Compliance with Azure naming rules
* No hidden truncation or randomness
* Reusability across environments

---

# 14. Autoscaling Rules

Single-variable validation in variables.

Cross-variable validation via:

```
check { }
```

Example:

```hcl
check "autoscaling_bounds" {
  assert = var.min_node_count <= var.initial_node_count &&
           var.initial_node_count <= var.max_node_count
}
```

---

# 15. Module Philosophy

Modules must:

* Be deterministic
* Not contain hidden defaults
* Accept inputs explicitly
* Not derive environment context internally

Root module controls orchestration.
Modules implement infrastructure logic.

---

# 16. State Management Rules

* One state per environment
* Never manually edit state
* Never store state locally in Git
* Always use remote backend

---

# 17. Platform Engineering Rule

Infrastructure code must:

* Be predictable
* Be declarative
* Be environment-driven
* Avoid magic
* Avoid hidden coupling

Terraform is not scripting.
Terraform is declarative state reconciliation.

---

# 18. Design Philosophy

We optimize for:

* Clarity over cleverness
* Explicit over implicit
* Separation of concerns
* Infrastructure auditability
* Long-term maintainability

---

# 19. Non-Goals

We do NOT:

* Hardcode policy in modules
* Embed credentials in code
* Mix environments in state
* Use defaults that hide architectural decisions

---

# 20. Dev vs Production Strategy

Dev:

* Simplified network
* Minimal route tables
* Controlled scaling

Production:

* Network segmentation
* Firewall routing
* Private endpoints
* Strict RBAC
* Centralized logging

---

# 21. Review Checklist

Before apply:

* Is state remote?
* Is .terraform ignored?
* Are variables explicit?
* Are tags applied?
* Are subnets non-overlapping?
* Is NAT required?
* Are NSGs meaningful?
* Are security rules defined in tfvars?
* Are resource names sanitized in locals?
* Is scaling bounded?

---

# 22. Long-Term Vision

The Terraform layer must evolve toward:

* Clear platform boundaries
* Reusable infrastructure modules
* Policy-as-code integration
* Scalable environment replication
* Predictable cloud topology

---

# 23. AKS Architecture Standards

Azure Kubernetes Service represents a critical platform component. These standards ensure AKS deployments remain deterministic, secure, and governance-aligned.

## 23.1 AKS Access Model

API server exposure must be explicitly controlled.

Dev environments:

* May use public API server with IP restriction
* IP ranges must be defined in tfvars
* No unrestricted public access

Production environments:

* Must use private API server
* API endpoint must be VNet-internal only
* Access via private endpoint or VPN/bastion

### Enforced Rule

* MUST explicitly set `private_cluster_enabled` per environment
* MUST define `api_server_authorized_ip_ranges` when using public endpoint
* MUST NOT allow implicit public exposure

---

## 23.2 AKS Identity Model

Modern workload identity is mandatory.

Required configuration:

* OIDC issuer must be enabled
* Workload Identity must be used for pod-to-Azure authentication
* System-assigned or user-assigned managed identity must be explicit

Deprecated patterns:

* aad-pod-identity (replaced by Workload Identity)
* Service principal authentication (legacy)

### Enforced Rule

* MUST enable `oidc_issuer_enabled`
* MUST enable `workload_identity_enabled`
* MUST NOT use deprecated identity methods
* Identity configuration MUST be explicit in root (no module defaults)

---

## 23.3 AKS Networking Model

Azure CNI is the enterprise-grade networking mode.

Required configuration:

* AKS must use a dedicated subnet
* Subnet must be delegated to `Microsoft.ContainerService/managedClusters`
* IP address planning must be explicit in tfvars
* Network plugin must be defined (`azure` or `kubenet`)
* Network policy must be defined (`azure`, `calico`, or `cilium`)
* Outbound strategy must be explicit (`loadBalancer`, `userDefinedRouting`, or `managedNATGateway`)

### Enforced Rule

* MUST use Azure CNI for production
* MUST delegate AKS subnet per Section 8
* MUST define `network_plugin`, `network_policy`, and `outbound_type` in root
* MUST NOT rely on provider defaults for networking

---

## 23.4 Node Pool Governance

Node pool configuration is environment-driven.

Required parameters:

* VM size must be defined in tfvars (no module defaults)
* Autoscaling bounds must be validated (Section 14)
* Initial, min, and max node counts must satisfy: `min <= initial <= max`
* Upgrade strategy (max surge) must be configurable

### Enforced Rule

* MUST expose all node pool parameters as variables
* MUST validate autoscaling bounds via `check` blocks
* MUST NOT hardcode VM sizes or node counts in modules
* Capacity decisions belong in root tfvars

---

## 23.5 Cost Governance

Environment tier determines resource sizing.

Dev:

* Cost-optimized VM sizes (e.g., B-series, D2s)
* SKU tier: Free or Standard
* Minimal node counts
* Autoscaling with low upper bounds

Production:

* Performance-optimized VM sizes
* SKU tier: Standard or Premium
* High-availability node counts
* Autoscaling with production capacity

### Enforced Rule

* MUST define `sku_tier` explicitly per environment
* MUST NOT apply production defaults to dev environments
* Cost optimization is an environment decision, not a module decision

---

## 23.6 Module Design Rule for AKS

AKS module is an implementation layer.

The module must:

* Accept all configuration as explicit inputs
* Expose identity attributes (principal ID, OIDC issuer)
* Not embed environment policy
* Be reusable across dev/stage/prod

The module must not:

* Hardcode SKU tier, VM sizes, or node counts
* Branch by environment
* Assume networking defaults
* Hide identity or security configuration

### Enforced Rule

* Root controls: networking, capacity, identity, and exposure
* Module implements: cluster creation and infrastructure wiring
* Outputs must include: `kube_config`, `cluster_name`, `oidc_issuer_url`, `managed_identity_principal_id`

---

# 24. Provider Compatibility Rule

Terraform providers evolve continuously. Schema changes, deprecated arguments, and new features must be accounted for during code generation and maintenance.

## 24.1 Provider Version Awareness

AI-assisted or human-generated Terraform code must:

* Verify the active provider version before using resource arguments
* Align implementation with the provider schema for that version
* Not assume argument compatibility across major versions

Example:

* `azurerm` v3.x uses `enable_auto_scaling` in node pools
* `azurerm` v4.x removes `enable_auto_scaling` and infers autoscaling from `min_count`/`max_count`

## 24.2 Schema Validation Strategy

When writing or refactoring Terraform:

* Check the provider documentation for the pinned version
* Verify argument names and types match the schema
* Do not rely on deprecated or removed arguments
* Do not carry over patterns from older provider versions without validation

### Enforced Rule

* MUST validate resource arguments against the active provider version
* MUST NOT use deprecated or removed arguments
* MUST check official provider documentation when major version changes
* Provider version is pinned in `providers.tf`; implementation must match

## 24.3 Backward Compatibility Discipline

When upgrading provider versions:

* Review breaking changes in provider release notes
* Update modules to align with new schema
* Do not assume forward compatibility
* Test plan output before apply

### Enforced Rule

* Provider upgrades require explicit schema validation
* Modules must be updated when provider arguments change
* AI-generated code must adapt to the declared provider version

---
