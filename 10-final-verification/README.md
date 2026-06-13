# Final verification

<img src="img/gitops.png" width="400">

Layihənin struktur bütövlüyünün, təhlükəsizlik qaydalarının və sənədləşmənin son yoxlama meyarları əsasında təsdiqlənməsi.

## Mühit
* Git Repository
* Documentation

## Task addımları
### 1. Repozitoriyanın strukturunun tam olaraq bu şəkildə olduğunu yoxlayın:

```
dost-internship.git        dost-internship.git
├── app/                   ├── src/gopher/
├── helm/gopher/     -->   ├── deploy/helm/gopher/
├── argocd/                ├── deploy/
└── .github/workflows/     └── .github/workflows/
```

### 2. `README.md` faylında layihənin sıfırdan qurulması və ayağa qaldırılması addımlarının tam, aydın şəkildə yazıldığından əmin olun.

Layihənin sıfırdan qurulması və ayağa qaldırılması addımları tam və ətraflı şəkildə [INSTALL.md](../INSTALL.md) faylında sənədləşdirilmişdir. Sənəd aşağıdakı mərhələləri əhatə edir:

1. **İnfrastrukturun Qurulması (VM & Kubernetes):** KVM üzərində Ansible ilə VM-lərin inisializasiya edilməsi, Kubespray asılılıqlarının konfiqurasiyası, klasterin ayağa qaldırılması və Calico CNI quraşdırılması.
2. **Tətbiqin Paketlənməsi (App & Packaging):** Go tətbiqinin multi-stage `Dockerfile` ilə build edilməsi və lokal Helm chart yoxlanışları.
3. **CI/CD və GitOps Axınının Qurulması:** GitHub Actions pipeline tənzimləmələri, ArgoCD quraşdırılması və App-of-Apps modeli ilə sinxronizasiya.
4. **Monitorinq və Observability:** `kube-prometheus-stack` Helm chart-ı və Grafana SLO dashboard-unun import edilməsi.
5. **Alerting və Yük Testi (Load Testing):** PrometheusRule alertləri, Alertmanager Discord webhook inteqrasiyası və `hey` vasitəsilə yük testləri.
6. **Dayanıqlılıq və Yoxlama (Resilience & Validation):** Helm hook ilə post-install testləri, rollback ssenarisi və sağlamlıq endpoint yoxlamaları.

### 3. Repozitoriyada heç bir gizli məlumatın (secret, token, şifrə) plain-text (açıq mətn) formasında qalmadığını yoxlayın.

```sh
gitleaks detect --source . --verbose --report-path=secrets-report.json --platform github
```
```console

    ○
    │╲
    │ ○
    ○ ░
    ░    gitleaks

9:46PM INF 48 commits scanned.
9:46PM INF scanned ~613730 bytes (613.73 KB) in 122ms
9:46PM INF no leaks found
```

### 4. Kodun repozitoriyaya `git push` olunmasından başlayaraq ArgoCD-nin mühiti tam sinxronizasiya etməsinə qədər olan bütün CI/CD və GitOps axınını bir dəfə canlı olaraq demo/test edin.

#### 4.1. Yenilikdən əvvəl applikasiyanın versiyasına baxın

```sh
curl http://gopher.naquadah.alak
```
```json
{"version":"1.0.0"}
```

#### 4.2. Gopher applikasiyasının versiyasını kodda qaldırın

[main.go](src/gopher/main.go)
```diff
@@ -94,7 +94,7 @@ func main() {
-    json.NewEncoder(w).Encode(map[string]string{"version": "1.0.0"})
+    json.NewEncoder(w).Encode(map[string]string{"version": "1.0.2"})
```

#### 4.3. Dəyişikliyi commit edib push edin

Commit-də `skip ca` ifadəsindən etmirik ki, CI pipeline-ı işə düşsün.

```sh
git add src/gopher
git commit -m "chore: bump gopher app version to 1.0.2"
git push origin main
```

#### 4.4. Actions-un icrasını müşahidə edin

![](<img/Screen Shot 2026-06-12 at 21.56.12.png>)
![](<img/Screen Shot 2026-06-12 at 21.56.14.png>)
![](<img/Screen Shot 2026-06-12 at 21.56.31.png>)

#### 4.5. ArgoCD-də sync prosesini müşahidə edin

![](<img/Screen Shot 2026-06-12 at 21.57.24.png>)

#### 4.6. Yenilikdən sonra applikasiyanın versiyasına baxın

```sh
curl http://gopher.naquadah.alak
```
```json
{"version":"1.0.2"}
```

### 5. Prometheus monitorinqinin işlədiyini və bütün metrikaların Grafana panellərində data göstərdiyini, dashboard JSON faylının repoda mövcudluğunu son dəfə təsdiqləyin.

#### 5.1. Grafana dashboard-ı müşahidə edin

- Yenilik sonrasından dərhal olduğu üçün **Memory Usage** hissəsində kəsinti müşahidə olunur
- Yenilikdən sonra `hey` vasitəsilə 98% hədəfli load **Request Rate**, **Error Rate** və **Availability** panellərində əks olunur

![](<img/Screen Shot 2026-06-12 at 22.09.27.png>)
#### 5.2. Bu dashobard-ın export faylının mövcudluğunu yoxlayın

```sh
ls grafana/dashboards/slo.json
```
```console
grafana/dashboards/slo.json
```
