# CI/CD & GitOps
Bu mərhələdə GitHub Actions vasitəsilə tətbiqin avtomatik test edilməsi, imicin GHCR-ə push olunması, GitOps manifestlərinin yenilənməsi və ArgoCD App-of-Apps modeli ilə mühitlərin avtomatik sinxronizasiyası qurulur.

## Mühit
- Kubernetes cluster
- ArgoCD
- GitHub repository (packages enabled)

## Task addımları

### 1. `.github/workflows/ci.yaml` faylını yaradın.

#### 1.1. Workflow faylını və qovluğunu yaradın

```sh
mkdir -p .github/workflows
touch .github/workflows/ci.yaml
```

#### 1.2. Applikasiya spesifik dəyişəni repozitoriyaya əlavə edin

[New variable](https://github.com/Zynthasius39/dost-internship/settings/variables/actions/new)
```
Name: APP_NAME
Value: gopher
```

### 2. Workflow daxilində **Job 1 (lint-and-test)** qurun: `helm lint` yoxlamasını icra etsin.

```diff
+name: App & Chart Integration Pipeline
+
+on:
+  push:
+    branches: [ $default-branch ]
+  pull_request:
+    branches: [ $default-branch ]
+
+jobs:
+  helm-lint:
+    runs-on: ubuntu-latest
+    steps:
+      - name: Checkout code
+        uses: actions/checkout@v6
+
+      - name: Install helm
+        uses: azure/setup-helm@v5
+        id: install
+
+      - name: Lint Code Base
+        run: helm lint deploy/helm/gopher
```

### 3. **Job 2 (build-and-push)** qurun (yalnız main branch-da və job 1 uğurla keçərsə): imici build edin və GitHub Container Registry-ə (GHCR) push edin. Teq olaraq `latest` + `sha-${{ github.sha }}` istifadə edin.
### 5. GHCR tokenini GitHub Secrets-ə əlavə edin və workflow daxilində `secrets.GITHUB_TOKEN` vasitəsilə istifadə edin.

```diff
@@ -19,3 +19,37 @@
jobs:

+  build-image:
+    runs-on: ubuntu-latest
+    needs: helm-lint
+    permissions:
+      packages: write
+    steps:
+      - name: Checkout code
+        uses: actions/checkout@v6
+
+      - name: Log in to the Container registry
+        uses: docker/login-action@v4
+        with:
+          registry: ghcr.io
+          username: ${{ github.actor }}
+          password: ${{ secrets.GITHUB_TOKEN }}
+
+      - name: Extract Docker metadata
+        id: meta
+        uses: docker/metadata-action@v6
+        with:
+          images: ghcr.io/${{ github.actor }}/${{ vars.APP_NAME }}
+          tags: |
+            type=raw,value=latest
+            type=sha,format=long
+
+      - name: Build and push Docker image
+        id: push
+        uses: docker/build-push-action@v7
+        with:
+          context: src/${{ vars.APP_NAME }}
+          push: true
+          tags: ${{ steps.meta.outputs.tags }}
+          labels: ${{ steps.meta.outputs.labels }}
```

### 4. **Job 3 (update-chart)** qurun (job 2 bitdikdən sonra): `values-prod.yaml` faylındakı `image.tag` dəyərini yeni SHA ilə dəyişdirin, commitsiz dövrə girməmək üçün `[skip ci]` ifadəsi ilə commit edib repozitoriyaya geri push edin.

```diff
@@ -52,3 +52,24 @@ jobs:
           push: true
           tags: ${{ steps.meta.outputs.tags }}
           labels: ${{ steps.meta.outputs.labels }}
+
+  update-chart:
+    runs-on: ubuntu-latest
+    needs: build-image
+    permissions:
+      contents: write
+    steps:
+      - name: Checkout code
+        uses: actions/checkout@v6
+
+      - name: Update Image Tag in values-prod.yaml
+        run: yq -i '.image.tag = "sha-${{ github.sha }}"' deploy/helm/${{ vars.APP_NAME }}/values-prod.yaml
+
+      - name: Commit and Push Changes
+        run: |
+          git config --global user.name "github-actions[bot]"
+          git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
+          
+          git add deploy/helm/${{ vars.APP_NAME }}/values-prod.yaml
+          git commit -m "chore(ci): bump image tag to sha-${{ github.sha }} [skip ci]"
+          git push origin "$GITHUB_REF_NAME"
```

### 6. Pipeline status badge-ini `README.md` faylına əlavə edin.

#### 6.1. GitHub-da repozitoriyanın **Actions** səhifəsinə keçid edin.

#### 6.2. Sol paneldə yaratdığımız workflow-u seçin.

#### 6.3. Səhifənin sağ tərəfində, "Filter workflow runs" sahəsinin yanında açılan menyunu klikləyib **Create status badge** seçin.

#### 6.4. **Copy status badge Markdown** düyməsini klikləyin və markdown-u `README.md` faylına əlavə edin.

```diff
@@ -1,5 +1,7 @@
 # DOST Internship
 
+[![App & Chart Integration Pipeline](https://github.com/Zynthasius39/dost-internship/actions/workflows/ci.yaml/badge.svg)](https://github.com/Zynthasius39/dost-internship/actions/workflows/ci.yaml)
+
```

### 7. ArgoCD-ni Kubernetes klasterinə qurun.

### 8. ArgoCD UI-a daxil olun və default admin şifrəsini dəyişdirin.

### 9. `argocd/apps/dev-app.yaml` manifestini yazın — `source: helm/gopher`, `valueFiles: [values.yaml, values-dev.yaml]`, `namespace: gopher-dev`, `syncPolicy: automated + selfHeal + prune`.

### 10. `argocd/apps/prod-app.yaml` manifestini yazın — eyni struktur ilə, fərqli olaraq `values-prod.yaml` və `namespace: gopher-prod` istifadə edin.

### 11. `argocd/root-app.yaml` manifestini yazın (App-of-Apps modeli) və `argocd/apps/` qovluğunu hədəf göstərin.

### 12. Klasterdə yalnız `kubectl apply -f argocd/root-app.yaml` əmrini icra edin; qalan bütün resursların idarəçiliyini ArgoCD-yə buraxın.

