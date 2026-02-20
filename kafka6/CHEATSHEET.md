# Памятка по Kafka Lab 6.3

## Быстрые команды

```bash
# Полный цикл
make all

# По шагам
make setup      # Запуск кластера
make topic      # Создание топика
make check      # Проверка ISR
make produce    # Отправка сообщений
make consume    # Чтение сообщений

# Эксперименты
make experiments                 # Все эксперименты
make experiment-failover         # Failover тест
make experiment-min-isr          # min.insync.replicas
make experiment-performance      # Бенчмарк acks

# Утилиты
make status     # Статус кластера
make logs       # Все логи
make clean      # Очистка
make help       # Справка
```

## Ключевые концепции

### ISR (In-Sync Replicas)
- Набор реплик, синхронных с лидером
- Включает самого лидера
- Автоматически сжимается/расширяется

### Параметр acks
```
acks=0   → Не ждать подтверждения (быстро, ненадежно)
acks=1   → Ждать лидера (средне)
acks=all → Ждать всех ISR (медленно, надежно)
```

### min.insync.replicas
```
replication.factor = 3
min.insync.replicas = 2

3 брокера живы → ✓ Запись работает
2 брокера живы → ✓ Запись работает  
1 брокер живой → ✗ NotEnoughReplicasException
```

## Полезные Docker команды

```bash
# Остановить брокер
docker-compose stop kafka2

# Запустить брокер
docker-compose start kafka2

# Логи брокера
docker-compose logs -f kafka1

# Shell в контейнере
docker-compose exec kafka1 bash

# Статус всех контейнеров
docker-compose ps
```

## Kafka CLI команды

```bash
# Внутри контейнера
docker-compose exec kafka1 bash

# Список топиков
kafka-topics --bootstrap-server localhost:9092 --list

# Описание топика
kafka-topics --bootstrap-server localhost:9092 \
  --describe --topic replication-test

# Конфигурация топика
kafka-configs --bootstrap-server localhost:9092 \
  --entity-type topics \
  --entity-name replication-test \
  --describe

# Изменить конфигурацию
kafka-configs --bootstrap-server localhost:9092 \
  --entity-type topics \
  --entity-name replication-test \
  --alter \
  --add-config min.insync.replicas=1

# Отправить сообщение
echo "test" | kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic replication-test

# Прочитать сообщения
kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic replication-test \
  --from-beginning \
  --max-messages 10

# Consumer groups
kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --list
```

## Gradle команды

```bash
# Сборка
./gradlew clean build

# Запуск продюсера
./gradlew runProducer -PappArgs="localhost:9092,1000,all"

# Запуск консьюмера
./gradlew runConsumer -PappArgs="localhost:9092,test-group,100"

# Тесты
./gradlew test
```

## Сценарии экспериментов

### Failover тест
```bash
1. make check                    # Запомнить лидера
2. docker-compose stop kafka1    # Остановить брокер
3. make check                    # Проверить нового лидера
4. make produce                  # Отправить сообщения
5. docker-compose start kafka1   # Восстановить
6. make check                    # Проверить ISR
```

### min.insync.replicas тест
```bash
1. make check                    # ISR = [1,2,3]
2. docker-compose stop kafka2 kafka3
3. make produce                  # Ошибка!
4. docker-compose start kafka2 kafka3
5. make produce                  # Успех
```

### Performance тест
```bash
make experiment-performance

Результат:
- acks=0:   ~2ms   (может потерять)
- acks=1:   ~10ms  (может потерять при failover)
- acks=all: ~20ms  (не потеряет данные)
```

## Метрики для мониторинга

```
UnderReplicatedPartitions → Партиции с ISR < Replicas
OfflinePartitionsCount    → Партиции без лидера
ISRShrinkRate            → Частота уменьшения ISR
ISRExpandRate            → Частота увеличения ISR
```

## Troubleshooting

### Порты заняты
```bash
sudo lsof -i :9092
docker-compose down
```

### Брокеры не стартуют
```bash
docker-compose logs kafka1
docker-compose down -v
docker-compose up -d
```

### Java не компилируется
```bash
./gradlew clean build --refresh-dependencies
```

## Важные файлы

```
README.md          → Полное руководство
QUICKSTART.md      → Быстрый старт
ARCHITECTURE.md    → Архитектура
Makefile           → Команды
docker-compose.yml → Конфигурация кластера
```

## Контрольные вопросы

1. Что происходит с ISR при остановке брокера?
2. Можно ли писать с acks=all, если доступен 1 из 3 брокеров?
3. В чем разница между replication.factor и min.insync.replicas?
4. Почему unclean.leader.election.enable=true опасно?
5. Как min.insync.replicas влияет на доступность?

## Ответы

1. ISR уменьшается, исключая остановленный брокер
2. Нет, если min.insync.replicas=2 → NotEnoughReplicasException
3. RF - количество копий, min ISR - минимум синхронных для записи
4. Может выбрать не-ISR реплику → потеря данных
5. Повышает надежность, но снижает доступность

---

**Удачи! 🚀**
