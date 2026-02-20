public class OffsetCommitNotes {
    public static void main(String[] args) {
        System.out.println("Commit offsets: auto vs manual");
        System.out.println("auto commit -> проще, но риск повторов");
        System.out.println("sync commit -> надежно, но медленнее");
        System.out.println("async commit -> быстрее, возможен пропуск последнего offset");
        System.out.println("");
        System.out.println("Гарантии:");
        System.out.println("- at-most-once: commit до обработки");
        System.out.println("- at-least-once: commit после обработки");
    }
}
