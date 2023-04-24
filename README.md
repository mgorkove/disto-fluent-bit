# disto-fluent-bit

to create a kubernetes cluster in aws:
eksctl create cluster --name sockshop-cluster --region us-east-2

to install fluent bit:
kubectl create namespace disto-fluentbit  
kubectl apply -f fluent-bit.yaml 

to run sockshop application on kubernetes cluster:
clone this repo: https://github.com/microservices-demo/microservices-demo
cd microservices-demo/
cd deploy/kubernetes
kubectl create namespace sock-shop
kubectl apply -f complete-demo.yaml
