#!/bin/bash

# Демонстрация consumer group

set -e

TOPIC="chapter4-group"
COMPOSE_FILE="$(cd "$(dirname "$0")/.." && pwd)/../../kafka-6-comp/docker-compose.yml"

cd "$(dirname "$0")/.."

echo "=== Demo Consumer Group ==="

docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 3 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Список групп:"
docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-consumer-groups \
  --bootstrap-server kafka1:29092 \
  --list

echo ""
echo "Подсказка: запустите два consumer в разных терминалах и проверьте assign:"
echo "kafka-console-consumer --bootstrap-server kafka1:29092 --topic $TOPIC --group chapter4-group"
