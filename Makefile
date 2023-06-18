# Env files can be used to override any variable defaults
# (e.g., DOCKER_SPECIFIC_ENV_PATH=config/docker/env/base.env DOCKER_SPECIFIC_ENV_PATH=config/docker/env/local.env make do-something)
ifdef DOCKER_COMMON_ENV_PATH
include $(DOCKER_COMMON_ENV_PATH)
DOCKER_COMMON_ENV_PATH_FROM_PYTHON_DOCKER=$(DOCKER_CTX_FROM_PYTHON_DOCKER)/$(DOCKER_COMMON_ENV_PATH)
endif

ifdef DOCKER_SPECIFIC_ENV_PATH
include $(DOCKER_SPECIFIC_ENV_PATH)
DOCKER_SPECIFIC_ENV_PATH_FROM_PYTHON_DOCKER=$(DOCKER_CTX_FROM_PYTHON_DOCKER)/$(DOCKER_SPECIFIC_ENV_PATH)
endif

export

NAMESPACE ?= local
PROJECT_NAME ?= balancer_backend
PYTHON_VERSION ?= 3.10

DOCKER_APP_DEST ?= /app
DOCKER_CTX_FROM_COMPOSE ?= ../../..
DOCKER_CTX_FROM_PROJECT_ROOT ?= .
DOCKER_CTX_FROM_PYTHON_DOCKER ?= ..
DOCKER_ENTRYPOINT_DEST ?= /entrypoint.sh
DOCKER_LOCAL_CMD ?= /bin/bash
DOCKER_LOG_FOLDER_PATH ?= /root/.$(PROJECT_NAME)/logs
DOCKER_NO_CACHE ?=  # Define with any value to disable caching on build
DOCKER_PROJECT_ROOT_FROM_CTX ?= .
DOCKER_PROJECT_SERVICE_NAME ?= balancer-backend
DOCKER_PYTHON_DOCKER_FROM_CTX ?= Python-Docker
DOCKER_REGISTRY ?= docker.fakecodeforphillydomain.com
DOCKER_TAG_VERSION ?= latest
DOCKER_WATCH ?= # Define with any value to display background deployment

# These are built dyanimcally and used below?
DOCKER_APP_SOURCE_FROM_COMPOSE ?= $(DOCKER_CTX_FROM_COMPOSE)/$(DOCKER_PROJECT_ROOT_FROM_CTX)
DOCKER_COMPOSE_FILE ?= $(DOCKER_CTX_FROM_PYTHON_DOCKER)/$(DOCKER_PROJECT_ROOT_FROM_CTX)/config/docker/compose/docker-compose.$(NAMESPACE).yaml
DOCKER_CONFIG_FOLDER_PATH ?= /root/.$(DOCKER_PROJECT_SERVICE_NAME)/config
DOCKER_ENTRYPOINT_SOURCE_FROM_CTX ?= $(DOCKER_PROJECT_ROOT_FROM_CTX)/config/docker/scripts/$(NAMESPACE)-entrypoint.sh
DOCKER_USER_CONFIG_PATH_FROM_CTX ?= $(DOCKER_PROJECT_ROOT_FROM_CTX)/config
DOCKER_USER_LOCAL_LOG_PATH_FROM_CTX ?= $(DOCKER_PROJECT_ROOT_FROM_CTX)/logs

# No need to do this manually
pull-python-docker:
	if ! [ -d Python-Docker ]; then\
		git clone https://github.com/jusjayson/Python-Docker.git;\
	fi
	cd Python-Docker && git pull;

build-base-image: pull-python-docker
	cd $(DOCKER_CTX_FROM_PROJECT_ROOT)/$(DOCKER_PYTHON_DOCKER_FROM_CTX) && \
		DOCKER_REGISTRY=$(DOCKER_REGISTRY) \
		DOCKER_TAG_VERSION=$(DOCKER_TAG_VERSION) \
		PYTHON_VERSION=$(PYTHON_VERSION) \
		make build-base-image

