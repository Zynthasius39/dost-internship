# Alerting & Load testing

<img src="img/alertmanager.png" width="400">

Bu mərhələdə infrastruktur və tətbiq xətalarına qarşı Alertmanager xəbərdarlıq mexanizminin (PrometheusRule) qurulması, Slack/Discord inteqrasiyası və yük testləri (`hey` / `ab`) vasitəsilə sistemin bu xəbərdarlıqlara reaksiyasının yoxlanılması həyata keçirilir.

## Mühit
* Prometheus Alertmanager
* Slack Webhook
* hey v0.1.5

## Task addımları
### 1. _PrometheusRule_ manifesti yaradın və daxilində bu alert-ləri təyin edin

#### 1.1. **HighErrorRate**: error rate 5%-dən artıq olarsa və 2 dəqiqə davam edərsə

[prometheus-rule.yaml](../deploy/helm/gopher/templates/prometheus-rule.yaml)
```diff
@@ -0,0 +1,21 @@
+{{- if .Values.prometheusRule.enabled }}
+apiVersion: monitoring.coreos.com/v1
+kind: PrometheusRule
+metadata:
+  name: {{ include "gopher.fullname" . }}
+  labels:
+    {{- include "gopher.labels" . | nindent 4 }}
+spec:
+  groups:
+    - name: gopher-alert-rules
+      rules:
+        - alert: HighErrorRate
+          expr: (sum(rate(http_errors_total{namespace="{{ .Release.Namespace }}"}[2m])) by (pod) / sum(rate(http_requests_total{namespace="{{ .Release.Namespace }}"}[2m])) by (pod)) * 100 > 5
+          for: 2m
+          labels:
+            severity: critical
+            namespace: {{ .Release.Namespace }}
+          annotations:
+            summary: "High HTTP error rate on pod {{ "{{" }} $labels.pod {{ "}}" }}"
+            description: "The HTTP error rate for pod {{ "{{" }} $labels.pod {{ "}}" }} in namespace {{ "{{" }} $labels.namespace {{ "}}" }} is {{ "{{" }} $value | printf \"%.2f\" {{ "}}" }}%, which is above the 5% threshold."
+{{- end }}
```

#### 1.2. **HighLatency**: P99 latency 500ms-dən artıq olarsa və 5 dəqiqə davam edərsə

```diff
@@ -19,6 +19,16 @@ spec:
+        - alert: HighLatency
+          expr: histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{namespace="{{ .Release.Namespace }}"}[5m])) by (le, pod)) > 0.5
+          for: 5m
+          labels:
+            severity: warning
+            namespace: {{ .Release.Namespace }}
+          annotations:
+            summary: "High P99 latency on pod {{ "{{" }} $labels.pod {{ "}}" }}"
+            description: "The P99 HTTP latency for pod {{ "{{" }} $labels.pod {{ "}}" }} in namespace {{ "{{" }} $labels.namespace {{ "}}" }} is {{ "{{" }} $value | printf \"%.3f\" {{ "}}" }}s, which is above the 500ms threshold."
```

#### 1.3. **PodCrashLooping**: pod restart rate sıfırdan böyük olarsa və 5 dəqiqə davam edərsə

```diff
@@ -28,4 +28,14 @@ spec:
+
+        - alert: PodCrashLooping
+          expr: sum(rate(kube_pod_container_status_restarts_total{namespace="{{ .Release.Namespace }}"}[5m])) by (pod) > 0
+          for: 5m
+          labels:
+            severity: warning
+            namespace: {{ .Release.Namespace }}
+          annotations:
+            summary: "Pod {{ "{{" }} $labels.pod {{ "}}" }} is crash looping"
+            description: "The pod {{ "{{" }} $labels.pod {{ "}}" }} in namespace {{ "{{" }} $labels.namespace {{ "}}" }} has container restarts rate above 0/sec for the last 5 minutes."
```

### 2. AlertManager konfiqurasiyasını yeniləyərək Slack/Discord webhook-unu əlavə edin.

#### 2.1. Discord webhook-unu saxlamaq üçün secret yaradın

```sh
kubectl -n gopher-prod create secret generic discord-webhook-secret --from-literal url=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN
```

#### 2.2. `values.yaml` və `values-prod.yaml` fayllarına `alertmanagerConfig` dəyişənini əlavə edin

```diff
diff --git a/deploy/helm/gopher/values-prod.yaml b/deploy/helm/gopher/values-prod.yaml
@@ -11,6 +11,8 @@ serviceMonitor:
+alertmanagerConfig:
+  enabled: true
diff --git a/deploy/helm/gopher/values.yaml b/deploy/helm/gopher/values.yaml
@@ -30,3 +30,6 @@ serviceMonitor:
+
+alertmanagerConfig:
+  enabled: false
```

#### 2.3. _AlertmanagerConfig_ template-i

