# Архитектура лабораторной работы 6.3

## Обзор системы

Эта лабораторная работа демонстрирует внутренние механизмы репликации Kafka через практические эксперименты.

## Компоненты

### 1. Kafka Cluster (Docker)

```
┌──────────────── Kafka Cluster ────────────────┐
│                                                │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│  │ Kafka1  │  │ Kafka2  │  │ Kafka3  │       │
│  │ :9092   │  │ :9093   │  │ :9094   │       │
│  │ ID=1    │  │ ID=2    │  │ ID=3    │       │
│  └────┬────┘  └────┬────┘  └────┬────┘       │
│       │            │            │             │
│       └────────────┴────────────┘             │
│                    │                          │
│              ┌─────┴──────┐                   │
│              │ ZooKeeper  │                   │
│              │   :2181    │                   │
│              └────────────┘                   │
└────────────────────────────────────────────────┘
```

**Характеристики:**
- 3 брокера для полной репликации
- ZooKeeper для координации метаданных
- Отдельные volumes для каждого брокера

### 2. Test Topic: replication-test

```
Topic: replication-test
├── Partition 0
│   ├── Leader: Broker X
│   ├── Replicas: [1, 2, 3]
│   └── ISR: [1, 2, 3]
├── Partition 1
│   ├── Leader: Broker Y
│   ├── Replicas: [2, 3, 1]
│   └── ISR: [2, 3, 1]
└── Partition 2
    ├── Leader: Broker Z
    ├── Replicas: [3, 1, 2]
    └── ISR: [3, 1, 2]
```

**Конфигурация:**
- `partitions`: 3 (для распределения нагрузки)
- `replication.factor`: 3 (каждое сообщение на всех брокерах)
- `min.insync.replicas`: 2 (минимум 2 ISR для записи)

### 3. Java Applications

#### ReliableProducer
```java
Producer with:
├── acks=all             // Ждать подтверждения от всех ISR
├── retries=3            // 3 попытки при ошибках
├── max.in.flight=1      // Гарантия порядка
└── enable.idempotence   // Предотвращение дубликатов
```

#### SimpleConsumer
```java
Consumer with:
├── earliest offset      // Читать с начала
├── manual commit        // Явный контроль оффсетов
└── unique group.id      // Независимое потребление
```

## Потоки данных

### Сценарий 1: Нормальная запись

```
Producer (acks=all)
    │
    ├─→ Broker 1 (Leader) ──┐
    │                        │
    │                        ├─→ Commit
    │                        │
    ├─→ Broker 2 (Follower) ─┤
    │                        │
    └─→ Broker 3 (Follower) ─┘
         │
         └─→ ACK to Producer
```

**Шаги:**
1. Продюсер отправляет сообщение лидеру
2. Лидер записывает в свой лог
3. Фолловеры копируют из лидера
4. Когда все ISR подтвердили → ACK продюсеру

### Сценарий 2: Failover

```
Before:
Partition 0: Leader=1, ISR=[1,2,3]

Broker 1 fails ❌

After (automatic):
Partition 0: Leader=2, ISR=[2,3]

ZooKeeper triggers:
├── Controller notice broker 1 offline
├── Select new leader from ISR (broker 2)
├── Update metadata
└── Notify all brokers
```

**Время failover:**
- Обнаружение сбоя: ~6-10 секунд (ZK session timeout)
- Выбор лидера: <1 секунда
- Обновление метаданных: <1 секунда

### Сценарий 3: min.insync.replicas

```
Configuration:
├── replication.factor = 3
├── min.insync.replicas = 2
└── acks = all

Scenario A: 3 броkers alive
ISR = [1, 2, 3]
Result: ✓ Write succeeds

Scenario B: 2 brokers alive
ISR = [1, 2]
Result: ✓ Write succeeds (min.insync.replicas met)

Scenario C: 1 broker alive
ISR = [1]
Result: ✗ NotEnoughReplicasException
         (ISR count < min.insync.replicas)
```

## Ключевые концепции

### ISR (In-Sync Replicas)

**Критерии включения в ISR:**
1. Реплика должна быть живой (heartbeat к ZooKeeper)
2. Реплика должна запрашивать данные в течение `replica.lag.time.max.ms` (10s)
3. Реплика не должна отставать по данным

