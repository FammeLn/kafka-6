#!/bin/bash

# Демонстрация produce/fetch запросов

set -e

TOPIC="chapter6-requests"

cd "$(dirname "$0")/.."

echo "=== Demo Requests ==="

echo "Создание топика (если нет)..."
docker-compose exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 1 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Produce: отправка 3 сообщений"
docker-compose exec -T kafka1 bash -c "printf 'a\nb\nc\n' | kafka-console-producer \
  --bootstrap-server kafka1:29092 \
  --topic $TOPIC" 

echo ""
echo "Fetch: чтение 3 сообщений"
docker-compose exec -T kafka1 kafka-console-consumer \
  --bootstrap-server kafka1:29092 \
  --topic "$TOPIC" \
  --from-beginning \
  --max-messages 3

echo ""
echo "Теория: produce пишет в лог лидера, fetch читает до high watermark."
