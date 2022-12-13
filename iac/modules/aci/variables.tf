variable "root_name" {
  type = string
}

variable "group_name" {
  type = string
}

variable "pull_identity_resource_id" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "image" {
  type    = string
  default = "nginx:alpine"
}
variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}
