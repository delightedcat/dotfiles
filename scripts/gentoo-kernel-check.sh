#!/bin/bash

WEBHOOK_URL="<your discord webhook url>"

KERNEL_CURRENT=linux-$(uname -r)
KERNEL_LATEST=$(basename $(realpath /usr/src/linux))

if [[ $KERNEL_CURRENT != $KERNEL_LATEST ]]; then
	CONTENT="Update kernel from \`$KERNEL_CURRENT\` to \`$KERNEL_LATEST\`!"
	/usr/bin/curl -X POST \
		-d "{\"username\": \"$HOSTNAME\", \"content\": \"$CONTENT\"}" \
		-H "Content-Type: application/json" $WEBHOOK_URL
fi

