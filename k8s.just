set shell := ["bash", "-c"]
set positional-arguments

all: version build deploy config check test clean
[group('k8s')]
@deps:
    echo ">> running $0"
    minikube start 
    nohup minikube tunnel --cleanup &

[group('k8s')]
@build: 
    echo ">> running $0"
    just docker::build

[group('k8s')]
@version:
    echo ">> running $0"
    kubectl version
    minikube version

[group('k8s')]
@load-image:
    echo ">> running $0"
    minikube image load login-page:latest

[group('k8s')]
check:
    echo ">> running $0"
    minikube image ls
    kubectl get pods -A

[group('k8s')]
@deploy: load-image
    echo ">> running $0"
    helm install vault hashicorp/vault -n vault --create-namespace --values helm-vault-values.yaml
    kubectl create -f login-page-deployment.yaml
    sleep 5

[group('k8s')]
@clean:
    echo ">> running $0"
    helm uninstall vault -n vault
    kubectl delete -f login-page-deployment.yaml
    minikube stop
    minikube delete

[group('k8s')]
@test:
    echo ">> running $0"
    open -a safari http://localhost:8501

[group('k8s')]
@config:
    echo ">> running $0"
    vault auth enable userpass
    sleep 1
    vault write auth/userpass/users/ken.keller \
        password=four \
        policies=default