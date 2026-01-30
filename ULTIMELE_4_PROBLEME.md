# Probleme Helm și Kubernetes Rezolvate

## Problema 1: Conflict Secret "secrets" la instalarea Helm Chart

### Problema
La prima instalare a Helm chart-ului backend, Helm nu putea crea Secret-ul `secrets` pentru că un Secret cu același nume exista deja în namespace-ul `default`, creat anterior manual sau de alt release Helm.

### Simptomul (Eroarea)
```
Error: INSTALLATION FAILED: unable to continue with install: Secret "secrets" in namespace "default" exists and cannot be imported into the release: resource exists but is not managed by Helm
```

### Rezolvarea
Secret-ul `secrets` a fost creat manual (probabil din `local-deployment/secret.yaml` cu `kubectl apply`) și nu avea metadata-ul necesar (labels, annotations) pentru ca Helm să-l gestioneze ca parte a release-ului.

**Pași de rezolvare:**

1. Șters Secret-ul vechi care nu era gestionat de Helm (dacă nu conține date critice):
   ```bash
   kubectl delete secret secrets
   helm install backend ./helm/backend
   ```

2. Alternativ, renumit Secret-ul în Helm chart pentru a evita conflictele:
   - Actualizat `helm/backend/templates/secret.yaml` pentru a folosi un nume unic bazat pe release:
     ```yaml
     apiVersion: v1
     kind: Secret
     metadata:
       name: {{ include "backend.fullname" . }}-secret
       labels:
         {{- include "backend.labels" . | nindent 4 }}
     ```
   - Actualizat `helm/backend/templates/backend-deployment.yaml` pentru a referi noul nume:
     ```yaml
     - name: AWS_ACCESS_KEY_ID
       valueFrom:
         secretKeyRef:
           name: {{ include "backend.fullname" . }}-secret
           key: AWS_ACCESS_KEY_ID
     ```

**Rezultat:** Helm poate crea și gestiona Secret-ul fără conflicte.

---

## Problema 2: Serviciu "db" redundant și conflict cu Bitnami PostgreSQL

### Problema
Helm chart-ul backend conținea un serviciu `db` redundant care intra în conflict cu serviciul PostgreSQL creat automat de Bitnami PostgreSQL subchart.

### Simptomul (Eroarea)
```
Error: INSTALLATION FAILED: unable to continue with install: Service "db" in namespace "default" exists and cannot be imported into the release: resource exists but is not managed by Helm
```

Sau în alte cazuri:
```
Error: services "db" already exists
```

### Rezolvarea
În `helm/backend/templates/service.yaml` existau două definiții de Service:
1. Un Service pentru backend (corect)
2. Un Service `db` pentru PostgreSQL (redundant)

Bitnami PostgreSQL subchart creează automat propriul serviciu cu numele `{{ .Release.Name }}-postgresql`, deci serviciul `db` manual era redundant și cauza conflicte.

**Pași de rezolvare:**

1. Eliminat serviciul `db` redundant din `helm/backend/templates/service.yaml`:
   ```yaml
   # ELIMINAT - serviciul redundant pentru PostgreSQL
   # ---
   # apiVersion: v1
   # kind: Service
   # metadata:
   #   name: db
   # spec:
   #   selector:
   #     app: postgres
   #   ports:
   #     - port: 5432
   #       targetPort: 5432
   #   type: ClusterIP
   ```

2. Actualizat `helm/backend/templates/backend-config-map.yml` pentru a folosi numele corect al serviciului Bitnami PostgreSQL:
   ```yaml
   data:
     DB_HOST: "{{ .Release.Name }}-postgresql"  # Numele serviciului Bitnami
     DB_PORT: "{{ .Values.postgresql.primary.service.port }}"
   ```

3. Șters serviciul `db` vechi dacă exista:
   ```bash
   kubectl delete service db
   helm upgrade backend ./helm/backend
   ```

**Rezultat:** Nu mai există conflicte de servicii, iar backend-ul se conectează corect la PostgreSQL folosind serviciul generat de Bitnami.

---

## Problema 3: Sintaxă YAML greșită pentru AWS_S3_ENDPOINT în ConfigMap

### Problema
Backend pod-ul nu putea porni din cauza unei erori legate de cheia `AWS_S3_ENDPOINT` lipsă din ConfigMap, chiar dacă cheia era declarată în ConfigMap.

### Simptomul (Eroarea)
```
Error: couldn't find key AWS_S3_ENDPOINT in ConfigMap default/app-config
```

În `kubectl describe pod <backend-pod>`:
```
Events:
  Warning  Failed      Error: couldn't find key AWS_S3_ENDPOINT in ConfigMap default/app-config
```

