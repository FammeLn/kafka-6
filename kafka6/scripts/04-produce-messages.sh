#!/bin/bash

# Скрипт 4: Отправка сообщений с acks=all
# Использует ReliableProducer для отправки сообщений

set -e

echo "========================================="
echo "Шаг 4: Отправка сообщений"
echo "========================================="

cd "$(dirname "$0")/.."

# Параметры
BOOTSTRAP_SERVERS=${1:-"localhost:9092,localhost:9093,localhost:9094"}
MESSAGE_COUNT=${2:-1000}
ACKS=${3:-"all"}

echo ""
echo "Параметры:"
echo "  Bootstrap servers: $BOOTSTRAP_SERVERS"
echo "  Количество сообщений: $MESSAGE_COUNT"
echo "  Acks: $ACKS"
echo ""

# Проверка наличия Gradle wrapper
if [ ! -f "./gradlew" ]; then
    echo "Инициализация Gradle wrapper..."
    gradle wrapper --gradle-version 8.4
fi

# Сборка приложения
echo "Сборка приложения..."
./gradlew clean build -x test

echo ""
echo "Запуск продюсера..."
echo "========================================="

./gradlew runProducer -PappArgs="$BOOTSTRAP_SERVERS,$MESSAGE_COUNT,$ACKS"

echo ""
echo "========================================="
echo "Отправка завершена!"
echo "========================================="
echo ""
echo "Проверьте ISR статус: ./scripts/03-check-isr.sh"
echo "Прочитайте сообщения: ./scripts/05-consume-messages.sh"
