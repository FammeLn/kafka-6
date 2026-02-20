# Проект-доказательство понимания Главы 4 Kafka

Доказательство изучения: "Kafka: The Definitive Guide" (2-е издание), Глава 4 (Consumers).

## Цель
Показать понимание работы потребителей Kafka: группы, ребалансировка, commit offset, стратегия доставки, lag и поведение при сбоях.

## Структура

```
chapter4/
├── README.md
├── report.txt
├── scripts/
│   ├── demo-consumer-group.sh
│   ├── demo-offset-reset.sh
│   ├── demo-lag.sh
│   ├── demo-rebalance.sh
│   └── demo-assignments.sh
└── java/
	├── ConsumerFlowDemo.java
	└── OffsetCommitNotes.java
```

## Соответствие разделам главы

1. Модель потребления и pull-подход
2. Consumer groups и распределение партиций
3. Rebalance и стратегии назначения
4. Управление offset (auto/commit sync/async)
5. Lag, retries и обработка ошибок

## Факты и термины

### Pull-модель
- Потребитель сам запрашивает данные (poll), контролирует скорость чтения.
- Batch-получение снижает накладные расходы.

### Consumer group
- Каждая партиция читается одним потребителем в группе.
- При изменении состава группы возникает rebalance.

### Rebalance
- Останавливает распределение партиций и назначает их заново.
- Риск: остановка обработки при длительной ребалансировке.

### Commit offset
- Auto commit: простой, но риск повторов.
- Sync commit: надежнее, но медленнее.
- Async commit: быстрее, но возможна потеря последнего offset.

### Lag
- Lag = difference between last produced offset and last committed offset.
- Важный показатель производительности и стабильности потребителя.

## Демонстрации и теория

### Demo 1: Consumer group
Файл: `scripts/demo-consumer-group.sh`

Теория: В группе один partition обслуживается одним consumer. При втором consumer происходит перераспределение.

### Demo 2: Offset reset
Файл: `scripts/demo-offset-reset.sh`

Теория: `auto.offset.reset` определяет старт чтения при отсутствии commit: earliest или latest.

### Demo 3: Lag
Файл: `scripts/demo-lag.sh`

Теория: Lag отражает отставание потребителя. Используется для мониторинга и алертинга.

### Demo 4: Rebalance
Файл: `scripts/demo-rebalance.sh`

Теория: Rebalance при добавлении/удалении потребителей. Важна настройка `max.poll.interval.ms` и `session.timeout.ms`.

### Demo 5: Assignments
Файл: `scripts/demo-assignments.sh`

Теория: Разные стратегии назначения (range, round-robin, sticky) влияют на распределение партиций.

## Код и теория

### ConsumerFlowDemo.java
Объясняет жизненный цикл poll/commit и риски при сбоях.

### OffsetCommitNotes.java
Сравнивает auto/sync/async commit и последствия для гарантии доставки.

## Теоретические вопросы и ответы

1. Почему Kafka использует pull модель?
Ответ: Потребитель сам управляет скоростью, что снижает риск перегрузки.

2. Что такое rebalance и почему он важен?
Ответ: Это перераспределение партиций в группе, временно останавливающее обработку.

3. Чем отличается auto commit от manual commit?
Ответ: Auto commit проще, но менее точный; manual commit позволяет контролировать границы обработки.

4. Зачем нужен lag?
Ответ: Lag показывает отставание и помогает обнаружить проблемы производительности.

5. Что происходит при падении consumer?
Ответ: Его партиции переходят другим участникам группы после rebalance.

6. Почему важен `max.poll.interval.ms`?
Ответ: При превышении потребитель считается зависшим и исключается из группы.

7. Когда полезен sticky assignor?
Ответ: Он минимизирует перемещения партиций при rebalance.

8. Что такое at-least-once доставка?
Ответ: Возможны дубликаты при повторной обработке после сбоев.

9. Как избежать потери сообщений?
Ответ: Использовать manual commit после успешной обработки.

10. Почему важно обрабатывать ошибки в consumer?
Ответ: Ошибки без commit приводят к повторному чтению.

## Как запустить

Используется общий docker-compose из kafka-6-comp:

```bash
cd /workspaces/kafka-6/kafka4-5/chapter4
docker-compose -f ../../kafka-6-comp/docker-compose.yml up -d
./scripts/demo-consumer-group.sh
./scripts/demo-offset-reset.sh
./scripts/demo-lag.sh
./scripts/demo-rebalance.sh
./scripts/demo-assignments.sh
```

## Итог
Проект покрывает все ключевые механизмы работы потребителей, включая группы, ребалансировки, коммиты и lag.
