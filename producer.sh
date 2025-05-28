#!/bin/bash

INPUT_FILE="deal_ids.txt"
PARALLEL_WORKERS=16
TMPFS_SIZE=1G
TMP_DIR="./tmp"

RUN_ID=$(date +%Y%m%d_%H%M%S)
IMG_DIR="./images/$RUN_ID"
LOG_DIR="./logs/$RUN_ID"
QUEUE_NAME="task_queue"

# Redis 큐 초기화
redis-cli DEL "$QUEUE_NAME" >/dev/null
cat "$INPUT_FILE" | while read line; do
    redis-cli RPUSH "$QUEUE_NAME" "$line"
done

# tmpfs 준비
sudo umount "$TMP_DIR" 2>/dev/null
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
sudo mount -t tmpfs -o size=$TMPFS_SIZE tmpfs "$TMP_DIR"

mkdir -p "$IMG_DIR" "$LOG_DIR"

START_TIME=$(date +%s)

# worker 실행
for ((i=0; i<PARALLEL_WORKERS; i++)); do
    ./consumer.sh "$TMP_DIR" "$IMG_DIR" "$LOG_DIR" &
done
wait

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "총 실행 시간: $DURATION초 ($(date))" | tee -a "$LOG_DIR/summary.log"

sudo umount "$TMP_DIR"
rm -rf "$TMP_DIR"
