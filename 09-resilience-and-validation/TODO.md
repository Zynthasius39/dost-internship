# Dayanıqlılıq və Yoxlama (Resilience & validation)
Yekun mərhələdə Helm Hook vasitəsilə deploy-sonrası testlərin aparılması, bilərəkdən səhv konfiqurasiya edilərək rollback (geri qaytarma) mexanizmlərinin sınanması və git push addımından ArgoCD sinxronizasiyasına qədər bütün axının validation-ı həyata keçirilir.

## Mühit
* Kubernetes cluster
* ArgoCD UI / CLI
* Git Repository

## Task addımları
1. `templates/post-install-test.yaml` adlı Helm hook manifesti yaradın.
2. Manifest daxilində annotations bölməsini təyin edin: `helm.sh/hook: post-install,post-upgrade` və `helm.sh/hook-delete-policy: hook-succeeded`.
3. Hook container-i daxilində tətbiqin sağlamlığını yoxlayan `curl -sf http://myapp/health || exit 1` skriptini işlədin.
4. Deployment icra edildikdən sonra hook pod-unun uğurla işlədiyini və tamamlandığını yoxlayın.
5. `values-prod.yaml` faylına qəsdən mövcud olmayan səhv bir imic teqi (image tag) yazın, commit edin və repoya push edin.
6. ArgoCD-nin bu dəyişikliyi sinxronizasiya (sync) etdiyini və pod-ların `ImagePullBackOff` və ya `CrashLoopBackOff` vəziyyətinə düşdüyünü klasterdə müşahidə edin.
7. ArgoCD UI vasitəsilə tətbiqi dərhal əvvəlki stabil revision-a rollback (geri) edin.
8. Klasterdə `helm history myapp-prod -n myapp-prod` əmrini işlədərək release tarixçəsini və dəyişiklikləri yoxlayın.
9. Tətbiqin `/health` endpoint-inə sorğu ataraq sistemin yenidən tam işlək vəziyyətə qayıtdığını təsdiqləyin.
