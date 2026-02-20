public class ConsumerFlowDemo {
    public static void main(String[] args) {
        System.out.println("Поток работы consumer в Kafka");
        System.out.println("1) subscribe() -> присоединение к group");
        System.out.println("2) poll() -> получение batch сообщений");
        System.out.println("3) обработка сообщений");
        System.out.println("4) commit offsets (sync/async)");
        System.out.println("");
        System.out.println("Теория:");
        System.out.println("- poll управляет скоростью чтения");
        System.out.println("- commit после обработки гарантирует at-least-once");
        System.out.println("- при сбое без commit сообщения читаются повторно");
    }
}
