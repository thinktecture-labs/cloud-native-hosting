variable "root_name" {
  type = string
}


variable "group_id" {
  type = string
}

variable "log_analytics" {
  type = object({ workspace_id = string, shared_key = string })
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}
