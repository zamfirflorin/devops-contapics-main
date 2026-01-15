# Cum Să Ștergi Service-urile Rămase

## 🔍 Verificare Service-uri

```bash
# Vezi toate service-urile din namespace
kubectl get services -n argocd

# Caută service-uri specifice (ex: demo-app)
kubectl get services -n argocd | grep demo
```

## 🗑️ Ștergere Service

### Ștergere un Service Specific

```bash
# Șterge un service specific
kubectl delete service <service-name> -n <namespace>

# Exemplu pentru demo-app:
kubectl delete service demo-app -n argocd
```

### Ștergere Multiple Service-uri

```bash
# Șterge mai multe service-uri
kubectl delete service service1 service2 service3 -n argocd

# Exemplu:
kubectl delete service demo-app demo-app-2 -n argocd
```

### Ștergere Toate Service-urile (NU RECOMANDAT!)

```bash
# ⚠️ ATENȚIE: Va șterge TOATE service-urile din namespace!
kubectl delete services --all -n argocd
```

**⚠️ NU FACE ASTA** în namespace-ul `argocd` pentru că va șterge și service-urile ArgoCD (argocd-server, argocd-repo-server, etc.)!

## 🔍 Găsire Service-uri Rămase

### Verificare Service-uri Orfane (fără Deployment/StatefulSet)

```bash
# Vezi toate service-urile
kubectl get services -n argocd

# Verifică dacă există deployments/statefulsets care le folosesc
kubectl get deployments -n argocd
kubectl get statefulsets -n argocd

# Dacă un service nu are deployment/statefulset, este probabil "orfan"
```

### Verificare Label-uri

```bash
# Vezi service-uri cu label-uri specifice
kubectl get services -n argocd -l app=demo-app

# Șterge toate service-urile cu un label specific
kubectl delete services -n argocd -l app=demo-app
```

## ✅ Pasii Recomandați

### 1. Identificare Service-uri Rămase

```bash
# Vezi toate service-urile
kubectl get services -n argocd

# Caută service-uri care nu ar trebui să existe
# (ex: demo-app după ce ai șters deployment-ul)
```

### 2. Verificare Dependențe

```bash
# Verifică dacă există deployments/statefulsets care le folosesc
kubectl get deployments -n argocd | grep demo
kubectl get statefulsets -n argocd | grep demo

# Dacă nu există, service-ul este "orfan" și poate fi șters
```

### 3. Ștergere Service-ul

```bash
# Șterge service-ul orfan
kubectl delete service <service-name> -n argocd

# Exemplu pentru demo-app:
kubectl delete service demo-app -n argocd
```

### 4. Verificare Finală

```bash
# Verifică că service-ul este șters
kubectl get services -n argocd | grep <service-name>

# Nu ar trebui să vezi nimic
```

## 🎯 Pentru Cazul Tău (demo-app)

```bash
# 1. Verifică service-ul
kubectl get service demo-app -n argocd

# 2. Șterge service-ul
kubectl delete service demo-app -n argocd

# 3. Verifică că este șters
kubectl get services -n argocd | grep demo-app

# Nu ar trebui să vezi nimic (service-ul este șters)
```

## 📋 Service-uri ArgoCD (NU le șterge!)

**NU șterge** aceste service-uri (sunt necesare pentru ArgoCD):

- `argocd-server`
- `argocd-repo-server`
- `argocd-dex-server`
- `argocd-redis`
- `argocd-metrics`
- `argocd-applicationset-controller`
- `argocd-notifications-controller-metrics`
- `argocd-server-metrics`

## ⚠️ Atenție

**NU șterge service-urile ArgoCD!** Acestea sunt necesare pentru funcționarea ArgoCD.

Șterge doar service-urile care sunt **orfane** (nu au deployment/statefulset asociat).

## ✅ Verificare Completă

```bash
# Vezi toate resursele din namespace
kubectl get all -n argocd

# Verifică dacă mai există resurse demo-app
kubectl get all -n argocd | grep demo-app

# Nu ar trebui să vezi nimic (totul este șters)
```
