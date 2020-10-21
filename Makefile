image_name := gqdev

build:
	DOCKER_BUILDKIT=1 docker build -t $(image_name) .
