variable "project_name" { type = string }
variable "environment"  { type = string }
variable "location"     { type = string }
variable "sql_admin_login" { 
  type      = string
  sensitive = true 
}
variable "sql_admin_password" { 
  type      = string
  sensitive = true # This hides the password from terminal logs
}