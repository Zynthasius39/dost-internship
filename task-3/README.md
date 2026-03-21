# Kubernetes Cluster

<img src="https://github.com/kubernetes/kubernetes/raw/master/logo/logo.png" width="100">

---
## Mühit
- Kubespray
- 1 master, 2 worker nodları
- Calico ~>3.29
- Quraşdırılacaq versiya: 1.32.x
- Güncəllənəcək versiya: 1.34.x

---
<!-- toc -->

- [Kubernetes Cluster](#kubernetes-cluster)
  - [Mühit](#mühit)
  - [Tapşırıq siyahısı](#tapşırıq-siyahısı)
    - [1. Node-ları
      hazırla](#1-node-ları-hazırla)
      - [1.1. Yeni node-lar
        yarat](#11-yeni-node-lar-yarat)
      - [1.2. Yeni node-ları **known_hosts**-a əlavə
        et](#12-yeni-node-ları-known_hosts-a-əlavə-et)
    - [2. Master node-da cluster qaldır
      (1.32.x)](#2-master-node-da-cluster-qaldır-132x)
      - [2.1. Sample kubespray inventory-sini
        köçür](#21-sample-kubespray-inventory-sini-köçür)
      - [2.2. Inventory-də dəyişiklik
        et](#22-inventory-də-dəyişiklik-et)
      - [2.3. Kubespray konfiqurasiyasını
        dəyiş](#23-kubespray-konfiqurasiyasını-dəyiş)
      - [2.3. Kubespray-i collection kimi
        quraşdır](#23-kubespray-i-collection-kimi-quraşdır)
      - [2.4. Kubespray üçün spesifik ansible versiyasını
        quraşdır](#24-kubespray-üçün-spesifik-ansible-versiyasını-quraşdır)
      - [2.5. Playbook-u icra
        et](#25-playbook-u-icra-et)
    - [3. Kubectl konfiqurasiyasını
      qur](#3-kubectl-konfiqurasiyasını-qur)
    - [4. Calico Operator (3.29) tətbiq
      et](#4-calico-operator-329-tətbiq-et)
      - [4.1. Tigera Operator və custom CRD-lərini
        quraşdır](#41-tigera-operator-və-custom-crd-lərini-quraşdır)
      - [4.2. Calico Installation resursunu yüklə və dəyişiklik
        et](#42-calico-installation-resursunu-yüklə-və-dəyişiklik-et)
      - [4.2. Calico Installation resursunu
        quraşdır](#42-calico-installation-resursunu-quraşdır)
      - [4.3. Calico available olana qədər
        gözlə](#43-calico-available-olana-qədər-gözlə)
    - [5. Worker node-ları
      qoş](#5-worker-node-ları-qoş)
      - [5.1. Inventory-yə dəyişiklik
        et](#51-inventory-yə-dəyişiklik-et)
      - [5.2. Scale playbook-unu icra
        et](#52-scale-playbook-unu-icra-et)
      - [5.3. Cluster playbook-unu icra
        et](#53-cluster-playbook-unu-icra-et)
      - [5.4. MetalLB üçün BGPAdvertisement resurunu
        quraşdır](#54-metallb-üçün-bgpadvertisement-resurunu-quraşdır)
    - [6. Node statusunu
      yoxla](#6-node-statusunu-yoxla)
    - [7. Pod statusunu yoxla
      (kube-system)](#7-pod-statusunu-yoxla-kube-system)
    - [8. Əsas komponentlərin loglarını
      çıxar](#8-əsas-komponentlərin-loglarını-çıxar)
    - [9. Cluster upgrade et -- 1.34.x (master +
      worker)](#9-cluster-upgrade-et--134x-master--worker)
      - [9.1. Cluster playbook-unu icra et
        (1.33.9)](#91-cluster-playbook-unu-icra-et-1339)
      - [9.2. Cluster playbook-unu icra et
        (1.34.5)](#92-cluster-playbook-unu-icra-et-1345)
      - [9.2. Kubespray konfiqurasiyasını
        dəyiş](#92-kubespray-konfiqurasiyasını-dəyiş)
    - [10. Node statusunu
      yoxla](#10-node-statusunu-yoxla)
    - [11. Pod statusunu yoxla
      (kube-system)](#11-pod-statusunu-yoxla-kube-system)
    - [12. Əsas komponentlərin loglarını
      çıxar](#12-əsas-komponentlərin-loglarını-çıxar)
    - [13. Hər addımın ekran görüntüsünü və loglarını
      paylaş](#13-hər-addımın-ekran-görüntüsünü-və-loglarını-paylaş)
    - [14. Final cluster statusunu
      paylaş](#14-final-cluster-statusunu-paylaş)
    - [15. (ƏLAVƏ) Calico-nu
      güncəllə](#15-əlavə-calico-nu-güncəllə)
      - [15.1. Tigera Operator və custom CRD-lərini
        yüklə](#151-tigera-operator-və-custom-crd-lərini-yüklə)
      - [15.2. Güncəlləməni
        başlat](#152-güncəlləməni-başlat)
      - [15.3. Flow logs və Calico Whisker-i
        quraşdır](#153-flow-logs-və-calico-whisker-i-quraşdır)
      - [15.4. Calico available olana qədər
        gözlə](#154-calico-available-olana-qədər-gözlə)

<!-- tocstop -->

---
## Tapşırıq siyahısı

### 1. Node-ları hazırla

#### 1.1. Yeni node-lar yarat

``` sh
ansible-playbook -i inventory/jellybean -e "nodes_file=../vars/nodes-jellybean.yml" playbooks/vms.yml --tags init
```
``` console
PLAY [Set-up VMs on a KVM] *****************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
ok: [jellybean]

TASK [vm_init : SSH Keygen] ****************************************************************************************************************************
included: /proj/dost-internship/task-3/roles/vm_init/tasks/ssh.yml for jellybean

TASK [vm_init : Create a directory if it does not exist] ***********************************************************************************************
ok: [jellybean]

TASK [vm_init : Generate an OpenSSH keypair] ***********************************************************************************************************
changed: [jellybean]

TASK [vm_init : Virt Install] **************************************************************************************************************************
included: /proj/dost-internship/task-3/roles/vm_init/tasks/install.yml for jellybean => (item={'name': 'k8s-eclair-1', 'ip': '10.0.16.11', 'mac': '52:54:00:0a:10:0b', 'memory': 4096, 'vcpu': 2, 'role': 'master'})
included: /proj/dost-internship/task-3/roles/vm_init/tasks/install.yml for jellybean => (item={'name': 'k8s-eclair-2', 'ip': '10.0.16.12', 'mac': '52:54:00:0a:10:0c', 'memory': 8192, 'vcpu': 4, 'role': 'worker'})
included: /proj/dost-internship/task-3/roles/vm_init/tasks/install.yml for jellybean => (item={'name': 'k8s-eclair-3', 'ip': '10.0.16.13', 'mac': '52:54:00:0a:10:0d', 'memory': 8192, 'vcpu': 4, 'role': 'worker'})

TASK [vm_init : Install the VM - k8s-eclair-1] *********************************************************************************************************
changed: [jellybean]

TASK [vm_init : Install the VM - k8s-eclair-2] *********************************************************************************************************
changed: [jellybean]

TASK [vm_init : Install the VM - k8s-eclair-3] *********************************************************************************************************
changed: [jellybean]

PLAY [Provision the cluster] ***************************************************************************************************************************
skipping: no hosts matched

PLAY RECAP *********************************************************************************************************************************************
jellybean                  : ok=10   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

``` sh
virsh -c qemu:///system list | grep k8s
```
``` console
 23   k8s-eclair-1       running
 24   k8s-eclair-2       running
 25   k8s-eclair-3       running
```

#### 1.2. Yeni node-ları **known_hosts**-a əlavə et

``` sh
for NODE_HOST in $(yq '.all.hosts[].ansible_host' inventory/local-cluster/hosts.yml); do
  ssh-keygen -R $NODE_HOST
  ssh-keyscan -H $NODE_HOST >> ~/.ssh/known_hosts
done
```

### 2. Master node-da cluster qaldır (1.32.x)

#### 2.1. Sample kubespray inventory-sini köçür

``` sh
KUBESPRAY_REPO=/tmp/kubespray
git clone --branch=release-2.30 --single-branch https://github.com/kubernetes-sigs/kubespray $KUBESPRAY_REPO
cp -r $KUBESPRAY_REPO/inventory/sample inventory/local-cluster
rm -rf $KUBESPRAY_REPO
```

#### 2.2. Inventory-də dəyişiklik et

- _inventory.ini_ faylını silib yerinə _hosts.yml_ yaradırıq
- Hazırladığımız node-u **hosts**-a əlavə edirik.
- Yeni node-u **kube_control_plane** və **etcd** qruplarına əlavə edirik.
- **kube_node** adlı hosts hissəsi boş qrup yaradırıq.
- **kube_control_plane** və **kube_node** qruplarını **k8s_cluster** qrupuna əlavə edirik.
- Ansible üçün lazımi variable-ları əlavə edirik (ssh açarı, user və s.).

``` sh
rm inventory/local-cluster/inventory.ini
touch inventory/local-cluster/hosts.yml
```

[hosts.yml](inventory/local-cluster/hosts.yml)
``` diff
1a2,23
  all:
    hosts:
>     k8s-eclair-1:
>       ansible_host: 192.168.122.11
>       ip: 192.168.122.11

    children:
>     kube_control_plane:
>       hosts:
>         k8s-eclair-1:

>     kube_node:
>       hosts: {}

>     etcd:
>       hosts:
>         k8s-eclair-1:

>     k8s_cluster:
>       children:
>         kube_control_plane:
>         kube_node:
```

#### 2.3. Kubespray konfiqurasiyasını dəyiş

``` diff
inventory/sample/group_vars/all/all.yml
# CoreDNS loop-a girməməsi üçün DNS serverlərini əl ilə əlavə edirik.
39,41c39,40
< # upstream_dns_servers:
< #   - 8.8.8.8
< #   - 8.8.4.4
---
> upstream_dns_servers:
>   - 192.168.122.1
inventory/sample/group_vars/k8s_cluster/addons.yml
# Metrics serveri.
16c16
< metrics_server_enabled: false
---
> metrics_server_enabled: true
# MetalLB speaker-ini Calico BGPAdvertisement ilə əvəz edirik.
147,148c147,148
< metallb_enabled: false
< metallb_speaker_enabled: "{{ metallb_enabled }}"
---
> metallb_enabled: true
> metallb_speaker_enabled: false
149a150,158
> metallb_config:
>   address_pools:
>     primary:
>       ip_range:
>         - 192.168.122.128/25
>       auto_assign: true
>   layer2:
>     - primary
> calico_advertise_service_loadbalancer_ips: "{{ metallb_config.address_pools.primary.ip_range }}"
inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml
# Sonra upgrade etmək üçün ilk 1.32.13 versiyasını seçirik.
6a7
> kube_version: 1.32.13
# CNI-yı Calico Operator ilə quracağımız üçün custom cni seçirik.
68c69
< kube_network_plugin: calico
---
> kube_network_plugin: cni
# Debian 13 nftables native dəstəklədiyi üçün nftables seçirik.
121c122
< kube_proxy_mode: ipvs
---
> kube_proxy_mode: nftables
```

#### 2.3. Kubespray-i collection kimi quraşdır

``` sh
ansible-galaxy install -r requirements.yml
```

#### 2.4. Kubespray üçün spesifik ansible versiyasını quraşdır

``` sh
python3 -m venv venv
source venv/bin/active
pip install -r ~/.ansible/collections/ansible_collections/kubernetes_sigs/kubespray/requirements.txt
```

#### 2.5. Playbook-u icra et

- **MetalLB**-nı worker node-ları cluster-ə əlavə etdikdən sonra quraşdıracayıq.
- MetalLB controller control plane-də schedule olunmur.
``` sh
ansible-playbook -i inventory/local-cluster -b playbooks/kubespray_cluster.yml --skip-tags metallb
```

``` console
...
TASK [kubernetes_sigs.kubespray.kubernetes/preinstall : Remove kubespray specific config from dhclient config] *****************************************
skipping: [k8s-eclair-1]

TASK [kubernetes_sigs.kubespray.kubernetes/preinstall : Remove kubespray specific dhclient hook] *******************************************************
skipping: [k8s-eclair-1]

TASK [kubernetes_sigs.kubespray.kubernetes/preinstall : Flush handlers] ********************************************************************************

RUNNING HANDLER [kubernetes_sigs.kubespray.kubernetes/preinstall : Preinstall | Restart systemd-resolved] **********************************************
changed: [k8s-eclair-1]

TASK [kubernetes_sigs.kubespray.kubernetes/preinstall : Check if we are running inside a Azure VM] *****************************************************
skipping: [k8s-eclair-1]

TASK [Run calico checks] *******************************************************************************************************************************
skipping: [k8s-eclair-1]

PLAY RECAP *********************************************************************************************************************************************
adF37ef6b4D4c5cECdB5Df6fBECDDaB57EbafddF17FFf71b2d7Beca5DEBbC77F : ok=1    changed=0    unreachable=0    failed=0    skipped=11   rescued=0    ignored=0   
k8s-eclair-1               : ok=498  changed=36   unreachable=0    failed=0    skipped=916  rescued=0    ignored=0
```

### 3. Kubectl konfiqurasiyasını qur

``` sh
MASTER_HOST=$(yq ".all.hosts.k8s-eclair-1.ip" inventory/local-cluster/hosts.yml)
rsync -a --rsync-path="sudo rsync" debian@$MASTER_HOST:/etc/kubernetes/admin.conf ~/.kube/config
sed -i "s/127\.0\.0\.1/$MASTER_HOST/" ~/.kube/config

kubectl get nodes -o wide
```
``` console
NAME           STATUS   ROLES           AGE   VERSION    INTERNAL-IP      EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION                CONTAINER-RUNTIME
k8s-eclair-1   Ready    control-plane   15h   v1.32.13   192.168.122.11   <none>        Debian GNU/Linux 13 (trixie)   6.12.74+deb13+1-cloud-amd64   containerd://2.2.2
```

### 4. Calico Operator (3.29) tətbiq et

https://docs.tigera.io/calico/3.29/getting-started/kubernetes/quickstart

#### 4.1. Tigera Operator və custom CRD-lərini quraşdır

``` sh
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.7/manifests/tigera-operator.yaml
```

#### 4.2. Calico Installation resursunu yüklə və dəyişiklik et

``` sh
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.29.7/manifests/custom-resources.yaml
```

``` diff
# kube_proxy_mode üçün nftables seçdiyimiz üçün Calico da nftables istifadə etməlidir.
9a10
>     linuxDataplane: Nftables
# cidr yerinə kube_pods_subnet veririk.
# Node-lar eyni broadcast domain-də olduğu üçün encapsulation-a ehtiyac yoxdur. None seçirik.
13,14c14,15
<       cidr: 192.168.0.0/16
<       encapsulation: VXLANCrossSubnet
---
>       cidr: 10.233.64.0/18
>       encapsulation: None
```

#### 4.2. Calico Installation resursunu quraşdır

``` sh
kubectl create -f custom-resources.yaml
```

#### 4.3. Calico available olana qədər gözlə

``` sh
kubectl get tigerastatus -w
```
``` console
NAME        AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver   True        False         False      13h
calico      True        False         False      14h
ippools     True        False         False      13h

```

### 5. Worker node-ları qoş

#### 5.1. Inventory-yə dəyişiklik et

- Hazırladığımız son 2 node-u **hosts**-a əlavə et.
- Yeni node-ları **kube_node** qrupuna əlavə et.

[hosts.yml](inventory/local-cluster/hosts.yml)
``` diff
6a7,14
  all:
    hosts:
>     k8s-eclair-2:
>       ansible_host: 192.168.122.12
>       ip: 192.168.122.12
> 
>     k8s-eclair-3:
>       ansible_host: 192.168.122.13
>       ip: 192.168.122.13
> 
13c21,23
  children:
    kube_node:
<       hosts: {}
---
    kube_node
>       hosts:
>         k8s-eclair-2:
>         k8s-eclair-3:
```

#### 5.2. Scale playbook-unu icra et

``` sh
ansible-playbook -i inventory/local-cluster -b playbooks/kubespray_scale.yml
```

#### 5.3. Cluster playbook-unu icra et

Worker node-ları gözləyən resursları quraşdırırıq.
``` sh
ansible-playbook -i inventory/local-cluster -b playbooks/kubespray_cluster.yml
```

#### 5.4. MetalLB üçün BGPAdvertisement resurunu quraşdır

- İlk quraşdırma zamanı MetalLB speaker-ini söndürdüyümüz üçün service IP route-larını Calico ilə advertise etmək lazımdır.
- Calico-nu quraşdıran zamanı encapsulation-i None seçdiyimiz üçün bu step vacib deyil.

``` sh
kubectl create -f calico-serviceips-advertisement.yml
```

### 6. Node statusunu yoxla

Calico quraşdırılana qədər yeni node-lar NotReady olacaq.
``` sh
kubectl get nodes
```
``` console
NAME           STATUS     ROLES           AGE     VERSION
k8s-eclair-1   Ready      control-plane   17h     v1.32.13
k8s-eclair-2   NotReady   <none>          2m33s   v1.32.13
k8s-eclair-3   NotReady   <none>          2m33s   v1.32.13
```

``` sh
kubectl get tigerastatus -w
```
``` console
NAME        AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver   True        False         False      15h
calico      False       True          False      4m26s
ippools     True        False         False      15h
```

Bir müddət sonra node-lar Ready olur.
``` sh
kubectl get nodes
```
``` console
NAME           STATUS   ROLES           AGE     VERSION
k8s-eclair-1   Ready    control-plane   17h     v1.32.13
k8s-eclair-2   Ready    <none>          8m16s   v1.32.13
k8s-eclair-3   Ready    <none>          8m16s   v1.32.13
```

``` sh
kubectl get tigerastatus -w
```
``` console
NAME        AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver   True        False         False      15h
calico      True        False         False      3m22s
ippools     True        False         False      15h
```

### 7. Pod statusunu yoxla (kube-system)

``` sh
kubectl -n kube-system get pods -o wide
```
``` console
NAME                                   READY   STATUS    RESTARTS        AGE   IP               NODE           NOMINATED NODE   READINESS GATES
coredns-64d6ddf4b8-hzz9j               1/1     Running   5 (7m20s ago)   17h   10.233.113.34    k8s-eclair-1   <none>           <none>
dns-autoscaler-676999957f-56sl7        1/1     Running   5 (7m20s ago)   17h   10.233.113.37    k8s-eclair-1   <none>           <none>
kube-apiserver-k8s-eclair-1            1/1     Running   5 (7m20s ago)   17h   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-controller-manager-k8s-eclair-1   1/1     Running   6 (7m20s ago)   17h   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-proxy-67tn2                       1/1     Running   1 (7m21s ago)   52m   192.168.122.12   k8s-eclair-2   <none>           <none>
kube-proxy-dxjz7                       1/1     Running   5 (7m20s ago)   17h   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-proxy-n4mjr                       1/1     Running   1 (7m20s ago)   52m   192.168.122.13   k8s-eclair-3   <none>           <none>
kube-scheduler-k8s-eclair-1            1/1     Running   6 (7m20s ago)   17h   192.168.122.11   k8s-eclair-1   <none>           <none>
metrics-server-7cd7f9897-8n9bt         1/1     Running   5 (7m20s ago)   17h   10.233.113.35    k8s-eclair-1   <none>           <none>
nginx-proxy-k8s-eclair-2               1/1     Running   1 (7m21s ago)   52m   192.168.122.12   k8s-eclair-2   <none>           <none>
nginx-proxy-k8s-eclair-3               1/1     Running   1 (7m20s ago)   52m   192.168.122.13   k8s-eclair-3   <none>           <none>
nodelocaldns-blbgn                     1/1     Running   5 (7m20s ago)   17h   192.168.122.11   k8s-eclair-1   <none>           <none>
nodelocaldns-c5h76                     1/1     Running   1 (7m20s ago)   52m   192.168.122.13   k8s-eclair-3   <none>           <none>
nodelocaldns-mhrvl                     1/1     Running   1 (7m21s ago)   52m   192.168.122.12   k8s-eclair-2   <none>           <none>
```

### 8. Əsas komponentlərin loglarını çıxar

``` sh
kubectl -n kube-system logs daemonsets/kube-proxy
```
``` console
Found 3 pods, using pod/kube-proxy-dxjz7
I0320 14:32:47.007054       1 server.go:698] "Successfully retrieved node IP(s)" IPs=["192.168.122.11"]
I0320 14:32:47.010387       1 conntrack.go:121] "Set sysctl" entry="net/netfilter/nf_conntrack_max" value=131072
I0320 14:32:47.011198       1 conntrack.go:60] "Setting nf_conntrack_max" nfConntrackMax=131072
I0320 14:32:47.011316       1 conntrack.go:121] "Set sysctl" entry="net/netfilter/nf_conntrack_tcp_timeout_established" value=86400
I0320 14:32:47.011412       1 conntrack.go:121] "Set sysctl" entry="net/netfilter/nf_conntrack_tcp_timeout_close_wait" value=3600
I0320 14:32:47.011466       1 server.go:243] "kube-proxy running in dual-stack mode" primary ipFamily="IPv4"
I0320 14:32:47.011506       1 server_linux.go:292] "Using nftables Proxier"
I0320 14:32:47.079907       1 server.go:497] "Version info" version="v1.32.13"
I0320 14:32:47.079932       1 server.go:499] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0320 14:32:47.081941       1 config.go:329] "Starting node config controller"
I0320 14:32:47.082659       1 shared_informer.go:313] Waiting for caches to sync for node config
I0320 14:32:47.082848       1 config.go:199] "Starting service config controller"
I0320 14:32:47.082881       1 shared_informer.go:313] Waiting for caches to sync for service config
I0320 14:32:47.083012       1 config.go:105] "Starting endpoint slice config controller"
I0320 14:32:47.083020       1 shared_informer.go:313] Waiting for caches to sync for endpoint slice config
I0320 14:32:47.183034       1 shared_informer.go:320] Caches are synced for node config
I0320 14:32:47.183089       1 shared_informer.go:320] Caches are synced for endpoint slice config
I0320 14:32:47.183098       1 shared_informer.go:320] Caches are synced for service config
I0320 14:33:11.674359       1 proxier.go:1204] "Deleting stale nftables chains" ipFamily="IPv4" numChains=8
```

``` sh
kubectl -n kube-system logs kube-apiserver-k8s-eclair-1
```
``` console
Flag --apiserver-count has been deprecated, apiserver-count is deprecated and will be removed in a future version.
I0320 14:32:38.640414       1 options.go:238] external host was not specified, using 192.168.122.11
I0320 14:32:38.642722       1 server.go:147] Version: v1.32.13
I0320 14:32:38.642748       1 server.go:149] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0320 14:32:38.873017       1 shared_informer.go:313] Waiting for caches to sync for node_authorizer
I0320 14:32:38.878339       1 shared_informer.go:313] Waiting for caches to sync for *generic.policySource[*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicy,*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicyBinding,k8s.io/apiserver/pkg/admission/plugin/policy/validating.Validator]
I0320 14:32:38.882284       1 plugins.go:157] Loaded 13 mutating admission controller(s) successfully in the following order: NamespaceLifecycle,LimitRanger,ServiceAccount,NodeRestriction,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,RuntimeClass,DefaultIngressClass,MutatingAdmissionPolicy,MutatingAdmissionWebhook.
I0320 14:32:38.882299       1 plugins.go:160] Loaded 13 validating admission controller(s) successfully in the following order: LimitRanger,ServiceAccount,PodSecurity,Priority,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSigning,ClusterTrustBundleAttest,CertificateSubjectRestriction,ValidatingAdmissionPolicy,ValidatingAdmissionWebhook,ResourceQuota.
...
```

``` sh
kubectl -n kube-system logs kube-controller-manager-k8s-eclair-1
```
``` console
I0320 14:32:38.917564       1 serving.go:386] Generated self-signed cert in-memory
I0320 14:32:39.221969       1 controllermanager.go:185] "Starting" version="v1.32.13"
I0320 14:32:39.221987       1 controllermanager.go:187] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0320 14:32:39.223955       1 dynamic_cafile_content.go:161] "Starting controller" name="request-header::/etc/kubernetes/ssl/front-proxy-ca.crt"
I0320 14:32:39.224003       1 dynamic_cafile_content.go:161] "Starting controller" name="client-ca-bundle::/etc/kubernetes/ssl/ca.crt"
I0320 14:32:39.224443       1 secure_serving.go:213] Serving securely on [::]:10257
I0320 14:32:39.224712       1 tlsconfig.go:243] "Starting DynamicServingCertificateController"
I0320 14:32:39.224999       1 leaderelection.go:257] attempting to acquire leader lease kube-system/kube-controller-manager...
E0320 14:32:44.125851       1 leaderelection.go:436] error retrieving resource lock kube-system/kube-controller-manager: leases.coordination.k8s.io "kube-controller-manager" is forbidden: User "system:kube-controller-manager" cannot get resource "leases" in API group "coordination.k8s.io" in the namespace "kube-system"
I0320 14:33:05.518413       1 leaderelection.go:271] successfully acquired lease kube-system/kube-controller-manager
I0320 14:33:05.518985       1 event.go:389] "Event occurred" object="kube-system/kube-controller-manager" fieldPath="" kind="Lease" apiVersion="coordination.k8s.io/v1" type="Normal" reason="LeaderElection" message="k8s-eclair-1_6699a136-dcf5-4e0f-bb13-69e4c6a5ec20 became leader"
I0320 14:33:05.527743       1 controllermanager.go:765] "Started controller" controller="serviceaccount-token-controller"
I0320 14:33:05.528394       1 shared_informer.go:313] Waiting for caches to sync for tokens
I0320 14:33:05.557162       1 range_allocator.go:112] "No Secondary Service CIDR provided. Skipping filtering out secondary service addresses" logger="node-ipam-controller"
I0320 14:33:05.557255       1 controllermanager.go:765] "Started controller" controller="node-ipam-controller"
...
```

``` sh
kubectl -n kube-system logs kube-scheduler-k8s-eclair-1
```
``` console
I0320 14:32:38.950132       1 serving.go:386] Generated self-signed cert in-memory
W0320 14:32:44.146202       1 requestheader_controller.go:204] Unable to get configmap/extension-apiserver-authentication in kube-system.  Usually fixed by 'kubectl create rolebinding -n kube-system ROLEBINDING_NAME --role=extension-apiserver-authentication-reader --serviceaccount=YOUR_NS:YOUR_SA'
W0320 14:32:44.146228       1 authentication.go:397] Error looking up in-cluster authentication configuration: configmaps "extension-apiserver-authentication" is forbidden: User "system:kube-scheduler" cannot get resource "configmaps" in API group "" in the namespace "kube-system"
W0320 14:32:44.146241       1 authentication.go:398] Continuing without authentication configuration. This may treat all requests as anonymous.
W0320 14:32:44.146247       1 authentication.go:399] To require authentication configuration lookup to succeed, set --authentication-tolerate-lookup-failure=false
I0320 14:32:44.156934       1 server.go:166] "Starting Kubernetes Scheduler" version="v1.32.13"
I0320 14:32:44.156956       1 server.go:168] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0320 14:32:44.159726       1 configmap_cafile_content.go:205] "Starting controller" name="client-ca::kube-system::extension-apiserver-authentication::client-ca-file"
I0320 14:32:44.160227       1 secure_serving.go:213] Serving securely on [::]:10259
I0320 14:32:44.161597       1 shared_informer.go:313] Waiting for caches to sync for client-ca::kube-system::extension-apiserver-authentication::client-ca-file
I0320 14:32:44.162173       1 tlsconfig.go:243] "Starting DynamicServingCertificateController"
I0320 14:32:44.261723       1 leaderelection.go:257] attempting to acquire leader lease kube-system/kube-scheduler...
I0320 14:32:44.261838       1 shared_informer.go:320] Caches are synced for client-ca::kube-system::extension-apiserver-authentication::client-ca-file
I0320 14:33:00.793344       1 leaderelection.go:271] successfully acquired lease kube-system/kube-scheduler
E0320 14:33:58.080504       1 leaderelection.go:429] Failed to update lock optimistically: Put "https://127.0.0.1:6443/apis/coordination.k8s.io/v1/namespaces/kube-system/leases/kube-scheduler?timeout=5s": net/http: request canceled (Client.Timeout exceeded while awaiting headers), falling back to slow path
```

``` sh
ssh debian@$MASTER_HOST journalctl -u etcd
```
``` console
Starting etcd.service - etcd...
{"level":"info","ts":"2026-03-19T20:48:51.001558Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_ADVERTISE_CLIENT_URLS","variable-value":"https://192.168.122.11:2379"}
{"level":"info","ts":"2026-03-19T20:48:51.001614Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_AUTO_COMPACTION_RETENTION","variable-value":"8"}
{"level":"info","ts":"2026-03-19T20:48:51.001620Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_CERT_FILE","variable-value":"/etc/ssl/etcd/ssl/member-k8s-eclair-1.pem"}
{"level":"info","ts":"2026-03-19T20:48:51.001624Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_CLIENT_CERT_AUTH","variable-value":"true"}
{"level":"info","ts":"2026-03-19T20:48:51.001629Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_DATA_DIR","variable-value":"/var/lib/etcd"}
{"level":"info","ts":"2026-03-19T20:48:51.001633Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_ELECTION_TIMEOUT","variable-value":"5000"}
{"level":"info","ts":"2026-03-19T20:48:51.001641Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_ENABLE_V2","variable-value":"true"}
{"level":"info","ts":"2026-03-19T20:48:51.001649Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_EXPERIMENTAL_INITIAL_CORRUPT_CHECK","variable-value":"True"}
{"level":"info","ts":"2026-03-19T20:48:51.001655Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_EXPERIMENTAL_WATCH_PROGRESS_NOTIFY_INTERVAL","variable-value":"5s"}
{"level":"info","ts":"2026-03-19T20:48:51.001658Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_HEARTBEAT_INTERVAL","variable-value":"250"}
{"level":"info","ts":"2026-03-19T20:48:51.001663Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_INITIAL_ADVERTISE_PEER_URLS","variable-value":"https://192.168.122.11:2380"}
{"level":"info","ts":"2026-03-19T20:48:51.001666Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_INITIAL_CLUSTER","variable-value":"etcd1=https://192.168.122.11:2380"}
{"level":"info","ts":"2026-03-19T20:48:51.001668Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_INITIAL_CLUSTER_STATE","variable-value":"new"}
{"level":"info","ts":"2026-03-19T20:48:51.001671Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_INITIAL_CLUSTER_TOKEN","variable-value":"k8s_etcd"}
{"level":"info","ts":"2026-03-19T20:48:51.001675Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_KEY_FILE","variable-value":"/etc/ssl/etcd/ssl/member-k8s-eclair-1-key.pem"}
{"level":"info","ts":"2026-03-19T20:48:51.001685Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_LISTEN_CLIENT_URLS","variable-value":"https://192.168.122.11:2379,https://127.0.0.1:2379"}
{"level":"info","ts":"2026-03-19T20:48:51.001690Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_LISTEN_PEER_URLS","variable-value":"https://192.168.122.11:2380"}
{"level":"info","ts":"2026-03-19T20:48:51.001693Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_LOG_LEVEL","variable-value":"info"}
{"level":"info","ts":"2026-03-19T20:48:51.001696Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_MAX_REQUEST_BYTES","variable-value":"1572864"}
{"level":"info","ts":"2026-03-19T20:48:51.001699Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_MAX_SNAPSHOTS","variable-value":"5"}
{"level":"info","ts":"2026-03-19T20:48:51.001702Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_MAX_WALS","variable-value":"5"}
{"level":"info","ts":"2026-03-19T20:48:51.001704Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_METRICS","variable-value":"basic"}
{"level":"info","ts":"2026-03-19T20:48:51.001706Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_NAME","variable-value":"etcd1"}
{"level":"info","ts":"2026-03-19T20:48:51.001709Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_PEER_CERT_FILE","variable-value":"/etc/ssl/etcd/ssl/member-k8s-eclair-1.pem"}
```

``` sh
ssh debian@$MASTER_HOST journalctl -u kubelet
```
``` console
Started kubelet.service - Kubernetes Kubelet Server.
kubelet.service: Referenced but unset environment variable evaluates to an empty string: DOCKER_SOCKET, KUBELET_API_SERVER, KUBELET_NETWORK_PLUGIN, KUBELET_PORT, KUBELET_VOLUME_PLUGIN, KUBE_LOGTOSTDERR
I0319 20:49:11.693966   12292 flags.go:64] FLAG: --address="0.0.0.0"
I0319 20:49:11.694129   12292 flags.go:64] FLAG: --allowed-unsafe-sysctls="[]"
I0319 20:49:11.694137   12292 flags.go:64] FLAG: --anonymous-auth="true"
I0319 20:49:11.694140   12292 flags.go:64] FLAG: --application-metrics-count-limit="100"
I0319 20:49:11.694146   12292 flags.go:64] FLAG: --authentication-token-webhook="false"
I0319 20:49:11.694148   12292 flags.go:64] FLAG: --authentication-token-webhook-cache-ttl="2m0s"
I0319 20:49:11.694150   12292 flags.go:64] FLAG: --authorization-mode="AlwaysAllow"
I0319 20:49:11.694153   12292 flags.go:64] FLAG: --authorization-webhook-cache-authorized-ttl="5m0s"
I0319 20:49:11.694155   12292 flags.go:64] FLAG: --authorization-webhook-cache-unauthorized-ttl="30s"
I0319 20:49:11.694157   12292 flags.go:64] FLAG: --boot-id-file="/proc/sys/kernel/random/boot_id"
I0319 20:49:11.694159   12292 flags.go:64] FLAG: --bootstrap-kubeconfig="/etc/kubernetes/bootstrap-kubelet.conf"
I0319 20:49:11.694161   12292 flags.go:64] FLAG: --cert-dir="/var/lib/kubelet/pki"
I0319 20:49:11.694165   12292 flags.go:64] FLAG: --cgroup-driver="cgroupfs"
I0319 20:49:11.694167   12292 flags.go:64] FLAG: --cgroup-root=""
I0319 20:49:11.694168   12292 flags.go:64] FLAG: --cgroups-per-qos="true"
I0319 20:49:11.694170   12292 flags.go:64] FLAG: --client-ca-file=""
I0319 20:49:11.694172   12292 flags.go:64] FLAG: --cloud-config=""
I0319 20:49:11.694173   12292 flags.go:64] FLAG: --cloud-provider=""
I0319 20:49:11.694175   12292 flags.go:64] FLAG: --cluster-dns="[]"
I0319 20:49:11.694177   12292 flags.go:64] FLAG: --cluster-domain=""
I0319 20:49:11.694180   12292 flags.go:64] FLAG: --config="/etc/kubernetes/kubelet-config.yaml"
I0319 20:49:11.694182   12292 flags.go:64] FLAG: --config-dir=""
I0319 20:49:11.694184   12292 flags.go:64] FLAG: --container-hints="/etc/cadvisor/container_hints.json"
```

### 9. Cluster upgrade et – 1.34.x (master + worker)

- Cluster-i 1.32-dən 1.34-ə güncəlləmək üçün ardıcıl olaraq ortadakı bütün minor versiyalarından keçərək etmək lazımdır.
- Kubespray yalnız 2 minor versiya arası güncəlləməni dəstəkləyir.

- İlk quraşdıran vaxtı ən son kubernetes versiyası 1.34.5 idi.
  https://github.com/kubernetes-sigs/kubespray/releases/tag/v2.30.0

- Unsafe upgrade metodundan istifadə etdim, çünki cluster-da vacib iş yox idi.
  https://kubespray.io/#/docs/operations/upgrades?id=unsafe-upgrade-example

#### 9.1. Cluster playbook-unu icra et (1.33.9)

``` sh
ansible-playbook -i inventory/local-cluster -b playbooks/kubespray_cluster.yml -e kube_version=1.33.9 -e upgrade_cluster_setup=true
```

#### 9.2. Cluster playbook-unu icra et (1.34.5)

``` sh
ansible-playbook -i inventory/local-cluster -b playbooks/kubespray_cluster.yml -e kube_version=1.34.5 -e upgrade_cluster_setup=true
```

#### 9.2. Kubespray konfiqurasiyasını dəyiş

İstədiyimiz versiyaya çatdıqdan sonra versiyanı pin-ləyirik.

[k8s-cluster.yml](inventory/local-cluster/group_vars/k8s_cluster/k8s-cluster.yml)
``` diff
7d6
< kube_version: 1.32.13
---
> kube_version: 1.34.5
```

### 10. Node statusunu yoxla

``` sh
kubectl get nodes -o wide
```
``` console
NAME           STATUS   ROLES           AGE   VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION                CONTAINER-RUNTIME
k8s-eclair-1   Ready    control-plane   27h   v1.34.5   192.168.122.11   <none>        Debian GNU/Linux 13 (trixie)   6.12.74+deb13+1-cloud-amd64   containerd://2.2.2
k8s-eclair-2   Ready    <none>          10h   v1.34.5   192.168.122.12   <none>        Debian GNU/Linux 13 (trixie)   6.12.74+deb13+1-cloud-amd64   containerd://2.2.2
k8s-eclair-3   Ready    <none>          10h   v1.34.5   192.168.122.13   <none>        Debian GNU/Linux 13 (trixie)   6.12.74+deb13+1-cloud-amd64   containerd://2.2.2
```

### 11. Pod statusunu yoxla (kube-system)

``` sh
kubectl -n kube-system get pods -o wide
```
``` console
NAME                                   READY   STATUS    RESTARTS        AGE     IP               NODE           NOMINATED NODE   READINESS GATES
coredns-b89bccbf8-sq5sc                1/1     Running   0               4m54s   10.233.119.8     k8s-eclair-2   <none>           <none>
dns-autoscaler-56cb45595c-689jz        1/1     Running   1 (3h56m ago)   9h      10.233.114.71    k8s-eclair-3   <none>           <none>
kube-apiserver-k8s-eclair-1            1/1     Running   0               9m31s   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-controller-manager-k8s-eclair-1   1/1     Running   0               8m52s   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-proxy-f877j                       1/1     Running   0               5m4s    192.168.122.11   k8s-eclair-1   <none>           <none>
kube-proxy-hxpj5                       1/1     Running   0               5m4s    192.168.122.13   k8s-eclair-3   <none>           <none>
kube-proxy-sl2pt                       1/1     Running   0               5m4s    192.168.122.12   k8s-eclair-2   <none>           <none>
kube-scheduler-k8s-eclair-1            1/1     Running   0               8m40s   192.168.122.11   k8s-eclair-1   <none>           <none>
metrics-server-7cd7f9897-8n9bt         1/1     Running   6 (3h56m ago)   27h     10.233.113.41    k8s-eclair-1   <none>           <none>
nginx-proxy-k8s-eclair-2               1/1     Running   0               12m     192.168.122.12   k8s-eclair-2   <none>           <none>
nginx-proxy-k8s-eclair-3               1/1     Running   0               12m     192.168.122.13   k8s-eclair-3   <none>           <none>
nodelocaldns-blbgn                     1/1     Running   6 (3h56m ago)   27h     192.168.122.11   k8s-eclair-1   <none>           <none>
nodelocaldns-c5h76                     1/1     Running   2 (3h56m ago)   10h     192.168.122.13   k8s-eclair-3   <none>           <none>
nodelocaldns-mhrvl                     1/1     Running   2 (3h56m ago)   10h     192.168.122.12   k8s-eclair-2   <none>           <none>
```

### 12. Əsas komponentlərin loglarını çıxar

``` sh
kubectl -n kube-system logs daemonsets/kube-proxy
```
``` console
Found 3 pods, using pod/kube-proxy-hxpj5
I0321 00:17:17.943143       1 shared_informer.go:349] "Waiting for caches to sync" controller="node informer cache"
I0321 00:17:18.044029       1 shared_informer.go:356] "Caches are synced" controller="node informer cache"
I0321 00:17:18.044141       1 server.go:219] "Successfully retrieved NodeIPs" NodeIPs=["192.168.122.13"]
I0321 00:17:18.047208       1 conntrack.go:60] "Setting nf_conntrack_max" nfConntrackMax=131072
I0321 00:17:18.047310       1 server.go:265] "kube-proxy running in dual-stack mode" primary ipFamily="IPv4"
I0321 00:17:18.047388       1 server_linux.go:246] "Using nftables Proxier"
I0321 00:17:18.098445       1 server.go:527] "Version info" version="v1.34.5"
I0321 00:17:18.098532       1 server.go:529] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0321 00:17:18.100197       1 config.go:200] "Starting service config controller"
I0321 00:17:18.100207       1 shared_informer.go:349] "Waiting for caches to sync" controller="service config"
I0321 00:17:18.100279       1 config.go:309] "Starting node config controller"
I0321 00:17:18.100304       1 shared_informer.go:349] "Waiting for caches to sync" controller="node config"
I0321 00:17:18.100333       1 shared_informer.go:356] "Caches are synced" controller="node config"
I0321 00:17:18.100407       1 config.go:106] "Starting endpoint slice config controller"
I0321 00:17:18.100417       1 shared_informer.go:349] "Waiting for caches to sync" controller="endpoint slice config"
I0321 00:17:18.100427       1 config.go:403] "Starting serviceCIDR config controller"
I0321 00:17:18.100432       1 shared_informer.go:349] "Waiting for caches to sync" controller="serviceCIDR config"
I0321 00:17:18.200981       1 shared_informer.go:356] "Caches are synced" controller="service config"
I0321 00:17:18.200999       1 shared_informer.go:356] "Caches are synced" controller="serviceCIDR config"
I0321 00:17:18.201009       1 shared_informer.go:356] "Caches are synced" controller="endpoint slice config"
I0321 00:17:29.543091       1 proxier.go:1170] "Deleting stale nftables chains" ipFamily="IPv4" numChains=1
I0321 00:17:32.312018       1 proxier.go:1170] "Deleting stale nftables chains" ipFamily="IPv4" numChains=3
I0321 00:17:55.510678       1 proxier.go:1170] "Deleting stale nftables chains" ipFamily="IPv4" numChains=1
```

``` sh
kubectl -n kube-system logs kube-apiserver-k8s-eclair-1
```
``` console
Flag --apiserver-count has been deprecated, apiserver-count is deprecated and will be removed in a future version.
I0321 00:12:49.330982       1 options.go:263] external host was not specified, using 192.168.122.11
I0321 00:12:49.332578       1 server.go:150] Version: v1.34.5
I0321 00:12:49.332614       1 server.go:152] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
W0321 00:12:49.519655       1 logging.go:55] [core] [Channel #2 SubChannel #4]grpc: addrConn.createTransport failed to connect to {Addr: "192.168.122.11:2379", ServerName: "192.168.122.11:2379", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: dial tcp 192.168.122.11:2379: operation was canceled"
I0321 00:12:49.519780       1 shared_informer.go:349] "Waiting for caches to sync" controller="node_authorizer"
W0321 00:12:49.520114       1 logging.go:55] [core] [Channel #1 SubChannel #3]grpc: addrConn.createTransport failed to connect to {Addr: "192.168.122.11:2379", ServerName: "192.168.122.11:2379", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: authentication handshake failed: context canceled"
I0321 00:12:49.526613       1 shared_informer.go:349] "Waiting for caches to sync" controller="*generic.policySource[*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicy,*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicyBinding,k8s.io/apiserver/pkg/admission/plugin/policy/validating.Validator]"
...
```

``` sh
kubectl -n kube-system logs kube-controller-manager-k8s-eclair-1
```
``` console
I0321 00:13:29.767964       1 serving.go:386] Generated self-signed cert in-memory
I0321 00:13:30.093352       1 controllermanager.go:191] "Starting" version="v1.34.5"
I0321 00:13:30.093366       1 controllermanager.go:193] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0321 00:13:30.094181       1 dynamic_cafile_content.go:161] "Starting controller" name="request-header::/etc/kubernetes/ssl/front-proxy-ca.crt"
I0321 00:13:30.094220       1 dynamic_cafile_content.go:161] "Starting controller" name="client-ca-bundle::/etc/kubernetes/ssl/ca.crt"
I0321 00:13:30.094702       1 secure_serving.go:211] Serving securely on [::]:10257
I0321 00:13:30.094902       1 tlsconfig.go:243] "Starting DynamicServingCertificateController"
I0321 00:13:30.094886       1 leaderelection.go:257] attempting to acquire leader lease kube-system/kube-controller-manager...
I0321 00:13:47.046870       1 leaderelection.go:271] successfully acquired lease kube-system/kube-controller-manager
I0321 00:13:47.047025       1 event.go:389] "Event occurred" object="kube-system/kube-controller-manager" fieldPath="" kind="Lease" apiVersion="coordination.k8s.io/v1" type="Normal" reason="LeaderElection" message="k8s-eclair-1_9ddae4e3-712d-4ed0-b16c-206e9cd152e4 became leader"
I0321 00:13:47.049371       1 controllermanager.go:781] "Started controller" controller="serviceaccount-token-controller"
I0321 00:13:47.049688       1 shared_informer.go:349] "Waiting for caches to sync" controller="tokens"
I0321 00:13:47.051581       1 certificate_controller.go:120] "Starting certificate controller" logger="certificatesigningrequest-signing-controller" name="csrsigning-kubelet-serving"
I0321 00:13:47.051590       1 shared_informer.go:349] "Waiting for caches to sync" controller="certificate-csrsigning-kubelet-serving"
I0321 00:13:47.051598       1 dynamic_serving_content.go:135] "Starting controller" name="csr-controller::/etc/kubernetes/ssl/ca.crt::/etc/kubernetes/ssl/ca.key"
...
```

``` sh
kubectl -n kube-system logs kube-scheduler-k8s-eclair-1
```
``` console
I0321 00:13:41.597708       1 serving.go:386] Generated self-signed cert in-memory
I0321 00:13:41.880368       1 server.go:175] "Starting Kubernetes Scheduler" version="v1.34.5"
I0321 00:13:41.880383       1 server.go:177] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0321 00:13:41.882639       1 secure_serving.go:211] Serving securely on [::]:10259
I0321 00:13:41.882682       1 requestheader_controller.go:180] Starting RequestHeaderAuthRequestController
I0321 00:13:41.883287       1 configmap_cafile_content.go:205] "Starting controller" name="client-ca::kube-system::extension-apiserver-authentication::client-ca-file"
I0321 00:13:41.883299       1 shared_informer.go:349] "Waiting for caches to sync" controller="client-ca::kube-system::extension-apiserver-authentication::client-ca-file"
I0321 00:13:41.883309       1 tlsconfig.go:243] "Starting DynamicServingCertificateController"
I0321 00:13:41.883810       1 configmap_cafile_content.go:205] "Starting controller" name="client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file"
I0321 00:13:41.883815       1 shared_informer.go:349] "Waiting for caches to sync" controller="RequestHeaderAuthRequestController"
I0321 00:13:41.883818       1 shared_informer.go:349] "Waiting for caches to sync" controller="client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file"
I0321 00:13:41.983184       1 leaderelection.go:257] attempting to acquire leader lease kube-system/kube-scheduler...
I0321 00:13:41.983392       1 shared_informer.go:356] "Caches are synced" controller="client-ca::kube-system::extension-apiserver-authentication::client-ca-file"
I0321 00:13:41.983902       1 shared_informer.go:356] "Caches are synced" controller="RequestHeaderAuthRequestController"
I0321 00:13:41.984267       1 shared_informer.go:356] "Caches are synced" controller="client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file"
```

```

