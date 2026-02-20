#!/bin/bash

# Демонстрация информации о контроллере

set -e

cd "$(dirname "$0")/.."

echo "=== Demo Controller ==="

echo "Проверка контейнеров:"
docker-compose ps

echo ""
echo "Информация о контроллере в ZooKeeper:"
docker-compose exec -T zookeeper bash -c "echo -e 'get /controller\nquit' | zookeeper-shell localhost:2181" \
  2>/dev/null || echo "Не удалось получить /controller (проверьте контейнер zookeeper)"

echo ""
echo "Подсказка: остановите брокер-контроллер и повторите скрипт, чтобы увидеть нового контроллера."
