#!/bin/bash

# Скрипт 5: Чтение сообщений
# Использует SimpleConsumer для верификации данных

set -e

echo "========================================="
echo "Шаг 5: Чтение сообщений"
echo "========================================="

cd "$(dirname "$0")/.."

# Параметры
BOOTSTRAP_SERVERS=${1:-"localhost:9092,localhost:9093,localhost:9094"}
GROUP_ID=${2:-"lab6-consumer-group-$(date +%s)"}
MAX_MESSAGES=${3:-100}

echo ""
echo "Параметры:"
echo "  Bootstrap servers: $BOOTSTRAP_SERVERS"
echo "  Consumer Group: $GROUP_ID"
echo "  Max сообщений: $MAX_MESSAGES"
echo ""

# Проверка наличия Gradle wrapper
if [ ! -f "./gradlew" ]; then
    echo "Инициализация Gradle wrapper..."
    gradle wrapper --gradle-version 8.4
fi

echo "Запуск консьюмера..."
echo "========================================="

./gradlew runConsumer -PappArgs="$BOOTSTRAP_SERVERS,$GROUP_ID,$MAX_MESSAGES"

echo ""
echo "========================================="
echo "Чтение завершено!"
echo "========================================="