``` sh
ssh debian@$MASTER_HOST journalctl -u etcd
```
``` console
Starting etcd.service - etcd...
{"level":"info","ts":"2026-03-19T20:48:51.001558Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_ADVERTISE_CLIENT_URLS","variable-value":"https://192.168.122.11:2379"}
{"level":"info","ts":"2026-03-19T20:48:51.001614Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_AUTO_COMPACTION_RETENTION","variable-value":"8"}
{"level":"info","ts":"2026-03-19T20:48:51.001620Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_CERT_FILE","variable-value":"/etc/ssl/etcd/ssl/member-k8s-eclair-1.pem"}
{"level":"info","ts":"2026-03-19T20:48:51.001624Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_CLIENT_CERT_AUTH","variable-value":"true"}
{"level":"info","ts":"2026-03-19T20:48:51.001629Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_DATA_DIR","variable-value":"/var/lib/etcd"}
{"level":"info","ts":"2026-03-19T20:48:51.001633Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_ELECTION_TIMEOUT","variable-value":"5000"}
{"level":"info","ts":"2026-03-19T20:48:51.001641Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_ENABLE_V2","variable-value":"true"}
{"level":"info","ts":"2026-03-19T20:48:51.001649Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_EXPERIMENTAL_INITIAL_CORRUPT_CHECK","variable-value":"True"}
{"level":"info","ts":"2026-03-19T20:48:51.001655Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_EXPERIMENTAL_WATCH_PROGRESS_NOTIFY_INTERVAL","variable-value":"5s"}
{"level":"info","ts":"2026-03-19T20:48:51.001658Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_HEARTBEAT_INTERVAL","variable-value":"250"}
{"level":"info","ts":"2026-03-19T20:48:51.001663Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_INITIAL_ADVERTISE_PEER_URLS","variable-value":"https://192.168.122.11:2380"}
{"level":"info","ts":"2026-03-19T20:48:51.001666Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_INITIAL_CLUSTER","variable-value":"etcd1=https://192.168.122.11:2380"}
{"level":"info","ts":"2026-03-19T20:48:51.001668Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_INITIAL_CLUSTER_STATE","variable-value":"new"}
{"level":"info","ts":"2026-03-19T20:48:51.001671Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_INITIAL_CLUSTER_TOKEN","variable-value":"k8s_etcd"}
{"level":"info","ts":"2026-03-19T20:48:51.001675Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_KEY_FILE","variable-value":"/etc/ssl/etcd/ssl/member-k8s-eclair-1-key.pem"}
{"level":"info","ts":"2026-03-19T20:48:51.001685Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_LISTEN_CLIENT_URLS","variable-value":"https://192.168.122.11:2379,https://127.0.0.1:2379"}
{"level":"info","ts":"2026-03-19T20:48:51.001690Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_LISTEN_PEER_URLS","variable-value":"https://192.168.122.11:2380"}
{"level":"info","ts":"2026-03-19T20:48:51.001693Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_LOG_LEVEL","variable-value":"info"}
{"level":"info","ts":"2026-03-19T20:48:51.001696Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_MAX_REQUEST_BYTES","variable-value":"1572864"}
{"level":"info","ts":"2026-03-19T20:48:51.001699Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_MAX_SNAPSHOTS","variable-value":"5"}
{"level":"info","ts":"2026-03-19T20:48:51.001702Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_MAX_WALS","variable-value":"5"}
{"level":"info","ts":"2026-03-19T20:48:51.001704Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_METRICS","variable-value":"basic"}
{"level":"info","ts":"2026-03-19T20:48:51.001706Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_NAME","variable-value":"etcd1"}
{"level":"info","ts":"2026-03-19T20:48:51.001709Z","caller":"flags/flag.go:113","msg":"recognized and used environment variable","variable-name":"ETCD_PEER_CERT_FILE","variable-value":"/etc/ssl/etcd/ssl/member-k8s-eclair-1.pem"}
```

