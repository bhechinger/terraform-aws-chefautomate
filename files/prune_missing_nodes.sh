#!/usr/bin/env bash

for node in $(automate-ctl node-summary | grep missing | awk '{print $2}'); do
    automate-ctl delete-node --force -u ${node}
done