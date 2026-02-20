#!/bin/bash

# Скрипт: Эксперимент с min.insync.replicas
# Демонстрирует NotEnoughReplicasException

set -e

echo "========================================="
echo "Эксперимент: min.insync.replicas"
echo "========================================="

cd "$(dirname "$0")/.."

TOPIC="replication-test"

echo ""
echo "Этот эксперимент демонстрирует, как min.insync.replicas"
echo "защищает от потери данных, но влияет на доступность."
echo ""

echo "1. Текущая конфигурация:"
docker-compose exec -T kafka1 kafka-configs \
    --bootstrap-server kafka1:29092 \
    --entity-type topics \
    --entity-name $TOPIC \
    --describe | grep min.insync.replicas || echo "  min.insync.replicas=2 (по умолчанию)"

echo ""
echo "2. Текущий ISR:"
docker-compose exec -T kafka1 kafka-topics \
    --bootstrap-server kafka1:29092 \
    --describe \
    --topic $TOPIC

echo ""
echo "3. Останавливаем 2 брокера из 3..."
docker-compose stop kafka2 kafka3

echo ""
echo "Ожидание 5 секунд..."
sleep 5

echo ""
echo "4. Попытка отправить сообщение с acks=all..."
echo "   (Ожидается ошибка NotEnoughReplicasException)"
echo ""

docker-compose exec -T kafka1 bash -c "timeout 10 bash -c 'echo \"test-message\" | kafka-console-producer \
    --bootstrap-server kafka1:29092 \
    --topic $TOPIC \
    --request-required-acks all 2>&1' || true"

echo ""
echo "========================================="
echo "Результат:"
echo "========================================="
echo "С min.insync.replicas=2 и только 1 живой репликой,"
echo "продюсер с acks=all НЕ может записать данные."
echo ""
echo "Это защищает от потери данных, но снижает доступность!"
echo ""
echo "========================================="
echo "Восстановление:"
echo "========================================="
echo "  docker-compose start kafka2 kafka3"
echo ""
echo "Альтернатива (ОПАСНО - может потерять данные!):"
echo "  Установить min.insync.replicas=1"
echo ""

read -p "Восстановить брокеры? (yes/no): " restore

if [ "$restore" = "yes" ]; then
    echo ""
    echo "Восстановление брокеров..."
    docker-compose start kafka2 kafka3
    echo "Ожидание 10 секунд..."
    sleep 10
    echo "Проверка ISR:"
    ./scripts/03-check-isr.sh
fi
