# Alerting & Load testing
Bu mərhələdə infrastruktur və tətbiq xətalarına qarşı Alertmanager xəbərdarlıq mexanizminin (PrometheusRule) qurulması, Slack/Discord inteqrasiyası və yük testləri (`hey` / `ab`) vasitəsilə sistemin bu xəbərdarlıqlara reaksiyasının yoxlanılması həyata keçirilir.

## Mühit
* Prometheus Alertmanager
* Slack Webhook
* hey v0.1.5

## Task addımları
### 1. _PrometheusRule_ manifesti yaradın və daxilində bu alert-ləri təyin edin

#### 1.1. **HighErrorRate**: error rate 5%-dən artıq olarsa və 2 dəqiqə davam edərsə

#### 1.2. **HighLatency**: P99 latency 500ms-dən artıq olarsa və 5 dəqiqə davam edərsə

#### 1.3. **PodCrashLooping**: pod restart rate sıfırdan böyük olarsa və 5 dəqiqə davam edərsə

### 2. AlertManager konfiqurasiyasını yeniləyərək Slack/Discord webhook-unu əlavə edin.

### 3. Sistemə test alert-i göndərin və onun müvafiq xəbərdarlıq kanalında (Slack/Discord) göründüyünü yoxlayın.

### 4. Local mühitinizdə və ya test serverində `hey` və ya `ab` alətini quraşdırın.

### 5. Normal yük üçün `hey -z 30s -c 50 http://<app-url>/` əmrini işlədin.

### 6. Yük testi zamanı eyni anda Grafana panelində request rate-in real-time artdığını müşahidə edin.

### 7. Xəta dərəcəsini artırmaq üçün mövcud olmayan endpointə yük vurun: `hey -z 30s -c 100 http://<app-url>/nonexistent`.

### 8. Prometheus və Alertmanager interfeysində alert-in statusunun `Pending` rejimindən `Firing` rejiminə keçdiyini vizual olaraq göstərin.

### 9. Yük testini dayandırın və metrikaların yenidən normal/stabil vəziyyətə qayıtdığını yoxlayın.

