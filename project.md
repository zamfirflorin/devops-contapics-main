Proiect Devmind
REDACTED

1. Backend

- Pentru serviciul de Backend am modificat fișierul application.yaml pentru a seta variabilele de mediu si a fi configurabile

	- creat un fișier .env pentru setarea variabilelor de mediu
	- am creat un fișier Dockerfile pentru crearea imaginii in doua stages, primul stage de build in folosesc ca imagine de bass eclipse alpine tbmurin, creez un workind directory app si includ in imagine fișierul de pomxml cât si sursa ./src
	- in cel de al doilea stage imachetez aplicația intr un jar creat in folderul /app din stagiul precedent. Aplicată va rula default pe portul 8080 si va avea ca prima comanda java, -jar app.jar. 

1. Frontend

- Analog ca si in cazul imaginii de backend, am creat o imagine pentru frontend plecând de la fișierul de Dockerfile 


Deploy in K8s local - Crearea Manifestelor

Mergand mai departe am inceput sa creez fisiere de manifest in local-deployment pentru deployul in minikube. Am plecat astfel de la fisiere de baza precum postgres-pod iar mai apoi treptat pe baza imaginilor de frontend si backend anterior creeate si incarcate in contextul local de minikube sa deployez intr-un k8s local. Am folosit manifeste de tip deployment, service configMap si secrets.

Am creat deployemntyru cu replicaset pentru a gestiona si mentine numarul de poduri constant. 
Am creat un manifest de service pentru db de tip ClusterIP pentru accesul doar din interiorul clusterului pentru toate cele 3 aplicatii. 

Scalarea K8s cluster

Pentru a asigura performanta, disponibilitatea si eficienta costurilor am folosit doua tipuri de mecanisme de scalare, orizontala si verticala prin implemntarea unui HPA si respectiv VPA. 

Am definit requests si limits pentru a defini resursele si maxime pentru containerele de frontend si backend. 

La momentul aplicarii manifestului de VPA, am constatat ca VPA nu exista in cluster si trebuie instalat ca addon. 


La momentul testarii cu si rularii comenzii de

hey -n 100 -c 10 \
  -m POST \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"adminpass"}' \
  http://localhost:8080/auth/login

si apoi rularii comenzii:

kubectl get events | grep Scaling

151m        Normal    ScalingReplicaSet         deployment/backend-deployment              Scaled down replica set backend-deployment-77547d599b from 2 to 1
57m         Normal    ScalingReplicaSet         deployment/backend-deployment              Scaled up replica set backend-deployment-77547d599b from 1 to 3

se poate observa ca numarul de poduri se scaleaza in sus la atingerea unei limite

pentru loguri detaliate putem accesa logurile de la controller-manager:
kubectl logs -n kube-system kube-controller-manager-minikube

I1229 11:43:59.837697       1 horizontal.go:927] "Successfully rescaled" logger="horizontal-pod-autoscaler-controller" HPA="default/backend-hpa" currentReplicas=1 desiredReplicas=3 reason="cpu resource utilization (percentage of request) above target"

sau se poat vedea eventurile ruland comanda  

kubectl describe hpa backend-hpa

sau monitoriza prin comanda 
kubectl get hpa backend-hpa -w