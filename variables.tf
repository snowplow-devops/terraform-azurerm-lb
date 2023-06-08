variable "name" {
  description = "A name which will be pre-pended to the resources created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the Application Gateway into"
  type        = string
}

variable "subnet_id" {
  description = "The subnet id to deploy the load balancer across"
  type        = string
}

variable "capacity" {
  description = "The capacity units assigned to the load balancer (1-32)"
  type        = number
  default     = 2
}

variable "egress_port" {
  description = "The port that the downstream webserver exposes over HTTP"
  type        = number
  default     = 8080
}

variable "probe_path" {
  description = "The path to bind for health checks"
  type        = string
}

variable "probe_match_status_codes" {
  description = "The valid status codes for health checks"
  type        = list(string)
  default     = ["200-399"]
}

variable "ssl_certificate_enabled" {
  description = "A boolean which triggers adding or removing the HTTPS proxy"
  type        = bool
  default     = false
}

variable "ssl_certificate_data" {
  description = "The base64-encoded PFX certificate data"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssl_certificate_password" {
  description = "The base64-encoded PFX certificate password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "The tags to append to this resource"
  default     = {}
  type        = map(string)
}