[discord-alertmanagerconfig.yaml](../deploy/helm/gopher/templates/discord-alertmanagerconfig.yaml)
```yaml
{{- if .Values.alertmanagerConfig.enabled }}
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: {{ include "gopher.fullname" . }}
  labels:
    {{- include "gopher.labels" . | nindent 4 }}
spec:
  route:
    groupBy: ['alertname', 'namespace']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 12h
    receiver: 'discord-notifications'
  receivers:
    - name: 'discord-notifications'
      discordConfigs:
        - apiURL:
            name: discord-webhook-secret
            key: url
          sendResolved: true
{{- end }}
```

### 3. Sistemə test alert-i göndərin və onun müvafiq xəbərdarlıq kanalında (Slack/Discord) göründüyünü yoxlayın.

![](<img/20260611_224950.png>)

### 4. Local mühitinizdə və ya test serverində `hey` və ya `ab` alətini quraşdırın.

[04/12.2-load-testini-başlat](../04-k8s-gateway-monitoring-scaling/README.md#122-load-testini-başlat)
`hey` aləti artıq yüklüdür.

### 5. Normal yük üçün `hey -z 30s -c 50 http://<app-url>/` əmrini işlədin.

```sh
hey -z 30s -c 50 http://gopher.naquadah.alak/
```
```console
Summary:
  Total:        30.0055 secs
  Slowest:      0.0831 secs
  Fastest:      0.0033 secs
  Average:      0.0133 secs
  Requests/sec: 3746.1080

  Total data:   2248080 bytes
  Size/request: 20 bytes

Response time histogram:
  0.003 [1]     |
  0.011 [55647] |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.019 [41376] |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.027 [9066]  |■■■■■■■
  0.035 [3559]  |■■■
  0.043 [1667]  |■
  0.051 [601]   |
  0.059 [211]   |
  0.067 [138]   |
  0.075 [81]    |
  0.083 [57]    |


Latency distribution:
  10%% in 0.0070 secs
  25%% in 0.0088 secs
  50%% in 0.0113 secs
  75%% in 0.0151 secs
  90%% in 0.0219 secs
  95%% in 0.0283 secs
  99%% in 0.0430 secs

Details (average, fastest, slowest):
  DNS+dialup:   0.0000 secs, 0.0000 secs, 0.0033 secs
  DNS-lookup:   0.0000 secs, 0.0000 secs, 0.0021 secs
  req write:    0.0000 secs, 0.0000 secs, 0.0005 secs
  resp wait:    0.0133 secs, 0.0033 secs, 0.0830 secs
  resp read:    0.0000 secs, 0.0000 secs, 0.0006 secs

Status code distribution: 
  [200] 112404 responses
```

### 6. Yük testi zamanı eyni anda Grafana panelində request rate-in real-time artdığını müşahidə edin.

![](<img/Screen Shot 2026-06-11 at 22.25.10.png>)

### 7. Xəta dərəcəsini artırmaq üçün mövcud olmayan endpointə yük vurun: `hey -z 30s -c 100 http://<app-url>/nonexistent`.

```sh
hey -z 30s -c 100 http://gopher.naquadah.alak/bura-haradi
```
```console
Summary:
  Total:        30.0514 secs
  Slowest:      0.1335 secs
  Fastest:      0.0067 secs
  Average:      0.0268 secs
  Requests/sec: 3725.4873

  Total data:   2463032 bytes
  Size/request: 22 bytes

Response time histogram:
  0.007 [1]     |
  0.019 [34061] |■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.032 [52090] |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.045 [15685] |■■■■■■■■■■■■
  0.057 [5017]  |■■■■
  0.070 [2996]  |■■
  0.083 [1207]  |■
  0.095 [623]   |
  0.108 [206]   |
  0.121 [62]    |
  0.134 [8]     |


Latency distribution:
  10%% in 0.0142 secs
  25%% in 0.0182 secs
  50%% in 0.0234 secs
  75%% in 0.0311 secs
  90%% in 0.0429 secs
  95%% in 0.0561 secs
  99%% in 0.0794 secs

Details (average, fastest, slowest):
  DNS+dialup:   0.0000 secs, 0.0000 secs, 0.0053 secs
  DNS-lookup:   0.0000 secs, 0.0000 secs, 0.0032 secs
  req write:    0.0000 secs, 0.0000 secs, 0.0010 secs
  resp wait:    0.0268 secs, 0.0066 secs, 0.1334 secs
  resp read:    0.0000 secs, 0.0000 secs, 0.0011 secs

Status code distribution: 
  [404] 111956 responses
```

### 8. Prometheus və Alertmanager interfeysində alert-in statusunun `Pending` rejimindən `Firing` rejiminə keçdiyini vizual olaraq göstərin.

![](<img/20260611_225732.png>)
![](<img/20260611_225736.png>)

### 9. Yük testini dayandırın və metrikaların yenidən normal/stabil vəziyyətə qayıtdığını yoxlayın.

![](<img/Screen Shot 2026-06-11 at 22.58.13.png>)
![](<img/Screen Shot 2026-06-11 at 23.05.47.png>)
![](<img/20260611_235840.png>)
