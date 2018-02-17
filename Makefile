IMAGE = gitmesh-ui:dev

RUN = docker run -it --rm \
	  -p 3000:3000 \
	  -v $(PWD):/src \
	  $(IMAGE)

.PHONY: it
it: image deps build dev

# Development

.PHONY: image
image:
	@docker build -t $(IMAGE) .

.PHONY: shell
shell:
	$(RUN) bash

.PHONY: deps
deps:
	$(RUN) npm run reinstall

.PHONY: build
build:
	$(RUN) npm run prebuild
	$(RUN) npm run build

.PHONY: dev
dev:
	$(RUN) npm run dev

.PHONY: clean
clean:
	@rm -rf node_modules
	@rm -rf elm-stuff
	@rm -rf dist
