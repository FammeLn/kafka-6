package com.kafka.lab;

import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

/**
 * Простой консьюмер для верификации данных
 */
public class SimpleConsumer {
    
    private static final Logger logger = LoggerFactory.getLogger(SimpleConsumer.class);
    private static final String TOPIC = "replication-test";
    
    public static void main(String[] args) {
        String bootstrapServers = args.length > 0 ? args[0] : "localhost:9092,localhost:9093,localhost:9094";
        String groupId = args.length > 1 ? args[1] : "lab6-consumer-group";
        int maxMessages = args.length > 2 ? Integer.parseInt(args[2]) : 1000;
        
        logger.info("Запуск SimpleConsumer");
        logger.info("Bootstrap servers: {}", bootstrapServers);
        logger.info("Group ID: {}", groupId);
        
        Properties props = createConsumerConfig(bootstrapServers, groupId);
        
        int messageCount = 0;
        
        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props)) {
            consumer.subscribe(Collections.singletonList(TOPIC));
            
            logger.info("Подписка на топик: {}", TOPIC);
            
            while (messageCount < maxMessages) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));
                
                if (records.isEmpty()) {
                    logger.info("Нет новых сообщений, ожидание...");
                    continue;
                }
                
                for (ConsumerRecord<String, String> record : records) {
                    logger.info("Получено: partition={}, offset={}, key={}, value={}",
                            record.partition(), record.offset(), record.key(), record.value());
                    messageCount++;
                }
                
                // Синхронный commit для надежности
                consumer.commitSync();
                
                logger.info("Всего получено сообщений: {}", messageCount);
            }
            
        } catch (Exception e) {
            logger.error("Ошибка при потреблении: ", e);
        }
        
        logger.info("Завершено. Всего получено: {} сообщений", messageCount);
    }
    
    private static Properties createConsumerConfig(String bootstrapServers, String groupId) {
        Properties props = new Properties();
        
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        
        // Читать с начала при первом запуске
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        
        // Отключить auto-commit для явного контроля
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
        
        props.put(ConsumerConfig.CLIENT_ID_CONFIG, "simple-consumer-lab6");
        
        return props;
    }
}
