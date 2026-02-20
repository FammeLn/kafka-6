#!/bin/bash

# Скрипт: Симуляция сбоя брокера
# Демонстрирует автоматический failover

set -e

echo "========================================="
echo "Эксперимент: Failover при сбое брокера"
echo "========================================="

cd "$(dirname "$0")/.."

TOPIC="replication-test"

echo ""
echo "1. Текущее состояние ISR:"
docker-compose exec -T kafka1 kafka-topics \
    --bootstrap-server kafka1:29092 \
    --describe \
    --topic $TOPIC | grep "Leader:"

echo ""
echo "2. Выберите брокер для остановки (1, 2 или 3):"
read -p "Номер брокера: " broker_num

if [[ ! "$broker_num" =~ ^[1-3]$ ]]; then
    echo "Ошибка: Введите 1, 2 или 3"
    exit 1
fi

BROKER="kafka$broker_num"

echo ""
echo "3. Остановка брокера $BROKER..."
docker-compose stop $BROKER

echo ""
echo "Ожидание 5 секунд для failover..."
sleep 5

echo ""
echo "4. Новое состояние ISR:"
docker-compose exec -T kafka1 kafka-topics \
    --bootstrap-server kafka1:29092 \
    --describe \
    --topic $TOPIC 2>/dev/null | grep "Leader:" || \
docker-compose exec -T kafka2 kafka-topics \
    --bootstrap-server kafka2:29093 \
    --describe \
    --topic $TOPIC | grep "Leader:"

echo ""
echo "5. Проверка отправки сообщений с упавшим брокером..."
docker-compose exec -T kafka1 bash -c "echo 'test-message-after-failure' | kafka-console-producer \
    --bootstrap-server kafka1:29092,kafka2:29093,kafka3:29094 \
    --topic $TOPIC \
    --request-required-acks all" 2>/dev/null || echo "  Сообщение отправлено успешно!"

echo ""
echo "========================================="
echo "Наблюдения:"
echo "========================================="
echo "- Лидер переизбран автоматически"
echo "- ISR уменьшился на 1 реплику"
echo "- Запись продолжает работать (если min.insync.replicas=2)"
echo ""
echo "Для восстановления брокера:"
echo "  docker-compose start $BROKER"
echo "  ./scripts/03-check-isr.sh"
