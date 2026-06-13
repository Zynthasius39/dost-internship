# 1. Introduction

I spent my internship period at "DOST Digital Innovations Center" as a DevOps engineer, getting closely acquainted with the core working principles and processes of this field in a real working environment. Thanks to practical tasks, I gained valuable experience in container technologies, automation mechanisms, server administration, and system monitoring.

This report highlights in detail the key skills I acquired, the technical tasks I performed, the modern tools I applied, and the project phases I executed during the internship. It also reflects my contributions to the resilience of these projects and the impact of the experience gained on my future professional activities as a DevOps specialist.

## 2.2 My Experience

During the internship, I adopted the essential DevOps philosophy and mindset, such as system resilience, prioritizing security, automating repetitive tasks, and declarative environment management. This experience helped me develop not only the ability to manage individual tools but also systematic approach habits for continuous infrastructure development, proactive troubleshooting through monitoring, and secure and agile delivery of applications in a real business environment.

# 3. Developed Skills

## 3.1 PKI and Security

I gained extensive experience in creating Root CA and Intermediate CA using OpenSSL, managing Certificate Signing Requests (CSR), and generating SSL/TLS certificates. I also implemented mechanisms for ensuring certificate trust at the browser level and revoking certificates via CRL (Certificate Revocation List) and OCSP (Online Certificate Status Protocol).

## 3.2 Containerization and Local Infrastructure

Using OCI containerization technologies, I learned how to set up multi-tier local environments based on NGINX, PHP-FPM, and MySQL 8. I acquired practical skills in network isolation (Docker custom bridge networks), data persistence (Volumes), resource limits application, and the secure management of sensitive information (.env/secrets).

## 3.3 Kubernetes Cluster Management and Traffic Routing

I gained experience in setting up multi-node Kubernetes clusters using Kubespray, Calico CNI configuration, securely upgrading clusters from version 1.32.x to 1.34.x, managing external traffic using Gateway API and Ingress, TLS termination, HPA (Horizontal Pod Autoscaler), and Cluster Autoscaler configurations.

## 3.4 CI/CD and GitOps Automation

I built pipelines using GitHub Actions to automatically validate applications (Helm lint), build OCI images and push them to GHCR, and automatically update prod tags in the GitOps repository. I also implemented declarative environment (dev/prod) auto-sync using ArgoCD by adopting the "App-of-Apps" model.

## 3.5 System Monitoring and Alerting Mechanisms

I set up the cluster-internal monitoring infrastructure using kube-prometheus-stack. I organized metric collection from applications using ServiceMonitor, created dashboards on Grafana to track key performance indicators (SLOs) such as P99 latency, error rate, and availability, and configured alert delivery to Discord/Slack channels via Alertmanager.

# 4. Projects and Tasks

## 4.1 Task 1: OpenSSL PKI and SSL Termination with HAProxy

**Objective:** Build a private PKI Infrastructure, ensure certificate management, and apply advanced security rules on HAProxy.

Activities:

- A Root CA and Intermediate CA infrastructure was built using OpenSSL.
- SSL/TLS certificates were signed for HAProxy and users.
- The HAProxy Stats page was enabled and secured with Basic Auth using an encrypted password.
- SSL/crl configuration was set up for client certificate verification, and the revocation of a test certificate was verified in the browser.
- ACL rules were written on HAProxy for different paths and domains.

## 4.2 Task 2: High Availability with Keepalived and HAProxy

**Objective:** Build a highly available load balancer architecture for local web servers by applying a Virtual IP (VIP) via Keepalived.

Activities:

- Two HAProxy servers were installed and configured identically.
- Keepalived service was configured, and a Virtual IP address was assigned.
- Active-passive operation and automatic failover mechanisms were tested on both servers.
- Health checks were configured for the web services.
- Traffic balancing between web servers was enabled via the new VIP address.

## 4.3 Task 3: Multi-tier Application Environment with Docker Compose

**Objective:** Set up an isolated and secure multi-tier container environment based on NGINX reverse proxy, PHP-FPM application tier, and MySQL 8 database.

Activities:

- NGINX, PHP-FPM, and MySQL 8 containers were configured using Docker Compose.
- Custom Docker Bridge networks (frontend and backend) were created to increase inter-application isolation.
- Named volumes were used to ensure MySQL database persistence.
- Resource limits (CPU/RAM) and automatic recovery (Restart Policy) settings were applied.
- For security, database plain-text passwords were moved to the .env file to prevent leakage of plain-text credentials.

## 4.4 Task 4: Setup and Upgrade of Kubernetes Cluster

**Objective:** Set up a production-ready Kubernetes cluster using Kubespray/kubeadm, configure CNI, and upgrade the cluster to a new version without causing downtime.

Activities:

- A Kubernetes cluster consisting of 1 Master and 2 Worker nodes was initialized in version 1.32.x using Kubespray.
- Calico CNI (via Tigera Operator) was installed to ensure secure inter-pod communication.
- The Kubernetes cluster was upgraded step-by-step to version 1.34.x without causing any downtime.
- Node statuses, kube-system pod states, and logs of key components were verified post-upgrade.

## 4.5 Task 5: Kubernetes Gateway API and Traffic Management

**Objective:** Implement Gateway and HTTPRoute resources in the Kubernetes cluster using the more advanced Kubernetes Gateway API infrastructure instead of Ingress resources.

Activities:

