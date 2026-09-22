# K3s Server – Hetzner

My implementation of a K3s cluster on Hetzner, built as part of a
hands-on assignment for DevOps, base was originally on Azure but
migrated to Hetzner, where my academy runs its school environment

## Tech stack used
1. **Terraform** provisions the servers on Hetzner and builds the infrastructure/architecture 
2. **Ansible** configures the nodes, installs K3s, installs basic Linux tools, and installs Helm and ArgoCD to the cluster 
3. **Helm** packages the application and install charts from the Artifact Hub 
4. **ArgoCD** deploys/synchronises the applications from the **Helm** charts (GitOps)

## Repository structure
| Folder       | Contents                             |
|--------------|--------------------------------------|
| `terraform/` | Infrastructure on Hetzner            |
| `ansible/`   | Node configuration and K3s install   |
| `charts/`    | Helm charts for the API and web app  |
| `argocd/`    | ArgoCD apps (app-of-apps pattern)    |

## CI/CD
The pipeline ran on GitLab CI (`.gitlab-ci.yml`).

## What I learned
- First time using Terraform, Ansible, Helm and ArgoCD
- More understanding of the architecture of Virtual Machines in a cloud-environment
- More understanding of Kubernetes as a tool and as a container orchestrator   
