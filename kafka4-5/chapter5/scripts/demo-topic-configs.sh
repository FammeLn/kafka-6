#!/bin/bash

# Демонстрация topic configs

set -e

TOPIC="chapter5-configs"
COMPOSE_FILE="$(cd "$(dirname "$0")/.." && pwd)/../../kafka-6-comp/docker-compose.yml"

cd "$(dirname "$0")/.."

echo "=== Demo Topic Configs ==="

docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-topics \
  --bootstrap-server kafka1:29092 \
  --create \
  --topic "$TOPIC" \
  --partitions 1 \
  --replication-factor 3 \
  2>/dev/null || echo "Топик уже существует"

echo ""
echo "Текущие конфиги:"
docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-configs \
  --bootstrap-server kafka1:29092 \
  --entity-type topics \
  --entity-name "$TOPIC" \
  --describe
