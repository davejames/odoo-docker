#!/bin/sh

export $(cat docker/.env | sed 's/#.*//g' | xargs)
export TEST_ENABLE=test-and-close
export PGDATA=/var/lib/postgresql/data/pgdata

docker-compose -f docker/docker-compose.yml down
docker-compose -f docker/docker-compose.yml up --exit-code-from odoo db odoo
docker-compose -f docker/docker-compose.yml down
