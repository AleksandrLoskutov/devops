variable "instance_family_image" {
  description = "Instance image"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "ssh_credentials" {
  description = "Credentials for connect to instances"
  type        = object({
    user        = string
    private_key = string
    pub_key     = string
  })
  default     = {
    user        = "ubuntu"
    private_key = "~/.ssh/id_*"
    pub_key     = "~/.ssh/id_*.pub"
  }
}
