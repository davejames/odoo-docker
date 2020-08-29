#!/bin/sh

# usage:     run-tests.sh root_dir modules_dir

# Params:       if not specified, the defaults will be used from the .env file
# root_dir    - all modules under root_dir will be available as dependencies but will not
#               be explicitly installed.
# modules_dir - all modules under modules_dir will be explicitly installed
# init_list   - list of modules to pre-initialize the database with before running
#               tests on the modules in modules_dir

export $(cat docker/.env | sed 's/#.*//g' | xargs)
export TEST_ENABLE=test-and-close
export PGDATA=/var/lib/postgresql/data/pgdata

# Determine root_dir and modules_dir from paramters, or stick to defaults
if [ -z "$1" ]
  then
    echo "No root path set, using default"
  else
    export PROJECT=$1
    echo "Root path set: $PROJECT"
fi

if [ -z "$2" ]
  then
    echo "No modules path set, testing modules under: $PROJECT/$MODULES_DIR"
  else
    export PROJECT=$1
    echo "Modules path set, testing modules under: $PROJECT/$MODULES_DIR"
fi

# Bring down any previous instance. It is important that the postgres machine
# is empty
docker-compose -f docker/docker-compose.yml down

# db needs to be initialized first.
docker-compose -f docker/docker-compose.yml up --exit-code-from db

# If init_list has been passed, pre-initialize the database before running tests
if [ "$3" ]
  then
    echo "Testing with strategy: pre-initialize $3"
    INIT_MODULES=$3 bash -c 'echo $INIT_MODULES'
    INIT_MODULES=$3 bash -c 'docker-compose -f docker/docker-compose.yml up --exit-code-from odoo db odoo'
    echo "=========================="
    echo "Finished pre-initalization"
    echo "=========================="
  else
    echo "Testing with strategy: initialize all"
fi

# Run tests and bring down the instance
echo "====running===="
docker-compose -f docker/docker-compose.yml up --exit-code-from odoo db odoo
docker-compose -f docker/docker-compose.yml down
