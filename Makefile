# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mokutucu <mokutucu@student.42berlin.de>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/20 12:25:06 by mokutucu          #+#    #+#              #
#    Updated: 2026/01/20 13:31:31 by mokutucu         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

SHELL := /bin/bash

COMPOSE_FILE := srcs/docker-compose.yml
ENV_FILE     := srcs/.env

DATA_DIR := /goinfre/mokutucu/data
DB_DIR   := $(DATA_DIR)/mariadb
WP_DIR   := $(DATA_DIR)/wordpress

COMPOSE  := docker compose -p srcs --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

.PHONY: all up down clean fclean re

all: up

up:
	@echo ">> Ensuring host data directories exist under $(DATA_DIR)"
	mkdir -p "$(DB_DIR)" "$(WP_DIR)"
	chmod 777 "$(DB_DIR)" "$(WP_DIR)" || true
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean:
	@echo ">> Removing containers/images/volumes/networks (best-effort)"
	@docker ps -qa | xargs -r docker stop >/dev/null 2>&1 || true
	@docker ps -qa | xargs -r docker rm -f >/dev/null 2>&1 || true
	@docker images -qa | xargs -r docker rmi -f >/dev/null 2>&1 || true
	@docker volume ls -q | xargs -r docker volume rm >/dev/null 2>&1 || true
	@docker network ls -q | xargs -r docker network rm >/dev/null 2>&1 || true
	@echo ">> Clearing bind-mounted data under $(DATA_DIR)"
	@docker run --rm -v "$(DB_DIR)":/data alpine:3.19 sh -lc 'chmod -R a+rwx /data || true; rm -rf /data/*' >/dev/null 2>&1 || true
	@docker run --rm -v "$(WP_DIR)":/data alpine:3.19 sh -lc 'chmod -R a+rwx /data || true; rm -rf /data/*' >/dev/null 2>&1 || true
	@rm -rf "$(DB_DIR)" "$(WP_DIR)" || true

re: fclean up