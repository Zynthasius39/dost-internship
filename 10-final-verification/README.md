# Final verification
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

### 4. Kodun repozitoriyaya `git push` olunmasından başlayaraq ArgoCD-nin mühiti tam sinxronizasiya etməsinə qədər olan bütün CI/CD və GitOps axınını bir dəfə canlı olaraq demo/test edin.

### 5. Prometheus monitorinqinin işlədiyini və bütün metrikaların Grafana panellərində data göstərdiyini, dashboard JSON faylının repoda mövcudluğunu son dəfə təsdiqləyin.
