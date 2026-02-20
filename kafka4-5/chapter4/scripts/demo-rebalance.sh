#!/bin/bash

# Демонстрация rebalance

set -e

TOPIC="chapter4-rebalance"
COMPOSE_FILE="$(cd "$(dirname "$0")/.." && pwd)/../../kafka-6-comp/docker-compose.yml"

cd "$(dirname "$0")/.."

echo "=== Demo Rebalance ==="

docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 3 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Подсказка: запустите два consumer с одной группой и наблюдайте ребаланс."
echo "kafka-console-consumer --bootstrap-server kafka1:29092 --topic $TOPIC --group chapter4-rebalance"
