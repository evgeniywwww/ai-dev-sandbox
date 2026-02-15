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
