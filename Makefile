build: Dockerfile
	docker build -t mini-openresty .

tag: build
	docker tag -f mini-openresty mutterio/mini-openresty

publish: tag
	docker push mutterio/mini-openresty
