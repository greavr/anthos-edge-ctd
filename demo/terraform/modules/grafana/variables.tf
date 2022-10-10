variable "project_id" {}
variable "zone" {}
variable "vpc-id" {}
variable "node-os" {}

variable "instance-type" {
    default = "e2-small"
}
variable "grafana-sa-roles" {
    default = [
      "logging.logWriter",
      "monitoring.metricWriter",
      "stackdriver.resourceMetadata.writer",
      "opsconfigmonitoring.resourceMetadata.writer",
      "monitoring.dashboardEditor",
      "monitoring.admin"
  ]
}