``` sh
ssh debian@$MASTER_HOST journalctl -u kubelet
```
``` console
Started kubelet.service - Kubernetes Kubelet Server.
kubelet.service: Referenced but unset environment variable evaluates to an empty string: DOCKER_SOCKET, KUBELET_API_SERVER, KUBELET_NETWORK_PLUGIN, KUBELET_PORT, KUBELET_VOLUME_PLUGIN, KUBE_LOGTOSTDERR
I0319 20:49:11.693966   12292 flags.go:64] FLAG: --address="0.0.0.0"
I0319 20:49:11.694129   12292 flags.go:64] FLAG: --allowed-unsafe-sysctls="[]"
I0319 20:49:11.694137   12292 flags.go:64] FLAG: --anonymous-auth="true"
I0319 20:49:11.694140   12292 flags.go:64] FLAG: --application-metrics-count-limit="100"
I0319 20:49:11.694146   12292 flags.go:64] FLAG: --authentication-token-webhook="false"
I0319 20:49:11.694148   12292 flags.go:64] FLAG: --authentication-token-webhook-cache-ttl="2m0s"
I0319 20:49:11.694150   12292 flags.go:64] FLAG: --authorization-mode="AlwaysAllow"
I0319 20:49:11.694153   12292 flags.go:64] FLAG: --authorization-webhook-cache-authorized-ttl="5m0s"
I0319 20:49:11.694155   12292 flags.go:64] FLAG: --authorization-webhook-cache-unauthorized-ttl="30s"
I0319 20:49:11.694157   12292 flags.go:64] FLAG: --boot-id-file="/proc/sys/kernel/random/boot_id"
I0319 20:49:11.694159   12292 flags.go:64] FLAG: --bootstrap-kubeconfig="/etc/kubernetes/bootstrap-kubelet.conf"
I0319 20:49:11.694161   12292 flags.go:64] FLAG: --cert-dir="/var/lib/kubelet/pki"
I0319 20:49:11.694165   12292 flags.go:64] FLAG: --cgroup-driver="cgroupfs"
I0319 20:49:11.694167   12292 flags.go:64] FLAG: --cgroup-root=""
I0319 20:49:11.694168   12292 flags.go:64] FLAG: --cgroups-per-qos="true"
I0319 20:49:11.694170   12292 flags.go:64] FLAG: --client-ca-file=""
I0319 20:49:11.694172   12292 flags.go:64] FLAG: --cloud-config=""
I0319 20:49:11.694173   12292 flags.go:64] FLAG: --cloud-provider=""
I0319 20:49:11.694175   12292 flags.go:64] FLAG: --cluster-dns="[]"
I0319 20:49:11.694177   12292 flags.go:64] FLAG: --cluster-domain=""
I0319 20:49:11.694180   12292 flags.go:64] FLAG: --config="/etc/kubernetes/kubelet-config.yaml"
I0319 20:49:11.694182   12292 flags.go:64] FLAG: --config-dir=""
I0319 20:49:11.694184   12292 flags.go:64] FLAG: --container-hints="/etc/cadvisor/container_hints.json"
```

