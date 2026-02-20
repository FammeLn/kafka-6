#!/bin/bash

# Демонстрация quotas

set -e

COMPOSE_FILE="$(cd "$(dirname "$0")/.." && pwd)/../../kafka-6-comp/docker-compose.yml"

cd "$(dirname "$0")/.."

echo "=== Demo Quotas ==="

echo "Подсказка: quotas настраиваются для user/client-id"
echo "Пример команды (не выполняется автоматически):"
echo "kafka-configs --bootstrap-server kafka1:29092 --alter --entity-type users --entity-name <user> --add-config 'producer_byte_rate=1048576'"

echo ""
echo "Текущие quotas (если есть):"
docker-compose -f "$COMPOSE_FILE" exec -T kafka1 kafka-configs \
  --bootstrap-server kafka1:29092 \
  --entity-type users \
  --describe 2>/dev/null || echo "Quotas не настроены"
