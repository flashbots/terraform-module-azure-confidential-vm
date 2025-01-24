variable "location" {
  type        = string
  description = "The location where to create the instance at"
}

variable "name" {
  type        = string
  description = "The name of the group to create"
}

variable "egress_ranges" {
  type    = map(list(string))
  default = {}

  description = <<-EOT
    A list of range-based egress rules to create.

    Example:

    ```terraform
      egress_ranges = {
        "0 | all" = ["0.0.0.0/0", "::/0"]
      }
    ```
  EOT
}

variable "ingress_ranges" {
  type    = map(list(string))
  default = {}

  description = <<-EOT
    A list of range-based ingress rules to create.

    Example:

    ```terraform
      ingress_ranges = {
        "30303 | tcp      " = ["0.0.0.0/0", "::/0"]
        "30303 | udp | p2p" = ["0.0.0.0/0", "::/0"]
      }
    ```
  EOT
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the instance in"
}
