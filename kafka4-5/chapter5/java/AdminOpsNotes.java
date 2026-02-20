public class AdminOpsNotes {
    public static void main(String[] args) {
        System.out.println("Управление Kafka: краткие тезисы");
        System.out.println("- broker configs задают defaults");
        System.out.println("- topic configs могут переопределять defaults");
        System.out.println("- retention удаляет целые сегменты");
        System.out.println("- compaction сохраняет последнее значение по ключу");
        System.out.println("- quotas защищают кластер от перегрузки");
    }
}
