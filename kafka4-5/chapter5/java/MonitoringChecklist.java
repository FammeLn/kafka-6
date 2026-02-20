public class MonitoringChecklist {
    public static void main(String[] args) {
        System.out.println("Ключевые метрики Kafka");
        System.out.println("- UnderReplicatedPartitions");
        System.out.println("- OfflinePartitionsCount");
        System.out.println("- IsrShrinksPerSec / IsrExpandsPerSec");
        System.out.println("- RequestHandlerAvgIdlePercent");
        System.out.println("- LogFlushRateAndTimeMs");
    }
}
