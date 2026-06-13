# Observability

<img src="img/opentelemetry.png" width="400">

Bu mərhələdə klaster daxilində kube-prometheus-stack vasitəsilə monitorinq infrastrukturunun qurulması, ServiceMonitor ilə tətbiqdən metrikaların toplanması və Grafana üzərində əsas performans göstəricilərini (SLO) əks etdirən dashboard-un yaradılması reallaşdırılır.

## Mühit
* Kubernetes cluster
* Helm CLI v4.2.0
- Helm Chart `kube-prometheus-stack`

## Task addımları

### 1. Tətbiqi klasterə deploy edin və `/metrics` endpoint-inin düzgün metrikalar qaytardığını yoxlayın.

```sh
curl http://gopher.naquadah.alak/metrics | head -n 8
```
```console
# HELP go_gc_duration_seconds A summary of the wall-time pause (stop-the-world) duration in garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 0
go_gc_duration_seconds{quantile="0.25"} 0
go_gc_duration_seconds{quantile="0.5"} 0
go_gc_duration_seconds{quantile="0.75"} 0
go_gc_duration_seconds{quantile="1"} 0
go_gc_duration_seconds_sum 0
```

### 2. `kube-prometheus-stack` Helm chart-ını repozitoriyaya əlavə edin.

OCI istifadə etdiyimizə görə `helm repo add` komandasına ehtiyac qalmır. Çünki OCI registry-ləri birbaşa chart-ın URL-si vasitəsilə çağırılır.

### 3. Monitorinq infrastrukturunu `monitoring` namespace-ində qurun və Helm vasitəsilə `grafana.adminPassword` təyin edin.

#### 3.1. Helm chart-ı install edərkən istifadə etmək üçün `values.yaml` yaradın

[values-kube-prometheus-stack.yaml](../deploy/values-kube-prometheus-stack.yaml)
```diff
@@ -0,0 +1,12 @@
+grafana:
+  admin:
+    existingSecret: grafana-admin-secret
+  defaultDashboardsTimezone: Asia/Baku
+  ingress:
+    enabled: true
+    ingressClassName: cilium
+    hosts:
+      - grafana.naquadah.alak
+prometheus:
+  prometheusSpec:
+    serviceMonitorSelectorNilUsesHelmValues: false
```

#### 3.2. `grafana-admin-secret` adlı secret yaradın

```sh
kubectl -n monitoring create secret generic grafana-admin-secret \
  --from-literal=admin-user="admin" \
  --from-literal=admin-password=$(openssl rand -hex 16) \
```

#### 3.3. Helm chart-ını install edin

Ötən tasklarda bu Helm Chart-ını klasterə artıq quraşdırdığım üçün `upgrade` edirəm.
```sh
helm upgrade monitoring oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
  --version 86.2.2 \
  --namespace monitoring \
  --create-namespace \
  --values deploy/values-kube-prometheus-stack.yaml
```

#### 3.4. (ƏLAVƏ) Grafana üçün DNS rekordu yaradın

```hcl
resource "dns_cname_record_set" "dns_naquadah_cname_grafana" {
  cname     = "naquadah.alak."
  name      = "grafana"
  ttl       = 300
  zone      = "naquadah.alak."
}
```

### 4. Grafana UI-a daxil olaraq default gələn Kubernetes dashboard-larının işlədiyini yoxlayın.

#### 4.1. Daxil olmaq üçün `admin-password`-u əldə edin

```sh
kubectl -n monitoring get secrets grafana-admin-secret -o jsonpath="{.data.admin-password}" | base64 -d; echo
```

#### 4.2. Dashboard-ların işlədiyini yoxlayın

![](<img/Screen Shot 2026-06-11 at 13.54.50.png>)
![](<img/Screen Shot 2026-06-11 at 13.55.16.png>)
![](<img/Screen Shot 2026-06-11 at 13.55.23.png>)

### 5. Tətbiq üçün xüsusi _ServiceMonitor_ manifesti yazın və `monitoring` namespace-inə apply edin.

Applikasiya üçün yazdığımız Helm chart-da _ServiceMonitor_ mövcuddur və production mühiti üçün `serviceMonitor.enabled=true` artıq əlavə edilib.

### 6. Prometheus UI-da `http_requests_total` metrikasının toplandığını və göründüyünü yoxlayın.

![](<img/Screen Shot 2026-06-11 at 16.02.09.png>)

### 7. Grafana-da yeni boş dashboard yaradın.

![](<img/Screen Shot 2026-06-11 at 16.07.26.png>)

### 8. Dashboard daxilində aşağıdakı panelləri və PromQL sorğularını qurun:

#### 8.1. **Request rate** → `rate(http_requests_total[5m])`

#### 8.2. **Error rate %** → `rate(http_errors_total[5m]) / rate(http_requests_total[5m]) * 100`

Verilmiş query birdən çox xəta kodu olan zaman işləməyəcək, ona görə ilk öncə onları `sum()` edib bölürük.
```promql
sum(rate(http_errors_total{namespace="gopher-prod"}[5m])) 
/ 
sum(rate(http_requests_total{namespace="gopher-prod"}[5m])) * 100
```

#### 8.3. **P99 latency** → `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))`

#### 8.4. **CPU usage** → `container_cpu_usage_seconds_total`

Query-ni namespace dəyişəni ilə limitləyib, yalnız `container` label-liləri göstəririk.
```promql
container_cpu_usage_seconds_total{namespace="$Namespace", container!=""}
```

#### 8.5. **Memory usage** → `container_memory_working_set_bytes`

### 8.6. **Availability %** → `(1 - error_rate) * 100` (Rəng qaydası: yaşıl >99.9%, sarı >99%, qırmızı altında)

![](<img/Screen Shot 2026-06-11 at 18.29.16.png>)

### 9. Hazırlanmış dashboard-u JSON formatında export edin və `grafana/dashboards/slo.json` adı ilə repozitoriyaya əlavə edin.

[slo.json](../grafana/dashboards/slo.json)
```diff
+{
+  "apiVersion": "dashboard.grafana.app/v2",
+  "kind": "Dashboard",
+  "metadata": {
+    "name": "adg5d8s",
+    "namespace": "default",
+    "uid": "b48f69a8-4045-4b16-a634-da43d8954379",
+    "resourceVersion": "1781188292602984",
+    "generation": 8,
+    "creationTimestamp": "2026-06-11T12:07:21Z",
+    "labels": {
...
```
