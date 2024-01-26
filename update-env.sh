#!/bin/sh

jq --version || (echo "Need setup jq. https://jqlang.github.io/jq/download/" && exit 1)

cat << EOF > .env
ARTI_VERSION=$(curl -s https://gitlab.torproject.org/api/v4/projects/647/repository/tags | jq -r ".[0].name")
OBFS4_VERSION=$(curl -s https://gitlab.com/api/v4/projects/10387781/repository/tags | jq -r ".[0].name")
SNOWFLAKE_VERSION=$(curl -s https://gitlab.torproject.org/api/v4/projects/43/repository/tags | jq -r ".[0].name")
EOF
 
