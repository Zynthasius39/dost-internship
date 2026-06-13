# Agent Guidelines & Repository Map

Welcome, agent! This document provides context on the repository structure, tools, environments, and general guidelines for working in this workspace.

## Repository Overview

This repository contains internship tasks and labs completed at DOST. The tasks are divided into two categories:
1. **Standalone Labs (`01-04`)**: Individual concepts and standalone infrastructure components.
2. **Project Pipeline (`05-10`)**: A continuous pipeline where each task builds upon the previous one.

### Directory Map

* [`01-openssl-pki/`](file:///home/zynf/Projects/dost-internship/01-openssl-pki): PKI Setup with OpenSSL (Root CA, Intermediate CA, TLS x509 certificates). Contains browser-testing and VM provision scripts.
* [`02-docker-compose/`](file:///home/zynf/Projects/dost-internship/02-docker-compose): Standalone Docker Compose environment deploying NGINX, PHP-FPM, and MySQL with custom bridge networks.
* [`03-kubernetes-cluster/`](file:///home/zynf/Projects/dost-internship/03-kubernetes-cluster): Kubernetes cluster installation using `kubeadm`. Includes CNI (Calico) configuration and `etcd` backup procedures.
* [`04-k8s-gateway-monitoring-scaling/`](file:///home/zynf/Projects/dost-internship/04-k8s-gateway-monitoring-scaling): Advanced routing with Kubernetes Gateway API, HPA, Cluster Autoscaler, and Canary deployments.
* [`05-app-and-packaging/`](file:///home/zynf/Projects/dost-internship/05-app-and-packaging): Core application development (Go/Python/Node.js) with Prometheus metrics endpoint and Multi-stage Docker optimization. Includes Helm Chart layouts (`values-dev.yaml`, `values-prod.yaml`).
* [`06-cicd-and-gitops/`](file:///home/zynf/Projects/dost-internship/06-cicd-and-gitops): GitHub Actions workflow targeting GHCR for images, and ArgoCD application-of-applications deployment pipeline.
* [`07-observability/`](file:///home/zynf/Projects/dost-internship/07-observability): Monitoring setup utilizing `kube-prometheus-stack` alongside ServiceMonitor and Grafana SLO dashboards.
* [`08-alerting-and-load-testing/`](file:///home/zynf/Projects/dost-internship/08-alerting-and-load-testing): Alarm triggers using `PrometheusRule`, Alertmanager routing to Discord/Slack, and load testing via `hey`/`ab`.
* [`09-resilience-and-validation/`](file:///home/zynf/Projects/dost-internship/09-resilience-and-validation): Helm hooks validation, fallback testing, and ArgoCD synchronization validation.
* [`10-final-verification/`](file:///home/zynf/Projects/dost-internship/10-final-verification): Verification scripts and structural checking parameters.

## Tech Stack & Environment Reference

* **Containerization**: Podman / Docker
* **Orchestration**: Kubernetes, Helm, ArgoCD, Gateway API
* **CI/CD**: GitHub Actions
* **Observability**: Prometheus, Grafana, Alertmanager
* **Programming**: Go (and potentially Python / Node.js)

## Guidelines for Future Agents

1. **Language & Tone**: Maintain the exact Azerbaijani/English hybrid professional tone established in the `README.md` and commit logs.
2. **References**: Always update [`README.md`](file:///home/zynf/Projects/dost-internship/README.md) and [`JOURNAL.md`](file:///home/zynf/Projects/dost-internship/JOURNAL.md) if adding new tasks.
3. **Paths**: Use standard relative paths for files and folders.
