.PHONY: install start dev test clean

install:
	npm install

start:
	npm start

dev:
	npm run dev

test:
	npm test

clean:
	rm -rf dist .log