#!/bin/bash

echo "🔧 Corectare /etc/hosts pentru myapp.local"
echo ""
echo "Problema: Ai 192.168.49.2 în hosts, dar pentru port-forward trebuie 127.0.0.1"
echo ""
echo "Rulează următoarea comandă pentru a corecta:"
echo ""
echo "sudo sed -i '' 's/192.168.49.2.*myapp.local/127.0.0.1       myapp.local/' /etc/hosts"
echo ""
echo "SAU editează manual /etc/hosts și schimbă:"
echo "  192.168.49.2    myapp.local"
echo "în:"
echo "  127.0.0.1       myapp.local"
echo ""
echo "După corectare, accesează: http://myapp.local:8081"