### 13. Hər addımın ekran görüntüsünü və loglarını paylaş

<img src="https://media1.tenor.com/m/MpC76hQbFOkAAAAd/thumbsup.gif" width="15%" heigth="15%" />

### 14. Final cluster statusunu paylaş

``` sh
kubectl cluster-info
```
``` console
Kubernetes control plane is running at https://192.168.122.11:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

``` sh
kubectl get nodes -o wide
```
``` console
NAME           STATUS   ROLES           AGE   VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION                CONTAINER-RUNTIME
k8s-eclair-1   Ready    control-plane   27h   v1.34.5   192.168.122.11   <none>        Debian GNU/Linux 13 (trixie)   6.12.74+deb13+1-cloud-amd64   containerd://2.2.2
k8s-eclair-2   Ready    <none>          10h   v1.34.5   192.168.122.12   <none>        Debian GNU/Linux 13 (trixie)   6.12.74+deb13+1-cloud-amd64   containerd://2.2.2
k8s-eclair-3   Ready    <none>          10h   v1.34.5   192.168.122.13   <none>        Debian GNU/Linux 13 (trixie)   6.12.74+deb13+1-cloud-amd64   containerd://2.2.2
```

``` sh
kubectl get pods -A -o wide
```
``` console
NAMESPACE          NAME                                       READY   STATUS      RESTARTS        AGE   IP               NODE           NOMINATED NODE   READINESS GATES
calico-apiserver   calico-apiserver-55669d89ff-ljv7f          1/1     Running     4 (4h10m ago)   25h   10.233.113.45    k8s-eclair-1   <none>           <none>
calico-apiserver   calico-apiserver-55669d89ff-nhxgk          1/1     Running     4 (4h10m ago)   26h   10.233.113.42    k8s-eclair-1   <none>           <none>
calico-system      calico-kube-controllers-6fd986d966-rpbvd   1/1     Running     4 (4h10m ago)   26h   10.233.113.44    k8s-eclair-1   <none>           <none>
calico-system      calico-node-dm7hx                          1/1     Running     2 (4h10m ago)   10h   192.168.122.13   k8s-eclair-3   <none>           <none>
calico-system      calico-node-hnz46                          1/1     Running     2 (4h10m ago)   10h   192.168.122.12   k8s-eclair-2   <none>           <none>
calico-system      calico-node-j6snb                          1/1     Running     4 (4h10m ago)   26h   192.168.122.11   k8s-eclair-1   <none>           <none>
calico-system      calico-typha-688d88c6dc-hbk4v              1/1     Running     4 (4h10m ago)   26h   192.168.122.11   k8s-eclair-1   <none>           <none>
calico-system      calico-typha-688d88c6dc-l8lvn              1/1     Running     3 (4h10m ago)   10h   192.168.122.12   k8s-eclair-2   <none>           <none>
calico-system      csi-node-driver-t8xxf                      2/2     Running     4 (4h10m ago)   10h   10.233.114.72    k8s-eclair-3   <none>           <none>
calico-system      csi-node-driver-x7zmw                      2/2     Running     8 (4h10m ago)   26h   10.233.113.46    k8s-eclair-1   <none>           <none>
calico-system      csi-node-driver-xctjg                      2/2     Running     4 (4h10m ago)   10h   10.233.119.7     k8s-eclair-2   <none>           <none>
kube-system        coredns-b89bccbf8-sq5sc                    1/1     Running     0               19m   10.233.119.8     k8s-eclair-2   <none>           <none>
kube-system        dns-autoscaler-56cb45595c-689jz            1/1     Running     1 (4h10m ago)   9h    10.233.114.71    k8s-eclair-3   <none>           <none>
kube-system        kube-apiserver-k8s-eclair-1                1/1     Running     0               23m   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-system        kube-controller-manager-k8s-eclair-1       1/1     Running     0               23m   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-system        kube-proxy-f877j                           1/1     Running     0               19m   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-system        kube-proxy-hxpj5                           1/1     Running     0               19m   192.168.122.13   k8s-eclair-3   <none>           <none>
kube-system        kube-proxy-sl2pt                           1/1     Running     0               19m   192.168.122.12   k8s-eclair-2   <none>           <none>
kube-system        kube-scheduler-k8s-eclair-1                1/1     Running     0               22m   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-system        metrics-server-7cd7f9897-8n9bt             1/1     Running     6 (4h10m ago)   27h   10.233.113.41    k8s-eclair-1   <none>           <none>
kube-system        nginx-proxy-k8s-eclair-2                   1/1     Running     0               26m   192.168.122.12   k8s-eclair-2   <none>           <none>
kube-system        nginx-proxy-k8s-eclair-3                   1/1     Running     0               26m   192.168.122.13   k8s-eclair-3   <none>           <none>
kube-system        nodelocaldns-blbgn                         1/1     Running     6 (4h10m ago)   27h   192.168.122.11   k8s-eclair-1   <none>           <none>
kube-system        nodelocaldns-c5h76                         1/1     Running     2 (4h10m ago)   10h   192.168.122.13   k8s-eclair-3   <none>           <none>
kube-system        nodelocaldns-mhrvl                         1/1     Running     2 (4h10m ago)   10h   192.168.122.12   k8s-eclair-2   <none>           <none>
metallb-system     controller-576fddb64d-brptc                1/1     Running     2 (4h10m ago)   27h   10.233.119.6     k8s-eclair-2   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-24z4t            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-6bpbp            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-6t5g6            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-ctrn8            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-fr5jw            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-jg796            1/1     Running     8 (24m ago)     25h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-lfl5s            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-m68dn            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-mmxrs            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-pgjst            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-pm6w7            0/1     Completed   1 (26h ago)     26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-qxgpz            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-vg4km            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-vvwg4            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-w6mlh            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
tigera-operator    tigera-operator-d77bd6f45-whfv2            0/1     Completed   0               26h   192.168.122.11   k8s-eclair-1   <none>           <none>
```

``` sh
kubectl get tigerastatus
```
``` console
NAME        AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver   True        False         False      26m
calico      True        False         False      120m
ippools     True        False         False      25h
```

``` sh
kubectl get svc -A -o wide
```
``` console
NAMESPACE          NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE   SELECTOR
calico-apiserver   calico-api                        ClusterIP   10.233.2.79     <none>        443/TCP                  26h   apiserver=true
calico-system      calico-kube-controllers-metrics   ClusterIP   None            <none>        9094/TCP                 26h   k8s-app=calico-kube-controllers
calico-system      calico-typha                      ClusterIP   10.233.36.164   <none>        5473/TCP                 26h   k8s-app=calico-typha
default            kubernetes                        ClusterIP   10.233.0.1      <none>        443/TCP                  27h   <none>
kube-system        coredns                           ClusterIP   10.233.0.3      <none>        53/UDP,53/TCP,9153/TCP   27h   k8s-app=kube-dns
kube-system        metrics-server                    ClusterIP   10.233.17.118   <none>        443/TCP                  27h   app.kubernetes.io/name=metrics-server
metallb-system     webhook-service                   ClusterIP   10.233.7.94     <none>        443/TCP                  27h   component=controller
```

### 15. (ƏLAVƏ) Calico-nu güncəllə

https://docs.tigera.io/calico/latest/operations/upgrading/kubernetes-upgrade#upgrading-an-installation-that-uses-the-operator

#### 15.1. Tigera Operator və custom CRD-lərini yüklə

``` sh
curl https://raw.githubusercontent.com/projectcalico/calico/v3.31.4/manifests/operator-crds.yaml -O
curl https://raw.githubusercontent.com/projectcalico/calico/v3.31.4/manifests/tigera-operator.yaml -O
```

#### 15.2. Güncəlləməni başlat

``` sh
kubectl apply --server-side --force-conflicts -f operator-crds.yaml
kubectl apply --server-side --force-conflicts -f tigera-operator.yaml
```

#### 15.3. Flow logs və Calico Whisker-i quraşdır

3.30-də gətirilmiş yeni xüsusiyyətlərdir.

``` sh
kubectl apply -f - <<EOF
apiVersion: operator.tigera.io/v1
kind: Goldmane
metadata:
  name: default
---
apiVersion: operator.tigera.io/v1
kind: Whisker
metadata:
  name: default
EOF
```

#### 15.4. Calico available olana qədər gözlə

Bir müddət sonra.
``` sh
kubectl get tigerastatus -w
```
``` console
NAME        AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver   True        False         False      9m31s
calico      True        False         False      6m51s
goldmane    True        False         False      10m
ippools     True        False         False      26h
whisker     True        False         False      9m31s
```

Calico v3.31.4
``` sh
kubectl get clusterinfo -o yaml
```
``` console
apiVersion: v1
items:
- apiVersion: projectcalico.org/v3
  kind: ClusterInformation
  metadata:
    creationTimestamp: "2026-03-19T22:00:34Z"
    name: default
    resourceVersion: "147784"
    uid: 346ebdc1-edd2-4c8e-847b-6e22288cc191
  spec:
    calicoVersion: v3.31.4
    clusterGUID: b941113458ad4e28994dedfa4556e6bb
    clusterType: typha,kdd,k8s,operator,bgp,kubeadm
    datastoreReady: true
kind: List
metadata:
  resourceVersion: ""
```

