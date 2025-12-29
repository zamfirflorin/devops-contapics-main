#!/bin/bash

# Script pentru a deschide Minikube Dashboard și a vizualiza metrici

echo "Pornire Minikube Dashboard..."
echo ""
echo "Dashboard-ul se va deschide în browser automat."
echo "Dacă nu se deschide, accesează manual URL-ul afișat mai jos."
echo ""
echo "Pentru a vedea metricile de CPU și Memory:"
echo "1. Navighează la 'Nodes' sau 'Pods' în meniul din stânga"
echo "2. Selectează un node sau pod"
echo "3. Vei vedea secțiunea 'Metrics' cu CPU și Memory usage"
echo ""
echo "SAU"
echo "4. Navighează la 'Workloads' > 'Deployments'"
echo "5. Selectează 'backend-deployment' sau 'frontend-deployment'"
echo "6. Vei vedea metricile pentru toate replicile"
echo ""

minikube dashboard

