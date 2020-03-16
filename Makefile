include .env
export $(shell sed 's/=.*//' .env)
.PHONY: help docker-env nginx-config

.DEFAULT_GOAL := help
RUN = docker-compose run --rm
START = docker-compose up -d
STOP = docker-compose stop
LOGS = docker-compose logs
EXEC = docker-compose exec
STATUS = docker-compose -f docker-compose.yml ps

# Spin up docker-env
docker-env: nginx-config ssl build-all composer-install yarn-install migrations seeds up hosts

# BUILDS SECTION
build-all: build-laravel build-vue build-nginx

build-laravel:
	@docker build \
	-t ${APP_NAME}-php:latest ./laravel

build-vue:
	@docker build \
	-t ${APP_NAME}-vue:latest ./vue

build-nginx: nginx-config ssl
	@docker build --no-cache -t ${APP_NAME}-nginx:latest ./nginx

# CONTAINERS MANAGEMENT
up:
	@echo "\n\033[0;33m Spinning up docker environment... \033[0m"
	@$(START)
	@$(MAKE) --no-print-directory status

down:
	@echo "\n\033[0;33m Halting containers... \033[0m"
	@$(STOP)
	@$(MAKE) --no-print-directory status

# just alias for down
stop: down

restart:
	@echo "\n\033[0;33m Restarting containers... \033[0m"
	@$(STOP)
	@$(START)
	@$(MAKE) --no-print-directory status

clean:
	@echo "\033[1;31m\033[5m\t\t\t WARNING! \033[0m"
	@echo "\033[1;31m\033[5m Removing all containers and Applications source directories! \033[0m"
	@echo "\033[1;31m\033[5m Ensure that you have pushed your changes to origin \033[0m"
	@echo "\033[1;31m\033[5m\t\t Are you sure to proceed? \033[0m"
	@$(MAKE) --no-print-directory dialog
	@docker-compose -f  docker-compose.yml down --rmi all 2> /dev/null
	@sudo rm -rf nginx/configs/conf.d/*.conf
	@$(MAKE) --no-print-directory status

status:
	@echo "\n\033[0;33m Containers statuses \033[0m"
	@$(STATUS)
logs:
	@echo "\n\033[0;33m Containers logs \033[0m"
	@$(LOGS)


# reload nginx config
reload:
	@$(EXEC) nginx nginx -s reload

# run laravel seeds
seeds:
	@$(RUN) -u www-data laravel php artisan db:seed

# install php dependancies
composer-install:
	@$(RUN) -T -u www-data laravel composer install

# run laravel migrations
migrations:
	@$(RUN) -u www-data laravel php artisan migrate

# install js dependancies
yarn-install:
	@$(RUN) -T vue yarn

# build js artefacts
vue-build: 
	@$(RUN) -T vue vue-cli-service build

# watch js artefacts and build on change
vue-watch:
	@$(RUN) -T vue vue-cli-service watch

# cli inside nginx container
console-nginx:
	@$(EXEC) nginx bash

# cli inside laravel container
console-laravel:
	@$(EXEC) laravel bash

# cli inside vue container
console-vue:
	@$(EXEC) vue bash

# cli inside db container
console-db:
	@$(EXEC) db bash

## Logs section

logs-db:
	@$(LOGS) db
logs-laravel:
	@$(LOGS) laravel
logs-vue:
	@$(LOGS) vue
logs-nginx:
	@$(LOGS) nginx

# "R U SHURE" Message
dialog:
	@bash ./bin/dialog

# Make configs for nginx
nginx-config: ssl
	@echo "\n\033[0;33m Generating nginx config...\033[0m"
	@bash ./bin/nginx-config

# Generate SSL sertificates for our sites
generate-ssl:
	@echo "\n\033[0;33mGenerating SSL certificates\033[0m"
	@. ./bin/ssl

remove-ssl:
	@echo "\n\033[0;33mRemoving SSL certificates\033[0m"
	@rm -Rf ./nginx/ssl/server*

reissue-ssl: remove-ssl generate-ssl

# alias
ssl: generate-ssl

# Adds local domains to hosts so wee can reach it via our SERVER_NAME env variable. Also, If it's already there, sed will remove it first
hosts:
	@echo "\033[0;33m Adding records into your local hosts file.\033[0m"
	@echo "\033[0;33m *please use your local sudo password.\033[0m"
	@sudo sed -i '' '/${SERVER_NAME}/d' /etc/hosts 2> /dev/null; true
	@sudo sed -i '/${SERVER_NAME}/d' /etc/hosts 2>/dev/null; true
	@sudo echo '127.0.0.1 localhost '${SERVER_NAME}' '${API_SERVER_NAME}'' | sudo tee -a /etc/hosts

help:
	@echo "\033[1;34mContainer management section\033[0m"
	@echo "\033[1;12mdocker-env\033[0m\t\t- spin up docker environment preparing all you need for development"
	@echo "up\t\t\t- start project"
	@echo "stop/down\t\t- stop project"
	@echo "restart\t\t\t- restart containers"
	@echo "status\t\t\t- show status of containers"
	@echo "nginx-config\t\t- generates nginx config file based on .env parameters"
	@echo "\033[1;31mclean\t\t\t- !!! Purge all Local application data!!!\033[0m"

	@echo "\n\033[1;34mConsole section\033[0m"
	@echo "console-laravel\t\t- run bash console for laravel container"
	@echo "console-vue\t\t- run bash console for vue container"

	@echo "console-db\t\t- run bash console for mysql container"
	@echo "console-nginx\t\t- run bash console for web server container"

	@echo "\n\033[1;34mLogs section\033[0m"
	@echo "logs\t\t\t- Logs from all containers"
	@echo "logs-nginx\t\t- show web server logs"
	@echo "logs-db\t\t\t- show database logs"
	@echo "logs-laravel\t\t- show laravel logs"
	@echo "logs-vue\t\t- show vue logs"
	@echo "\n\033[0;33mhelp\t\t\t- show this menu\033[0m"