### Rezolvarea
În `local-deployment/backend-config-map.yml` sau `helm/backend/templates/backend-config-map.yml`, cheia `AWS_S3_ENDPOINT` era declarată fără valoare sau cu sintaxă YAML invalidă:
```yaml
# GREȘIT:
AWS_S3_ENDPOINT:  # Fără valoare - YAML invalid
```

**Pași de rezolvare:**

1. Actualizat ConfigMap-ul pentru a include o valoare explicită (chiar dacă este string gol):
   ```yaml
   # CORECT:
   AWS_S3_ENDPOINT: ""  # String gol pentru valoare opțională
   ```

2. În `helm/backend/templates/backend-config-map.yml`:
   ```yaml
   data:
     AWS_S3_ENDPOINT: "{{ .Values.aws.s3.endpoint }}"
   ```

3. În `helm/backend/values.yaml`:
   ```yaml
   aws:
     s3:
       endpoint: ""  # String gol dacă nu se folosește endpoint custom (ex: MinIO)
   ```

4. Verificat că deployment-ul citește corect din ConfigMap:
   ```yaml
   - name: AWS_S3_ENDPOINT
     valueFrom:
       configMapKeyRef:
         name: backend-config
         key: AWS_S3_ENDPOINT
   ```

**Rezultat:** ConfigMap-ul conține cheia `AWS_S3_ENDPOINT` cu o valoare validă (string gol), iar backend-ul poate citi variabila de mediu fără erori.

---

## Problema 4: Lipsă variabile de mediu AWS în Backend Deployment

### Problema
Backend pod-ul nu putea porni din cauza unei erori Spring Boot legate de crearea bean-ului `s3Config` - variabilele de mediu AWS nu erau disponibile.

### Simptomul (Eroarea)
În log-urile backend pod:
```
Error creating bean with name 's3Config': Injection of autowired dependencies failed
...
Could not resolve placeholder 'aws.s3.bucket-name' in value "${AWS_S3_BUCKET_NAME}"
Could not resolve placeholder 'aws.region' in value "${AWS_REGION}"
```

Sau:
```
java.lang.IllegalArgumentException: Could not resolve placeholder 'aws.s3.endpoint' in value "${AWS_S3_ENDPOINT:}"
```

### Rezolvarea
În `helm/backend/templates/backend-deployment.yaml` sau `local-deployment/backend-deployment.yml`, nu erau definite toate variabilele de mediu necesare pentru AWS S3:
- `AWS_S3_BUCKET_NAME`
- `AWS_REGION`
- `AWS_S3_ENDPOINT`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Pași de rezolvare:**

1. Adăugat toate variabilele de mediu AWS în `helm/backend/templates/backend-deployment.yaml`:
   ```yaml
   env:
     # ... alte variabile de mediu ...
     
     - name: AWS_S3_BUCKET_NAME
       valueFrom:
         configMapKeyRef:
           name: backend-config
           key: AWS_S3_BUCKET_NAME
     
     - name: AWS_REGION
       valueFrom:
         configMapKeyRef:
           name: backend-config
           key: AWS_REGION
     
     - name: AWS_S3_ENDPOINT
       valueFrom:
         configMapKeyRef:
           name: backend-config
           key: AWS_S3_ENDPOINT
     
     - name: AWS_ACCESS_KEY_ID
       valueFrom:
         secretKeyRef:
           name: secrets
           key: AWS_ACCESS_KEY_ID
     
     - name: AWS_SECRET_ACCESS_KEY
       valueFrom:
         secretKeyRef:
           name: secrets
           key: AWS_SECRET_ACCESS_KEY
   ```

2. Verificat că ConfigMap-ul (`backend-config`) conține toate cheile necesare:
   ```yaml
   data:
     AWS_S3_BUCKET_NAME: "florin-zamf-demo-bucket"
     AWS_REGION: "eu-central-1"
     AWS_S3_ENDPOINT: ""
   ```

3. Verificat că Secret-ul (`secrets`) conține credențialele AWS:
   ```yaml
   data:
     AWS_ACCESS_KEY_ID: <base64-encoded>
     AWS_SECRET_ACCESS_KEY: <base64-encoded>
   ```

**Rezultat:** Backend-ul primește toate variabilele de mediu necesare și poate crea corect bean-ul `s3Config` pentru conexiunea la AWS S3.

---

## Problema 5: OCR Service folosea ConfigMap în loc de Secret pentru AWS Credentials

### Problema
OCR service pod-ul nu putea porni din cauza unei erori că nu găsește cheile AWS în ConfigMap, deși credențialele trebuie să fie în Secret.

### Simptomul (Eroarea)
```
Error: couldn't find key AWS_ACCESS_KEY_ID in ConfigMap default/app-config
Error: couldn't find key AWS_SECRET_ACCESS_KEY in ConfigMap default/app-config
```

