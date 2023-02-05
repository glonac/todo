#!make
include .env
export $(shell sed 's/=.*//' .env)
RED='\033[0;31m'        #  ${RED}
GREEN='\033[0;32m'      #  ${GREEN}
BOLD='\033[1;m'          #  ${BOLD}
WARNING=\033[37;1;41m  #  ${WARNING}
END_COLOR='\033[0m'       #  ${END_COLOR}

.PHONY: clone rebuild up stop restart status console-app console-db logs logs-app logs-db help

docker-env: clone up

deploy: rebuild up


clone: clone-auth-service clone-todo-service

clone-auth-service:
	@echo "\n\033[01;33m Cloning auth-service repository \033[0m"
	@bash -c "if [ -d ./auth-service ]; then cd ./auth-service && git fetch && git checkout main && git reset --hard origin/main; else git clone -b main git@github.com:glonac/auth-service.git ./auth-service; fi"

clone-todo-service:
	@echo "\n\033[01;33m Cloning todo-service repository  \033[0m"
	@bash -c "if [ -d ./todo-service ]; then cd ./todo-service && git fetch && git checkout main && git reset --hard origin/main; else git clone -b main git@github.com:glonac/todo-service.git ./todo-service; fi"


rebuild: stop
	@echo "\n\033[1;m Rebuilding containers... \033[0m"
	@docker build -t auth-service:latest auth-service/
	@docker build -t todo-service:latest todo-service/
	@docker-compose ${COMPOSE_PROJECT_NAME} build --no-cache

up:
	@echo "\n\033[1;m Spinning up containers for ${ENVIRONMENT} environment... \033[0m"
	@docker-compose ${COMPOSE_PROJECT_NAME} up -d
	@$(MAKE) --no-print-directory status

stop:
	@echo "\n\033[1;m Halting containers... \033[0m"
	@docker-compose  ${COMPOSE_PROJECT_NAME} stop

restart: stop up

up-dev:
	@echo "\n\033[1;m Spinning up containers for ${ENVIRONMENT} environment... \033[0m"
	@docker-compose -f docker-compose.dev.yml up -d
	@$(MAKE) --no-print-directory status


down:
	echo "\n\033[1;m Removing containers... \033[0m"
	@docker-compose  ${COMPOSE_PROJECT_NAME} down

status:
	@echo "\n\033[1;m Containers statuses \033[0m"
	@docker-compose  ${COMPOSE_PROJECT_NAME} ps

todo-console:
	@docker-compose  ${COMPOSE_PROJECT_NAME} exec todo-service sh
auth-console:
	@docker-compose  ${COMPOSE_PROJECT_NAME} exec auth-service sh

logs:
	@docker-compose logs --tail=1000 -f

help:
	@echo "\033[1;32mdocker-env\t\t- Main scenario, used by default\033[0m"

	@echo "\n\033[1mMain section\033[0m"
	@echo "clone\t\t\t- clone app repo"

	@echo "rebuild\t\t\t- build containers w/o cache"
	@echo "up\t\t\t- start project"
	@echo "stop\t\t\t- stop project"
	@echo "restart\t\t\t- restart containers"
	@echo "status\t\t\t- show status of containers"
