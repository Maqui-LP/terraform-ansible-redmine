provider "uptimerobot" {
  api_key = file("./uptimerobotApiKey.txt")
}

resource "uptimerobot_monitor" "redmine_monitor" {
  friendly_name = "Redmine Monitor"
  type          = "http"
  url           = "http://${aws_instance.redmine_app.public_dns}"


  depends_on = [
    aws_instance.redmine_app
  ]
}

output "monitor_url" {
  value = uptimerobot_monitor.redmine_monitor.url
}
