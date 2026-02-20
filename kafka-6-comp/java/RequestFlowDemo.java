public class RequestFlowDemo {
    public static void main(String[] args) {
        System.out.println("Demo: Поток обработки Produce/Fetch запросов в Kafka");
        System.out.println("1) Acceptor принимает соединение");
        System.out.println("2) Processor читает запрос и кладет в очередь");
        System.out.println("3) IO-thread обрабатывает запрос");
        System.out.println("4) Purgatory удерживает запрос до условий acks");
        System.out.println("");
        System.out.println("acks=0  -> ответ без ожидания реплик");
        System.out.println("acks=1  -> ответ после записи лидером");
        System.out.println("acks=all-> ответ после подтверждения всеми ISR");
        System.out.println("");
        System.out.println("Идея: надежность растет, но latency увеличивается.");
    }
}
