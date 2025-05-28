#!/bin/bash

TMP_DIR="$1"
IMG_DIR="$2"
LOG_DIR="$3"
QUEUE_NAME="task_queue"

while :; do
    ID=$(redis-cli LPOP "$QUEUE_NAME")
    if [ -z "$ID" ]; then
        break
    fi

    URL="https://www.tmon.co.kr/deal/$ID"
    FILENAME="deal_$ID.jpg"
    OUTPUT_PATH="$TMP_DIR/$FILENAME"

    START_TIME_MS=$(date +%s%3N)
    START_FMT=$(date '+%Y-%m-%d %H:%M:%S')

    wkhtmltoimage \
      --load-error-handling ignore \
      --disable-javascript \
      --width 860 \
      --height 700 \
      --quality 100 \
      "$URL" "$OUTPUT_PATH"

    EXIT_CODE=$?
    END_TIME_MS=$(date +%s%3N)
    END_FMT=$(date '+%Y-%m-%d %H:%M:%S')
    DURATION=$((END_TIME_MS - START_TIME_MS))

    if [ "$EXIT_CODE" -eq 0 ]; then
        mv "$OUTPUT_PATH" "$IMG_DIR/"
        echo "[$ID] $FILENAME | $DURATION ms ($START_FMT → $END_FMT)" >> "$LOG_DIR/consumer.log"
    else
        echo "[$ID] ERROR ($START_FMT → $END_FMT)" >> "$LOG_DIR/error.log"
    fi
done
