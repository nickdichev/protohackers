image:
	docker build . -t protohackers:latest

container: image
	docker run --rm -p 5555:5555 -p 5556:5556 protohackers:latest

lint:
	mix format --check-formatted
	mix xref graph --label compile-connected --fail-above 0
