PROJECT=blog-builder
TEAM=amaaai
PACKAGE_NAME=blog_builder
PYTHON_LOC=blog_builder
IMAGE_TAG=latest
DOCKER_IMAGE=${PACKAGE_NAME}:${IMAGE_TAG}
DOCKERFILE=Dockerfile
DOCKER_WORKING_DIR="/mount_dir"

GIT_COMMIT=$(shell git rev-parse --short=20 HEAD)


default: help
help:
	@echo 'Usage: make [target] ...'
	@echo
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "%-35s %s\n", $$1, $$2}'

#----------- DOCKER ------------------------------------------------------------
DOCKER_ARGS= \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \

docker-build: ## Build our variant of the blog docker image
	docker build \
	-t ${DOCKER_IMAGE} \
	-f docker/$(DOCKERFILE) .

docker-mypy: ## Run mypy inside of docker, intended to be used both from jenkins or locally
	docker run \
	--entrypoint="/bin/bash" \
	-v $(PWD)/:/blog \
	${DOCKER_ARGS} \
	$(DOCKER_IMAGE) \
	-c 'mypy --show-error-codes $(PYTHON_LOC)'

docker-pylint: ## Run pylint inside of docker.
	docker run \
	--entrypoint="/bin/bash" \
	-v $(PWD)/:/blog \
	${DOCKER_ARGS} \
	$(DOCKER_IMAGE) \
	-c 'python -m pylint -f parseable --rcfile=setup.cfg -j 4 $(PYTHON_LOC)'

docker-test-formatting: ### Run all the formatting inside of docker.
	docker run \
	--entrypoint="" \
	-v $(PWD)/:/blog \
	${DOCKER_ARGS} \
	$(DOCKER_IMAGE) \
	make test-formatting

docker-test-unit: ### Run test inside of docker, intended to be used both from jenkins or locally
	docker run \
	--entrypoint="/bin/bash" \
	-v $(PWD)/:/blog \
	${DOCKER_ARGS} \
	$(DOCKER_IMAGE) \
	-c 'python -m pytest test $(PYTHON_LOC) -m "not integration"'

docker-test-integration: ### Run IT inside of docker
	docker run \
	--entrypoint="/bin/bash" \
	-v $(PWD)/:/blog \
	${DOCKER_ARGS} \
	$(DOCKER_IMAGE) \
	-c 'python -m pytest test $(PYTHON_LOC) -m "integration"'

#----------- Terraform ------------------------------------------------------
validate-%: ### Run terraform validate. Valid versions are validate-nonprod or validate-production
	docker run -i $(TERRAFORM_DOCKER_ARGS) \
	./scripts/validate.sh $*;

plan-%: ### Runs terraform plan. Valid versions are plan-nonprod or plan-production
	docker run -i $(TERRAFORM_DOCKER_ARGS) \
	./scripts/plan.sh $* ${GIT_COMMIT}; \

deploy-%: ### Runs terraform plan and apply . Valid versions are deploy-nonprod or deploy-production
	docker run -i $(TERRAFORM_DOCKER_ARGS) \
	./scripts/deploy.sh $* ${GIT_COMMIT}; \

destroy-%: ### Runs terraform destroy . Valid versions are destroy-nonprod or destroy-production
	docker run -i $(TERRAFORM_DOCKER_ARGS) \
	./scripts/destroy.sh $*; \

#----------- RUN ------------------------------------------------------------

run-blog-builder:  ## Execute blog builder
	docker run \
	${DOCKER_ARGS} \
	-v $(PWD)/:${DOCKER_WORKING_DIR} \
	-e PYTHONPATH=. \
	-w ${DOCKER_WORKING_DIR} \
	$(DOCKER_IMAGE) \
	python3 -m blog_builder.cli

#----------- PYTHON ------------------------------------------------------------

black: ### Tests all the formatting.
	black -l 120  ${PYTHON_LOC} test --exclude version.py

isort: ## Sorts all the python code.
	isort -l120 -m3 -tc -rc $(PYTHON_LOC) test

#----------- TEST ------------------------------------------------------------

test-pylint: ### Tests pylint.
	pylint -f parseable --rcfile=setup.cfg -j 4 $(PYTHON_LOC) --ignore-patterns=test_.*?py

test-mypy: ### Tests the typing
	mypy --show-error-codes $(PYTHON_LOC)

test-black: ### Tests all the formatting.
	black -l 120  ${PYTHON_LOC} --check

test-isort: ### Tests the sorting.
	isort -l120 -m3 -tc -rc -c ${PYTHON_LOC}

test-formatting: ### Tests all the formatting.
	@$(PRE_ACTIVATE) $(MAKE) -j8 --no-print-directory \
	test-black \
	test-isort \
	test-mypy \
	test-pylint
