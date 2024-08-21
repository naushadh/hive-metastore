define HELP

Available commands:

- build: Build this project

- env-up: Boot up development environment

- test: Run all tests

- env-down: Tear down development environment

- help: Display this help message

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

build:
	docker compose pull
	docker compose build
.PHONY: build

env-up: build
	docker compose up --detach
	while ! (docker compose logs app | grep 'Starting Metastore'); do sleep 1 && printf .; done
.PHONY: env-up

test:
	docker compose run --no-deps --rm test
.PHONY: test

env-down:
	docker compose down
.PHONY: env-down