build-project: pull-python-docker
	cd $(DOCKER_CTX_FROM_PROJECT_ROOT)/$(DOCKER_PYTHON_DOCKER_FROM_CTX) && \
		DOCKER_APP_DEST=$(DOCKER_APP_DEST) \
		DOCKER_CONFIG_FOLDER_PATH=$(DOCKER_CONFIG_FOLDER_PATH) \
		DOCKER_CTX_FROM_PYTHON_DOCKER=$(DOCKER_CTX_FROM_PYTHON_DOCKER) \
		DOCKER_ENTRYPOINT_DEST=$(DOCKER_ENTRYPOINT_DEST) \
		DOCKER_ENTRYPOINT_SOURCE_FROM_CTX=$(DOCKER_ENTRYPOINT_SOURCE_FROM_CTX) \
		DOCKER_LOG_FOLDER_PATH=$(DOCKER_LOG_FOLDER_PATH) \
		DOCKER_NO_CACHE=$(DOCKER_NO_CACHE) \
		DOCKER_PROJECT_ROOT_FROM_CTX=$(DOCKER_PROJECT_ROOT_FROM_CTX) \
		DOCKER_REGISTRY=$(DOCKER_REGISTRY) \
		DOCKER_TAG_VERSION=$(DOCKER_TAG_VERSION) \
		DOCKER_USER_CONFIG_PATH_FROM_CTX=$(DOCKER_USER_CONFIG_PATH_FROM_CTX) \
		NAMESPACE=$(NAMESPACE) \
		PROJECT_NAME=$(PROJECT_NAME) \
		make build-project

deploy-project: pull-python-docker
	cd $(DOCKER_CTX_FROM_PROJECT_ROOT)/$(DOCKER_PYTHON_DOCKER_FROM_CTX) && \
		DOCKER_APP_DEST=$(DOCKER_APP_DEST) \
		DOCKER_APP_SOURCE_FROM_COMPOSE=$(DOCKER_APP_SOURCE_FROM_COMPOSE) \
		DOCKER_COMPOSE_FILE=$(DOCKER_COMPOSE_FILE) \
		DOCKER_CONFIG_FOLDER_PATH=$(DOCKER_CONFIG_FOLDER_PATH) \
		DOCKER_CTX_FROM_COMPOSE=$(DOCKER_CTX_FROM_COMPOSE) \
		DOCKER_LOG_FOLDER_PATH=$(DOCKER_LOG_FOLDER_PATH) \
		DOCKER_PROJECT_SERVICE_NAME=$(DOCKER_PROJECT_SERVICE_NAME) \
		DOCKER_REGISTRY=$(DOCKER_REGISTRY) \
		DOCKER_TAG_VERSION=$(DOCKER_TAG_VERSION) \
		DOCKER_USER_CONFIG_PATH_FROM_CTX=${DOCKER_USER_CONFIG_PATH_FROM_CTX} \
		DOCKER_USER_LOCAL_LOG_PATH_FROM_CTX=${DOCKER_USER_LOCAL_LOG_PATH_FROM_CTX} \
		DOCKER_WATCH=$(DOCKER_WATCH) \
		NAMESPACE=$(NAMESPACE) \
		PROJECT_NAME=$(PROJECT_NAME) \
	make deploy-project

teardown-project: pull-python-docker
	cd $(DOCKER_CTX_FROM_PROJECT_ROOT)/$(DOCKER_PYTHON_DOCKER_FROM_CTX) && \
		DOCKER_COMPOSE_FILE=$(DOCKER_COMPOSE_FILE) \
		make teardown-project

launch-local-project: pull-python-docker
	DOCKER_APP_DEST=${DOCKER_APP_DEST} \
	DOCKER_APP_SOURCE_FROM_COMPOSE=$(DOCKER_APP_SOURCE_FROM_COMPOSE) \
	DOCKER_CONFIG_FOLDER_PATH=$(DOCKER_CONFIG_FOLDER_PATH) \
	DOCKER_CTX_FROM_COMPOSE=$(DOCKER_CTX_FROM_COMPOSE) \
	DOCKER_LOG_FOLDER_PATH=$(DOCKER_LOG_FOLDER_PATH) \
	DOCKER_REGISTRY=$(DOCKER_REGISTRY) \
	DOCKER_TAG_VERSION=$(DOCKER_TAG_VERSION) \
	DOCKER_USER_CONFIG_PATH_FROM_CTX={DOCKER_USER_CONFIG_PATH_FROM_CTX} \
	DOCKER_USER_LOCAL_LOG_PATH_FROM_CTX={DOCKER_USER_LOCAL_LOG_PATH_FROM_CTX} \
	NAMESPACE=$(NAMESPACE) \
	PROJECT_NAME=$(PROJECT_NAME) \
	docker compose \
		-f config/docker/compose/docker-compose.local.yaml \
		run -it ${DOCKER_PROJECT_SERVICE_NAME} $(DOCKER_LOCAL_CMD)

init-project:
	cd $(DOCKER_CTX_FROM_PROJECT_ROOT)/$(DOCKER_PYTHON_DOCKER_FROM_CTX) && \
		DOCKER_ABSOLUTE_APP_SOURCE=$(shell realpath ".") \
		DOCKER_REGISTRY=$(DOCKER_REGISTRY) \
		DOCKER_TAG_VERSION=$(DOCKER_TAG_VERSION) \
		PYTHON_VERSION=$(PYTHON_VERSION) \
		make init-project

