# Directory to dump build tools into
GOBIN=$(shell go env GOPATH)/bin/

.PHONY: help
help: ## - Show help message
	@printf "${CMD_COLOR_ON} usage: make [target]\n\n${CMD_COLOR_OFF}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | sed -e "s/^Makefile://" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: test

test: ## - Run unit tests
	go test -v -race ./...

.PHONY: notice
notice: ## - Generates the NOTICE.txt file.
	@echo "Generating NOTICE.txt"
	@go mod tidy
	@go mod download all
	@env GOBIN=${GOBIN} go install go.elastic.co/go-licence-detector@latest
	go list -m -json all | env PATH="${GOBIN}:${PATH}" go-licence-detector \
		-includeIndirect \
		-rules dev-tools/notice/rules.json \
		-overrides dev-tools/notice/overrides.json \
		-noticeTemplate dev-tools/notice/NOTICE.txt.tmpl \
		-noticeOut NOTICE.txt \
		-depsOut ""
	@# Ensure the go.mod file is left unchanged after go mod download all runs.
	@# go mod download will modify go.sum in a way that conflicts with go mod tidy.
	@# https://github.com/golang/go/issues/43994#issuecomment-770053099
	@go mod tidy
