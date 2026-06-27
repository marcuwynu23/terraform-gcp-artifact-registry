provider "google" {
  project = var.project_id
  region  = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_project_service" "artifactregistry_api" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "${var.repository_id}-${random_id.suffix.hex}"
  description   = var.description
  format        = "DOCKER"
  mode          = "STANDARD_REPOSITORY"

  depends_on = [google_project_service.artifactregistry_api]
}

resource "google_artifact_registry_repository_iam_member" "read_access" {
  count = length(var.reader_members)

  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.reader"
  member     = var.reader_members[count.index]

  depends_on = [google_artifact_registry_repository.docker_repo]
}

resource "google_artifact_registry_repository_iam_member" "write_access" {
  count = length(var.writer_members)

  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.writer"
  member     = var.writer_members[count.index]

  depends_on = [google_artifact_registry_repository.docker_repo]
}
