# İş günləri (aya görə)

| Ay        | Günlər                                                                          |
| --------- | ------------------------------------------------------------------------------- |
| Fevral  2 | 16, 17, 18, 19, 20, 23, 24, 25, 26, 27                                          |
| Mart    3 | 2, 3, 4, 5, 6, 10, 11, 12, 13, 16, 17, 18, 19, 31                               |
| Aprel   4 | 1, 2, 3, 6, 7, 8, 9, 10, 13, 14, 15, 16, 17, 20, 21, 22, 23, 24, 27, 28, 29, 30 |
| May     5 | 1, 4, 5, 6, 7, 8, 12, 13, 14, 15, 18, 19, 20, 21, 22, 25, 26                    |
| İyun    6 | 1, 2, 3, 4, 5, 8, 9, 10, 11, 12, 16, 17, 18, 19, 22, 23, 24, 25, 29, 30         |
| İyul    7 | 1, 2, 3                                                                         |

- 3/86 günü təlim
- 83/86 günü tapşırıq

# Gündəlik tapşırıqları

| No  | Tapşırıq                                                                         |
| --- | -------------------------------------------------------------------------------- |
| 1   | Daxili şəbəkədə təhlükəsizlik üçün fərdi PKI infrastrukturunu quraşdırdım.       |
| 2   | OpenSSL ilə sistem üçün kök (Root CA) və aralıq sertifikatları yaratdım.         |
| 3   | Serverlər və istifadəçilər üçün TLS x509 sertifikatlarını imzaladım.             |
| 4   | L4/L7 səviyyəsində yük paylanması üçün HAProxy serverini tənzimlədim.            |
| 5   | Keepalived ilə Virtual IP (VIP) tətbiq edərək High Availability təmin etdim.     |
| 6   | Frontend üzərində HTTP trafikini 301 Redirect ilə HTTPS-ə yönləndirdim.          |
| 7   | HAProxy Stats səhifəsini aktivləşdirib Basic Auth ilə mühafizə etdim.            |
| 8   | Spesifik domen və IP-lər üçün HAProxy daxilində ACL qaydalarını yazdım.          |
| 9   | NGINX-i Reverse Proxy olaraq tənzimləyib, 8080 portunda xidmətə açdım.           |
| 10  | PHP-FPM konteynerini Host OS üzərindəki mənbə kodu ilə əlaqələndirdim.           |
| 11  | Məlumat qalıcılığını (Data Persistence) təmin edən MySQL 8 bazasını qurdum.      |
| 12  | Konteynerlər üçün Restart Policy tətbiq edərək avtomatik bərpanı tənzimlədim.    |
| 13  | PHP request-lərini proxy_pass vasitəsilə NGINX-dən PHP-FPM-ə ötürdüm.            |
| 14  | Konteynerlərarası izolyasiyanı artırmaq üçün fərdi Docker Bridge qurdum.         |
| 15  | Tətbiq təhlükəsizliyi üçün verilənlər bazası parollarını .env-ə keçirdim.        |
| 16  | Container-lərin resurs istehlakına limitlər (CPU/RAM) tətbiq etdim.              |
| 17  | Kubeadm, Kubelet və Kubectl paketlərini quraşdırıb konfiqurasiya etdim.          |
| 18  | Control Plane komponentlərini inisializasiya edərək K8s klasterini qurdum.       |
| 19  | Worker Node-ları konfiqurasiya edərək əsas klasterə inteqrasiya etdim.           |
| 20  | Pod-lararası əlaqə üçün Calico CNI (Container Network Interface) quraşdırdım.    |
| 21  | K8s klasterində etcd databazasının ehtiyat nüsxəsini (Backup) çıxardım.          |
| 22  | Node-ların resurs vəziyyətini izləmək üçün Metrics Server-i quraşdırdım.         |
| 23  | External trafikin idarəsi üçün NGINX Ingress Controller-i tətbiq etdim.          |
| 24  | Dinamik yaddaş təmini üçün StorageClass və PVC resurslarını tənzimlədim.         |
| 25  | Ingress əvəzinə daha inkişaf etmiş Kubernetes Gateway API-ni tətbiq etdim.       |
| 26  | Gateway resursu yaradaraq fərqli xidmətlərə HTTPRoute qaydaları yazdım.          |
| 27  | İstək sayına görə miqyaslanma üçün Horizontal Pod Autoscaler (HPA) qurdum.       |
| 28  | Cluster Autoscaler tətbiq edərək avtomatik Node miqyaslanmasını tənzimlədim.     |
| 29  | Pod-lar üçün CPU və yaddaş (RAM) request/limit dəyərlərini təyin etdim.          |
| 30  | Gateway API üzərində TLS Termination tənzimləmələrini konfiqurasiya etdim.       |
| 31  | Fərqli versiyalar arasında Canary Deployment üçün trafik bölgüsü yazdım.         |
| 32  | Mürəkkəb routing məntiqi üçün HTTP header əsaslı filtrləmə qaydaları yazdım.     |
| 33  | DaemonSet istifadə edərək xüsusi loqlama agentlərini hər Node-da quraşdırdım.    |
| 34  | Tətbiqin paylanması üçün optimallaşdırılmış multi-stage Dockerfile yazdım.       |
| 35  | Yığılmış (built) Docker image-lərini şəxsi Container Registry-yə push etdim.     |
| 36  | Tətbiqin idarəolunması üçün lokal Helm Chart strukturunu formalaşdırdım.         |
| 37  | Mühitə (Env) uyğun dəyişənləri idarə etmək üçün values.yaml faylını yazdım.      |
| 38  | Helm Release vasitəsilə tətbiqin klaster daxilində deploymentini icra etdim.     |
| 39  | Helm rollback komandası ilə əvvəlki versiyaya qayıdış mexanizmini test etdim.    |
| 40  | Helm template komandası ilə K8s manifest fayllarını render edib yoxladım.        |
| 41  | Chart-ları versiyalaşdıraraq mərkəzi Helm Repository-də qeydiyyata aldım.        |
| 42  | Deklarativ konfiqurasiya əsaslı CI/CD pipeline arxitekturasını qurdum.           |
| 43  | GitOps prinsiplərinə əsaslanaraq klasterdə ArgoCD alətini quraşdırdım.           |
| 44  | ArgoCD Application resursu ilə Git repozitoriyasını klasterə bağladım.           |
| 45  | Manifest dəyişikliklərinin klasterə avtomatik sinxronizasiyasını təmin etdim.    |
| 46  | Pipeline daxilində təhlükəsizlik üçün statik kod analizi (SAST) icra etdim.      |
| 47  | GitHub Actions / GitLab CI istifadə edərək Docker build prosesini yazdım.        |
| 48  | Dev və Prod mühitləri üçün izolyasiya edilmiş ArgoCD layihələri yaratdım.        |
| 49  | CI/CD axınında baş verən xətalar üçün webhook bildirişlərini tənzimlədim.        |
| 50  | Multi-Environment infrastrukturunu GitOps konseptinə inteqrasiya etdim.          |
| 51  | Mərkəzləşdirilmiş log toplanması üçün EFK (Elastic, Fluentd, Kibana) qurdum.     |
| 52  | Kube-state-metrics quraşdıraraq klaster komponentlərinin vəziyyətini izlədim.    |
| 53  | Metrikaların davamlı yığılması üçün Prometheus operatorunu deploy etdim.         |
| 54  | Grafana quraşdırıb, Prometheus verilənləri üçün idarəetmə panelləri yaratdım.    |
| 55  | Tətbiq üçün fərdiləşdirilmiş (custom) Prometheus metrikalarını eksport etdim.    |
| 56  | Mikroxidmətlərin Tracing analizi üçün Jaeger (OpenTelemetry) quraşdırdım.        |
| 57  | Mikroxidmətlər arası HTTP sorğularının gecikmə (Latency) vaxtlarını ölçdüm.      |
| 58  | Log rotasiyasını konfiqurasiya edərək yaddaşın dolmasının qarşısını aldım.       |
| 59  | Prometheus Alertmanager quraşdıraraq xəbərdarlıq sisteminin əsasını qurdum.      |
| 60  | CPU və RAM istifadəsinin kritik həddi keçməsinə dair Alert Rules yazdım.         |
| 61  | Alertmanager-in webhook funksiyası ilə Slack inteqrasiyasını tənzimlədim.        |
| 62  | k6 (və ya JMeter) alətini quraşdıraraq klasterə yüksək yük testləri etdim.       |
| 63  | Stress Test skriptləri yazaraq sistemin zəif nöqtələrini (Bottleneck) tapdım.    |
| 64  | Virtual istifadəçi (VU) simulyasiyası yaradaraq performans sınağı keçirdim.      |
| 65  | Stress ssenarisində HPA-nın pod sayını avtomatik artırmasını monitorinq etdim.   |
| 66  | İstək gecikməsinin (Latency) 95-ci persentil (P95) göstəricisini analiz etdim.   |
| 67  | HTTP Rate Limiting qaydalarının DDoS ssenarilərində effektivliyini test etdim.   |
| 68  | Xidmət kəsintisinə qarşı PodDisruptionBudget (PDB) konfiqurasiyasını yazdım.     |
| 69  | Konteyner yoxlanışı üçün Liveness, Readiness və Startup Probe-lar yazdım.        |
| 70  | Node qəzası (Failure) zamanı Pod-ların digər nodlara daşınmasını test etdim.     |
| 71  | StatefulSet istifadə edərək verilənlər bazasının replikasiyasını tənzimlədim.    |
| 72  | Etcd klasterinin Snapshot vasitəsilə bərpa (Restore) prosesini yoxladım.         |
| 73  | Pod-lararası şəbəkə izolyasiyası üçün Network Policy qaydalarını tətbiq etdim.   |
| 74  | Root icazələrini məhdudlaşdırmaq üçün SecurityContext parametrlərini sazladım.   |
| 75  | ServiceAccount səlahiyyətlərini RBAC (Role/RoleBinding) üzərindən idarə etdim.   |
| 76  | Məxfi məlumatları qorumaq üçün Kubernetes Secret şifrələməsini aktivləşdirdim.   |
| 77  | Bütün sistem arxitekturasının təhlükəsizlik və performans auditini icra etdim.   |
| 78  | Kube-bench istifadə edərək CIS (Center for Internet Security) skanlaması etdim.  |
| 79  | Klasterin tam işləkliyi haqqında texniki sənədləşdirmə (Documentation) yazdım.   |
| 80  | Disk yaddaşına qənaət üçün istifadəsiz konteyner İmage-lərini (Prune) sildim.    |
| 81  | Centralized Logging sistemində xətaların tez tapılması üçün indekslər yaratdım.  |
| 82  | Layihənin təhvil-təslim (Handover) və gələcək miqyaslanma xəritəsini hazırladım. |
| 83  | Bütün CI/CD, Deployment və Monitorinq proseslərinin inteqrasiyasını tamamladım.  |
