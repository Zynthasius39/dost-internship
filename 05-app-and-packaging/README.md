# App & packaging
Bu mərhələdə minimal tətbiqin (Python/Go/Node.js) yazılması, Prometheus metrikalarının inteqrasiyası, Multi-stage Dockerfile ilə optimallaşdırılmış imicin yığılması və Helm Chart strukturunun dev/prod mühitlərinə uyğun hazırlanması təmin edilir.

## Mühit
* Podman 5.8.2
* Helm CLI v4.1.4
* Go 1.26.3

## Task addımları

### 1. İstənilən dildə (Node.js / Python / Go) minimal tətbiq (app) yazın.

#### 1.1. Go modulu yaradın və dependency-ləri idarə edin
```bash
go mod init gopher
go mod tidy
```

### 2. Tətbiqdə 3 endpoint qurun: `/` (versiya məlumatı JSON formatında), `/health`, `/metrics` (Prometheus client library istifadə etməklə).

#### 2.1. Standart `net/http` paketi ilə serveri qurun

_[main.go](../src/gopher/main.go)_
```diff
+   http.HandleFunc("/", monitor("root", func(w http.ResponseWriter, r *http.Request) {
+     // ...
+     json.NewEncoder(w).Encode(map[string]string{"version": "1.0.0"})
+   }))
+ 
+   http.HandleFunc("/health", monitor("health", func(w http.ResponseWriter, r *http.Request) {
+     // ...
+     json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
+   }))
+ 
+   http.Handle("/metrics", promhttp.Handler())
```

### 3. `/metrics` endpoint-ində bu metrikaları reallaşdırın: `http_requests_total` (counter), `http_request_duration_seconds` (histogram), `http_errors_total` (counter).

#### 3.1. Metrikaları `prometheus` paketi ilə təyin edin

_[main.go](../src/gopher/main.go)_
```diff
+ var (
+   httpRequestsTotal = prometheus.NewCounterVec(...)
+   httpDuration = prometheus.NewHistogramVec(...)
+   httpErrorsTotal = prometheus.NewCounterVec(...)
+ )
```

#### 3.2. Middleware vasitəsilə hər sorğu üçün metrikaların toplanmasını təmin edin

_[main.go](../src/gopher/main.go)_
```diff
+ func monitor(endpoint string, handler http.HandlerFunc) http.HandlerFunc {
+   return func(w http.ResponseWriter, r *http.Request) {
+     start := time.Now()
+     rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}
+     handler(rw, r)
+ 
+     duration := time.Since(start).Seconds()
+     httpDuration.WithLabelValues(endpoint).Observe(duration)
+     
+     statusStr := http.StatusText(rw.statusCode)
+     httpRequestsTotal.WithLabelValues(endpoint, r.Method, statusStr).Inc()
+ 
+     if rw.statusCode >= 400 {
+       httpErrorsTotal.WithLabelValues(endpoint, statusStr).Inc()
+     }
+   }
+ }
```

### 4. Multi-stage Dockerfile yazın (builder + runtime stage).

#### 4.1. `Dockerfile` daxilində iki mərhələ (stage) tətbiq edin

_[Dockerfile](../src/gopher/Dockerfile)_
```diff
+ FROM golang:1.26.3-alpine AS builder
+ 
+ WORKDIR /app
+ 
+ COPY go.mod go.sum ./
+ RUN go mod download
+ 
+ COPY main.go ./
+ RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o gopher main.go
+ 
+ FROM scratch
+ 
+ WORKDIR /
+ 
+ COPY --from=builder /app/gopher /gopher
+ 
+ EXPOSE 8080
+ 
+ ENTRYPOINT ["/gopher"]
```

### 5. `.dockerignore` faylı əlavə edin.
`scratch` image-i istifadə edildiyi və yalnız binary faylı kopyalandığı üçün hazırda bu fayl boşdur.

### 6. Yekun (final) imicin ölçüsünün 100MB-dan az olmasını təmin edin.

#### 6.1. Docker image-ini build edin və ölçüsünə baxın
```sh
REPO=ghcr.io/zynthasius39/gopher
TAG=1.0.0
podman build src/gopher -t "$REPO:$TAG"
podman image ls | grep "$REPO"
```

