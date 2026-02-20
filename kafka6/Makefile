.PHONY: help setup topic check produce consume clean start stop restart logs build test experiments

# Цвета для вывода
BLUE=\033[0;34m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m # No Color

help: ## Показать справку
	@echo "$(BLUE)═══════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  Kafka Lab 6.3 - Репликация и ISR$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(YELLOW)Основные команды:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Примеры:$(NC)"
	@echo "  make all          # Полный цикл: setup → topic → produce → consume"
	@echo "  make experiments  # Запустить все эксперименты"
	@echo ""

all: setup topic produce consume ## Выполнить полный цикл лабораторной работы

setup: ## [1] Запустить кластер Kafka
	@echo "$(BLUE)[1/5] Запуск кластера...$(NC)"
	@./scripts/01-setup-cluster.sh

topic: ## [2] Создать топик с репликацией
	@echo "$(BLUE)[2/5] Создание топика...$(NC)"
	@./scripts/02-create-topic.sh

check: ## [3] Проверить ISR статус
	@echo "$(BLUE)[3/5] Проверка ISR...$(NC)"
	@./scripts/03-check-isr.sh

produce: build ## [4] Отправить сообщения
	@echo "$(BLUE)[4/5] Отправка сообщений...$(NC)"
	@./scripts/04-produce-messages.sh

consume: build ## [5] Прочитать сообщения
	@echo "$(BLUE)[5/5] Чтение сообщений...$(NC)"
	@./scripts/05-consume-messages.sh

build: ## Собрать Java приложение
	@echo "$(BLUE)Сборка приложения...$(NC)"
	@./gradlew clean build -x test

test: ## Запустить тесты
	@./gradlew test

clean: ## Очистить окружение
	@echo "$(YELLOW)Очистка окружения...$(NC)"
	@./scripts/06-cleanup.sh

# Docker команды
start: ## Запустить контейнеры
	@echo "$(GREEN)Запуск контейнеров...$(NC)"
	@docker-compose up -d

stop: ## Остановить контейнеры
	@echo "$(YELLOW)Остановка контейнеров...$(NC)"
	@docker-compose stop

restart: stop start ## Перезапустить контейнеры

logs: ## Показать логи всех контейнеров
	@docker-compose logs -f

logs-kafka1: ## Показать логи kafka1
	@docker-compose logs -f kafka1

logs-kafka2: ## Показать логи kafka2
	@docker-compose logs -f kafka2

logs-kafka3: ## Показать логи kafka3
	@docker-compose logs -f kafka3

# Эксперименты
experiments: experiment-failover experiment-min-isr experiment-performance ## Запустить все эксперименты

experiment-failover: ## Эксперимент: Failover
	@echo "$(BLUE)═══ Эксперимент: Failover ═══$(NC)"
	@./scripts/experiment-failover.sh

experiment-min-isr: ## Эксперимент: min.insync.replicas
	@echo "$(BLUE)═══ Эксперимент: min.insync.replicas ═══$(NC)"
	@./scripts/experiment-min-isr.sh

experiment-performance: ## Эксперимент: Производительность acks
	@echo "$(BLUE)═══ Эксперимент: Производительность acks ═══$(NC)"
	@./scripts/experiment-performance.sh

# Утилиты
shell-kafka1: ## Подключиться к shell kafka1
	@docker-compose exec kafka1 bash

shell-kafka2: ## Подключиться к shell kafka2
	@docker-compose exec kafka2 bash

shell-kafka3: ## Подключиться к shell kafka3
	@docker-compose exec kafka3 bash

describe-topic: ## Описать топик
	@docker-compose exec kafka1 kafka-topics --bootstrap-server kafka1:29092 --describe --topic replication-test

list-topics: ## Список всех топиков
	@docker-compose exec kafka1 kafka-topics --bootstrap-server kafka1:29092 --list

consumer-groups: ## Показать consumer groups
	@docker-compose exec kafka1 kafka-consumer-groups --bootstrap-server kafka1:29092 --list

status: ## Показать статус кластера
	@echo "$(BLUE)═══ Статус кластера ═══$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(BLUE)═══ Топики ═══$(NC)"
	@make list-topics || true
	@echo ""
	@echo "$(BLUE)═══ ISR ═══$(NC)"
	@make describe-topic || true

# Быстрые тесты
quick-produce: ## Быстрая отправка 100 сообщений
	@./scripts/04-produce-messages.sh localhost:9092,localhost:9093,localhost:9094 100 all

quick-consume: ## Быстрое чтение 20 сообщений
	@./scripts/05-consume-messages.sh localhost:9092,localhost:9093,localhost:9094 test-group 20

# Документация
docs: ## Открыть документацию
	@echo "$(GREEN)Документация:$(NC)"
	@echo "  - README.md          : Полное описание"
	@echo "  - QUICKSTART.md      : Быстрый старт"
	@echo "  - ARCHITECTURE.md    : Архитектура"
	@echo "  - results/observations.md : Шаблон для результатов"

readme: ## Показать README
	@cat README.md

quickstart: ## Показать QUICKSTART
	@cat QUICKSTART.md
