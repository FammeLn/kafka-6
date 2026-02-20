# Быстрый старт - Лабораторная работа 6.3

## Предварительные требования

- Docker и Docker Compose
- Java 11 или выше
- Gradle (или используйте wrapper)
- 4+ GB свободной RAM
- Свободные порты: 9092, 9093, 9094, 2181

## Быстрый запуск (5 минут)

### 1. Запуск кластера
```bash
cd kafka6
chmod +x scripts/*.sh
./scripts/01-setup-cluster.sh
```

### 2. Создание топика
```bash
./scripts/02-create-topic.sh
```

### 3. Проверка ISR
```bash
./scripts/03-check-isr.sh
```

### 4. Отправка сообщений
```bash
./scripts/04-produce-messages.sh
```

### 5. Чтение сообщений
```bash
./scripts/05-consume-messages.sh
```

## Эксперименты

### Failover при сбое
```bash
./scripts/experiment-failover.sh
```

### Тест min.insync.replicas
```bash
./scripts/experiment-min-isr.sh
```

### Бенчмарк производительности
```bash
./scripts/experiment-performance.sh
```

## Ручные команды

### Остановка брокера
```bash
docker-compose stop kafka2
```

### Запуск брокера
```bash
docker-compose start kafka2
```

### Проверка логов
```bash
docker-compose logs -f kafka1
```

### Отправка тестового сообщения
```bash
docker-compose exec kafka1 bash -c \
  "echo 'test' | kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic replication-test"
```

### Чтение сообщений
```bash
docker-compose exec kafka1 kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic replication-test \
  --from-beginning \
  --max-messages 10
```

## Полезные команды

### Список топиков
```bash
docker-compose exec kafka1 kafka-topics \
  --bootstrap-server localhost:9092 \
  --list
```

### Детали топика
```bash
docker-compose exec kafka1 kafka-topics \
  --bootstrap-server localhost:9092 \
  --describe \
  --topic replication-test
```

### Конфигурация топика
```bash
docker-compose exec kafka1 kafka-configs \
  --bootstrap-server localhost:9092 \
  --entity-type topics \
  --entity-name replication-test \
  --describe
```

### Изменение конфигурации
```bash
docker-compose exec kafka1 kafka-configs \
  --bootstrap-server localhost:9092 \
  --entity-type topics \
  --entity-name replication-test \
  --alter \
  --add-config min.insync.replicas=1
```

### Consumer groups
```bash
docker-compose exec kafka1 kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --list
```

## Очистка

```bash
./scripts/06-cleanup.sh
```

## Troubleshooting

### Порты заняты
```bash
# Проверить, что занимает порты
sudo lsof -i :9092
sudo lsof -i :9093
sudo lsof -i :9094

# Остановить существующие контейнеры
docker-compose down
```

### Брокеры не запускаются
```bash
# Проверить логи
docker-compose logs kafka1
docker-compose logs zookeeper

# Пересоздать контейнеры
docker-compose down -v
docker-compose up -d
```

### Ошибки при подключении
```bash
# Проверить сеть
docker network ls
docker network inspect kafka6_kafka-network

# Проверить статус
docker-compose ps
```

### Java приложение не компилируется
```bash
# Очистить кэш Gradle
./gradlew clean

# Пересобрать
./gradlew build --refresh-dependencies
```

## Дополнительные ресурсы

- [Полная документация](README.md)
- [Шаблон наблюдений](results/observations.md)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
