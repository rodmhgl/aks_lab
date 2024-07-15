locals {
  tags = merge(var.tags, {
    "purpose" = "k8s scaling lab"
  })
}

