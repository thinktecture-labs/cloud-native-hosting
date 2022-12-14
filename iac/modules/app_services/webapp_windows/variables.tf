variable "root_name" {
  type = string
}


variable "group_name" {
  type = string
}

variable "service_plan_id" {
  type = string
}

variable "application_insights_connection_string" {
  type      = string
  sensitive = true
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}
