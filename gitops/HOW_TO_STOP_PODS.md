# How to Stop Pods in ArgoCD Namespace

## 🛑 Opțiuni pentru Oprire Pods

### 1. Oprește Doar Demo App (Recomandat)

Dacă vrei să oprești doar aplicația de test `demo-app`, fără să afectezi ArgoCD:

```bash
# Șterge Deployment-ul (va șterge automat pods)
kubectl delete deployment demo-app -n argocd

# SAU șterge Application ArgoCD (va șterge tot ce este gestionat de ArgoCD)
kubectl delete application demo-app -n argocd
```

**Rezultat**: Demo App va fi oprit, dar ArgoCD va continua să ruleze.

---

### 2. Oprește un Pod Specific

Dacă vrei să oprești un pod specific (fără să-l ștergi):

```bash
# Oprește un pod specific (va fi recreeat automat dacă e parte dintr-un Deployment)
kubectl delete pod <pod-name> -n argocd

# Exemplu pentru demo-app:
kubectl delete pod demo-app-7bc8c78b44-4qsnd -n argocd
```

**⚠️ Atenție**: Dacă pod-ul face parte dintr-un Deployment, Kubernetes îl va recrea automat!

---

### 3. Scale Down un Deployment

Pentru a reduce numărul de replici la 0 (oprește pods, dar păstrează Deployment-ul):

```bash
# Scale down demo-app la 0 replici
kubectl scale deployment demo-app -n argocd --replicas=0

# Scale up din nou (dacă vrei)
kubectl scale deployment demo-app -n argocd --replicas=1
```

**Rezultat**: Pods-urile vor fi oprite, dar Deployment-ul rămâne (poți reporni mai târziu).

---

### 4. Oprește TOATE Pods-urile ArgoCD (NU RECOMANDAT!)

**⚠️ ATENȚIE**: Aceasta va opri ArgoCD complet și nu vei mai putea folosi GitOps!

```bash
# Scale down toate deployments-urile ArgoCD (NU recomandat!)
kubectl scale deployment --all -n argocd --replicas=0

# SAU șterge toate pods-urile (se vor recrea automat)
kubectl delete pods --all -n argocd
```

**⚠️ NU FACE ASTA** dacă vrei să folosești ArgoCD!

---

## 📋 Pods în Namespace ArgoCD

În namespace-ul `argocd` ai 2 tipuri de pods:

### 1. **ArgoCD System Pods** (NU le opri!)
- `argocd-application-controller-0`
- `argocd-repo-server-xxx`
- `argocd-server-xxx`
- `argocd-dex-server-xxx`
- etc.

**Ce fac**: Rulează ArgoCD (sistemul GitOps)
**De ce NU le opri**: ArgoCD nu va mai funcționa!

### 2. **Demo App Pod** (Poți opri!)
- `demo-app-xxx`

**Ce face**: Aplicația de test (doar "Hello GitOps!")
**De ce poți opri**: Este doar pentru testare, nu este necesară

---

## ✅ Recomandări

### Pentru Demo App:

**Opțiunea 1: Șterge Application ArgoCD** (Recomandat)
```bash
kubectl delete application demo-app -n argocd
```
**Pro**: ArgoCD va șterge automat tot (deployment, service, pods)
**Pro**: Păstrează lucrurile curate

**Opțiunea 2: Scale Down**
```bash
kubectl scale deployment demo-app -n argocd --replicas=0
```
**Pro**: Poți reporni mai târziu cu `--replicas=1`
**Contra**: Deployment-ul rămâne în cluster

### Pentru ArgoCD System Pods:

**NU le opri!** Dacă le oprești:
- ❌ ArgoCD nu va mai funcționa
- ❌ Nu vei mai putea sincroniza aplicații GitOps
- ❌ ArgoCD UI nu va funcționa

---

## 🔍 Verificare

După ce oprești pods, verifică:

```bash
# Vezi pods-urile care rulează
kubectl get pods -n argocd

# Vezi statusul deployments-urilor
kubectl get deployments -n argocd

# Vezi events pentru erori
kubectl get events -n argocd --sort-by='.lastTimestamp'
```

---

## 🎯 Comenzi Rapide

```bash
# Oprește doar demo-app (recomandat)
kubectl delete application demo-app -n argocd

# Verifică că demo-app este oprit
kubectl get pods -n argocd | grep demo-app

# Ar trebui să nu vezi nimic (demo-app oprit)
```

---

## ⚠️ Important

**NU opri pods-urile ArgoCD system!** (argocd-application-controller, argocd-repo-server, etc.)

Doar pods-urile `demo-app-*` pot fi oprite în siguranță.
