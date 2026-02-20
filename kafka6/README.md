# Лабораторная работа 6.3: Репликация и In-Sync Replicas (ISR)

## Цель
Изучить динамику репликации Kafka, механизм In-Sync Replicas (ISR) и процесс автоматического failover при сбоях брокеров.

## Теоретическая основа

### Репликация в Kafka
- **Лидер (Leader)**: Партиция имеет одного лидера, который обрабатывает все запросы чтения и записи
- **Фолловеры (Followers)**: Реплики, которые пассивно копируют данные от лидера
- **ISR (In-Sync Replicas)**: Набор реплик, которые "синхронны" с лидером (включая самого лидера)

### Критическая концепция: ISR
ISR определяет, какие реплики считаются актуальными. Реплика удаляется из ISR, если:
- Не запрашивает данные в течение `replica.lag.time.max.ms` (по умолчанию 10 секунд)
- Отстает от лидера по данным

### Параметры производителя
- `acks=0`: Не ждать подтверждения (может потерять данные)
- `acks=1`: Ждать подтверждения только от лидера (может потерять данные при сбое)
- `acks=all`: Ждать подтверждения от всех ISR (максимальная надежность)

## Архитектура лабораторной установки

```
┌─────────────────────────────────────────────────────────┐
│                    Kafka Cluster                        │
├─────────────────┬─────────────────┬─────────────────────┤
│   Broker 1      │   Broker 2      │   Broker 3         │
│   Port: 9092    │   Port: 9093    │   Port: 9094       │
│   broker.id=1   │   broker.id=2   │   broker.id=3      │
└─────────────────┴─────────────────┴─────────────────────┘
           │              │                │
           └──────────────┴────────────────┘
                          │
                    ZooKeeper
                    Port: 2181
```

**Топик конфигурация:**
- Имя: `replication-test`
- Партиции: 3
- Replication Factor: 3
- `min.insync.replicas`: 2

## Структура проекта

```
kafka6/
├── README.md                    # Этот файл
├── docker-compose.yml           # Конфигурация кластера
├── src/
│   └── main/
│       └── java/
│           └── ReliableProducer.java    # Продюсер с acks=all
├── scripts/
│   ├── 01-setup-cluster.sh      # Запуск кластера
│   ├── 02-create-topic.sh       # Создание топика
│   ├── 03-check-isr.sh          # Проверка ISR статуса
│   ├── 04-produce-messages.sh   # Отправка сообщений
│   ├── 05-consume-messages.sh   # Чтение сообщений
│   └── 06-cleanup.sh            # Очистка
├── build.gradle                 # Конфигурация сборки
└── results/
    └── observations.md          # Шаблон для записи результатов
```

## Шаги выполнения лабораторной работы

### Шаг 1: Запуск кластера
```bash
cd kafka6
./scripts/01-setup-cluster.sh
```

Ожидается запуск 3 брокеров и ZooKeeper.

### Шаг 2: Создание топика с репликацией
```bash
./scripts/02-create-topic.sh
```

Создается топик `replication-test` с:
- 3 партициями
- Replication factor = 3
- `min.insync.replicas` = 2

### Шаг 3: Проверка начального состояния ISR
```bash
./scripts/03-check-isr.sh
```

Вы увидите:
- Лидера для каждой партиции
- Список всех реплик
- Список ISR (должен совпадать со всеми репликами)

### Шаг 4: Отправка сообщений с гарантией репликации
```bash
./scripts/04-produce-messages.sh
```

Отправляет 1000 сообщений с `acks=all`, что гарантирует запись во все ISR.

### Шаг 5: Симуляция сбоя брокера
```bash
# Остановить брокер 2
docker-compose stop kafka2

# Проверить ISR (должен уменьшиться)
./scripts/03-check-isr.sh

# Отправить еще сообщения
./scripts/04-produce-messages.sh

# Проверить, что сообщения успешно записаны
./scripts/05-consume-messages.sh
```

### Шаг 6: Тестирование автоматического failover
```bash
# Определить лидера партиции 0
./scripts/03-check-isr.sh

# Остановить брокер-лидер (например, kafka1)
docker-compose stop kafka1

# Проверить, что выбран новый лидер
./scripts/03-check-isr.sh

# Убедиться, что данные доступны
./scripts/05-consume-messages.sh
```

### Шаг 7: Восстановление брокера
```bash
# Запустить остановленные брокеры
docker-compose start kafka1 kafka2

# Подождать 10-15 секунд
sleep 15

# Проверить, что реплики вернулись в ISR
./scripts/03-check-isr.sh
```

### Шаг 8: Тестирование unclean leader election
```bash
# ВНИМАНИЕ: Это может привести к потере данных!

# 1. Настроить unclean.leader.election.enable=true
docker-compose exec kafka1 kafka-configs.sh \
  --bootstrap-server localhost:9092 \
  --entity-type topics \
  --entity-name replication-test \
  --alter \
  --add-config unclean.leader.election.enable=true

# 2. Остановить все реплики в ISR, кроме одной
# 3. Остановить последнюю ISR реплику
# 4. Запустить не-ISR реплику
# 5. Наблюдать выбор unclean лидера
```

## Эксперименты

### Эксперимент 1: Влияние min.insync.replicas
1. Установить `min.insync.replicas=2`
2. Остановить 2 брокера из 3
3. Попытаться отправить сообщения с `acks=all`
4. Ожидается ошибка: `NotEnoughReplicasException`

### Эксперимент 2: Симуляция задержки реплики
```bash
# Использовать tc для добавления задержки
docker exec kafka2 tc qdisc add dev eth0 root netem delay 200ms

# Мониторить ISR - реплика может быть исключена
./scripts/03-check-isr.sh

# Удалить задержку
docker exec kafka2 tc qdisc del dev eth0 root

# Реплика должна вернуться в ISR
```

### Эксперимент 3: Сравнение acks параметров
Измерить latency для:
- `acks=0`: ~1-2 ms
- `acks=1`: ~5-10 ms
- `acks=all`: ~10-20 ms

## Ожидаемые результаты

1. **ISR динамика**: ISR автоматически сжимается/расширяется при сбоях/восстановлениях
2. **Автоматический failover**: При сбое лидера новый лидер выбирается из ISR за <1 секунды
3. **Гарантия данных**: `acks=all` + `min.insync.replicas=2` предотвращает потерю данных
4. **Trade-off**: Надежность vs. Производительность

## Метрики для мониторинга

- `kafka.server:type=ReplicaManager,name=UnderReplicatedPartitions`
- `kafka.server:type=ReplicaManager,name=PartitionCount`
- `kafka.cluster:type=Partition,name=InSyncReplicasCount`

## Контрольные вопросы

1. Что происходит с ISR, когда брокер останавливается?
2. Может ли продюсер с `acks=all` записать данные, если доступен только 1 брокер из 3?
3. В чем разница между `replica.lag.time.max.ms` и `replica.lag.max.messages`?
4. Почему `unclean.leader.election.enable=true` опасно?
5. Как `min.insync.replicas` влияет на доступность?

## Дополнительные ресурсы

- [Kafka Replication Design](https://kafka.apache.org/documentation/#replication)
- [Kafka Reliability Guarantees](https://kafka.apache.org/documentation/#semantics)
- Глава 6: "Kafka: The Definitive Guide" (2nd Edition)

## Очистка

```bash
./scripts/06-cleanup.sh
```

Останавливает все контейнеры и удаляет данные.
