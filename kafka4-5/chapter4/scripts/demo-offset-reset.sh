#!/bin/bash

# Демонстрация auto.offset.reset

set -e

TOPIC="chapter4-offset"
COMPOSE_FILE="$(cd "$(dirname "$0")/.." && pwd)/../../kafka-6-comp/docker-compose.yml"

cd "$(dirname "$0")/.."

echo "=== Demo Offset Reset ==="

docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 1 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Запись 3 сообщений..."
docker-compose -f "$COMPOSE_FILE" exec -T kafka1 bash -c "printf 'x\ny\nz\n' | kafka-console-producer \
  --bootstrap-server kafka1:29092 \
  --topic $TOPIC"

echo ""
echo "Подсказка: запуск consumer с auto.offset.reset=earliest/ latest"
echo "kafka-console-consumer --bootstrap-server kafka1:29092 --topic $TOPIC --group chapter4-offset --from-beginning"
