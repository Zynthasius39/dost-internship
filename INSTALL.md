# Layihənin Sıfırdan Qurulması və Ayağa Qaldırılması (Installation Guide)

Bu sənəd layihənin infrastrukturunun, tətbiq paketinin, CI/CD axınının və monitorinq sistemlərinin sıfırdan qurulması və konfiqurasiya edilməsi addımlarını əhatə edir.

## Mühit və Alətlər
* **Virtualizasiya:** Linux KVM, Libvirt, QEMU
* **Orkestrasiya:** Kubernetes v1.34.x (Kubespray ilə)
* **CNI:** Calico v3.29.7 (Tigera Operator)
* **GitOps:** ArgoCD
* **Monitorinq:** Prometheus, Grafana, Alertmanager (kube-prometheus-stack)
* **CI/CD:** GitHub Actions

## 1. İnfrastrukturun Qurulması (VM & Kubernetes)

İnfrastrukturun qurulması üçün yalnız [ansible](file:///home/zynf/Projects/dost-internship/bootstrap/ansible) repozitoriyasındakı konfiqurasiya fayllarından istifadə edilir.

### 1.1. VM-lərin KVM üzərində inisializasiya edilməsi
KVM hostuna (`jellybean` serveri, məsələn) qoşulmaq və virtual maşınları yaratmaq üçün müvafiq playbook tag-i ilə işə salınır:

```sh
ansible-playbook -i bootstrap/ansible/inventory/jellybean -e "nodes_file=../vars/nodes-jellybean.yml" bootstrap/ansible/playbooks/vms.yml --tags init
```

> [!NOTE]
> VM parametrləri və IP adresləri [nodes-jellybean.yml](file:///home/zynf/Projects/dost-internship/bootstrap/ansible/vars/nodes-jellybean.yml) faylı vasitəsilə tənzimlənir.

### 1.2. SSH SSH Keygen və known_hosts konfiqurasiyası
Yaranan virtual maşınların host IP adreslərini yerli mühitdə `known_hosts` siyahısına əlavə etmək üçün aşağıdakı skript işlədilir:

```sh
for NODE_HOST in $(yq '.all.hosts[].ansible_host' bootstrap/ansible/inventory/eclair-cluster/hosts.yml); do
  ssh-keygen -R $NODE_HOST
  ssh-keyscan -H $NODE_HOST >> ~/.ssh/known_hosts
done
```

### 1.3. Kubespray requirements-larının Quraşdırılması
Kubespray kolleksiyasını yükləyin və virtual mühit (venv) yaradaraq lazımi python paketlərini quraşdırın:

```sh
ansible-galaxy install -r bootstrap/ansible/requirements.yml

python3 -m venv bootstrap/ansible/venv
source bootstrap/ansible/venv/bin/activate
pip install -r ~/.ansible/collections/ansible_collections/kubernetes_sigs/kubespray/requirements.txt
```

### 1.4. Kubernetes Klasterinin Qurulması (Kubespray)
Klasteri `eclair-cluster` mühiti üçün ayağa qaldırın:

```sh
ansible-playbook -i bootstrap/ansible/inventory/eclair-cluster -b bootstrap/ansible/playbooks/kubespray_cluster.yml
```

Klasterə gələcəkdə yeni worker node əlavə etmək (miqyaslamaq) istədikdə isə scale playbook-u icra edilir:
```sh
ansible-playbook -i bootstrap/ansible/inventory/eclair-cluster -b bootstrap/ansible/playbooks/kubespray_scale.yml
```

### 1.5. Kubectl Konfiqurasiyasının Yaradılması
Master node-dan admin konfiqurasiya faylını yerli mühitə kopyalayın və `kubectl` əmrinin işləməsini təmin edin:

```sh
MASTER_HOST=$(yq ".all.hosts.k8s-eclair-1.ip" bootstrap/ansible/inventory/eclair-cluster/hosts.yml)
rsync -a --rsync-path="sudo rsync" debian@$MASTER_HOST:/etc/kubernetes/admin.conf ~/.kube/config
sed -i "s/127\.0\.0\.1/$MASTER_HOST/" ~/.kube/config

kubectl get nodes -o wide
```

### 1.6. Calico CNI Quraşdırılması
Tigera Operator-u və müvafiq custom CRD resurslarını klasterə tətbiq edin:

```sh
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.7/manifests/tigera-operator.yaml
```

Calico konfiqurasiyasını (məsələn, Linux dataplane olaraq Nftables istifadəsi və düzgün CIDR) tənzimləyən manifesti apply edin:
```sh
kubectl create -f custom-resources.yaml
kubectl get tigerastatus -w
```

## 2. Tətbiqin Paketlənməsi (App & Packaging)

### 2.1. Tətbiq Strukturunun Hazırlanması
[main.go](file:///home/zynf/Projects/dost-internship/src/gopher/main.go) faylında Go proqramlaşdırma dili ilə yazılmış minimal tətbiq yerləşir. Tətbiqin Go asılılıqlarını toplayın:

```sh
cd src/gopher
go mod init gopher
go mod tidy
```

### 2.2. Multi-stage Docker Image Yığılması
Minimal ölçülü və təhlükəsiz runtime mühiti təmin etmək üçün tətbiq multi-stage [Dockerfile](file:///home/zynf/Projects/dost-internship/src/gopher/Dockerfile) vasitəsilə build edilir və GHCR-ə push olunur:

```sh
podman build . -t ghcr.io/zynthasius39/gopher:1.0.0
podman push ghcr.io/zynthasius39/gopher:1.0.0
```

### 2.3. Helm Chart Strukturunun Yoxlanılması
[gopher](file:///home/zynf/Projects/dost-internship/deploy/helm/gopher) chart-ının bütövlüyünü test edin:

```sh
helm lint deploy/helm/gopher
helm template gopher deploy/helm/gopher -f deploy/helm/gopher/values-dev.yaml
```

## 3. CI/CD və GitOps Axınının Qurulması

### 3.1. GitHub Actions Pipeline-ın Konfiqurasiyası
Layihədə [.github/workflows/ci.yaml](file:///home/zynf/Projects/dost-internship/.github/workflows/ci.yaml) faylında təyin olunmuş workflow tətbiq olunur. Hər commit zamanı:
* Chart-ın sintaksisi (`helm lint`) yoxlanılır.
* İmic GHCR-ə build olunaraq `latest` və `sha-${{ github.sha }}` teqləri ilə push edilir.
* İmic teqi avtomatik olaraq [values-prod.yaml](file:///home/zynf/Projects/dost-internship/deploy/helm/gopher/values-prod.yaml) faylında yenilənib geri push edilir.

### 3.2. ArgoCD Quraşdırılması və Insecure Rejim
ArgoCD manifestlərini klasterə yükləyin:

```sh
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Ingress arxasında işlədiyi üçün serverin daxili TLS-ini söndürün:
```sh
kubectl -n argocd patch configmap argocd-cmd-params-cm --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl -n argocd rollout restart deployment argocd-server
```

[argocd-ingress.yaml](file:///home/zynf/Projects/dost-internship/deploy/argocd-ingress.yaml) manifestini klasterə əlavə edin:
```sh
kubectl apply -f deploy/argocd-ingress.yaml
```

### 3.3. ArgoCD Şifrəsinin Dəyişdirilməsi
İlkin admin şifrəsini əldə edin və CLI vasitəsilə daxil olub onu yeniləyin:

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
argocd login argocd.naquadah.alak --username admin --password <initial-password> --grpc-web
argocd account update-password --current-password <initial-password> --new-password <new-password>
kubectl -n argocd delete secret argocd-initial-admin-secret
```

### 3.4. App-of-Apps GitOps Bootstrap
Klasterin bütün deployment idarəçiliyini ArgoCD-yə ötürmək üçün [root-app.yaml](file:///home/zynf/Projects/dost-internship/deploy/root-app.yaml) manifestini tətbiq edin:

```sh
kubectl apply -f deploy/root-app.yaml
```

> [!IMPORTANT]
> Bu resurs avtomatik olaraq [dev-app.yaml](file:///home/zynf/Projects/dost-internship/deploy/apps/dev-app.yaml) və [prod-app.yaml](file:///home/zynf/Projects/dost-internship/deploy/apps/prod-app.yaml) tətbiqlərini və klaster daxilində namespace-ləri yaradacaq.

## 4. Monitorinq və Observability

### 4.1. Kube-Prometheus-Stack Quraşdırılması
Grafana admin şifrəsi üçün secret yaradın və stack-i müvafiq dəyərlər faylı ilə install edin:

```sh
kubectl -n monitoring create secret generic grafana-admin-secret \
  --from-literal=admin-user="admin" \
  --from-literal=admin-password=$(openssl rand -hex 16)

helm upgrade --install monitoring oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
  --version 86.2.2 \
  --namespace monitoring \
  --create-namespace \
  --values deploy/values-kube-prometheus-stack.yaml
```

> [!NOTE]
> Grafana parametrləri və ingress konfiqurasiyası [values-kube-prometheus-stack.yaml](file:///home/zynf/Projects/dost-internship/deploy/values-kube-prometheus-stack.yaml) daxilində yer alır.

### 4.2. Grafana Dashboard Importu
Grafana panelinə (`grafana.naquadah.alak`) daxil olun, yadda saxladığımız [slo.json](file:///home/zynf/Projects/dost-internship/grafana/dashboards/slo.json) dashboard-unu sistemə import edərək tətbiq metrikalarını (Request rate, Error rate %, Latency, CPU/Memory) izləyin.

## 5. Alerting və Yük Testi (Load Testing)

### 5.1. PrometheusRule və Alertmanager Qaydaları
Helm chart-ında olan PrometheusRule alertlərini (`HighErrorRate`, `HighLatency`, `PodCrashLooping`) və Alertmanager-in Discord webhook-u vasitəsilə bildiriş ötürməsi üçün müvafiq secret resursunu yaradın:

```sh
kubectl -n gopher-prod create secret generic discord-webhook-secret --from-literal url=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN
```

### 5.2. Yük Testinin Başladılması
Klaster üzərində avtomatik miqyaslanmanı (HPA) və xəbərdarlıq qaydalarını test etmək üçün `hey` aləti ilə yük vurun:

```sh
# Normal yük testi
hey -z 30s -c 50 http://gopher.naquadah.alak/

# Xəta dərəcəsini (error rate) qaldırmaq üçün nonexistent endpoint-ə sorğu
hey -z 30s -c 100 http://gopher.naquadah.alak/nonexistent
```

## 6. Dayanıqlılıq və Yekun Yoxlama (Resilience & Validation)

### 6.1. Rollback və Roll-out Testləri
Tətbiqin dayanıqlılığını yoxlamaq üçün [values-prod.yaml](file:///home/zynf/Projects/dost-internship/deploy/helm/gopher/values-prod.yaml) faylında imic teqini səhv teq ilə dəyişin (məsələn, `tag: 1.0.1`) və repozitoriyaya push edin.

ArgoCD-nin bu dəyişikliyi tətbiq edərkən pod-ların `ImagePullBackOff` vəziyyətinə düşdüyünü müşahidə edin:
```sh
kubectl -n gopher-prod get pods
```

ArgoCD UI vasitəsilə dərhal əvvəlki stabil revision-a rollback edin və release tarixçəsini yoxlayın:
```sh
helm history gopher-prod -n gopher-prod
```

### 6.2. Sağlamlığın Təsdiqlənməsi
Tətbiqin endpoint-inə sorğu ataraq sistemin yenidən tam işlək vəziyyətə qayıtdığını yoxlayın:

```sh
curl -s http://gopher.naquadah.alak/health
```

Gözlənilən cavab:
```json
{"status":"healthy"}
```
