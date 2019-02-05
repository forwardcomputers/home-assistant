MAKEFLAGS			+= --warn-undefined-variables --no-print-directory --no-builtin-rules
SHELL				:= bash
.SHELLFLAGS			:= -eu -o pipefail -c
.DEFAULT_GOAL		:= help
#
export NC			:= \033[0m
export BLACK		:= \033[30m
export BLUE			:= \033[34m
export GREEN		:= \033[32m
export CYAN			:= \033[36m
export PURPLE		:= \033[35m
export RED			:= \033[31m
export WHITE		:= \033[37m
export YELLOW		:= \033[1;33m
#
export CONTAINER_ID	:= $(shell docker container ls --all > /dev/null 2>&1 | grep homeassistant | awk '{print $$1}')
#
.PHONY: help
help: ## Show this help message
	@printf '%b' '\nUsage:\n  ${GREEN}make ${YELLOW}[target]${NC}\n\nTargets:\n' ;\
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; { printf "  ${GREEN}%-15s${YELLOW}%s${NC}\n", $$1, $$2} ' ;\
	printf '\n'

.PHONY: push
push: ## Push to github
	@git add . ;\
	git commit -a -m "updates" ;\
	git push origin master

.PHONY: pull
pull: ## Pull from github
	@git pull origin master

.PHONY: start
start: ## Start docker container
	@docker container start ${CONTAINER_ID} > /dev/null

.PHONY: restart
restart: ## Restart docker container
	@docker container restart ${CONTAINER_ID} > /dev/null

.PHONY: stop
stop: ## Stop docker container
	@docker container stop ${CONTAINER_ID} > /dev/null

#	mkdir -p /config/packages/firetv/ ;\
#	cp -f .circleci/test.adbkey /config/packages/firetv/adbkey ;\
#	cp -f .circleci/test.adbkey.pub /config/packages/firetv/adbkey.pub ;\

.PHONY: test
test:
	@cp -f .circleci/test.secrets config/secrets.yaml ;\
	cp -f .circleci/test.adbkey config/packages/firetv/adbkey ;\
	hass -c ./config --script check_config --info all

.PHONY: redact
redact: ## Redact secrets file
	@sed -e 's/_lat:.*$$/_lat: 0/' \
    -e 's/_lng:.*$$/_lng: 0/' \
    -e 's/_name:.*$$/_name: johndoe/' \
    -e 's/_password:.*$$/_password: deadbeef/' \
    -e 's/_ip:.*$$/_ip: 127.0.0.1/' \
    -e 's/_url:.*$$/_url: http:\/\/127.0.0.1/' \
    -e 's/_mac:.*$$/_mac: 12:34:56:78:90:AB/' \
    -e 's/_email:.*$$/_email: john@doe.com/' \
    -e 's/_key:.*$$/_key: 1234567890ABCDEFGHIJKLMNOPQRTUVWXYZ/' \
    config/secrets.yaml > .circleci/test.secrets

.PHONY: update
update: ## Update scripts
	@printf '%b' '${GREEN}***** Updating other files *****${NC}\n' ;\
	cd config ;\
	. script/update_various_files.sh

