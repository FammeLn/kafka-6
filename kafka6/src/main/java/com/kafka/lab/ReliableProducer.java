package com.kafka.lab;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.time.Instant;

/**
 * Надежный продюсер для демонстрации репликации с acks=all
 * 
 * Этот продюсер демонстрирует:
 * - Использование acks=all для гарантии записи во все ISR
 * - Обработку ошибок репликации
 * - Измерение latency при различных настройках
 */
public class ReliableProducer {
    
    private static final Logger logger = LoggerFactory.getLogger(ReliableProducer.class);
    private static final String TOPIC = "replication-test";
    
    public static void main(String[] args) {
        // Параметры из командной строки
        String bootstrapServers = args.length > 0 ? args[0] : "localhost:9092,localhost:9093,localhost:9094";
        int messageCount = args.length > 1 ? Integer.parseInt(args[1]) : 1000;
        String acks = args.length > 2 ? args[2] : "all";
        
        logger.info("Запуск ReliableProducer");
        logger.info("Bootstrap servers: {}", bootstrapServers);
        logger.info("Количество сообщений: {}", messageCount);
        logger.info("Acks: {}", acks);
        
        Properties props = createProducerConfig(bootstrapServers, acks);
        
        long totalLatency = 0;
        int successCount = 0;
        int errorCount = 0;
        
        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            
            for (int i = 0; i < messageCount; i++) {
                String key = "key-" + (i % 10); // 10 уникальных ключей для распределения по партициям
                String value = String.format("Message %d at %s", i, Instant.now());
                
                ProducerRecord<String, String> record = new ProducerRecord<>(TOPIC, key, value);
                
                long startTime = System.currentTimeMillis();
                
                try {
                    // Синхронная отправка для измерения latency
                    Future<RecordMetadata> future = producer.send(record, new Callback() {
                        @Override
                        public void onCompletion(RecordMetadata metadata, Exception exception) {
                            if (exception != null) {
                                logger.error("Ошибка отправки сообщения {}: {}", i, exception.getMessage());
                            } else {
                                if (i % 100 == 0) {
                                    logger.info("Сообщение {} отправлено в partition {}, offset {}",
                                            i, metadata.partition(), metadata.offset());
                                }
                            }
                        }
                    });
                    
                    // Ждем подтверждения
                    RecordMetadata metadata = future.get();
                    
                    long latency = System.currentTimeMillis() - startTime;
                    totalLatency += latency;
                    successCount++;
                    
                    if (i % 100 == 0) {
                        logger.info("Latency для сообщения {}: {} ms", i, latency);
                    }
                    
                } catch (ExecutionException e) {
                    errorCount++;
                    logger.error("ExecutionException для сообщения {}: {}", i, e.getCause().getMessage());
                    
                    // Обработка специфичных ошибок
                    if (e.getCause() instanceof org.apache.kafka.common.errors.NotEnoughReplicasException) {
                        logger.error("NotEnoughReplicasException - недостаточно ISR для записи!");
                    } else if (e.getCause() instanceof org.apache.kafka.common.errors.TimeoutException) {
                        logger.error("TimeoutException - превышено время ожидания репликации!");
                    }
                    
                } catch (InterruptedException e) {
                    errorCount++;
                    logger.error("InterruptedException для сообщения {}", i);
                    Thread.currentThread().interrupt();
                    break;
                }
                
                // Небольшая пауза для наблюдаемости
                if (i % 100 == 0 && i > 0) {
                    Thread.sleep(100);
                }
            }
            
            // Flush для гарантии отправки всех сообщений
            producer.flush();
            
        } catch (Exception e) {
            logger.error("Критическая ошибка: ", e);
        }
        
        // Статистика
        logger.info("=== Статистика отправки ===");
        logger.info("Успешно отправлено: {}", successCount);
        logger.info("Ошибок: {}", errorCount);
        if (successCount > 0) {
            logger.info("Средняя latency: {} ms", totalLatency / successCount);
        }
        logger.info("========================");
    }
    
    /**
     * Создает конфигурацию продюсера с фокусом на надежность
     */
    private static Properties createProducerConfig(String bootstrapServers, String acks) {
        Properties props = new Properties();
        
        // Базовые настройки
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        
        // Настройки надежности
        props.put(ProducerConfig.ACKS_CONFIG, acks);
        // acks=all означает ждать подтверждения от всех ISR
        
        props.put(ProducerConfig.RETRIES_CONFIG, 3);
        // Количество повторных попыток при ошибках
        
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 1);
        // Гарантирует порядок сообщений (только 1 batch в полете)
        
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        // Идемпотентность предотвращает дубликаты при retry
        
        props.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, 30000);
        // Таймаут для запроса (30 секунд)
        
        props.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, 60000);
        // Общий таймаут доставки (60 секунд)
        
        // Настройки батчинга (для эксперимента можно отключить)
        props.put(ProducerConfig.BATCH_SIZE_CONFIG, 16384);
        props.put(ProducerConfig.LINGER_MS_CONFIG, 10);
        
        // Compression для эффективности
        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");
        
        // Client ID для мониторинга
        props.put(ProducerConfig.CLIENT_ID_CONFIG, "reliable-producer-lab6");
        
        return props;
    }
}
