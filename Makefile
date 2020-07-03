compile: 
	@npx elm make src/Main.elm --optimize --output=main.js

unit-test:
	@npx elm-test 

e2e-test: 
	@make dev && npm run integration:test

tidyup:
	@sudo lsof -ti :8000 | xargs kill -9