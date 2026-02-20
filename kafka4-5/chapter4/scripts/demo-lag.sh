#!/bin/bash

# Демонстрация lag

set -e

TOPIC="chapter4-lag"
GROUP="chapter4-lag-group"
COMPOSE_FILE="$(cd "$(dirname "$0")/.." && pwd)/../../kafka-6-comp/docker-compose.yml"

cd "$(dirname "$0")/.."

echo "=== Demo Lag ==="

docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 1 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Запись 5 сообщений..."
docker-compose -f "$COMPOSE_FILE" exec -T kafka1 bash -c "printf '1\n2\n3\n4\n5\n' | kafka-console-producer \
  --bootstrap-server kafka1:29092 \
  --topic $TOPIC"

echo ""
echo "Текущий lag:"
docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-consumer-groups \
  --bootstrap-server kafka1:29092 \
  --describe \
  --group "$GROUP" 2>/dev/null || echo "Группа еще не создана"

echo ""
echo "Подсказка: запустите consumer в другой консоли, чтобы увидеть изменение lag."
