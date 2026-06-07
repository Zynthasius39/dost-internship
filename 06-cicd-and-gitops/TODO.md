## Task addımları
1. `.github/workflows/ci.yaml` faylını yaradın.
2. Workflow daxilində **Job 1 (lint-and-test)** qurun: `helm lint` yoxlamasını icra etsin.
3. **Job 2 (build-and-push)** qurun (yalnız main branch-da və job 1 uğurla keçərsə): imici build edin və GitHub Container Registry-ə (GHCR) push edin. Teq olaraq `latest` + `sha-${{ github.sha }}` istifadə edin.
4. **Job 3 (update-chart)** qurun (job 2 bitdikdən sonra): `values-prod.yaml` faylındakı `image.tag` dəyərini yeni SHA ilə dəyişdirin, commitsiz dövrə girməmək üçün `[skip ci]` ifadəsi ilə commit edib repozitoriyaya geri push edin.
5. GHCR tokenini GitHub Secrets-ə əlavə edin və workflow daxilində `secrets.GITHUB_TOKEN` vasitəsilə istifadə edin.
6. Pipeline status badge-ini `README.md` faylına əlavə edin.
7. ArgoCD-ni Kubernetes klasterinə qurun.
8. ArgoCD UI-a daxil olun və default admin şifrəsini dəyişdirin.
9. `argocd/apps/dev-app.yaml` manifestini yazın — `source: helm/gopher`, `valueFiles: [values.yaml, values-dev.yaml]`, `namespace: gopher-dev`, `syncPolicy: automated + selfHeal + prune`.
10. `argocd/apps/prod-app.yaml` manifestini yazın — eyni struktur ilə, fərqli olaraq `values-prod.yaml` və `namespace: gopher-prod` istifadə edin.
11. `argocd/root-app.yaml` manifestini yazın (App-of-Apps modeli) və `argocd/apps/` qovluğunu hədəf göstərin.
12. Klasterdə yalnız `kubectl apply -f argocd/root-app.yaml` əmrini icra edin; qalan bütün resursların idarəçiliyini ArgoCD-yə buraxın.
