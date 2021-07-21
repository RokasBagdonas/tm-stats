# Aliases =====================================================================
ddown = docker-compose down --remove-orphans
dtest = docker-compose -f docker-compose.test.yml
dmanage = docker-compose run api python manage.py
initial_data_path = ./mars_api/data_import/terra-mars-initial-data.csv

# General =====================================================================
install: build migrate import_initial_data collectstatic

prod-install: prod-build migrate import_initial_data collectstatic

export-secrets:
	# git-crypt unencrypt secrets.env
	# export

prod-build:
	docker-compose build --file docker-compose.prod.yml --env-file ./secrets.env;

build:
	docker-compose build

up:
	docker-compose up
up-no-f:
	docker-compose up api db rabbitmq

down:
	$(ddown)

import_initial_data:
	$(dmanage) import_initial_data $(initial_data_path)

dmanage:
	$(dmanage) $(cmd) $(flag);

# API =========================================================================
api-rebuild:
	$(ddown)
	docker image rmi tm-stats_web && docker-compose build

# DB ==========================================================================
migrate:
	$(dmanage) migrate $(flags);

reset_migrate:
	$(dmanage) migrate api 0003 --fake;
	$(dmanage) migrate;

migzero:
	$(dmanage) migrate mars_api zero;

makemigrations:
	$(dmanage) makemigrations;
	$(ddown)

flush:
	$(dmanage) flush;

psql:
	#docker exec -it $(container_id) psql -h db mars martian
	pgcli -h $(db_ip) -U martian -d mars

# Testing =====================================================================
test-build:
	$(dtest) build

test:
	 $(dtest) run --rm test-web pytest $(path)

test-player:
	$(dtest) build && $(dtest) run --rm test-web pytest tests/*/test_player.py

shell:
	$(dmanage) shell_plus --ipython --print-sql

shell-test:
	$(dtest) run --rm web python manage.py shell_plus --ipython

# Utility =======================================================================
c-shell:
	docker exec -it $(container_id) /bin/bash

api-shell:
	docker exec -it $(container_id) /bin/bash

clear:
	docker system prune

collectstatic:
	$(dmanage) collectstatic;
	#$(ddown)
