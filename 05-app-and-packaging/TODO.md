# App & packaging
Bu mərhələdə minimal tətbiqin (Python/Go/Node.js) yazılması, Prometheus metrikalarının inteqrasiyası, Multi-stage Dockerfile ilə optimallaşdırılmış imicin yığılması və Helm Chart strukturunun dev/prod mühitlərinə uyğun hazırlanması təmin edilir.

## Mühit
* Podman 5.8.2
* Helm CLI v4.1.4
* Go 1.26.3

## Task addımları
1. İstənilən dildə (Node.js / Python / Go) minimal tətbiq (app) yazın.
2. Tətbiqdə 3 endpoint qurun: `/` (versiya məlumatı JSON formatında), `/health`, `/metrics` (Prometheus client library istifadə etməklə).
3. `/metrics` endpoint-ində bu metrikaları reallaşdırın: `http_requests_total` (counter), `http_request_duration_seconds` (histogram), `http_errors_total` (counter).
4. Multi-stage Dockerfile yazın (builder + runtime stage).
5. `.dockerignore` faylı əlavə edin.
6. Yekun (final) imicin ölçüsünün 100MB-dan az olmasını təmin edin.
7. `helm create myapp` əmri ilə chart yaradın və lazımsız default faylları silin.
8. `Chart.yaml` faylını müvafiq məlumatlarla doldurun.
9. `values.yaml` faylında bu dəyərləri təyin edin: `image.repository`, `image.tag`, `replicaCount`, `service`, `ingress`, `hpa`, `resources`, `serviceMonitor`.
10. `values-dev.yaml` faylını yazın: 1 replica və dev mühitinə uyğun ingress host təyin edin.
11. `values-prod.yaml` faylını yazın: 3 replica, HPA aktiv, prod ingress host və serviceMonitor aktiv edin.
12. `templates/deployment.yaml` fayllarında imic teqini (image tag) `{{ .Values.image.tag }}` formatında dinamik edin.
13. `templates/hpa.yaml` və `templates/servicemonitor.yaml` fayllarını `{{ if .Values.hpa.enabled }}` şərti ilə conditional (şərtə bağlı) edin.
14. `helm lint helm/myapp` əmri ilə chart-ı yoxlayın (heç bir xəta olmamalıdır).
15. `helm template myapp helm/myapp -f helm/myapp/values-dev.yaml` əmrini işlədərək manifest çıxışını yoxlayın.
