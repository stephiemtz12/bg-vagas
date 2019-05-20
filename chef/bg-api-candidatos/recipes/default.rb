#
# Cookbook:: bg-api-candidatos
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

git '/opt/vagas' do
  repository 'https://github.com/jailson-silva/bg-vagas.git'
  revision 'master'
  action :sync
end

# execute 'Iniciar dockerSwarm' do
#   command 'docker swarm init && touch /opt/docker-swarm-iniciado'
#   not_if { ::File.exists?('/opt/docker-swarm-iniciado') } 
#   action :run
# end

# bash 'Deploy Aplicacao' do
#   code <<-EOH
#   exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#   DATA=$(date '+%Y-%m-%d %H:%M:%S')

#   echo "$DATA Fazendo deploy do servidor"

#   fazer_deploy_containers(){
#     docker stack deploy -c /opt/docker-compose-qa.yml api-candidatos
#   }

#   rodar_aplicacao(){
#     fazer_download_imagen && \
#     iniciar_docker_swarm && \
#     fazer_deploy_containers
#   }

#   rodar_aplicacao

#   echo "$DATA Deploy finalizado com sucesso"
#   EOH
# end

# execute 'Deploy' do
#   command 'docker stack deploy -c /opt/vagas/docker-compose-qa.yml api-candidatos'
#   action :run
# end
