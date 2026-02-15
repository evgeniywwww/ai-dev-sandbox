#########################################################
# Network Module - Input Variables
#########################################################
#
# PURPOSE:
#   Defines the contract for the network topology module.
#   All inputs are required and must be passed from root.
#
# LAYER RESPONSIBILITY:
#   - Type definitions
#   - Input validation (where applicable)
#   - Documentation
#
# MUST NOT CONTAIN:
#   - Default values (policy decisions)
#   - Environment-specific logic
#   - Hardcoded values
#
# STANDARDS ALIGNMENT:
#   Section 2.1: variables.tf = Contract Only
#   Section 15:  Module Philosophy (explicit inputs)
#
#########################################################

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network. All other resource names are derived from this."
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network in CIDR notation."
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the public subnet."
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR prefix for the public subnet."
}

variable "aks_subnet_name" {
  type        = string
  description = "Name of the private subnet reserved for AKS node pools."
}

variable "aks_subnet_cidr" {
  type        = string
  description = "CIDR prefix for the AKS (private) subnet."
}

variable "location" {
  type        = string
  description = "Azure region for all network resources."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group where network resources will be created."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all network resources."
}
