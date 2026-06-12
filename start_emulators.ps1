Write-Host "Démarrage des Émulateurs Firebase via Docker Compose..." -ForegroundColor Cyan
docker-compose up -d
Write-Host "Émulateurs Firebase démarrés en arrière-plan !" -ForegroundColor Green
Write-Host "UI de l'Émulateur accessible sur: http://localhost:4000" -ForegroundColor Yellow