**Исключение из ISR:**
- Брокер падает
- Сетевые проблемы (задержка > 10s)
- Медленный диск (не успевает копировать)

### Гарантии надежности

| acks | Гарантия | Риск потери | Latency |
|------|----------|-------------|---------|
| 0    | Нет      | Высокий     | ~1-2ms  |
| 1    | Лидер    | Средний     | ~5-10ms |
| all  | Все ISR  | Низкий*     | ~10-20ms|

*С правильным `min.insync.replicas`

### Trade-offs

```
Надежность ⟷ Производительность
     ↑              ↓
acks=all      acks=0
min.isr=2     min.isr=1
     ↓              ↑
 Latency++     Latency--
```

## Мониторинг

### Ключевые метрики

1. **UnderReplicatedPartitions**
   - Значение: Количество партиций с ISR < Replicas
   - Критично: > 0 означает проблемы с репликацией

2. **OfflinePartitionsCount**
   - Значение: Партиции без лидера
   - Критично: > 0 означает недоступность данных

3. **ISR Shrink/Expand Rate**
   - Значение: Частота изменения ISR
   - Высокая частота → нестабильность кластера

4. **Replica Lag**
   - Значение: Задержка фолловеров от лидера
   - Высокая задержка → риск исключения из ISR

## Сетевая топология

```
Host Machine
    │
    ├─ localhost:9092 → kafka1:29092 (internal)
    ├─ localhost:9093 → kafka2:29093 (internal)
    ├─ localhost:9094 → kafka3:29094 (internal)
    └─ localhost:2181 → zookeeper:2181
         │
         └─ Docker Network: kafka-network
              │
              ├─ kafka1 (kafka1:29092)
              ├─ kafka2 (kafka2:29093)
              ├─ kafka3 (kafka3:29094)
              └─ zookeeper (zookeeper:2181)
```

**Listeners:**
- `PLAINTEXT`: Для inter-broker communication
- `PLAINTEXT_HOST`: Для клиентов извне Docker

## Хранилище данных

```
Docker Volumes:
├── zookeeper-data/      # Метаданные кластера
├── zookeeper-logs/      # Логи ZK
├── kafka1-data/         # Логи партиций брокера 1
├── kafka2-data/         # Логи партиций брокера 2
└── kafka3-data/         # Логи партиций брокера 3

На каждом брокере:
/var/lib/kafka/data/
└── replication-test-{partition}/
    ├── 00000000000000000000.log   # Сегмент данных
    ├── 00000000000000000000.index # Индекс оффсетов
    └── 00000000000000000000.timeindex # Временной индекс
```

## Протокол репликации

### Fetch Request (Follower → Leader)

```
1. Follower отправляет FetchRequest:
   {
     "partition": 0,
     "fetchOffset": 1000,
     "maxBytes": 1048576
   }

2. Leader отвечает FetchResponse:
   {
     "partition": 0,
     "highWatermark": 2000,
     "records": [...]
   }

3. Follower:
   - Записывает records в свой лог
   - Обновляет свой highWatermark
   - Отправляет следующий FetchRequest
```

### High Watermark

```
Leader Log:    [0...1000...2000...2500]
                          ↑      ↑
                          HW     LEO

Follower1:     [0...1000...2000]
                          ↑
                          LEO

Follower2:     [0...1000...1800]
                          ↑
                          LEO

HW = min(all ISR LEO) = 1800
```

**High Watermark (HW):**
- Оффсет последнего сообщения, скопированного всеми ISR
- Только сообщения до HW видны консьюмерам
- Гарантирует, что консьюмеры не читают нереплицированные данные

## Резюме

Эта архитектура демонстрирует:
1. ✅ Автоматический failover через ISR
2. ✅ Гарантии доставки через acks и min.insync.replicas
3. ✅ Trade-off надежности и производительности
4. ✅ Внутренние механизмы репликации Kafka

Для production добавьте:
- Мониторинг (Prometheus, Grafana)
- Алертинг (AlertManager)
- Больше брокеров (5+)
- Rack awareness
- Security (SSL, SASL)
