#!/bin/sh

jq --version > /dev/null || (echo "Need setup jq. https://jqlang.github.io/jq/download/" && exit 1)

# Return last tag from gitlab project
#
# Usage: gitlab_get_last_tag <domain> <project_id>
# Example: gitlab_get_last_tag gitlab.torproject.org 647
gitlab_get_last_tag()
{
  echo $(curl -s https://$1/api/v4/projects/$2/repository/tags | jq -r ".[0].name")
}

# Rewrute .env file
cat << EOF > .env
ARTI_VERSION=$(gitlab_get_last_tag gitlab.torproject.org 647)
OBFS4_VERSION=$(gitlab_get_last_tag gitlab.com 10387781)
SNOWFLAKE_VERSION=$(gitlab_get_last_tag gitlab.torproject.org 43)
WEBTUNNEL_VERSION=399c24557a186fcb8ca079f6be38d9cba5fa8ec5
EOF

cat .env
