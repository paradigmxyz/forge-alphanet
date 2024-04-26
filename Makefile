.PHONY: setup
setup:
	git submodule update --init --recursive

.PHONY: build
build: setup
	docker run --rm \
		-v $$(pwd):/app/foundry \
		-u $$(id -u):$$(id -g) \
		ghcr.io/fgimenez/eip3074-tools:latest \
		--foundry-directory /app/foundry \
		--foundry-command build

.PHONY: test
test: setup
	docker run --rm \
		-v $$(pwd):/app/foundry \
		-u $$(id -u):$$(id -g) \
		ghcr.io/fgimenez/eip3074-tools:latest \
		--foundry-directory /app/foundry \
		--foundry-command "test -vvv"