În `kubectl describe pod <ocr-pod>`:
```
Events:
  Warning  Failed      Error: couldn't find key AWS_ACCESS_KEY_ID in ConfigMap default/app-config
```

### Rezolvarea
În `local-deployment/ocr-deployment.yml`, credențialele AWS erau configurate să fie citite din ConfigMap în loc de Secret:
```yaml
# GREȘIT:
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    configMapKeyRef:  # ❌ ConfigMap în loc de Secret
      name: app-config
      key: AWS_ACCESS_KEY_ID
```

Credențialele sensibile (AWS Access Key ID și Secret Access Key) trebuie să fie stocate în Secret, nu în ConfigMap.

**Pași de rezolvare:**

1. Actualizat `local-deployment/ocr-deployment.yml` pentru a folosi `secretKeyRef` în loc de `configMapKeyRef`:
   ```yaml
   env:
     # ConfigMap pentru configurații non-sensibile
     - name: AWS_S3_BUCKET_NAME
       valueFrom:
         configMapKeyRef:
           name: app-config
           key: AWS_S3_BUCKET_NAME
     
     - name: AWS_REGION
       valueFrom:
         configMapKeyRef:
           name: app-config
           key: AWS_REGION
     
     - name: AWS_S3_ENDPOINT
       valueFrom:
         configMapKeyRef:
           name: app-config
           key: AWS_S3_ENDPOINT
     
     # Secret pentru credențiale sensibile
     - name: AWS_ACCESS_KEY_ID
       valueFrom:
         secretKeyRef:  # ✅ Secret pentru credențiale
           name: secrets
           key: AWS_ACCESS_KEY_ID
     
     - name: AWS_SECRET_ACCESS_KEY
       valueFrom:
         secretKeyRef:  # ✅ Secret pentru credențiale
           name: secrets
           key: AWS_SECRET_ACCESS_KEY
   ```

2. Verificat că Secret-ul `secrets` conține cheile AWS:
   ```bash
   kubectl get secret secrets -o yaml
   ```

**Rezultat:** OCR service-ul citește corect credențialele AWS din Secret, respectând best practices pentru date sensibile.

**Notă:** Best practice: Credențialele (passwords, API keys, tokens) trebuie stocate întotdeauna în **Secret**, nu în **ConfigMap**. ConfigMap-ul este pentru configurații non-sensibile (URLs, bucket names, regions, etc.).

---

## Problema 6: Autentificare eșuată la PostgreSQL

### Problema
Backend-ul nu se putea conecta la baza de date PostgreSQL în Kubernetes, deși podul PostgreSQL era pornit și funcțional.

### Simptomul (Eroarea)
```
FATAL: password authentication failed for user "admin"
```

În log-urile pod-ului backend:
```
DBC Connection for DDL execution [FATAL: password authentication failed for user "admin"] [n/a]
```

### Rezolvarea
Existau trei surse diferite pentru parola PostgreSQL:
1. `helm/backend/values.yaml` conținea `postgresql.auth.password: adminpass`
2. `helm/backend/templates/secret.yaml` era hardcodat cu o parolă diferită (base64 pentru "secure123")
3. Bitnami PostgreSQL subchart genera automat o parolă aleatoare (`RH6M0CsJdD`)

**Pași de rezolvare:**

1. Actualizat `helm/backend/values.yaml` pentru a seta explicit parola Bitnami PostgreSQL:
   ```yaml
   postgresql:
     auth:
       postgresPassword: adminpass  # Forțează Bitnami să folosească această parolă
       username: admin
       password: adminpass
   ```

2. Actualizat `helm/backend/templates/backend-deployment.yaml` pentru a citi parola direct din Secret-ul generat de Bitnami:
   ```yaml
   - name: DB_PASSWORD
     valueFrom:
       secretKeyRef:
         name: {{ .Release.Name }}-postgresql  # Secret-ul generat de Bitnami
         key: postgres-password
   ```

3. Șters StatefulSet-ul și PVC-ul vechi PostgreSQL pentru a forța o reinstalare curată:
   ```bash
   kubectl delete statefulset backend-postgresql
   kubectl delete pvc data-backend-postgresql-0
   ```

4. Reinstalat Helm chart-ul:
   ```bash
   helm upgrade backend .
   ```

**Rezultat:** Backend-ul se conectează cu succes la PostgreSQL folosind parola `adminpass` din Secret-ul Bitnami.

---

## Problema 7: ConfigMap existent pentru Frontend

### Problema
Helm nu putea instala chart-ul frontend din cauza unui conflict de resurse - ConfigMap-ul `frontend-config` exista deja în namespace-ul `default` și nu era gestionat de Helm.

