output "repository_id" {
  description = "The ID of the created repository"
  value       = google_artifact_registry_repository.docker_repo.repository_id
}

output "repository_name" {
  description = "The name (full resource name) of the repository"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "docker_registry_url" {
  description = "The Docker registry URL for pushing/pulling images"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "registry_location" {
  description = "The location (region) of the repository"
  value       = google_artifact_registry_repository.docker_repo.location
}
