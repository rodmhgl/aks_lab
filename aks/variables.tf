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