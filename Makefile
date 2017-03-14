REPO?=mutterio
NAME=mini-openresty

BUILD_NUMBER?=0
TAG?=latest
IMAGE_BASE=${REPO}/${NAME}

build: Dockerfile
	docker build -t ${NAME}:${TAG} .

tag: build
	docker tag ${NAME}:${TAG} ${IMAGE_BASE}:${TAG}

publish: tag
	docker push ${IMAGE_BASE}:${TAG}
