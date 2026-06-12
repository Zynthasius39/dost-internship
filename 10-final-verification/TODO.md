## Task addımları
1. Repozitoriyanın strukturunun tam olaraq bu şəkildə olduğunu yoxlayın:
   ├── app/
   ├── helm/gopher/
   ├── argocd/
   └── .github/workflows/
2. `README.md` faylında layihənin sıfırdan qurulması və ayağa qaldırılması addımlarının tam, aydın şəkildə yazıldığından əmin olun.
3. Repozitoriyada heç bir gizli məlumatın (secret, token, şifrə) plain-text (açıq mətn) formasında qalmadığını yoxlayın.
4. Kodun repozitoriyaya `git push` olunmasından başlayaraq ArgoCD-nin mühiti tam sinxronizasiya etməsinə qədər olan bütün CI/CD və GitOps axınını bir dəfə canlı olaraq demo/test edin.
5. Prometheus monitorinqinin işlədiyini və bütün metrikaların Grafana panellərində data göstərdiyini, dashboard JSON faylının repoda mövcudluğunu son dəfə təsdiqləyin.
