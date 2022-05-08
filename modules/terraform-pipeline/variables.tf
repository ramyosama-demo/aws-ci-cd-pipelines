variable "tags" {
  type = map(string)
}

# repo/id

variable "repository_name" {
  type        = string
  description = "The name of the repository of the project."
}

variable "repo_owner" {
  type        = string
  description = "The name of the owner of the project."
  default     = "Ramynassef"
}

variable "repo_org" {
  type        = string
  description = "The name of the owner of the project."
  default     = "ramyosama-demo"
}

variable "custom_identifier" {
  description = "pipeline custom identifier. useful when multiple pipelines off same repo branch"
  default     = ""
}

# build

variable "build_image" {
  default = "aws/codebuild/python:3.5.2"
}

variable "build_spec" {
  default = "buildspec.yml"
}

# environment

variable "enable_dev" {
  type    = bool
  default = false
}

variable "enable_prod" {
  type    = bool
  default = false
}

# accounts

variable "dev_account_id" {
  default = ""
}

variable "prod_account_id" {
  default = ""
}

#iam

variable "pipeline_role" {
  default = "interject-deployment-role"
}

# prod branch choice
variable "branch" {
  type        = string
  description = "Name for the listening branch for Prod pipelines"
  default     = "main"
}
