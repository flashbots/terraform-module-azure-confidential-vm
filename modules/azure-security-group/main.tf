locals {
  egress_ranges = flatten([for k, ranges in var.egress_ranges : [for r in ranges : {
    name = replace(title(replace(replace(join(" ", [
      "allow",
      (length(split("|", k)) == 3 ? trimspace(split("|", k)[2]) : replace(trimspace(split("|", k)[0], "..", "-"))), # description or port range
    ]), "*", "any"), "-", " ")), " ", "")

    from_port = trimspace(split("..", trimspace(split("|", k)[0]))[0])
    to_port   = trimspace(reverse(split("..", trimspace(split("|", k)[0])))[0])
    range     = r

    protocol = title(trimspace(split("|", k)[1]))
  }]])

  ingress_ranges = flatten([for k, ranges in var.ingress_ranges : [for r in ranges : {
    name = replace(title(replace(replace(join(" ", [
      "allow",
      (length(split("|", k)) == 3 ? trimspace(split("|", k)[2]) : replace(trimspace(split("|", k)[0], "..", "-"))), # description or port range
    ]), "*", "any"), "-", " ")), " ", "")

    from_port = trimspace(split("..", trimspace(split("|", k)[0]))[0])
    to_port   = trimspace(reverse(split("..", trimspace(split("|", k)[0])))[0])
    range     = r

    protocol = title(trimspace(split("|", k)[1]))
  }]])
}


resource "azurerm_network_security_group" "this" {
  name = var.name

  location            = var.location
  resource_group_name = var.resource_group_name

  # Egress

  dynamic "security_rule" {
    for_each = zipmap(range(length(local.egress_ranges)), local.egress_ranges)

    content {
      access    = "Allow"
      direction = "Outbound"
      priority  = 1000 + security_rule.key

      name     = format("%s_%03d", security_rule.value.name, 1000 + security_rule.key)
      protocol = security_rule.value.protocol

      source_address_prefix = "*"
      source_port_range     = "*"

      destination_address_prefix = security_rule.value.range

      destination_port_range = (security_rule.value.from_port == security_rule.value.to_port
        ? security_rule.value.from_port
        : "${security_rule.value.from_port}-${security_rule.value.to_port}"
      )
    }
  }

  # Ingress

  dynamic "security_rule" {
    for_each = zipmap(range(length(local.ingress_ranges)), local.ingress_ranges)

    content {
      access    = "Allow"
      direction = "Inbound"
      priority  = 2000 + security_rule.key

      name     = format("%s_%03d", security_rule.value.name, 2000 + security_rule.key)
      protocol = security_rule.value.protocol

      source_address_prefix = security_rule.value.range
      source_port_range     = "*"

      destination_address_prefix = "*"

      destination_port_range = (security_rule.value.from_port == security_rule.value.to_port
        ? security_rule.value.from_port
        : "${security_rule.value.from_port}-${security_rule.value.to_port}"
      )
    }
  }
}
