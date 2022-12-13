variable "root_name" {
  type = string
}

variable "group_name" {
  type = string
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}
