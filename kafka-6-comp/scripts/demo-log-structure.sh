#!/bin/bash

# Демонстрация структуры логов Kafka

set -e

TOPIC="chapter6-log"

cd "$(dirname "$0")/.."

echo "=== Demo Log Structure ==="

echo "Создание топика (если нет)..."
docker-compose exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 1 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Каталоги логов на брокере kafka1:"
docker-compose exec -T kafka1 bash -c "ls -1 /var/lib/kafka/data | head -n 10"

echo ""
echo "Сегменты для топика $TOPIC (пример):"
docker-compose exec -T kafka1 bash -c "ls -1 /var/lib/kafka/data/${TOPIC}-0 | head -n 10" \
  2>/dev/null || echo "Файлы сегментов появятся после записи сообщений"

echo ""
echo "Подсказка: запишите сообщения и повторите скрипт, чтобы увидеть .log/.index/.timeindex"
