variable "nsg_id" {
  type        = string
  description = "ID of the existing Network Security Group to attach rules to."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group containing the NSG."
}

variable "security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "List of security rules to create on the NSG. Rule names must be unique within the list."
}