```console
[1/2] STEP 1/6: FROM golang:1.26.3-alpine AS builder
[1/2] STEP 2/6: WORKDIR /app
--> ec044ae899ac
[1/2] STEP 3/6: COPY go.mod go.sum ./
--> 7af68a958645
[1/2] STEP 4/6: RUN go mod download
--> 5a81b6ff8b7a
[1/2] STEP 5/6: COPY main.go ./
--> dcfb4169ce0c
[1/2] STEP 6/6: RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o gopher main.go
--> 3ec3d532ac46
[2/2] STEP 1/5: FROM scratch
[2/2] STEP 2/5: WORKDIR /
--> 48ed497fa1f2
[2/2] STEP 3/5: COPY --from=builder /app/gopher /gopher
--> 9734e5960a39
[2/2] STEP 4/5: EXPOSE 8080
--> ee8e26e6db42
[2/2] STEP 5/5: ENTRYPOINT ["/gopher"]
[2/2] COMMIT ghcr.io/zynthasius39/gopher:1.0.0
--> 653eb16da726
Successfully tagged ghcr.io/zynthasius39/gopher:1.0.0
653eb16da7260ce56d94a269814b5d9bcee9e49dbcb5785141212818f5910725

ghcr.io/zynthasius39/gopher         1.0.0           653eb16da726  Less than a second ago  10.4 MB
```

### 7. `helm create gopher` əmri ilə chart yaradın və lazımsız default faylları silin.

#### 7.1 Yeni chart yarat və lazımsız faylları silin

```sh
mkdir deploy && cd deploy
helm create helm/gopher
rm -rf helm/gopher/charts helm/gopher/templates/{tests,{httproute,serviceaccount}.yaml,NOTES.txt} helm/gopher/values.yaml
```

#### 7.2. Sıfırdan values faylı işlətdiyimiz üçün default template-ləri düzəldin

_[_helpers.tpl](../deploy/helm/gopher/templates/_helpers.tpl)_
```diff
52,62d51
- 
- {{/*
- Create the name of the service account to use
- */}}
- {{- define "gopher.serviceAccountName" -}}
- {{- if .Values.serviceAccount.create }}
- {{- default (include "gopher.fullname" .) .Values.serviceAccount.name }}
- {{- else }}
- {{- default "default" .Values.serviceAccount.name }}
- {{- end }}
- {{- end }}
```

#### 7.3. (ƏLAVƏ) Klaster spesifik dəyişiklik edin

_[ingress.yaml](../deploy/helm/gopher/templates/ingress.yaml)_
```diff
@@ -5,6 +5,7 @@
   name: {{ include "gopher.fullname" . }}
   labels:
     {{- include "gopher.labels" . | nindent 4 }}
+    service.kubernetes.io/advertise-bgp: "true"
   {{- with .Values.ingress.annotations }}
   annotations:
     {{- toYaml . | nindent 4 }}
```

### 8. `Chart.yaml` faylını müvafiq məlumatlarla doldurun.

_[Chart.yaml](../deploy/helm/gopher/Chart.yaml)_
```diff
3c3,4
- description: A Helm chart for Kubernetes
+ description: Prometheus metrikaları ilə təmin olunmuş minimal Go tətbiqi üçün Helm chart.
+ icon: https://raw.githubusercontent.com/egonelbre/gophers/refs/heads/master/vector/computer/gamer.svg
18c19
- version: 0.1.0
+ version: 1.0.0
24c25
- appVersion: "1.16.0"
+ appVersion: "1.0.0"
```

### 9. `values.yaml` faylında bu dəyərləri təyin edin: `image.repository`, `image.tag`, `replicaCount`, `service`, `ingress`, `hpa`, `resources`, `serviceMonitor`.

_[values.yaml](../deploy/helm/gopher/values.yaml)_
```diff
+ image:
+   repository: ghcr.io/zynthasius39/gopher
+   pullPolicy: IfNotPresent
+   tag: 1.0.0
+ 
+ ingress:
+   enabled: false
+   className: cilium
+   annotations: {}
+   hosts: []
+   tls: []
+ 
+ hpa:
+   enabled: false
+   minReplicas: 1
+   maxReplicas: 100
+   targetCPUUtilizationPercentage: 80
+ 
+ replicaCount: 1
+ 
+ resources: {}
+ 
+ service:
+   type: ClusterIP
+   port: 8080
+ 
+ serviceMonitor:
+   enabled: false
```

### 10. `values-dev.yaml` faylını yazın: 1 replica və dev mühitinə uyğun ingress host təyin edin.

_[values-dev.yaml](../deploy/helm/gopher/values-dev.yaml)_
```diff
0a1,7
+ ingress:
+   enabled: true
+   hosts:
+     - host: dev.gopher.naquadah.alak
+       paths:
+         - path: /
+           pathType: Prefix
```

### 11. `values-prod.yaml` faylını yazın: 3 replica, HPA aktiv, prod ingress host və serviceMonitor aktiv edin.

_[values-prod.yaml](../deploy/helm/gopher/values-prod.yaml)_
```diff
0a1,15
+ ingress:
+   enabled: true
+   hosts:
+     - host: gopher.naquadah.alak
+       paths:
+         - path: /
+           pathType: Prefix
+ 
+ hpa:
+   enabled: true
+ 
+ serviceMonitor:
+   enabled: true
+ 
+ replicaCount: 3
```

