# Проект-доказательство понимания Главы 5 Kafka

Доказательство изучения: "Kafka: The Definitive Guide" (2-е издание), Глава 5 (Managing Kafka).

## Цель
Показать понимание операционных аспектов Kafka: конфигурации брокеров и топиков, ретеншн, компактизация, мониторинг, безопасность и best practices.

## Структура

```
chapter5/
├── README.md
├── report.txt
├── scripts/
│   ├── demo-topic-configs.sh
│   ├── demo-retention.sh
│   ├── demo-compaction.sh
│   ├── demo-quotas.sh
│   └── demo-monitoring.sh
└── java/
    ├── AdminOpsNotes.java
    └── MonitoringChecklist.java
```

## Соответствие разделам главы

1. Конфигурация брокеров и топиков
2. Retention и log cleanup
3. Compaction для ключевых данных
4. Безопасность и quotas
5. Мониторинг и метрики

## Факты и термины

### Конфигурации
- Брокеры имеют server properties.
- Топики могут переопределять настройки брокеров.

### Retention
- Очистка по времени (`retention.ms`) или размеру (`retention.bytes`).
- Удаляются целые сегменты, не отдельные сообщения.

### Compaction
- Сохраняется последнее значение по ключу.
- Полезно для changelog и state восстановления.

### Quotas
- Ограничения на скорость produce/fetch.
- Защищают кластер от noisy neighbors.

### Мониторинг
- UnderReplicatedPartitions, OfflinePartitionsCount, ISR shrink/expand.
- Логи и JMX метрики критичны для эксплуатации.

## Демонстрации и теория

### Demo 1: Конфиги топиков
Файл: `scripts/demo-topic-configs.sh`

Теория: Сравнение broker defaults и topic overrides. Важна согласованность для стабильности.

### Demo 2: Retention
Файл: `scripts/demo-retention.sh`

Теория: Ретеншн удаляет целые сегменты. Это влияет на срок хранения и диск.

### Demo 3: Compaction
Файл: `scripts/demo-compaction.sh`

Теория: Оставляет последнее значение по ключу, уменьшает объем и сохраняет актуальное состояние.

### Demo 4: Quotas
Файл: `scripts/demo-quotas.sh`

Теория: Quotas ограничивают throughput клиентов и защищают стабильность.

### Demo 5: Monitoring
Файл: `scripts/demo-monitoring.sh`

Теория: Метрики ISR и offline partitions дают раннее предупреждение о проблемах.

## Код и теория

### AdminOpsNotes.java
Фиксирует best practices управления Kafka: конфиги, ретеншн, compaction, quotas.

### MonitoringChecklist.java
Список ключевых метрик и что они означают.

## Теоретические вопросы и ответы

1. Чем broker config отличается от topic config?
Ответ: Topic config может переопределять broker defaults только для одного топика.

2. Почему удаляются целые сегменты?
Ответ: Это быстрее и проще, чем удалять отдельные сообщения.

3. Чем полезна compaction?
Ответ: Хранит последнее значение по ключу, полезна для state и CDC.

4. Зачем нужны quotas?
Ответ: Чтобы защитить кластер от одного клиента.

5. Какие метрики критичны для эксплуатации?
Ответ: UnderReplicatedPartitions, OfflinePartitionsCount, ISR shrink/expand.

6. Почему важен log.segment.bytes?
Ответ: Он определяет размер сегментов и влияет на скорость очистки.

7. Чем отличаются retention.ms и retention.bytes?
Ответ: Первое — по времени, второе — по размеру.

8. Зачем менять log.cleanup.policy?
Ответ: Для выбора delete или compact стратегии.

9. Что важнее: дисковая скорость или CPU?
Ответ: Для Kafka критичны оба, но диск часто является бутылочным горлышком.

10. Почему важно мониторить JMX?
Ответ: Через JMX доступны метрики, необходимые для диагностики.

## Как запустить

Используется общий docker-compose из kafka-6-comp:

```bash
cd /workspaces/kafka-6/kafka4-5/chapter5
docker-compose -f ../../kafka-6-comp/docker-compose.yml up -d
./scripts/demo-topic-configs.sh
./scripts/demo-retention.sh
./scripts/demo-compaction.sh
./scripts/demo-quotas.sh
./scripts/demo-monitoring.sh
```

## Итог
Проект покрывает ключевые операционные темы главы 5: конфигурации, ретеншн, компактизация, квоты и мониторинг.
