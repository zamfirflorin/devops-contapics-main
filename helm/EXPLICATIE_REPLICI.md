# De Ce Ai 3 Replici Rulează?

## 📊 Structura Ta Actuală

Ai **3 pods** care rulează din **2 surse diferite**:

### 1. **Backend Deployment** (2 replici)
- **Deployment**: `postgres-db-for-backend`
- **Număr de replici**: 2 (din `values.yaml`: `replicaCount: 2`)
- **Status**: ❌ ImageInspectError (imaginea `backend:latest` nu poate fi găsită)
- **Pods**:
  - `postgres-db-for-backend-764d878d54-5z6f7` (ImageInspectError)
  - `postgres-db-for-backend-764d878d54-mxkfm` (ImageInspectError)

### 2. **PostgreSQL StatefulSet** (1 replică)
- **StatefulSet**: `postgres-db-for-backend-postgresql` (din dependency Bitnami)
- **Număr de replici**: 1 (default pentru PostgreSQL standalone)
- **Status**: ✅ Running
- **Pod**: `postgres-db-for-backend-postgresql-0`

## 🎯 De Ce 2 Replici pentru Backend?

În fișierul `values.yaml` ai setat:

```yaml
replicaCount: 2
```

Aceasta creează **2 pods** pentru aplicația backend.

## 🔧 Cum Să Schimbi Numărul de Replici?

### Opțiunea 1: Modifică `values.yaml`

```yaml
# Schimbă în helm/postgres-db-for-backend/values.yaml
replicaCount: 1  # în loc de 2
```

Apoi actualizează:
```bash
helm upgrade postgres-db-for-backend . -n default
```

### Opțiunea 2: Override la Install/Upgrade

```bash
# Instalează cu 1 replică (fără să modifici values.yaml)
helm install postgres-db-for-backend . --set replicaCount=1

# SAU upgrade cu 1 replică
helm upgrade postgres-db-for-backend . --set replicaCount=1
```

### Opțiunea 3: Scale Direct în Kubernetes

```bash
# Scale down la 1 replică
kubectl scale deployment postgres-db-for-backend --replicas=1 -n default

# Verifică
kubectl get deployment postgres-db-for-backend -n default
```

## ❌ Problema Actuală: ImageInspectError

Pods-urile backend **NU rulează** pentru că:
- Imaginea `backend:latest` nu poate fi găsită
- Helm încearcă să folosească `backend:latest` (din `values.yaml`)
- Imaginea nu există în Minikube sau nu este încărcată

**Soluție**:
1. **Build și încarcă imaginea**:
   ```bash
   # Build imaginea
   docker build -t backend:latest ./backend
   
   # Încarcă în Minikube
   minikube image load backend:latest
   ```

2. **SAU folosește o imagine existentă**:
   ```yaml
   # Modifică în values.yaml
   image:
     repository: docker.io/library/backend
     tag: "2.0"  # sau ce tag ai
   ```

## 📋 Rezumat

**3 pods total:**
- ✅ 1 pod PostgreSQL (rulează corect)
- ❌ 2 pods Backend (nu rulează - ImageInspectError)

**De ce 2 replici backend?**
- `replicaCount: 2` în `values.yaml`

**Cum să schimbi?**
- Modifică `values.yaml` → `replicaCount: 1`
- SAU `helm upgrade --set replicaCount=1`
- SAU `kubectl scale deployment --replicas=1`