### 12. `templates/deployment.yaml` fayllarında image taq-ini dinamik edin.

`helm create` üzərində gələn default _Deployment_ resursunda image tag-i dinamikdir.
_[deployment.yaml](../deploy/helm/gopher/templates/deployment.yaml)_
```yaml
  ...
    {{- toYaml . | nindent 12 }}
  {{- end }}
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  ports:
  ...
```

### 13. `templates/hpa.yaml` və `templates/servicemonitor.yaml` fayllarını conditional edin.

#### 13.1. _ServiceMonitor_ resurs template-i

_[service-monitor.yaml](../deploy/helm/gopher/templates/service-monitor.yaml)_
```diff
@@ -0,0 +1,14 @@
+ {{- if .Values.serviceMonitor.enabled }}
+ apiVersion: monitoring.coreos.com/v1
+ kind: ServiceMonitor
+ metadata:
+   name: {{ include "gopher.fullname" . }}
+   labels:
+     {{- include "gopher.labels" . | nindent 4 }}
+ spec:
+   selector:
+     matchLabels:
+       {{- include "gopher.selectorLabels" . | nindent 6 }}
+   endpoints:
+     - port: {{ .Values.service.portName | default "http" }}
+ {{- end }}
```

#### 13.2. _HorizontalPodAutoscaler_ resurs template-ində **hpa** dəyərindən istifadə edin

_[hpa.yaml](../deploy/helm/gopher/templates/hpa.yaml)_
```diff
13,14c13,14
-   minReplicas: {{ .Values.autoscaling.minReplicas }}
-   maxReplicas: {{ .Values.autoscaling.maxReplicas }}
---
+   minReplicas: {{ .Values.hpa.minReplicas }}
+   maxReplicas: {{ .Values.hpa.maxReplicas }}
16c16
-     {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
---
+     {{- if .Values.hpa.targetCPUUtilizationPercentage }}
22c22
-           averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
---
+           averageUtilization: {{ .Values.hpa.targetCPUUtilizationPercentage }}
24c24
-     {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
---
+     {{- if .Values.hpa.targetMemoryUtilizationPercentage }}
30c30
-           averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
---
+           averageUtilization: {{ .Values.hpa.targetMemoryUtilizationPercentage }}
```

### 14. `helm lint helm/gopher` əmri ilə chart-ı yoxlayın (heç bir xəta olmamalıdır).

```console
==> Linting helm/gopher

1 chart(s) linted, 0 chart(s) failed
```

### 15. `helm template gopher helm/gopher -f helm/gopher/values-dev.yaml` əmrini işlədərək manifest çıxışını yoxlayın.

```yaml
---
# Source: gopher/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: gopher
  labels:
    helm.sh/chart: gopher-1.0.0
    app.kubernetes.io/name: gopher
    app.kubernetes.io/instance: gopher
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: Helm
spec:
  type: ClusterIP
  ports:
    - port: 8080
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: gopher
    app.kubernetes.io/instance: gopher
---
# Source: gopher/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gopher
  labels:
    helm.sh/chart: gopher-1.0.0
    app.kubernetes.io/name: gopher
    app.kubernetes.io/instance: gopher
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: gopher
      app.kubernetes.io/instance: gopher
  template:
    metadata:
      labels:
        helm.sh/chart: gopher-1.0.0
        app.kubernetes.io/name: gopher
        app.kubernetes.io/instance: gopher
        app.kubernetes.io/version: "1.0.0"
        app.kubernetes.io/managed-by: Helm
    spec:
      containers:
        - name: gopher
          image: "ghcr.io/zynthasius39/gopher:1.0.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
---
# Source: gopher/templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gopher
  labels:
    helm.sh/chart: gopher-1.0.0
    app.kubernetes.io/name: gopher
    app.kubernetes.io/instance: gopher
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: Helm
    service.kubernetes.io/advertise-bgp: "true"
spec:
  ingressClassName: cilium
  rules:
    - host: "dev.gopher.naquadah.alak"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: gopher
                port:
                  number: 8080
```

### 16. (ƏLAVƏ) Terraform DNS resursları

```hcl
resource "dns_a_record_set" "dns_naquadah" {
  addresses = ["10.0.20.1"]
  ttl       = 300
  zone      = "naquadah.alak."
}

resource "dns_cname_record" "dns_naquadah_cname_dev_gopher" {
  cname = "naquadah.alak."
  name  = "dev.gopher"
  ttl   = 300
  zone  = "naquadah.alak."
}

resource "dns_cname_record" "dns_naquadah_cname_gopher" {
  cname = "naquadah.alak."
  name  = "gopher"
  ttl   = 300
  zone  = "naquadah.alak."
}
```
