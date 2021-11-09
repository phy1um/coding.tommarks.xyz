
REPO=https://github.com/phy1um/coding.tommarks.xyz
URL=localhost:8000

build:
	URL=$(URL) REPOSITORY_URL=$(REPO) BRANCH=$(shell git branch --show-current) COMMIT_REF=$(shell git rev-parse HEAD) bash make-site.sh

serve-dev:
	cd http && python -m http.server

