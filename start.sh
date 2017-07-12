docker run -it --name pokemon-webhook -d -p 8000:4567 -v $PWD/commands:/usr/src/app/commands -v $PWD/config:/usr/src/app/config --env-file config/environment pokemon-webhook
