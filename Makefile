# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mokutucu <mokutucu@student.42berlin.de>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/20 12:25:06 by mokutucu          #+#    #+#              #
#    Updated: 2026/01/20 15:21:24 by mokutucu         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

SHELL := /bin/bash

COMPOSE_FILE := srcs/docker-compose.yml
ENV_FILE     := srcs/.env

DATA_DIR := /home/mokutucu/data
DB_DIR   := $(DATA_DIR)/mariadb
WP_DIR   := $(DATA_DIR)/wordpress

COMPOSE  := docker compose -p srcs --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

.PHONY: all up down clean fclean re

all: up

up:
	@echo ">> Ensuring host data directories exist under $(DATA_DIR)"
	mkdir -p "$(DB_DIR)" "$(WP_DIR)"
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean:
	docker stop $$(docker ps -qa); \
	docker rm $$(docker ps -qa); \
	docker rmi -f $$(docker images -qa); \
	docker volume rm $$(docker volume ls -q); \
	docker network rm $$(docker network ls -q) 2>/dev/null; \
	rm -rf "$(DB_DIR)" "$(WP_DIR)"

re: fclean up