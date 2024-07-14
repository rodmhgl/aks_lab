data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

data "azuread_group" "aks_admins" {
  display_name = "k8s_admins"
}

# Get current IP address for use in KV firewall rules
data "http" "ip" {
  url = "https://api.ipify.org/"
  retry {
    attempts     = 5
    max_delay_ms = 1000
    min_delay_ms = 500
  }
}