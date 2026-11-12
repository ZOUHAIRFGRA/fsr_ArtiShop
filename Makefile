# ==========================================
# VARIABLES (Partie B & D)
# ==========================================
PORT    ?= 3000
NPM     ?= npm
NODE    ?= node
URL     ?= http://localhost:$(PORT)

APP     := artishop
VERSION := $(shell $(NODE) -p "require('./package.json').version")
DIST    := dist
ARCHIVE := $(DIST)/$(APP)-$(VERSION).tar.gz
SRC     := $(wildcard src/*.js src/data/*.js public/*)

# ==========================================
# CONDITIONS D'INSTALLATION (Partie E)
# ==========================================
ifeq ($(CI), true)
    INSTALL_CMD := $(NPM) ci
else
    INSTALL_CMD := $(NPM) install
endif

# Déclaration des cibles actions (Partie A)
.PHONY: help install start dev test clean health package start-bg stop status restart ci

# ==========================================
# AIDE AUTOMATIQUE (Partie F) - Doit être la première cible
# ==========================================
help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*## "}; {printf " make %-10s %s\n", $$1, $$2}'
# ==========================================
# REGLES & BUILD INCREMENTAL (Partie A & C)
# ==========================================
node_modules: package.json package-lock.json
	$(INSTALL_CMD)
	@touch $@

install: node_modules ## Installe les dépendances du projet

start: node_modules ## Lance l'application en production
	PORT=$(PORT) $(NPM) start

dev: node_modules ## Lance l'application en mode développement
	PORT=$(PORT) $(NPM) run dev

test: node_modules ## Lance la suite de tests
	$(NPM) test

clean: ## Supprime le dossier dist et les fichiers .log
	rm -rf dist *.log

health: ## Interroge la route health pour vérifier si le site répond
	@curl -fsS $(URL)/health || (echo "ArtiShop ne répond pas sur $(URL)" && exit 1)

# ==========================================
# LIVRABLE & ARCHIVE (Partie D)
# ==========================================
$(DIST):
	mkdir -p $@

$(ARCHIVE): $(SRC) package.json package-lock.json README.md | $(DIST)
	tar -czf $@ src public package.json package-lock.json README.md

package: $(ARCHIVE) ## Construit l'archive à livrer

# ==========================================
# PILOTAGE DU SERVEUR EN ARRIERE-PLAN (Partie F)
# ==========================================
start-bg: node_modules ## Lance le serveur en arrière-plan
	@if kill -0 $$(cat .artishop.pid 2>/dev/null) 2>/dev/null; then echo "Serveur déjà lancé"; exit 1; fi
	PORT=$(PORT) $(NODE) src/server.js > artishop.log 2>&1 & \
	echo $$! > .artishop.pid

stop: ## Arrête le serveur en arrière-plan
	@kill $$(cat .artishop.pid 2>/dev/null) 2>/dev/null || true
	@rm -f .artishop.pid

status: ## Indique si le serveur tourne
	@kill -0 $$(cat .artishop.pid 2>/dev/null) 2>/dev/null && echo "Serveur en cours d'exécution" || echo "Serveur arrêté"

restart: ## Redémarre le serveur
	$(MAKE) stop
	$(MAKE) start-bg

ci: ## Lance la chaîne d'intégration continue
	$(MAKE) CI=true install test package