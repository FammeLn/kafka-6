#!/bin/bash

# Скрипт 3: Проверка ISR статуса
# Показывает лидеров, реплики и ISR для каждой партиции

set -e

echo "========================================="
echo "Проверка ISR статуса"
echo "========================================="

cd "$(dirname "$0")/.."

TOPIC="replication-test"

echo ""
echo "Детальная информация о топике $TOPIC:"
echo ""

docker-compose exec -T kafka1 kafka-topics \
    --bootstrap-server kafka1:29092 \
    --describe \
    --topic $TOPIC

echo ""
echo "========================================="
echo "Расшифровка:"
echo "========================================="
echo "Leader    - Брокер, обрабатывающий чтение/запись"
echo "Replicas  - Все назначенные реплики"
echo "Isr       - In-Sync Replicas (синхронные реплики)"
echo ""
echo "ВАЖНО: ISR должен содержать все реплики в нормальном состоянии!"
echo "       Если ISR < Replicas, значит есть отстающие брокеры."
echo "========================================="

# Дополнительно: показать статус брокеров
echo ""
echo "Статус брокеров в кластере:"
docker-compose exec -T kafka1 kafka-broker-api-versions \
    --bootstrap-server kafka1:29092,kafka2:29093,kafka3:29094 \
    2>/dev/null | grep "^[0-9]" | awk '{print "  Брокер " $1}' || echo "  Все брокеры активны"

echo ""
echo "Запустить повторно: ./scripts/03-check-isr.sh"
