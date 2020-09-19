#!/bin/bash

# Launch the Odoo server
export ADDONS_PATH=$(find -L /opt/odoo/project/$PROJECT -type f \
  -name "__manifest__.py" -or -name "__openerp__.py" 2>/dev/null | \
  grep -E -v "/setup/" | sed -r 's|\/[^/]+\/[^/]+$||' | sort | uniq | paste -s -d, -)

case $TEST_ENABLE in
  test)
    export TEST_COMMAND="--test-enable --workers=0"
    ;;
  test-and-close)
    if [ -z "$INIT_MODULES" ]
      then
        INIT=$(ls -m /opt/odoo/project/$PROJECT/$MODULES_DIR | \
          sed "s#[^ ]*#&#g;s/ //g;s/.*/&/" | tr -d '\n')
      else
        INIT=$INIT_MODULES
    fi
    export TEST_COMMAND="--test-enable --workers=0 --stop-after-init -d AUTO_TEST --init $INIT"
    ;;
  *)
    export TEST_COMMAND="--workers=2"
    ;;
esac

source /etc/odoo/configs/$COMPOSE_PROJECT_NAME.sh

source /entrypoint.sh
