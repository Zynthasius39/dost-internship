# End-to-End Kubernetes Application Delivery and Observability

<img src="img/control_plane_component.svg" width="100">

---

## Task Addımları

> [!NOTE]  
> Task addımları arasında müəyyən qədər vaxt keçmiş ola bilər 

> [!NOTE]  
> "resursu" ilə bitən task addımlarında verilən Kubneretes manifest-ləri ```kubectl apply -f``` ilə əlavə olunmuşdur

### 1. Sadə app deploy et (traefik/whoami)

App üçün **whoami** istifadə edirik.
https://github.com/traefik/whoami

### 2. Deployment və Service yaz

#### 2.1. _Deployment_ resursu

``` yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami-deployment
  labels:
    app: whoami
spec:
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
      - name: whoami
        image: traefik/whoami:v1.10
        ports:
        - containerPort: 80
        resources:  # HPA üçün lazım olacaq
          requests:
            cpu: 500m
          limits:
            cpu: 500m
```

#### 2.2. _Service_ resursu

``` yaml
---
apiVersion: v1
kind: Service
metadata:
  name: whoami-svc
spec:
  selector:
    app: whoami
  ports:
    - port: 80
      targetPort: 80
```

#### 2.3. Təsdiq et

``` sh
kubectl get all
```
``` console
NAME                                     READY   STATUS    RESTARTS   AGE
pod/whoami-deployment-56759f85b8-clz97   1/1     Running   0          15s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP   3d16h
service/whoami-svc   ClusterIP   10.43.18.134   <none>        80/TCP    15s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/whoami-deployment   1/1     1            1           16s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/whoami-deployment-56759f85b8   1         1         1       16s
```

### 3. Gateway API qur

_GatewayClass_ olaraq Cilium istifadə edirik.

#### 3.1 _Gateway_ resursu

``` yaml
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: whoami-gateway
spec:
  gatewayClassName: cilium
  infrastructure:
    annotations:
      io.cilium/lb-ipam-ips: 10.0.20.1
    labels:
      advertiseBGP: "true"
      advertiseL2: "true"
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: Same
```

#### 3.2. _HTTPRoute_ resursu

``` yaml
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: whoami-route
spec:
  parentRefs:
    - name: whoami-gateway
  hostnames:
    - "app.dost.naquadah.alak"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: whoami-svc
          port: 80
```

#### 3.3. Təsdiq et

``` sh
kubectl get gateway
kubectl get httproute
```
``` console
NAME             CLASS    ADDRESS     PROGRAMMED   AGE
whoami-gateway   cilium   10.0.20.1   True         37s

NAME           HOSTNAMES                    AGE
whoami-route   ["app.dost.naquadah.alak"]   37s
```

### 4. Domain ilə expose et (e.g., /etc/hosts ilə)

