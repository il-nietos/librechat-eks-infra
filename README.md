# LibreChat EKS Infrastructure

Terraform configuration for provisioning and deploying the [LibreChat](https://github.com/danny-avila/LibreChat) application on Amazon EKS. This infrastructure supports three isolated environments (dev, stage, prod), managed via GitHub Actions pipelines.

##  Project Overview


**LibreChat** is an open-source, self-hostable AI chat UI that supports multiple LLMs like GPT, Claude, and open models. This infrastructure project demonstrates how to deploy LibreChat on AWS in a scalable and reproducible way using EKS, Helm, and Terraform.

**Use Case**: This setup is useful for individuals or companies who want to offer a web-based chat interface backed by different LLM APIs, with full control over deployment and resource usage.

**Benefits of this setup:**
-  **Cost Efficiency**: For teams with multiple users you pay per API call, not per user.
-  **Data Privacy**: Keep all data within a company's AWS account. If you're using an API like Claude, then your chat data will necessarily transit and be processed by Anthropic’s infrastructure. However, if you plug in your own hosted model or use a custom inference API, you keep full data custody.
-  **Extensibility**: Plug in your own LLMs.
-  **Familiar UI**:  React-based interface similar to ChatGPT.

![Application diagram placeholder](/docs/images/application-diagram.png)

---

##  Architecture

This Terraform project provisions the following:

- VPC with public/private subnets across 2 AZs.
- NAT gateways and Internet Gateway for egress/ingress traffic
- EKS Cluster with managed node groups
- EBS CSI driver for persistent volumes
- AWS Load Balancer Controller for automatic provisioning of Network Load Balancers (NLBs)
- Helm chart deployment from a github registry

> Helm chart for librechat is built and pushed in a separate repo [`librechat-eks-deploy`](https://github.com/il-nietos/librechat-eks-deploy)

### Infrastructure Overview

![Infra Diagram Placeholder – Basic AWS Setup](/docs/images/infra-diagram.png)

---

### Kubernetes & Application Components

![K8s Diagram Placeholder – App + EBS + NLB](/docs/images/kubernetes-diagram.png)

---

##  Repository Structure

```bash
librechat-eks-infra/

├── .github/
│   └── workflows/
│       └── terraform.yml
├── docs/
│   └── images/
│       ├── infra-diagram.png
│       └── kubernetes-diagram.png
├── README.md
└── terraform
    ├── envs
    │   ├── dev/
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── terraform.tfvars
    │   │   └── variables.tf
    │   ├── prod/
    │   │   └── ...
    │   └── stage/
    │       └── ...
    ├── global
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── terraform.tfvars
    │   └── variables.tf
    └── modules
        ├── aws-lb-controller
        ├── eks
        └── vpc

```
* **envs/**: Environment-specific Terraform configs (dev, stage, prod).
* **global/**: Shared baseline infrastructure.
* **modules/**: Reusable infra modules:

  * `vpc`: Subnets, route tables, NATs, internet gateway
  * `eks`: Control plane, node group, EBS CSI driver for dynamic provisioning of an EBS volume.
  * `aws-lb-controller`: IAM policies and kubernetes resource aws load balancer controller for NLB management. This Kubernetes resouce watches for `Service` resources of type `LoadBalancer`. When detected, it provisions an AWS Network Load Balancer (NLB) automatically.


---

##  CI/CD Flow

GitHub Actions automates deployment. Based on `.github/workflows/terraform.yaml`, the logic is:

* On pull request to `main`, `develop` or `stage`: `terraform init`, `validate`, and `plan` run in the appropriate `terraform/envs` directory.
* A destroy plan is triggered if:

  * PR title contains the word "destroy"
  * PR has a label `destroy`

* `terraform apply` runs on PR merge to `main` (→ prod), `develop` (→ dev) or `stage`(→ stage), executing the saved plan.
* Terraform states for each environment are stored in a remote backend, in an S3 bucket. This eay each plan/apply reflects current infra state.

---

##  Environments

| Env   | Node Type   | Count | Notes                                                   |
| ----- | ----------- | ----- | ------------------------------------------------------- |
| dev   | `t3.medium` | 1–2   | Lightweight, for iterative development                  |
| stage | `t5.large`  | \~10  | Mirrors production. For testing real workload behaviour.|
| prod  | `t5.large`  | \~10+ | High-availability, customer-facing                      |

Each environment is tagged and runs in its own VPC.

---

##  Security & IAM

* Worker nodes in **private subnets** (egress via NAT Gateway).
* Load Balancers in **public subnets**.
* OIDC authentication between Kubernetes and AWS for secure IAM roles.

---

##  Storage & Persistent Volumes

MongoDB uses a `StatefulSet` with a `PersistentVolumeClaim` (PVC). Here's how the EBS CSI driver enables this:

1. MongoDB pod requests PVC via `gp2` storage class.
2. CSI driver detects the claim.
3. Creates EBS volume dynamically via AWS API.
4. Binds it to the MongoDB pod as persistent storage.


---

##  Networking Flow

**Inbound**:
`User → Route53 → Internet Gateway → NLB → LoadBalancer Service → Pods`

**Outbound**:
`Pod → Node (private subnet) → NAT Gateway → Internet Gateway → Internet`

---

##  Extending This Project

* Plug in your own models via LibreChat plugins
* Swap MongoDB for a managed database (e.g., DocumentDB)
* Add disaster recovery strategies (snapshots, cross-region backup)
* Integrate secrets manager
* Enable monitoring with CloudWatch, Prometheus, or Grafana

---

##  Getting Started

```bash
# Clone the repo
git clone https://github.com/il-nietos/librechat-eks-infra.git

# Set up AWS credentials
export AWS_PROFILE=your-profile

# Initialize and apply for dev
cd terraform/envs/dev
terraform init
terraform apply
```

Ensure Helm chart is pushed to GitHub registry by the `librechat-eks-deploy` pipeline before applying infra.

---

##  References & Inspiration

* [LibreChat GitHub](https://github.com/danny-avila/LibreChat)

