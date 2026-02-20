#!/bin/bash

# Скрипт 6: Очистка окружения
# Останавливает контейнеры и удаляет данные

set -e

echo "========================================="
echo "Очистка окружения"
echo "========================================="

cd "$(dirname "$0")/.."

echo ""
read -p "Вы уверены, что хотите удалить все данные? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Отменено."
    exit 0
fi

echo ""
echo "Остановка контейнеров..."
docker-compose down

echo ""
echo "Удаление volumes..."
docker-compose down -v

echo ""
echo "Удаление сборочных файлов..."
rm -rf build/ .gradle/

echo ""
echo "========================================="
echo "Очистка завершена!"
echo "========================================="
echo ""
echo "Для повторного запуска используйте:"
echo "  ./scripts/01-setup-cluster.sh"
