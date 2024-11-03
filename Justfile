set shell := ["bash", "-c"]
set positional-arguments
mod k8s
mod docker

default: all
all: version build deploy check test clean

[group('default')]
@build:
    echo ">> running $0"
    pip install -r requirements.txt

[group('default')]
@version:
    echo ">> running $0"
    vault version
    streamlit version

[group('default')]
@deploy:
    echo ">> running $0"
    vault server -dev -dev-root-token-id root

[group('default')]
check:
    echo ">> running $0"
    vault status
    -lsof -P -i :8501

[group('default')]
@test:
    echo ">> running $0"
    streamlit run streamlit_app.py &

[group('default')]
@create-user user pass:
    echo ">> running $0"
    vault write auth/userpass/users/{{user}} \
        password={{pass}} \
        policies=default

[group('default')]
@clean:
    echo ">> running $0"
    pkill vault
