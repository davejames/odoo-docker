#!/bin/bash

# Script will start as root, run any system commands here

# Launch the Odoo server
export ADDONS_PATH=$(find /opt/odoo/project/$PROJECT -type f \
  -name "__manifest__.py" -or -name "__openerp__.py" 2>/dev/null | \
  sed -r 's|\/[^/]+\/[^/]+$||' | sort | uniq | paste -s -d, -)

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

source /entrypoint.sh
