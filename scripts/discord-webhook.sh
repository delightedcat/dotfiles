#!/bin/bash

WEBHOOK_URL="<your webhook url>"
/usr/bin/curl -X POST -H "Content-Type: application/json" -d "{\"content\": \"$1\"}" $WEBHOOK_URL