[Addım 3.1](#31-gateway-resursu)-də Gateway API-ın yaradacağı köməkçi servisinə ```io.cilium/lb-ipam-ips: 10.0.20.1``` annotation-unu verdiyimiz üçün artıq Cilium onu ExternalIP ilə təmin edib və ```advertiseBGP: "true"``` label-inə görə də BGP vasitəsilə IP-sini ruterlə paylaşıb. Bizə indi servisi "Domain ilə expose et"-mək üçün yalnız DNS record-u yaratmaq lazımdır.

#### 4.1. _DNS A record_ resursu

``` hcl
resource "dns_a_record_set" "this" {
  zone      = "naquadah.alak."
  name      = "app.dost"
  addresses = ["10.0.20.1"]
  ttl       = 3600
}
```

#### 4.2. Təsdiq et

``` sh
curl http://app.dost.naquadah.alak
```
``` console
Hostname: whoami-deployment-56759f85b8-clz97
IP: 127.0.0.1
IP: ::1
IP: 10.42.1.180
IP: fe80::8a6:caff:fe1e:21b4
RemoteAddr: 10.42.0.136:33463
GET / HTTP/1.1
Host: app.dost.naquadah.alak
User-Agent: curl/8.20.0
Accept: */*
X-Envoy-Internal: true
X-Forwarded-For: 10.0.10.25
X-Forwarded-Proto: http
X-Request-Id: 1d88b88e-0dc4-4c58-aa37-92f13364eea4

```

### 5. 2 replica ver

#### 5.1. Deployment-i scale et

``` sh
kubectl scale deployment whoami-deployment --replicas 2
kubectl get all
```
``` console
NAME                                     READY   STATUS    RESTARTS   AGE
pod/whoami-deployment-56759f85b8-clz97   1/1     Running   0          4m59s
pod/whoami-deployment-56759f85b8-wz97m   1/1     Running   0          11s

NAME                                    TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/cilium-gateway-whoami-gateway   LoadBalancer   10.43.92.10    10.0.20.1     80:31896/TCP   3m54s
service/kubernetes                      ClusterIP      10.43.0.1      <none>        443/TCP        3d16h
service/whoami-svc                      ClusterIP      10.43.18.134   <none>        80/TCP         4m59s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/whoami-deployment   2/2     2            2           4m59s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/whoami-deployment-56759f85b8   2         2         2       4m59s
```

### 6. Rolling update test et

#### 6.1. _Deployment_-dakı image versiyasını qaldır

``` sh
kubectl set image deployments/whoami-deployment whoami=docker.io/traefik/whoami:v1.11
```

#### 6.2. Təsdiq et

``` sh
kubectl get all
kubectl rollout status deployment whoami-deployment
```
``` console
NAME                                     READY   STATUS    RESTARTS   AGE
pod/whoami-deployment-7856f87c68-d52f5   1/1     Running   0          2m37s
pod/whoami-deployment-7856f87c68-nnfg8   1/1     Running   0          2m35s

NAME                                    TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/cilium-gateway-whoami-gateway   LoadBalancer   10.43.92.10    10.0.20.1     80:31896/TCP   9m8s
service/kubernetes                      ClusterIP      10.43.0.1      <none>        443/TCP        3d16h
service/whoami-svc                      ClusterIP      10.43.18.134   <none>        80/TCP         10m

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/whoami-deployment   2/2     2            2           10m

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/whoami-deployment-56759f85b8   0         0         0       10m
replicaset.apps/whoami-deployment-7856f87c68   2         2         2       2m37s

deployment "whoami-deployment" successfully rolled out
```

### 7. Prometheus və Grafana qur (Helm ilə olar)

Bu task üçün **prometheus-community/kube-prometheus-stack** helm chart-ından istifadə edirik.

#### 7.1. Helm chart-ı quraşdır

``` sh
helm install monitoring oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
  --version 85.0.1 \
  --namespace monitoring \
  --create-namespace
```

#### 7.2. Təsdiq et

``` sh
kubectl -n monitoring get all
```
``` console
NAME                                                         READY   STATUS    RESTARTS      AGE
pod/alertmanager-monitoring-kube-prometheus-alertmanager-0   2/2     Running   0             45m
pod/monitoring-grafana-f797f8ffc-48rcd                       3/3     Running   1 (42m ago)   46m
pod/monitoring-kube-prometheus-operator-84c6779586-mbtff     1/1     Running   0             46m
pod/monitoring-kube-state-metrics-5957bd45bc-qfwrt           1/1     Running   0             46m
pod/monitoring-prometheus-node-exporter-48gtl                1/1     Running   0             46m
pod/monitoring-prometheus-node-exporter-hfh6j                1/1     Running   0             46m
pod/monitoring-prometheus-node-exporter-qmjxx                1/1     Running   0             46m
pod/prometheus-monitoring-kube-prometheus-prometheus-0       2/2     Running   0             45m

NAME                                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/alertmanager-operated                     ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   45m
service/monitoring-grafana                        ClusterIP   10.43.36.151    <none>        80/TCP                       46m
service/monitoring-kube-prometheus-alertmanager   ClusterIP   10.43.137.235   <none>        9093/TCP,8080/TCP            46m
service/monitoring-kube-prometheus-operator       ClusterIP   10.43.129.121   <none>        443/TCP                      46m
service/monitoring-kube-prometheus-prometheus     ClusterIP   10.43.3.180     <none>        9090/TCP,8080/TCP            46m
service/monitoring-kube-state-metrics             ClusterIP   10.43.181.168   <none>        8080/TCP                     46m
service/monitoring-prometheus-node-exporter       ClusterIP   10.43.158.239   <none>        9100/TCP                     46m
service/prometheus-operated                       ClusterIP   None            <none>        9090/TCP                     45m

NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/monitoring-prometheus-node-exporter   3         3         3       3            3           kubernetes.io/os=linux   46m

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/monitoring-grafana                    1/1     1            1           46m
deployment.apps/monitoring-kube-prometheus-operator   1/1     1            1           46m
deployment.apps/monitoring-kube-state-metrics         1/1     1            1           46m

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/monitoring-grafana-f797f8ffc                     1         1         1       46m
replicaset.apps/monitoring-kube-prometheus-operator-84c6779586   1         1         1       46m
replicaset.apps/monitoring-kube-state-metrics-5957bd45bc         1         1         1       46m

NAME                                                                    READY   AGE
statefulset.apps/alertmanager-monitoring-kube-prometheus-alertmanager   1/1     45m
statefulset.apps/prometheus-monitoring-kube-prometheus-prometheus       1/1     45m
```

### 8. Node metrics izlənilsin

Bu və növbəti task üçün chart üzərində hazır konfiqurasiya olunmuş Grafana dashboard-lar tapmaq mümkündür.

![](<img/Screenshot 2026-05-12 at 21-15-34 Node Exporter _ Nodes - Dashboards - Grafana.png>)

### 9. Pod metrics izlənilsin

![](<img/Screenshot 2026-05-12 at 21-13-36 Kubernetes _ Compute Resources _ Pod - Dashboards - Grafana.png>)

### 10. Alert rule yaz (CPU > 80%)

Query olaraq chart-ın üzərində gələn default rule-u dəyişib istifadə edirik

#### 10.1. _PrometheusRule_ resursu

``` yaml
---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  creationTimestamp: null
  labels:
    release: monitoring
  name: high-cpu-alert-rule
spec:
  groups:
    - name: node-exporter
      rules:
        - alert: NodeCPUHighUsage80
          expr: sum without (mode) (avg without (cpu) (rate(node_cpu_seconds_total{job="node-exporter",mode!~"idle|iowait"}[2m]))) * 100 > 80
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High CPU usage on node {{ $labels.instance }}"
            description: "Node {{ $labels.instance }} has reported CPU utilization over 80% (current value: {{ $value | printf \"%.2f\" }}%)."
```

#### 10.2. Təsdiq et

![](<img/Screenshot 2026-05-13 at 00-37-01 Alert rules - Alerting - Grafana.png>)
![](<img/Screenshot 2026-05-13 at 00-45-28 NodeCPUHighUsage80.png>)

### 11. HPA qur (min: 1, max: 5)

_HorizontalPodAutoscaler_ resursu

``` yaml
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: whoami-hpa
spec:
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
      type: Resource
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: whoami-deployment
```

### 12. Application load test et (e.g., hey, ab, simple loop)

#### 12.1. _Deployment_-in testdən əvvəlki vəziyyətinə bax

``` sh
kubectl top pods -l app=whoami
kubectl get hpa whoami-hpa
```
``` console
NAME                                CPU(cores)   MEMORY(bytes)   
whoami-deployment-b86b4f5b8-hswck   1m           7Mi             

NAME         REFERENCE                      TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
whoami-hpa   Deployment/whoami-deployment   cpu: 0%/60%   1         5         1          39h
```

#### 12.2. Load testini başlat

``` sh
hey -n 100000 -c 50 -z 120s "http://app.dost.naquadah.alak/data?size=32&unit=KB"
```

#### 12.3. Test ərzində baş verən horizontal autoscaling-i müşahidə et

``` sh
kubectl top pods -l app=whoami
kubectl get hpa whoami-hpa
```
``` console
NAME                                CPU(cores)   MEMORY(bytes)   
whoami-deployment-b86b4f5b8-hswck   450m         9Mi             
NAME         REFERENCE                      TARGETS        MINPODS   MAXPODS   REPLICAS   AGE

whoami-hpa   Deployment/whoami-deployment   cpu: 90%/60%   1         5         1          39h
```

10 saniyə sonra ...

``` console
NAME                                CPU(cores)   MEMORY(bytes)   
whoami-deployment-b86b4f5b8-hswck   284m         9Mi             
whoami-deployment-b86b4f5b8-ktjcj   270m         8Mi             

NAME         REFERENCE                      TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
whoami-hpa   Deployment/whoami-deployment   cpu: 56%/60%   1         5         2          39h
```

#### 12.4. Test bitdikdən sonra hey və Grafana-da nəticəyə bax

``` console
Summary:
  Total:        120.0128 secs
  Slowest:      0.1625 secs
  Fastest:      0.0018 secs
  Average:      0.0239 secs
  Requests/sec: 2094.8593
  

Response time histogram:
  0.002 [1]     |
  0.018 [87820] |■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.034 [124274]        |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.050 [30445] |■■■■■■■■■■
  0.066 [6321]  |■■
  0.082 [1867]  |■
  0.098 [418]   |
  0.114 [116]   |
  0.130 [73]    |
  0.146 [42]    |
  0.163 [33]    |


Latency distribution:
  10%% in 0.0117 secs
  25%% in 0.0156 secs
  50%% in 0.0215 secs
  75%% in 0.0293 secs
  90%% in 0.0382 secs
  95%% in 0.0458 secs
  99%% in 0.0662 secs

Details (average, fastest, slowest):
  DNS+dialup:   0.0000 secs, 0.0000 secs, 0.0033 secs
  DNS-lookup:   0.0000 secs, 0.0000 secs, 0.0017 secs
  req write:    0.0000 secs, 0.0000 secs, 0.0015 secs
  resp wait:    0.0238 secs, 0.0017 secs, 0.1624 secs
  resp read:    0.0001 secs, 0.0000 secs, 0.1045 secs

Status code distribution:
  [200] 251410 responses
```

![](<img/Screenshot 2026-05-14 at 16-57-24 Kubernetes _ Compute Resources _ Workload - Dashboards - Grafana.png>)
![](<img/Screenshot 2026-05-14 at 18-19-34 Discord.png>)
