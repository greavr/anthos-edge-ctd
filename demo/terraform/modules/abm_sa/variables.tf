variable "project_id" {}

variable "connect-agent" {
  default = [
      "gkehub.connect"
  ]
}

variable "connect-register" {
  default = [
      "gkehub.admin"
  ]
}

variable "logging-sa" {
  default = [
      "logging.logWriter",
      "monitoring.metricWriter",
      "stackdriver.resourceMetadata.writer",
      "opsconfigmonitoring.resourceMetadata.writer",
      "monitoring.dashboardEditor"
  ]
}

variable "storage-sa" {
  default = [
      "storage.admin"
  ]
}


variable "abm-node-gce-roles" {
    default = [
        "logging.logWriter",
        "monitoring.metricWriter",
        "monitoring.dashboardEditor",
        "stackdriver.resourceMetadata.writer",
        "opsconfigmonitoring.resourceMetadata.writer",
        "multiclusterservicediscovery.serviceAgent",
        "multiclusterservicediscovery.serviceAgent"
    ]
  
}

variable "abm-workstation-gce-roles" {
    default = [
        "gkehub.connect",
        "gkehub.admin",
        "logging.logWriter",
        "monitoring.metricWriter",
        "monitoring.dashboardEditor",
        "stackdriver.resourceMetadata.writer",
        "opsconfigmonitoring.resourceMetadata.writer",
        "multiclusterservicediscovery.serviceAgent",
        "multiclusterservicediscovery.serviceAgent",
        "secretmanager.secretAccessor",
        "editor",
        "iam.securityAdmin"
    ]
  
}