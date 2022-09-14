variable "project_id" {}
variable "sa-name" {
  default = "edge-api-server"
}

variable "api-sa-roles" {
  default = [
      "logging.logWriter",
      "monitoring.metricWriter",
      "stackdriver.resourceMetadata.writer",
      "opsconfigmonitoring.resourceMetadata.writer",
      "monitoring.dashboardEditor",
      "compute.instanceAdmin.v1",
      "gkehub.viewer",
      "logging.viewer",
      "secretmanager.admin"
  ]
}