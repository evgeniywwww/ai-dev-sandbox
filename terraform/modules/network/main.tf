#########################################################
# Network Module - Topology Layer
#########################################################
#
# PURPOSE:
#   Defines Azure network topology including VNet, subnets,
#   NAT Gateway, NSG resources, and route tables.
#
# LAYER RESPONSIBILITY:
#   - Network topology (VNet, subnets, NAT, route tables)
#   - NSG resource creation (but NOT security rules)
#   - Infrastructure attachments (subnet associations)
#
# MUST NOT CONTAIN:
#   - Security policy (rules, firewall config)
#   - Environment-specific logic
#   - Hardcoded CIDR ranges
#   - Naming logic (names are passed from root)
#
# STANDARDS ALIGNMENT:
#   Section 7:  Network Architecture (Azure)
#   Section 8:  AKS Network Model (delegation)
#   Section 9:  NAT Design
#   Section 12: Security Module Architecture (NSG creation only)
#   Section 15: Module Philosophy (deterministic, explicit inputs)
#
# RELATION TO OTHER MODULES:
#   - Security module applies rules to NSGs created here
#   - Root module passes sanitized names and CIDRs
#
#########################################################

#########################################################
# VNet and Subnets
#########################################################

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "public" {
  name                 = var.public_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet_cidr]
}

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aks_subnet_cidr]

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
}

#########################################################
# NAT Gateway (for private subnet outbound)
#########################################################

resource "azurerm_public_ip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "${var.vnet_name}-nat-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "${var.vnet_name}-nat"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "aks" {
  count = var.enable_nat_gateway ? 1 : 0

  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}

#########################################################
# Network Security Groups (empty - rules applied via security module)
#########################################################

resource "azurerm_network_security_group" "public" {
  name                = "${var.vnet_name}-public-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "private" {
  name                = "${var.vnet_name}-private-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.private.id
}

#########################################################
# Route Tables
#########################################################

resource "azurerm_route_table" "public" {
  name                          = "${var.vnet_name}-public-rt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = var.tags
}

resource "azurerm_route_table" "private" {
  name                          = "${var.vnet_name}-private-rt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = var.tags
}

resource "azurerm_subnet_route_table_association" "public" {
  subnet_id      = azurerm_subnet.public.id
  route_table_id = azurerm_route_table.public.id
}

resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.private.id
}
