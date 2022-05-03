rm -rf microservices/
git clone https://github.com/hoalongnatsu/microservices.git && cd microservices/code
docker build . -t 080196/microservice
docker push 080196/microservice