#!/bin/bash -l

if [ -f "/home/kibana/bin/install-dashboard.sh" ]; then
  /home/kibana/bin/install-dashboard.sh
  sudo rm -f /home/kibana/bin/install-dashboard.sh
fi

/home/kibana/kibana-4.1.6/bin/kibana
