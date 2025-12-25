#!/bin/bash
set -e  # Para o script se qualquer comando falhar

# Configurações
versao=$(git rev-parse HEAD | cut -c 1-7)
REPO_URL="804826263064.dkr.ecr.us-east-1.amazonaws.com"

echo "🔐 Iniciando login no ECR..."
aws ecr get-login-password --region us-east-1 --profile valmir | docker login --username AWS --password-stdin $REPO_URL

echo "📦 Construindo a imagem bia:$versao..."
docker build -t bia .

echo "🏷️ Taggeando imagens..."
docker tag bia:latest $REPO_URL/bia:$versao
docker tag bia:latest $REPO_URL/bia:latest

echo "🚀 Enviando imagens para a AWS..."
docker push $REPO_URL/bia:$versao
docker push $REPO_URL/bia:latest

echo "🧹 Preparando pacote de deploy..."
rm .env 2> /dev/null
./gerar-compose.sh
rm bia-versao-*zip 2> /dev/null
zip -r bia-versao-$versao.zip docker-compose.yml
git checkout docker-compose.yml

echo "✅ Sucesso! Use o arquivo bia-versao-$versao.zip no Beanstalk."