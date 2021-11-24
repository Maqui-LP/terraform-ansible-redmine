
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

resource "local_file" "tf_ansible_vars" {
  content = yamlencode(
    {
      root_db_pass = var.root_db_pass
      redmine_db_pass = var.redmine_db_pass
      db_host = aws_db_instance.redmine-db.address
      use_externalDB = var.use_externalDB
    }
  ) 
  filename = "../provisioning/vars/tf_ansible_vars.yml"
}