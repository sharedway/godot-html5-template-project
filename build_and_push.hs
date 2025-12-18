#!/bin/bash

python3 bump_version.py
godot45 --export-release HTML5 --headless

# rsync -azv builds/web/assets/ deploy@10.8.0.11:/home/deploy/gamerstash_api/gamerstash_src/static/pixpool/assets/
docker stop pixpool_game
docker rm pixpool_game
docker build . -t registry.hostcert.com.br/deploy/pixpool:latest --push
docker create --name pixpool_game --restart always -p 10.8.0.3:7073:80 registry.hostcert.com.br/deploy/pixpool:latest
docker start pixpool_game
