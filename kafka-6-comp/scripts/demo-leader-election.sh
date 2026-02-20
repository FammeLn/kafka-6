#!/bin/bash

# Демонстрация выбора лидера партиций

set -e

TOPIC="chapter6-leader"

cd "$(dirname "$0")/.."

echo "=== Demo Leader Election ==="

echo "Создание топика (если нет)..."
docker-compose exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 3 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Текущие лидеры:"
docker-compose exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --describe \
  --topic "$TOPIC" | grep "Leader"

echo ""
echo "Чтобы увидеть переизбрание, остановите брокер:"
echo "  docker-compose stop kafka1"
echo "Затем повторите этот скрипт и посмотрите на нового лидера."
