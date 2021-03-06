# Scaffolded docker env for laravel 6.2 + vue 2.6.11 application

## Prerequisites:
 - docker
 - docker-compose
 - make(build-essentials)
## Instructions:
 - copy .env.example into .env file and pass the missing variables(see comments in .env file)
 - `make docker-env`
 - Check the `SERVER_NAME` and `API_SERVER_NAME` urls provided earlier in .env file with your browser.

You can find possible commands inside `makefile`. Just run `make` inside project's directory

## Frequently used commands:

 - Spin up containers
```bash
$ make up
```

 - Halt containers
```bash
$ make down
```

 - Restart containers
```bash
$ make restart
```

 - Dive into laravel container cli
```bash
$ make console-laravel
```

 - Watch and rebuild files for vue app
```bash
$ make watch
```
