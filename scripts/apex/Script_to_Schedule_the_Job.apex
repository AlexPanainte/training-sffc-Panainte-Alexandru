// Schedule the job daily at 10:00 AM
String dailyCron = '0 0 10 * * ?';
System.schedule('Opportunity Summary Daily', dailyCron, new OpportunitySummaryScheduler());

// Schedule the job once a week (Friday at 1:00 PM)
String weeklyCron = '0 0 13 ? * FRI';
System.schedule('Opportunity Summary Weekly', weeklyCron, new OpportunitySummaryScheduler());

// Schedule the job once a month (Last Friday of the Month at 6:00 PM)
String monthlyCron = '0 0 18 ? * 6L';
System.schedule('Opportunity Summary Monthly', monthlyCron, new OpportunitySummaryScheduler());
