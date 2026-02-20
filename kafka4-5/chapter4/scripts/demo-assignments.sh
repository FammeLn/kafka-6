#!/bin/bash

# Демонстрация assignor стратегий

set -e

TOPIC="chapter4-assign"
COMPOSE_FILE="$(cd "$(dirname "$0")/.." && pwd)/../../kafka-6-comp/docker-compose.yml"

cd "$(dirname "$0")/.."

echo "=== Demo Assignments ==="

docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 4 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Подсказка: используйте разные assignor (range, round-robin, sticky)"
echo "consumer property: partition.assignment.strategy"
