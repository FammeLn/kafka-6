#!/bin/bash

# Демонстрация динамики ISR

set -e

TOPIC="chapter6-isr"

cd "$(dirname "$0")/.."

echo "=== Demo ISR ==="

echo "Проверка доступности брокеров..."
docker-compose ps

echo "Создание топика (если нет)..."
docker-compose exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 3 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Состояние ISR:"
docker-compose exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --describe \
  --topic "$TOPIC"

echo ""
echo "Подсказка: остановите один брокер и повторите скрипт, чтобы увидеть сжатие ISR."