### Simptomul (Eroarea)
```
Error: INSTALLATION FAILED: unable to continue with install: ConfigMap "frontend-config" in namespace "default" exists and cannot be imported into the release: resource exists but is not managed by Helm
```

### Rezolvarea
ConfigMap-ul `frontend-config` a fost creat anterior manual (probabil cu `kubectl apply`) și nu avea label-urile și annotation-urile necesare pentru ca Helm să-l gestioneze.

**Pași de rezolvare:**

1. Șters ConfigMap-ul vechi care nu era gestionat de Helm:
   ```bash
   kubectl delete configmap frontend-config
   ```

2. Actualizat `helm/frontend/templates/frontend-config-map.yml` pentru a folosi label-uri standard Helm:
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: frontend-config
     labels:
       {{- include "frontend.labels" . | nindent 4 }}
   data:
     config.js: |
       window._env_ = {
         BACKEND_URL: "http://localhost:8080"
       };
   ```

3. Reinstalat chart-ul frontend:
   ```bash
   helm install frontend ./helm/frontend
   ```

**Rezultat:** Helm poate acum gestiona ConfigMap-ul și instalarea frontend-ului reușește.

---

## Problema 8: Eroare de validare YAML în Frontend Helm Chart

### Problema
Helm nu putea genera manifestele Kubernetes pentru frontend din cauza unui document YAML gol sau invalid.

### Simptomul (Eroarea)
```
Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest: error validating "": error validating data: [apiVersion not set, kind not set]
```

### Rezolvarea
În `helm/frontend/templates/service.yaml` exista un bloc de cod comentat folosind `#` în loc de sintaxa Helm pentru comentarii (`{{/* ... */}}`). Când Helm procesa template-ul, comentariile cu `#` erau ignorate, dar liniile goale sau parțial procesate generau un document YAML gol.

**Pași de rezolvare:**

1. Eliminat blocul comentat din `helm/frontend/templates/service.yaml`:
   ```yaml
   # ELIMINAT - blocul comentat care genera document YAML gol
   # apiVersion: v1
   # kind: Service
   # ...
   ```

2. Păstrat doar definiția corectă a Service-ului:
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: frontend-service
   spec:
     selector:
       app: frontend
     ports:
       - port: 3000
         targetPort: 80
     type: LoadBalancer
   ```

**Notă:** Dacă este nevoie să comentezi cod în template-uri Helm, folosește sintaxa `{{/* comentariu */}}` în loc de `#`.

**Rezultat:** Helm poate genera corect manifestele YAML și instalarea frontend-ului reușește.

---

## Problema 9: Frontend nu găsește URL-ul backend-ului

### Problema
Frontend-ul afișa eroarea "login failed" chiar dacă backend-ul loga autentificări reușite. Frontend-ul nu putea comunica cu backend-ul pentru că nu găsea URL-ul corect.

### Simptomul (Eroarea)
- În browser: Mesaj de eroare "login failed"
- În backend logs: Autentificări reușite (`Authentication successful for user: ...`)
- În browser console: Erori de rețea sau `window._env_` undefined

### Rezolvarea
Frontend-ul încerca să încarce configurația din `/config.js`, dar fișierul lipsea:
- `frontend/index.html` încărca `<script src="/config.js"></script>`
- Fișierul `frontend/public/config.js` nu exista local pentru development
- ConfigMap-ul Kubernetes conținea configurația, dar nu era accesibilă în modul local

**Pași de rezolvare:**

1. Creat fișierul `frontend/public/config.js` pentru development local:
   ```javascript
   window._env_ = {
     BACKEND_URL: "http://localhost:8080"
   };
   ```

2. Actualizat `helm/frontend/templates/frontend-config-map.yml` pentru a folosi același format (`window._env_`):
   ```yaml
   data:
     config.js: |
       window._env_ = {
         BACKEND_URL: "http://localhost:8080"
       };
   ```

3. Verificat că `frontend/index.html` încarcă corect script-ul:
   ```html
   <script src="/config.js"></script>
   ```

**Rezultat:** Frontend-ul poate găsi URL-ul backend-ului atât în modul local (din `public/config.js`) cât și în Kubernetes (din ConfigMap montat ca volum).

---

## Concluzie

Toate problemele au fost rezolvate prin:
1. **Sincronizarea configurațiilor** între Helm values, Secrets, ConfigMaps și Deployments
2. **Eliminarea hardcodărilor** și folosirea referințelor corecte la resurse Kubernetes
3. **Curățarea resurselor vechi** care nu erau gestionate de Helm
4. **Asigurarea consistenței** între configurațiile locale și Kubernetes
5. **Separarea corectă** între ConfigMap (configurații non-sensibile) și Secret (credențiale)
