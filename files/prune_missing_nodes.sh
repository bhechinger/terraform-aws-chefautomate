#!/usr/bin/env bash

for node in $(automate-ctl node-summary | awk '/missing/ {print $2}'); do
    automate-ctl delete-node --force -u ${node}
done