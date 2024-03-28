global class OpportunitySummaryScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        OpportunitySummaryBatch batch = new OpportunitySummaryBatch();
        Database.executeBatch(batch);
    }
}
