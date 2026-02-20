#!/bin/bash

# Скрипт 1: Запуск кластера Kafka
# Запускает 3 брокера Kafka и ZooKeeper

set -e

echo "========================================="
echo "Лабораторная работа 6.3: Репликация ISR"
echo "Шаг 1: Запуск кластера"
echo "========================================="

cd "$(dirname "$0")/.."

echo ""
echo "Останавливаем существующие контейнеры (если есть)..."
docker-compose down -v

echo ""
echo "Запускаем кластер (ZooKeeper + 3 брокера)..."
docker-compose up -d

echo ""
echo "Ожидание запуска сервисов (30 секунд)..."
sleep 30

echo ""
echo "Проверка статуса контейнеров:"
docker-compose ps

echo ""
echo "Проверка подключения к брокерам:"
for port in 9092 9093 9094; do
    echo -n "  Брокер на порту $port: "
    if nc -z localhost $port 2>/dev/null; then
        echo "✓ Доступен"
    else
        echo "✗ Недоступен"
    fi
done

echo ""
echo "Проверка логов брокеров для поиска ошибок:"
docker-compose logs kafka1 | grep -i error | tail -n 5 || echo "  Ошибок не найдено"

echo ""
echo "========================================="
echo "Кластер запущен успешно!"
echo "========================================="
echo ""
echo "Брокеры доступны на:"
echo "  - kafka1: localhost:9092"
echo "  - kafka2: localhost:9093"
echo "  - kafka3: localhost:9094"
echo "  - ZooKeeper: localhost:2181"
echo ""
echo "Следующий шаг: ./scripts/02-create-topic.sh"
