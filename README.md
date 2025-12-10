# ContaPics - Platformă pentru Gestionarea Documentelor Contabile

## Scop
O aplicație prin care cabinetele de contabilitate colectează fișiere (poze) cu documente de la clienții lor, procesează automat informațiile prin OCR și gestionează datele extrase într-o bază de date relațională, păstrând totul în mod multi-tenant.

---

## Arhitectură și componente

### 1. Frontend (pentru cabinete)
- **Tehnologie:** Node.js + React
- **Funcționalități:**
  - Gestionarea detaliilor despre clienți (nume, CUI, adresă, contacte)
  - Upload fișiere documente de la clienți
  - Vizualizare status procesare OCR și rezultate pentru contabili
  - Management utilizatori și permisiuni per tenant
  - Dashboard pentru fiecare cabinet (tenant)

### 2. Backend principal
- **Tehnologie:** Java (Spring Boot)
- **Funcționalități:**
  - Gestionarea conturilor multi-tenant (cabinete + clienți)
  - CRUD pentru clienți și documente
  - Expunere API pentru frontend
  - Organizarea de job-uri OCR si trimiterea taskurilor către serviciul OCR printr-o coada de mesaje

### 3. Serviciu computational intensiv OCR
- **Tehnologie:** Python
- **Funcționalități:**
  - Primește fișiere de la backend
  - Extrage automat date (număr factură, sumă, date client)
  - Salvează rezultatele în baza de date
  - Poate fi scalat independent (Kubernetes / container)

### 4. Storage fișiere
- Fișierele încărcate de clienți sunt salvate într-un storage de fișiere (local sau S3-compatible)
- Backend-ul stochează doar referințele către aceste fișiere

### 5. Bază de date
- **Tehnologie:** PostgreSQL
- **Funcționalități:**
  - Stocare relațională a informațiilor despre clienți, documente și date extrase OCR
  - Suport multi-tenant: datele fiecărui cabinet sunt segregate

---

## Flux de lucru
1. Clientul cabinetului trimite o poză jpg cu document contabil.
2. Frontend-ul încarcă fișierul către backend.
3. Backend-ul salvează fișierul în storage și creează un task OCR.
4. Serviciul OCR procesează fișierul și extrage datele relevante.
5. Datele extrase sunt salvate în PostgreSQL și legate de clientul corespunzător.
6. Cabinetul poate vizualiza progresul taskurilor și rezultatele în dashboard.

---

## Beneficii și scop DevOps
- **Multi-tenant:** fiecare cabinet are propriile date izolate.
- **Scalabilitate:** serviciile (mai ales serviciul computational intensiv OCR) pot fi scalate independent.
- **Observabilitate:** loguri și metrici pentru fiecare componentă.
- **Automatizare:** containerizare, CI/CD, IaC, monitorizare.
