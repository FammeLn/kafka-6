public class AcksLatencyNotes {
    public static void main(String[] args) {
        System.out.println("Acks и надежность записи");
        System.out.println("acks=0   -> нет ожидания подтверждений, минимальная latency");
        System.out.println("acks=1   -> подтверждение от лидера, риск при failover");
        System.out.println("acks=all -> подтверждение от всех ISR, максимум надежности");
        System.out.println("");
        System.out.println("Связь с ISR:");
        System.out.println("- ISR определяет, какие реплики считаются синхронными");
        System.out.println("- min.insync.replicas ограничивает запись при acks=all");
        System.out.println("");
        System.out.println("Связь с high watermark:");
        System.out.println("- потребители видят данные только до HW");
        System.out.println("- HW обновляется после репликации всеми ISR");
    }
}
