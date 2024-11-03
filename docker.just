set shell := ["bash", "-c"]
set positional-arguments

all: version build deploy check test clean

[group('docker')]
@version:
    echo ">> running $0"

[group('docker')]
@test:
    echo ">> running $0"

[group('docker')]
@stop:
    echo ">> running $0"
    docker stop $(docker ps -f name=vault -q)
    docker stop $(docker ps -f name=login-page -q)

[group('docker')]
details:
    echo ">> running $0"
    docker inspect $(docker container ls --filter "ancestor=login-page" --format "{{{{.ID}}")
    docker inspect $(docker container ls --filter "ancestor=hashicorp/vault" --format "{{{{.ID}}")

[group('docker')]
@build:
    echo ">> running $0"
    docker build -f Dockerfile -t login-page:latest .


[group('docker')]
@deploy:
    echo ">> running $0"
    pip install -r requirements.txt
    docker run --name vault --cap-add=IPC_LOCK --env VAULT_DEV_ROOT_TOKEN_ID=root --env VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200 --publish 8200:8200 --detach --rm hashicorp/vault
    sleep 3
    vault auth enable userpass
    sleep 1
    vault write auth/userpass/users/ken.keller \
        password=four \
        policies=default
    docker run -p 8501:8501 -e VAULT_ADDR="http://127.0.0.1:8200" login-page    

    [group('docker')]
@clean:
    echo ">> running $0"

[group('docker')]
@check:
    echo ">> running $0"
