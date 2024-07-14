resource "random_integer" "name" {
  min = 10
  max = 99
}

locals {
  name = "${var.name}${random_integer.name.result}"
  tags = merge(var.tags, {
    "purpose" = "k8s scaling lab"
  })
}

