#!/bin/bash

# Скрипт: Бенчмарк производительности acks
# Сравнивает latency для acks=0, 1, all

set -e

echo "========================================="
echo "Эксперимент: Сравнение acks параметров"
echo "========================================="

cd "$(dirname "$0")/.."

BOOTSTRAP_SERVERS="localhost:9092,localhost:9093,localhost:9094"
MESSAGE_COUNT=500

echo ""
echo "Тестируем производительность для разных значений acks"
echo "Количество сообщений: $MESSAGE_COUNT"
echo ""

# Проверка наличия Gradle wrapper
if [ ! -f "./gradlew" ]; then
    echo "Инициализация Gradle wrapper..."
    gradle wrapper --gradle-version 8.4
fi

# Сборка
echo "Сборка приложения..."
./gradlew clean build -x test > /dev/null 2>&1

declare -a RESULTS

for acks_value in 0 1 all; do
    echo ""
    echo "========================================="
    echo "Тест с acks=$acks_value"
    echo "========================================="
    
    # Запуск продюсера и сохранение вывода
    output=$(./gradlew runProducer -PappArgs="$BOOTSTRAP_SERVERS,$MESSAGE_COUNT,$acks_value" 2>&1)
    
    # Извлечение средней latency
    avg_latency=$(echo "$output" | grep "Средняя latency:" | awk '{print $3}')
    
    if [ -z "$avg_latency" ]; then
        avg_latency="N/A"
    fi
    
    RESULTS+=("acks=$acks_value: ${avg_latency} ms")
    
    echo "Средняя latency: ${avg_latency} ms"
    
    sleep 2
done

echo ""
echo "========================================="
echo "Сводка результатов:"
echo "========================================="

for result in "${RESULTS[@]}"; do
    echo "  $result"
done

echo ""
echo "========================================="
echo "Выводы:"
echo "========================================="
echo "- acks=0: Минимальная latency, НЕТ гарантий"
echo "- acks=1: Средняя latency, гарантия записи на лидера"
echo "- acks=all: Максимальная latency, ПОЛНАЯ гарантия"
echo ""
echo "Trade-off: Надежность ⟷ Производительность"
echo "========================================="
