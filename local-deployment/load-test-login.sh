#!/bin/bash

# Load test pentru endpoint-ul de login
# Testează backend-ul direct la localhost:8080/auth/login

echo "Load testing login endpoint..."
echo "Endpoint: http://localhost:8080/auth/login"
echo "Requests: 100, Concurrency: 10"
echo ""

hey -n 100 -c 10 \
  -m POST \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"adminpass"}' \
  http://localhost:8080/auth/login

