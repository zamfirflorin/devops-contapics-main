#!/bin/bash

# Script pentru a configura accesul la myapp.local

echo "Configurare acces pentru myapp.local..."
echo ""

# Obține IP-ul Minikube
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"
echo ""

echo "Opțiunea 1: Adaugă în /etc/hosts (necesită sudo)"
echo "Rulează:"
echo "  echo '$MINIKUBE_IP myapp.local' | sudo tee -a /etc/hosts"
echo ""

echo "Opțiunea 2: Folosește minikube tunnel (recomandat)"
echo "Rulează într-un terminal separat:"
echo "  minikube tunnel"
echo ""
echo "Apoi accesează: http://myapp.local"
echo ""

echo "Opțiunea 3: Accesează direct prin IP"
echo "  http://$MINIKUBE_IP (cu header Host: myapp.local)"
echo ""

echo "Pentru a testa:"
echo "  curl -H 'Host: myapp.local' http://$MINIKUBE_IP"

