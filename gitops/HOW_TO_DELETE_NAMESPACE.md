# Cum Să Ștergi un Namespace Complet

## ⚠️ ATENȚIE IMPORTANTĂ

**Ștergerea unui namespace va șterge TOATE resursele din el!**
- Toate pods-urile
- Toate deployments-urile
- Toate service-urile
- Toate configmaps
- Toate secrets
- **TOATE resursele!**

## 🗑️ Comanda Principală

### Ștergere Namespace Complet

```bash
# Șterge un namespace și TOATE resursele din el
kubectl delete namespace <namespace-name>

# Exemplu pentru namespace-ul "demo":
kubectl delete namespace demo
```

**Ce face**: Șterge namespace-ul și **TOATE** resursele din el automat!

## 📋 Verificare Înainte de Ștergere

```bash
# Vezi ce resurse există în namespace
kubectl get all -n <namespace-name>

# Vezi toate resursele (inclusiv configmaps, secrets, etc.)
kubectl get all,configmaps,secrets -n <namespace-name>

# Exemplu pentru namespace-ul "demo":
kubectl get all -n demo
```

## 🎯 Pentru Namespace-ul "demo"

Dacă vrei să ștergi namespace-ul `demo` (unde a fost demo-app):

```bash
# 1. Verifică ce există în namespace
kubectl get all -n demo

# 2. Șterge namespace-ul complet
kubectl delete namespace demo

# 3. Verifică că este șters
kubectl get namespace demo

# Ar trebui să vezi: Error from server (NotFound)
```

## ⚠️ NU Șterge Namespace-ul "argocd"!

**NU face asta:**
```bash
# ❌ NU FACE ASTA!
kubectl delete namespace argocd
```

**De ce:**
- ArgoCD nu va mai funcționa
- Nu vei mai putea folosi GitOps
- ArgoCD UI nu va funcționa
- Toate aplicațiile GitOps vor fi șterse

## 🔍 Verificare Namespace-uri

```bash
# Vezi toate namespace-urile
kubectl get namespaces

# Verifică ce namespace-uri există
kubectl get ns
```

## ✅ Pași Recomandați

### 1. Verificare Înainte

```bash
# Verifică ce resurse există în namespace
kubectl get all -n <namespace-name>

# Verifică dacă mai ai nevoie de acel namespace
```

### 2. Ștergere (Doar Dacă E Sigur)

```bash
# Șterge namespace-ul complet
kubectl delete namespace <namespace-name>
```

### 3. Verificare După

```bash
# Verifică că namespace-ul este șters
kubectl get namespace <namespace-name>

# SAU
kubectl get ns <namespace-name>

# Ar trebui să vezi: Error from server (NotFound)
```

## 🎓 Când Să Ștergi un Namespace

**Șterge un namespace când:**
- ✅ Nu mai ai nevoie de aplicațiile din el
- ✅ Este un namespace de test (ex: `demo`)
- ✅ Vrei să curăți cluster-ul

**NU șterge un namespace când:**
- ❌ Este un namespace de producție
- ❌ Conține aplicații importante
- ❌ Este namespace-ul `argocd`, `kube-system`, `default`

## 💡 Alternative la Ștergerea Namespace-ului

### Dacă Vrei Doar Să Oprești Resursele (Nu Să Ștergi Namespace-ul)

```bash
# Șterge toate deployments-urile
kubectl delete deployments --all -n <namespace-name>

# Șterge toate service-urile
kubectl delete services --all -n <namespace-name>

# Șterge toate resursele
kubectl delete all --all -n <namespace-name>

# Namespace-ul rămâne, dar este gol
```

## 🔧 Ștergere Forțată (Dacă Namespace-ul Blochează)

Uneori namespace-ul poate bloca ștergerea (Terminating state):

```bash
# Verifică statusul
kubectl get namespace <namespace-name>

# Dacă este în "Terminating" și blochează:

# 1. Editează namespace-ul pentru a elimina finalizers
kubectl get namespace <namespace-name> -o json > /tmp/ns.json

# 2. Editează fișierul și șterge "finalizers"
# 3. Aplică din nou
kubectl replace --raw "/api/v1/namespaces/<namespace-name>/finalize" -f /tmp/ns.json
```

## ✅ Rezumat Comenzi

```bash
# Șterge namespace complet (RECOMANDAT)
kubectl delete namespace <namespace-name>

# Verificare
kubectl get namespace <namespace-name>

# Vezi toate namespace-urile
kubectl get namespaces
```

## 🎯 Pentru Cazul Tău

**Dacă vrei să ștergi namespace-ul `demo`:**

```bash
# Șterge namespace-ul demo (dacă mai există)
kubectl delete namespace demo

# Verifică
kubectl get namespace demo
```

**NU șterge:**
- `argocd` - ArgoCD nu va mai funcționa
- `kube-system` - Kubernetes nu va mai funcționa
- `default` - Namespace-ul implicit (poate avea resurse importante)
