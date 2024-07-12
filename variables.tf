variable "name" {
  type        = string
  description = "Will be used as part of the naming for resources. Must be unique."
  default     = "gitops"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy the resources."
  default     = "East US"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default = {
    "environment" = "dev"
  }
}