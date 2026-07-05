# modules/ecr/variables.tf

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "rag-app"
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
  
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE"
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository"
  type        = string
  default     = "AES256"
  
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either AES256 or KMS"
  }
}

variable "enable_repository_policy" {
  description = "Enable repository policy for cross-account or public access"
  type        = bool
  default     = false
}

variable "enable_pull_through_cache" {
  description = "Enable pull-through cache for upstream registries"
  type        = bool
  default     = false
}

variable "pull_through_cache_prefix" {
  description = "Prefix for pull-through cache repository"
  type        = string
  default     = "docker-hub"
}

variable "upstream_registry_url" {
  description = "URL of the upstream registry (e.g., registry-1.docker.io for Docker Hub)"
  type        = string
  default     = "registry-1.docker.io"
}

variable "tags" {
  description = "Tags to apply to ECR resources"
  type        = map(string)
  default     = {}
}