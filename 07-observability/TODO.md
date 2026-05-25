# Observability
Bu mərhələdə klaster daxilində kube-prometheus-stack vasitəsilə monitorinq infrastrukturunun qurulması, ServiceMonitor ilə tətbiqdən metrikaların toplanması və Grafana üzərində əsas performans göstəricilərini (SLO) əks etdirən dashboard-un yaradılması reallaşdırılır.

## Mühit
* Kubernetes cluster
* Helm CLI v4.1.4
- Helm Chart `kube-prometheus-stack`

## Task addımları
1. Tətbiqi klasterə deploy edin və `/metrics` endpoint-inin düzgün metrikalar qaytardığını yoxlayın.
2. `kube-prometheus-stack` Helm chart-ını repozitoriyaya əlavə edin.
3. Monitorinq infrastrukturunu `monitoring` namespace-ində qurun və Helm vasitəsilə `grafana.adminPassword` təyin edin.
4. Grafana UI-a daxil olaraq default gələn Kubernetes dashboard-larının işlədiyini yoxlayın.
5. Tətbiq üçün xüsusi `ServiceMonitor` manifesti yazın və `monitoring` namespace-inə apply edin.
6. Prometheus UI-da `http_requests_total` metrikasının toplandığını və göründüyünü yoxlayın.
7. Grafana-da yeni boş dashboard yaradın.
8. Dashboard daxilində aşağıdakı panelləri və PromQL sorğularını qurun:
    * **Request rate** → `rate(http_requests_total[5m])`
    * **Error rate %** → `rate(http_errors_total[5m]) / rate(http_requests_total[5m]) * 100`
    * **P99 latency** → `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))`
    * **CPU usage** → `container_cpu_usage_seconds_total`
    * **Memory usage** → `container_memory_working_set_bytes`
    * **Availability %** → `(1 - error_rate) * 100` (Rəng qaydası: yaşıl >99.9%, sarı >99%, qırmızı altında)
9. Hazırlanmış dashboard-u JSON formatında export edin və `grafana/dashboards/slo.json` adı ilə repozitoriyaya əlavə edin.
