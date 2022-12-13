variable "root_name" {
  type = string
}


variable "group_id" {
  type = string
}

variable "container_app_environment_resource_id" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "msi_resource_id" {
  type = string
}

variable "acr_name" {
  type = string
}