- Gateway and HTTPRoute resources were created in the Kubernetes cluster.
- L7 routing and TLS Termination were configured for specific domains and IP addresses.
- Auto-scaling was enabled by installing Horizontal Pod Autoscaler (HPA) and Cluster Autoscaler.
- Complex routing rules based on HTTP headers were written and tested.
- A load test was performed on the application using the `hey` tool, verifying that HPA automatically increased the number of pods.

## 4.6 Task 6: Application Development and Helm Packaging

**Objective:** Write a Go application supporting Prometheus metrics, containerize it in an optimized manner, and package it with Helm Chart.

Activities:

- A minimal web application supporting 3 endpoints (`/`, `/health`, `/metrics`) was developed in Go.
- Custom metrics (`http_requests_total`, `http_request_duration_seconds`) were implemented in the application using the Prometheus client library.
- A Multi-stage Dockerfile was written under 100MB using builder stage and runtime stage.
- A Helm chart structure was created for the gopher application using `helm create`.
- `values-dev.yaml` and `values-prod.yaml` were configured to tune replica count, ingress host, and HPA status for different environments (dev/prod).

## 4.7 Task 7: GitHub Actions CI/CD and GitOps (ArgoCD)

**Objective:** Build a CI/CD pipeline that automatically tests the application, pushes the image to GHCR, and auto-syncs via ArgoCD App-of-Apps model.

Activities:

- A workflow containing `lint`, `test`, and `build-and-push` stages was prepared in `.github/workflows/ci.yaml`.
- After a successful build, the image tag in the `values-prod.yaml` file within the Git repo was automatically updated with the new commit SHA.
- ArgoCD was installed on the Kubernetes cluster, and secure namespaces were allocated for the applications.
- `root-app.yaml`, which supports the App-of-Apps model, was declared, delegating declarative management of all sub-applications (dev/prod) to ArgoCD.
- Automatic synchronization (auto-sync, self-heal, prune) of every change pushed to Git was tested.

## 4.8 Task 8: Observability and Setup of Grafana SLO Dashboards

**Objective:** Set up cluster-level monitoring using Prometheus Operator and kube-prometheus-stack, and visualize application SLOs in Grafana.

Activities:

- The `kube-prometheus-stack` monitoring stack was installed in the `monitoring` namespace of the cluster.
- A custom `ServiceMonitor` manifest was written to collect metrics from the Gopher application.
- It was tested and verified that application metrics were collected correctly on Prometheus.
- A dashboard was set up in Grafana displaying key SLO panels such as Request rate, Error rate %, Latency (P99), CPU/RAM usage, and availability.
- The dashboard was exported in JSON format and written to the `grafana/dashboards/slo.json` file in the Git repository.

## 4.9 Task 9: Alertmanager Alerting Mechanism and Load Testing

**Objective:** Define `PrometheusRule` alerts for exceeding infrastructure and application limits, and verify system resilience under load.

Activities:

- Special `PrometheusRule` alerting rules were declared for critical situations (HighErrorRate, HighLatency, PodCrashLooping).
- The Alertmanager configuration was updated to forward critical alerts to the corresponding channels via Slack or Discord webhooks.
- Real-time load was applied to the application using the `hey` load testing tool, and the dynamic increase in requests was monitored in Grafana.
- Requests were sent to a non-existent endpoint to artificially increase the error rate, and the alert transition to the Firing state was visually verified.

## 4.10 Task 10: Resilience, Rollback, and Final Verification

**Objective:** Perform post-deploy automatic tests using Helm Hooks, test the rollback mechanism in case of failures, and verify the integrity of the project.

Activities:

- A post-install and post-upgrade Helm hook (`templates/post-install-test.yaml`) was created to verify the health of the application.
- A application failure was simulated by intentionally providing an incorrect image tag, and pods entering the ImagePullBackOff state were observed in the cluster.
- The application was immediately rolled back to the previous working stable revision using the ArgoCD UI and CLI.
- The structural integrity of the repository, the absence of plain-text credential leaks, the INSTALL.md documentation, and the unified GitOps pipeline were verified as a final step.

# 5. Conclusion

The knowledge and skills I acquired in the DevOps field at "DOST Digital Innovations Center" during my internship period have been of great importance for my professional development. Working with various tools and technologies, I had the opportunity to participate in real projects, which allowed me to apply my theoretical knowledge in practice. During the internship, I gained valuable experience in areas such as teamwork, automation, monitoring, and infrastructure management. In general, this internship has been a key stage in my career and has built a solid foundation for continuing my work as a DevOps specialist in the future.

I express my deep gratitude to the management of "DOST Digital Innovations Center", my mentor, and the entire team for this opportunity. Their support and professional guidance are very valuable to me.

# 6. References

- [OpenSSL Official Website](https://www.openssl.org)
- [HAProxy Official Website](https://www.haproxy.org)
- [Docker Official Website](https://www.docker.com)
- [Kubernetes Official Documentation](https://kubernetes.io)
- [Helm Official Website](https://helm.sh)
- [ArgoCD Official Documentation](https://argoproj.github.io/cd)
- [Prometheus Official Website](https://prometheus.io)
- [Grafana Official Website](https://grafana.com)
- [DOST Digital Innovations Center](https://dost.gov.az/page/dost-reqemsal-innovasiyalar-merkezi)
- [Antigravity AI](https://deepmind.google)
- [GitHub Repository](https://github.com/Zynthasius39/dost-internship)
