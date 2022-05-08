variable "DEPLOY_ROLE" {} # TODO: uncomment line after seed deployment

variable "PROJECT" {
  type    = string
  default = "demo" # do not change after setting to first value
}

variable "repo_owner" {
  type        = string
  description = "The name of the owner of the project."
  default     = "Ramynassef"
}

variable "repo_org" {
  type        = string
  description = "The name of the owner of the project."
  default     = "Ramynassef"
}

variable "github_base_url" {
  type        = string
  description = "GitHub target API endpoint"
  default     = "https://api.github.com/"
}