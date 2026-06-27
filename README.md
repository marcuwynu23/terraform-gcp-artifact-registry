# terraform-gcp-artifact-registry

This Terraform project provisions a Google Artifact Registry Docker repository for storing and managing container images.

## Architecture

### Flowchart
```mermaid
graph TD
    A[User] -->|terraform apply| B(Terraform)
    B -->|Auth via gcloud ADC| C{GCP API}
    C -->|Enable| D[Artifact Registry API]
    C -->|Create| E[Docker Repository]
    C -->|Bind IAM| F[Reader/Writer Roles]
```

### Sequence Diagram
```mermaid
sequenceDiagram
    participant U as User
    participant T as Terraform
    participant G as gcloud CLI
    participant API as GCP Artifact Registry API
    participant AR as Artifact Registry

    U->>G: gcloud auth application-default login
    G-->>U: Authentication Success
    U->>T: terraform apply
    T->>API: Enable Artifact Registry API
    T->>API: Create Docker Repository
    T->>API: Bind IAM Roles
    API->>AR: Provision Repository
    API-->>T: Repository Ready
    T-->>U: Outputs (Registry URL, Repo ID)
```

## Repository Specifications
- **Format**: `DOCKER` (container images).
- **Regions**: `us-west1`, `us-central1`, or `us-east1`.
- **IAM**: Granular reader/writer roles for users and service accounts.

## Prerequisites
1.  **Google Cloud SDK**: [Installed and initialized](https://cloud.google.com/sdk/docs/install).
2.  **Terraform**: [Installed](https://developer.hashicorp.com/terraform/downloads).
3.  **Container CLI**: [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/docs/installation).

## Setup & Deployment

1.  **Authenticate and Select Project**:
    Instead of using a service account JSON file, this project uses your local `gcloud` credentials.
    ```bash
    # Authenticate
    gcloud auth application-default login

    # Select your project
    gcloud config set project your-project-id
    ```

2.  **Configure Variables**:
    Create a `terraform.tfvars` file based on the example:
    ```hcl
    project_id       = "your-project-id"
    region           = "us-central1"
    repository_id    = "docker-repo"
    description      = "Docker repository for storing container images"
    reader_members   = ["user:your-email@example.com"]
    writer_members   = ["user:your-email@example.com"]
    ```

3.  **Deploy**:
    ```bash
    terraform init
    terraform apply
    ```

4.  **Important: Configure Registry Auth**:
    After deployment, authenticate your container CLI to use your gcloud credentials.

    **Docker**:
    ```bash
    gcloud auth configure-docker us-central1-docker.pkg.dev
    ```

    **Podman** (option A — using gcloud access token):
    ```bash
    gcloud auth print-access-token | podman login -u oauth2accesstoken --password-stdin us-central1-docker.pkg.dev
    ```

    **Podman** (option B — using service account JSON key):
    ```bash
    podman login -u _json_key --password-stdin us-central1-docker.pkg.dev < path/to/key.json
    ```

5.  **Publish an Image**:
    **Docker**:
    ```bash
    # Build your image
    docker build -t my-app .

    # Tag for Artifact Registry (use the docker_registry_url from outputs)
    docker tag my-app us-central1-docker.pkg.dev/your-project-id/docker-repo-XXXX/my-app:latest

    # Push the image
    docker push us-central1-docker.pkg.dev/your-project-id/docker-repo-XXXX/my-app:latest
    ```

    **Podman**:
    ```bash
    # Build your image
    podman build -t my-app .

    # Tag for Artifact Registry
    podman tag my-app us-central1-docker.pkg.dev/your-project-id/docker-repo-XXXX/my-app:latest

    # Push the image
    podman push us-central1-docker.pkg.dev/your-project-id/docker-repo-XXXX/my-app:latest
    ```

6.  **Pull and Use the Image**:
    Any GCP service with `roles/artifactregistry.reader` (e.g. Cloud Run, GKE, Compute Engine) can pull the image:
    ```bash
    docker pull us-central1-docker.pkg.dev/your-project-id/docker-repo-XXXX/my-app:latest
    ```
    Or with Podman:
    ```bash
    podman pull us-central1-docker.pkg.dev/your-project-id/docker-repo-XXXX/my-app:latest
    ```

## Usage as a Module

Reference this repository as a Terraform module in your own configurations:

> **Option 1**: Terraform Registry (recommended)
> ```hcl
> module "artifact-registry" {
>   source  = "marcuwynu23/artifact-registry/gcp"
>   version = "1.0.0"
>
>   project_id     = var.project_id
>   region         = "us-central1"
>   repository_id  = "my-app-repo"
>   writer_members = ["user:writer@example.com"]
>   reader_members = ["user:reader@example.com"]
> }
> ```
>
> **Option 2**: GitHub source
> ```hcl
> module "artifact-registry" {
>   source = "github.com/marcuwynu23/terraform-gcp-artifact-registry?ref=main"
>
>   project_id     = var.project_id
>   region         = "us-central1"
>   repository_id  = "my-app-repo"
>   writer_members = ["user:writer@example.com"]
>   reader_members = ["user:reader@example.com"]
> }
> ```

Then use the outputs to get the registry URL:
```hcl
output "registry_url" {
  value = module.artifact-registry.docker_registry_url
}
```

## Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `project_id` | GCP project ID | `string` | (required) |
| `region` | GCP region (free tier: us-west1, us-central1, us-east1) | `string` | `"us-central1"` |
| `repository_id` | Base ID of the repository (random suffix appended) | `string` | `"docker-repo"` |
| `description` | Description of the repository | `string` | `"Docker repository for storing container images"` |
| `reader_members` | List of members with read access | `list(string)` | `[]` |
| `writer_members` | List of members with write access | `list(string)` | `[]` |

## Outputs

| Output | Description |
|--------|-------------|
| `repository_id` | The ID of the created repository |
| `repository_name` | The full resource name of the repository |
| `docker_registry_url` | The Docker registry URL for push/pull |
| `registry_location` | The region of the repository |
