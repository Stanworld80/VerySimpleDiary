# Very Simple Diary - Script de validation et de test pour PowerShell
# Utilisation : .\run_tests.ps1 <command>
# Commandes disponibles : setup, clean, build-runner, test-unit, test-firestore, test-mcp, test-integration, test-web, test-all

param (
    [string]$Action = "help"
)

function Show-Help {
    Write-Host "Very Simple Diary - Commandes de validation et de test en PowerShell" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\run_tests.ps1 setup            - Installe toutes les dépendances (Flutter + npm)"
    Write-Host "  .\run_tests.ps1 build-runner     - Génère le code Riverpod et Drift"
    Write-Host "  .\run_tests.ps1 clean            - Nettoye le projet Flutter"
    Write-Host "  .\run_tests.ps1 test-unit        - Exécute les tests unitaires / widget Flutter"
    Write-Host "  .\run_tests.ps1 test-firestore   - Exécute les tests des règles de sécurité Firestore"
    Write-Host "  .\run_tests.ps1 test-mcp         - Exécute les tests du serveur MCP"
    Write-Host "  .\run_tests.ps1 test-integration - Exécute les tests d'intégration E2E Flutter"
    Write-Host "  .\run_tests.ps1 test-web         - Exécute les tests d'intégration sur Chrome (Web)"
    Write-Host "  .\run_tests.ps1 test-all         - Lance l'ensemble des suites de tests"
}

switch ($Action) {
    "setup" {
        Write-Host "--> Installation des dépendances Flutter..." -ForegroundColor Yellow
        flutter pub get
        Write-Host "--> Installation des dépendances pour les tests Firestore..." -ForegroundColor Yellow
        Push-Location test\firestore_rules_test
        npm install
        Pop-Location
        Write-Host "--> Installation des dépendances pour le serveur MCP..." -ForegroundColor Yellow
        Push-Location mcp_server
        npm install
        Pop-Location
        Write-Host "Installation terminée avec succès." -ForegroundColor Green
    }
    "clean" {
        Write-Host "--> Nettoyage du projet Flutter..." -ForegroundColor Yellow
        flutter clean
        flutter pub get
    }
    "build-runner" {
        Write-Host "--> Génération de code (Riverpod, Drift)..." -ForegroundColor Yellow
        flutter pub run build_runner build --delete-conflicting-outputs
    }
    "test-unit" {
        Write-Host "--> Exécution des tests unitaires Flutter..." -ForegroundColor Yellow
        flutter test
    }
    "test-firestore" {
        Write-Host "--> Exécution des tests de sécurité Firestore..." -ForegroundColor Yellow
        npx firebase emulators:exec --only firestore "npm --prefix test/firestore_rules_test run test"
    }
    "test-mcp" {
        Write-Host "--> Exécution des tests du serveur MCP..." -ForegroundColor Yellow
        npm --prefix mcp_server run test
    }
    "test-integration" {
        Write-Host "--> Exécution des tests d'intégration E2E..." -ForegroundColor Yellow
        flutter test integration_test/app_e2e_test.dart
    }
    "test-web" {
        Write-Host "--> Exécution des tests d'intégration Web..." -ForegroundColor Yellow
        flutter test -d chrome integration_test/app_e2e_test.dart
    }
    "test-all" {
        Write-Host "--> Exécution de TOUTES les suites de tests..." -ForegroundColor Green
        Write-Host "[1/4] Tests Unitaires Flutter..." -ForegroundColor Cyan
        flutter test
        if ($LASTEXITCODE -ne 0) { throw "Les tests unitaires ont échoué." }

        Write-Host "[2/4] Tests de sécurité Firestore..." -ForegroundColor Cyan
        npx firebase emulators:exec --only firestore "npm --prefix test/firestore_rules_test run test"
        if ($LASTEXITCODE -ne 0) { throw "Les tests Firestore ont échoué." }

        Write-Host "[3/4] Tests du serveur MCP..." -ForegroundColor Cyan
        npm --prefix mcp_server run test
        if ($LASTEXITCODE -ne 0) { throw "Les tests du serveur MCP ont échoué." }

        Write-Host "[4/4] Tests d'intégration E2E..." -ForegroundColor Cyan
        flutter test integration_test/app_e2e_test.dart
        if ($LASTEXITCODE -ne 0) { throw "Les tests d'intégration ont échoué." }

        Write-Host "Félicitations, tous les tests ont réussi !" -ForegroundColor Green
    }
    Default {
        Show-Help
    }
}
