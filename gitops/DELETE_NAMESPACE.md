# Cum Să Ștergi un Namespace Complet

## 🗑️ Comanda Principală

```bash
# Șterge namespace-ul și TOATE resursele din el
kubectl delete namespace <namespace-name>
```

**Ce face**: Șterge namespace-ul și **automat TOATE** resursele din el:
- ✅ Toate pods-urile
- ✅ Toate deployments-urile
- ✅ Toate service-urile
- ✅ Toate configmaps
- ✅ Toate secrets
- ✅ Toate statefulsets
- ✅ **TOATE resursele!**

## 📋 Exemple

### Ștergere Namespace "demo"

```bash
# Șterge namespace-ul demo complet
kubectl delete namespace demo

# Verifică că este șters
kubectl get namespace demo

# Ar trebui să vezi: Error from server (NotFound)
```

### Ștergere Orice Namespace

```bash
# Înlocuiește <namespace-name> cu numele namespace-ului
kubectl delete namespace <namespace-name>
```

## ⚠️ ATENȚIE: Namespace-uri Care NU Trebuie Șterse

**NU șterge aceste namespace-uri:**

```bash
# ❌ NU FACE ASTA!
kubectl delete namespace argocd        # ArgoCD nu va mai funcționa
kubectl delete namespace kube-system   # Kubernetes nu va mai funcționa
kubectl delete namespace default       # Namespace implicit (poate avea resurse importante)
kubectl delete namespace ingress-nginx # Ingress nu va mai funcționa
kubectl delete namespace kubernetes-dashboard  # Dashboard nu va mai funcționa
```

## ✅ Namespace-uri Care Pot Fi Șterse

**OK să ștergi aceste namespace-uri:**
- ✅ `demo` (namespace de test)
- ✅ Orice namespace personalizat pentru testare
- ✅ Namespace-uri pe care nu mai ai nevoie de ele

## 🔍 Verificare Înainte de Ștergere

```bash
# Vezi ce resurse există în namespace
kubectl get all -n <namespace-name>

# Exemplu pentru namespace-ul "demo":
kubectl get all -n demo
```

## ✅ Verificare După Ștergere

```bash
# Verifică că namespace-ul este șters
kubectl get namespace <namespace-name>

# SAU
kubectl get ns <namespace-name>

# Ar trebui să vezi: Error from server (NotFound)
```

## 🎯 Pentru Cazul Tău

Dacă vrei să ștergi namespace-ul `demo` (unde a fost demo-app):

```bash
# 1. Verifică ce există (opțional)
kubectl get all -n demo

# 2. Șterge namespace-ul complet
kubectl delete namespace demo

# 3. Verifică că este șters
kubectl get namespace demo
```

## 💡 De Ce Este Mai Bine Decât Ștergerea Individuală

**În loc de:**
```bash
kubectl delete deployment demo-app -n demo
kubectl delete service demo-app -n demo
kubectl delete configmap ... -n demo
# etc. (trebuie să ștergi fiecare resursă)
```

**Poți face:**
```bash
kubectl delete namespace demo
# Șterge automat TOATE resursele!
```

## 🎓 Rezumat

```bash
# Comanda unică pentru ștergerea completă
kubectl delete namespace <namespace-name>

# Verificare
kubectl get namespace <namespace-name>
```

## ⚠️ Important

**Ștergerea namespace-ului este IRREVERSIBILĂ!**
- Nu poți recupera resursele după ștergere
- Asigură-te că nu mai ai nevoie de resursele din namespace
- Pentru namespace-uri importante, fă backup mai întâi
