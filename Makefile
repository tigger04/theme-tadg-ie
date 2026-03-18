# ABOUTME: Makefile for tadg_ie Hugo theme — build, test, and release targets
# ABOUTME: Provides standard entry points so users can run make test without framework knowledge

SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

.PHONY: help test test-one-off build clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

test: ## Run regression tests
	@bash tests/regression/run_tests.sh

test-one-off: ## Run one-off tests (optionally filter by ISSUE=NNN)
ifdef ISSUE
	@bash tests/one_off/run_tests.sh "$(ISSUE)"
else
	@bash tests/one_off/run_tests.sh
endif

build: ## Build the example site
	@cd exampleSite && hugo --themesDir ../..

clean: ## Remove build artifacts
	@rm -rf exampleSite/public tests/regression/fixtures/.hugo_build.lock tests/regression/fixtures/public
