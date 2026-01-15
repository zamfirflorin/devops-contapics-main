#!/bin/bash

echo "🚀 Pornire acces pentru myapp.local..."
echo ""

# Verifică dacă port-forward-ul rulează deja
if pgrep -f "port-forward.*ingress-nginx.*8081" > /dev/null; then
    echo "✅ Port-forward la ingress controller rulează deja pe portul 8081"
else
    echo "🔄 Pornire port-forward la ingress controller..."
    kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8081:80 > /dev/null 2>&1 &
    sleep 2
    echo "✅ Port-forward pornit pe portul 8081"
fi

echo ""
echo "📋 Opțiuni de acces:"
echo ""
echo "1. Accesează direct în browser:"
echo "   http://localhost:8081"
echo ""
echo "2. Test cu curl:"
echo "   curl -H 'Host: myapp.local' http://localhost:8081/"
echo ""
echo "3. Pentru a accesa ca myapp.local în browser:"
echo "   Adaugă în /etc/hosts:"
echo "   echo '127.0.0.1 myapp.local' | sudo tee -a /etc/hosts"
echo "   Apoi accesează: http://myapp.local:8081"
echo ""
echo "🔍 Verificare status:"
curl -H 'Host: myapp.local' http://localhost:8081/ -I 2>&1 | grep -E "HTTP|200" || echo "⚠️  Frontend nu răspunde"
echo ""

