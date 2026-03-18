# Kubernetes Cluster

## Mühit:
- 1 Master Node, 2 Worker Node
- İlk versiya: 1.32.x (Network Plugin: Calico 3.29 (Operator ilə))
- Upgrade versiya: 1.34.x

## Task Addımları
1. Node-larin hazirla
2. Master node-da cluster qaldır (1.32.x).
3. Kubectl konfiqurasiyasını qur.
4. Calico Operator (3.29) tətbiq et.
5. Worker node-ları qoş.
6. Node statusunu yoxla.
7. Pod statusunu yoxla (kube-system).
8. Əsas komponentlərin loglarını çıxar.
9. Cluster upgrade et – 1.34.x (master + worker).
10. Node statusunu yoxla.
11. Pod statusunu yoxla (kube-system).
12. Əsas komponentlərin loglarını çıxar.
13. Hər addımın ekran görüntüsünü və loglarını paylaş.
14. Final cluster statusunu paylaş
