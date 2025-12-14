variable "project_name" {
  default = "cloudops-practice"
}

variable "environment" {
  default = "dev"
}

variable "primary_location" {
  default     = "southeastasia"
  description = "Primary Region (Active)"
}

variable "secondary_location" {
  default     = "centralindia"
  description = "Secondary Region (Passive)"
}