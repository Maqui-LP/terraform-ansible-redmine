
variable "root_db_pass" {
  type    = string
  default = "rootpass"
}

variable "redmine_db_pass" {
  type    = string
  default = "password"
}

variable "use_externalDB" {
  type    = string
  default = "true"
}

# The window to perform maintenance in. Syntax: "ddd:hh24:mi-ddd:hh24:mi". 
# Eg: "Mon:00:00-Mon:03:00".
variable "maintenance_window" {
  type    = string
  default = "Sun:23:45-Mon:01:45"
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

# The daily time range (in UTC) during which automated backups are created if they are enabled. 
# Example: "09:46-10:16". Must not overlap with maintenance_window
variable "backup_window" {
  type    = string
  default = "02:30-03:30"
}

variable "backup_snapshot_identifier" {
  type    = string
  default = ""
}
