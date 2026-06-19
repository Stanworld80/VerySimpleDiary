# Makefile for Very Simple Diary Asynchronous Validation Loop
.PHONY: setup clean build-runner test-unit test-firestore test-mcp test-integration test-web test-all help

help:
	@echo "Very Simple Diary - Commandes de validation et de test"
	@echo ""
	@echo "Usage:"
	@echo "  make setup             Installe toutes les dépendances (Flutter + npm)"
	@echo "  make build-runner      Génère le code Riverpod et Drift"
	@echo "  make clean             Nettoye le projet Flutter"
	@echo "  make test-unit         Exécute les tests unitaires / widget Flutter"
	@echo "  make test-firestore    Exécute les tests des règles de sécurité Firestore"
	@echo "  make test-mcp          Exécute les tests du serveur MCP"
	@echo "  make test-integration  Exécute les tests d'intégration E2E Flutter"
	@echo "  make test-web          Exécute les tests d'intégration sur Chrome (Web)"
	@echo "  make test-all          Lance l'ensemble des suites de tests"

setup:
	flutter pub get
	cd test/firestore_rules_test && npm install
	cd mcp_server && npm install

clean:
	flutter clean
	flutter pub get

build-runner:
	flutter pub run build_runner build --delete-conflicting-outputs

test-unit:
	flutter test

test-firestore:
	npx firebase emulators:exec --only firestore "npm --prefix test/firestore_rules_test run test"

test-mcp:
	npm --prefix mcp_server run test

test-integration:
	flutter test integration_test/app_e2e_test.dart

test-web:
	flutter test -d chrome integration_test/app_e2e_test.dart

test-all: test-unit test-firestore test-mcp test-integration
