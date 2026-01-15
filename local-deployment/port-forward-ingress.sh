#!/bin/bash

# Script pentru port-forward la ingress controller
# Folosește un port liber (8081 în loc de 8080)

echo "🔧 Port-forward pentru ingress controller..."
echo ""
echo "Portul 8080 este ocupat. Folosim portul 8081..."
echo ""

kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8081:80

