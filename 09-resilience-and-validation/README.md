# Dayanıqlılıq və Yoxlama (Resilience & validation)
Yekun mərhələdə Helm Hook vasitəsilə deploy-sonrası testlərin aparılması, bilərəkdən səhv konfiqurasiya edilərək rollback (geri qaytarma) mexanizmlərinin sınanması və git push addımından ArgoCD sinxronizasiyasına qədər bütün axının validation-ı həyata keçirilir.

## Mühit
* Kubernetes cluster
* ArgoCD UI
* Git Repository

## Task addımları
### 1. `templates/post-install-test.yaml` adlı Helm hook manifesti yaradın.

[post-install-test.yaml](../deploy/helm/gopher/templates/post-install-test.yaml)
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}"
  labels:
    app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
    app.kubernetes.io/instance: {{ .Release.Name | quote }}
    app.kubernetes.io/version: {{ .Chart.AppVersion }}
    helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
spec:
  template:
    metadata:
      name: "{{ .Release.Name }}"
      labels:
        app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
        app.kubernetes.io/instance: {{ .Release.Name | quote }}
        helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
```

### 2. Manifest daxilində annotations bölməsini təyin edin: `helm.sh/hook: post-install,post-upgrade` və `helm.sh/hook-delete-policy: hook-succeeded`.

```diff
@@ -7,6 +7,10 @@ metadata:
     app.kubernetes.io/instance: {{ .Release.Name | quote }}
     app.kubernetes.io/version: {{ .Chart.AppVersion }}
     helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
+  annotations:
+    helm.sh/hook: post-install,post-upgrade
+    helm.sh/hook-weight: "-5"
+    helm.sh/hook-delete-policy: hook-succeeded
 spec:
   template:
     metadata:
```

### 3. Hook container-i daxilində tətbiqin sağlamlığını yoxlayan `curl -sf http://gopher/health || exit 1` skriptini işlədin.

```diff
@@ -19,3 +19,11 @@ spec:
         app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
         app.kubernetes.io/instance: {{ .Release.Name | quote }}
         helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
+    spec:
+      restartPolicy: Never
+      containers:
+      - name: post-install-job
+        image: docker.io/library/busybox:1.38.0
+        command: ["/bin/sh", "-c"]
+        args:
+          - "wget -qO - http://{{ include "gopher.fullname" . }}:{{ .Values.service.port }}/health || exit 1"
```

### 4. Deployment icra edildikdən sonra hook pod-unun uğurla işlədiyini və tamamlandığını yoxlayın.

```sh
kubectl -n gopher-prod get pods
```
```console
NAME                          READY   STATUS      RESTARTS   AGE
pod/gopher-7bfc66fc85-4ck2f   1/1     Running     0          21m
pod/gopher-zqkzj              0/1     Completed   0          3s
```

### 5. `values-prod.yaml` faylına qəsdən mövcud olmayan səhv bir imic teqi (image tag) yazın, commit edin və repoya push edin.

```diff
@@ -15,4 +15,4 @@ alertmanagerConfig:
   enabled: true
 replicaCount: 3
 image:
-  tag: sha-77f70f65ea9107b8884b89f77b09a0f5712680c9
+  tag: 1.0.1
```

### 6. ArgoCD-nin bu dəyişikliyi sinxronizasiya (sync) etdiyini və pod-ların `ImagePullBackOff` və ya `CrashLoopBackOff` vəziyyətinə düşdüyünü klasterdə müşahidə edin.

![](<img/Screen Shot 2026-06-12 at 01.40.26.png>)

```console
NAME                           READY   STATUS             RESTARTS   AGE
gopher-prod-754fdfcd74-h5jwl   0/1     ImagePullBackOff   0          28s
gopher-prod-7c4c6d6b9d-kxfck   1/1     Running            0          7h56m
```

### 7. ArgoCD UI vasitəsilə tətbiqi dərhal əvvəlki stabil revision-a rollback (geri) edin.

![](<img/Screen Shot 2026-06-12 at 01.42.16.png>)
![](<img/Screen Shot 2026-06-12 at 01.45.04.png>)

### 8. Klasterdə `helm history gopher-prod -n gopher-prod` əmrini işlədərək release tarixçəsini və dəyişiklikləri yoxlayın.

`gopher-prod` namespace-indəki gopher deployment-i ArgoCD ilə quraşdırıldığı üçün `helm -n gopher-prod history` komandası ilə onu görmək mümkün deyil. Default namespace-də quraşdırılmış başqa deployment belə görünür:

```sh
helm history gopher
```
```console
REVISION  UPDATED                   STATUS      CHART         APP VERSION  DESCRIPTION                                                                                                                      
1         Fri Jun 12 00:44:27 2026  superseded  gopher-1.0.0  1.0.0        Release "gopher" failed: failed post-install: resource Job/default/gopher not ready. status: InProgress, message: Job in progr...
2         Fri Jun 12 00:50:50 2026  superseded  gopher-1.0.0  1.0.0        Upgrade complete                                                                                                                 
3         Fri Jun 12 00:54:28 2026  superseded  gopher-1.0.0  1.0.0        Upgrade complete                                                                                                                 
4         Fri Jun 12 00:54:51 2026  superseded  gopher-1.0.0  1.0.0        Upgrade complete                                                                                                                 
5         Fri Jun 12 00:57:35 2026  failed      gopher-1.0.0  1.0.0        Upgrade "gopher" failed: context canceled                                                                                        
6         Fri Jun 12 01:02:40 2026  superseded  gopher-1.0.0  1.0.0        Upgrade complete                                                                                                                 
7         Fri Jun 12 01:03:56 2026  superseded  gopher-1.0.0  1.0.0        Upgrade complete                                                                                                                 
8         Fri Jun 12 01:05:34 2026  superseded  gopher-1.0.0  1.0.0        Upgrade complete                                                                                                                 
9         Fri Jun 12 01:05:42 2026  superseded  gopher-1.0.0  1.0.0        Upgrade complete                                                                                                                 
10        Fri Jun 12 01:05:50 2026  deployed    gopher-1.0.0  1.0.0        Upgrade complete                                                                                                                 
```

### 9. Tətbiqin `/health` endpoint-inə sorğu ataraq sistemin yenidən tam işlək vəziyyətə qayıtdığını təsdiqləyin.

```sh
curl -s http://gopher.naquadah.alak/health
```
```console
{"status":"healthy"}
```
