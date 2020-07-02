compile: 
	@npx elm make src/Main.elm --optimize --output=main.js

serve:
	@npx elm reactor

unit-test:
	@npx elm-test 

dev: 
	@make compile && make serve

e2e-test: 
	@make dev && npm run integration:test

tidyup:
	@sudo lsof -ti :8000 | xargs kill -9