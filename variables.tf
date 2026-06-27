variable "project_id" {
  description = "The GCP project ID where the Artifact Registry will be created"
  type        = string
}

variable "region" {
  description = "The region for the Artifact Registry repository (Free Tier: us-central1, us-east1, us-west1)"
  type        = string
  default     = "us-central1"

  validation {
    condition     = contains(["us-central1", "us-east1", "us-west1"], var.region)
    error_message = "Region must be one of us-central1, us-east1, or us-west1."
  }
}

variable "repository_id" {
  description = "The base ID of the repository (a random suffix will be appended)"
  type        = string
  default     = "docker-repo"
}

variable "description" {
  description = "Description of the repository"
  type        = string
  default     = "Docker repository for storing container images"
}

variable "reader_members" {
  description = "List of members (users/groups/sa) with read access (e.g. ['user:foo@example.com', 'group:bar@example.com'])"
  type        = list(string)
  default     = []
}

variable "writer_members" {
  description = "List of members (users/groups/sa) with write access"
  type        = list(string)
  default     = []
}
