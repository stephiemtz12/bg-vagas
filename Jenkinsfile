pipeline {
  agent any

  environment { 
    AWSCLI = "aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[?contains(Tags[?Key==`Name`].Value, `API-CANDIDATOS`)].[DesiredCapacity]' --output text"
    VERSAO = '0.2'
    BRANCH_PRODUCAO = 'master'
    BRANCH_STAGING = 'staging'
  }

  stages {
    stage('Deletando build anterior'){
      steps{
        cleanWs()
      }
    }

    stage('Setup AWSCLI Terraform e Packer'){
      steps{
        sh 'curl -o /usr/local/bin/aws https://raw.githubusercontent.com/mesosphere/aws-cli/master/aws.sh; chmod a+x /usr/local/bin/aws'
        sh 'curl -o /usr/local/bin/terraform.zip https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip; unzip -n /usr/local/bin/terraform.zip; chmod a+x /usr/local/bin/terraform'
      }
    }

    stage('Checkout Producao'){
      when {
        branch env.BRANCH_PRODUCAO
      }
      steps{
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, 
        extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/jailson-silva/bg-vagas.git']]])
      }
    }

    stage('Checkout Staging'){
      when {
        branch env.BRANCH_STAGING
      }
      steps{
        checkout([$class: 'GitSCM', branches: [[name: '*/staging']], doGenerateSubmoduleConfigurations: false, 
        extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/jailson-silva/bg-vagas.git']]])
      }
    }

    stage('Verificando servidores InService'){
      steps{
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jailson-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} AWS_DEFAULT_REGION=us-east-2 ${AWSCLI} >> $WORKSPACE/servidores.txt"
        }
      }
    }

    stage('Inicializando Terraform'){
      steps{
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jailson-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          dir('terraform/asg') {
            sh """
              terraform init \
              -backend-config="access_key=${AWS_ACCESS_KEY_ID} \
              -backend-config="secret_key=${AWS_SECRET_ACCESS_KEY}
            """
          }
        }
      }
    }

    stage('Deploy da nova imagem'){
      steps{
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jailson-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          dir('terraform') {
            sh """
              export AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID
              export AWS_SECRET_ACCESS_KEY_ID=\$AWS_SECRET_ACCESS_KEY
              SERVIDORES=`cat $WORKSPACE/servidores.txt | head -1`
              terraform apply -auto-approve \
              -var wait_for_elb_capacity=\$SERVIDORES \
              -var desired=\$SERVIDORES \
              -var aws_access_key=\$AWS_ACCESS_KEY_ID \
              -var aws_secret_key=\$AWS_SECRET_ACCESS_KEY \
              -input=false
            """
          }
        }
      }
    }
  }
}