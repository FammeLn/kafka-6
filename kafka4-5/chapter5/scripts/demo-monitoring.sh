#!/bin/bash

# Демонстрация мониторинга

set -e

COMPOSE_FILE="$(cd "$(dirname "$0")/.." && pwd)/../../kafka-6-comp/docker-compose.yml"

cd "$(dirname "$0")/.."

echo "=== Demo Monitoring ==="

echo "Ключевые метрики (JMX) для проверки:"
echo "- UnderReplicatedPartitions"
echo "- OfflinePartitionsCount"
echo "- IsrShrinksPerSec"
echo "- IsrExpandsPerSec"
echo "- RequestHandlerAvgIdlePercent"

echo ""
echo "Подсказка: подключитесь к JMX порту брокеров (19092/19093/19094)"
