#!/bin/bash

# Скрипт 2: Создание топика с репликацией
# Создает топик с 3 партициями и replication factor 3

set -e

echo "========================================="
echo "Шаг 2: Создание топика с репликацией"
echo "========================================="

cd "$(dirname "$0")/.."

TOPIC="replication-test"
PARTITIONS=3
REPLICATION_FACTOR=3

echo ""
echo "Параметры топика:"
echo "  Имя: $TOPIC"
echo "  Партиции: $PARTITIONS"
echo "  Replication Factor: $REPLICATION_FACTOR"
echo ""

# Удаляем топик если существует
echo "Удаление топика (если существует)..."
docker-compose exec -T kafka1 kafka-topics \
    --bootstrap-server kafka1:29092 \
    --delete \
    --topic $TOPIC \
    2>/dev/null || echo "  Топик не существовал"

sleep 2

# Создаем топик
echo ""
echo "Создание топика..."
docker-compose exec -T kafka1 kafka-topics \
    --bootstrap-server kafka1:29092,kafka2:29093,kafka3:29094 \
    --create \
    --topic $TOPIC \
    --partitions $PARTITIONS \
    --replication-factor $REPLICATION_FACTOR

sleep 2

# Настраиваем min.insync.replicas
echo ""
echo "Установка min.insync.replicas=2..."
docker-compose exec -T kafka1 kafka-configs \
    --bootstrap-server kafka1:29092 \
    --entity-type topics \
    --entity-name $TOPIC \
    --alter \
    --add-config min.insync.replicas=2

sleep 1

# Проверяем конфигурацию
echo ""
echo "Конфигурация топика:"
docker-compose exec -T kafka1 kafka-configs \
    --bootstrap-server kafka1:29092 \
    --entity-type topics \
    --entity-name $TOPIC \
    --describe

echo ""
echo "========================================="
echo "Топик создан успешно!"
echo "========================================="
echo ""
echo "Следующий шаг: ./scripts/03-check-isr.sh"
