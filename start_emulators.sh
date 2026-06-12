#!/bin/bash
echo "Démarrage des Émulateurs Firebase via Docker Compose..."
docker-compose up -d
echo "Émulateurs Firebase démarrés en arrière-plan !"
echo "UI de l'Émulateur accessible sur: http://localhost:4000"
