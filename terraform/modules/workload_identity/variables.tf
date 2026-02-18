#########################################################
# Workload Identity Module - Input Variables
#########################################################
#
# PURPOSE:
#   Defines the contract for workload identity creation.
#
# LAYER RESPONSIBILITY:
#   - Type definitions
#   - Input validation
#   - Documentation
#
# MUST NOT CONTAIN:
#   - Default values (policy decisions)
#   - Environment-specific logic
#   - Hardcoded names or namespaces
#
# STANDARDS ALIGNMENT:
#   Section 2.1: variables.tf = Contract Only
#   Section 15:  Module Philosophy (explicit inputs)
#
#########################################################

variable "identity_name" {
  type        = string
  description = "Name of the User Assigned Identity."
}

variable "location" {
  type        = string
  description = "Azure region for the identity."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the identity will be created."
}

variable "oidc_issuer_url" {
  type        = string
  description = "AKS OIDC issuer URL for federated credential binding."
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for the service account that will use this identity."
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes service account name that will use this identity."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the identity."
}
