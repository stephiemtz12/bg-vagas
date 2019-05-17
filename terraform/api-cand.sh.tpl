#!/bin/bash

set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
DATA=$(date '+%Y-%m-%d %H:%M:%S')

echo "$DATA Fazendo deploy do servidor"

rodar_docker_teste(){
  docker run -p 80:80 jailsonsilva/bg_app:0.2
}

iniciar_docker_swarm(){
  docker swarm init
}

fazer_download_imagen(){
  docker pull vagascombr/api-candidatos:0.2
}

fazer_deploy_containers(){
  docker stack deploy -c /opt/docker-compose-qa.yml api-candidatos
}

rodar_aplicacao(){
  fazer_download_imagen && \
  iniciar_docker_swarm && \
  fazer_deploy_containers
}

# rodar_aplicacao

rodar_docker_teste

echo "$DATA Deploy finalizado com sucesso"