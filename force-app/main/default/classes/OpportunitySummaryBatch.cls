global class OpportunitySummaryBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date startDate = System.today().toStartOfMonth();
        Date endDate = startDate.addMonths(1).toStartOfMonth().addDays(-1);
        
        return Database.getQueryLocator([
            SELECT AccountId, Account.Name, StageName, Amount
            FROM Opportunity
            WHERE CloseDate >= :startDate AND CloseDate <= :endDate
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        Map<Id, AccountSummary> accountSummaries = new Map<Id, AccountSummary>();
        
        for (Opportunity opp : scope) {
            if (!accountSummaries.containsKey(opp.AccountId)) {
                accountSummaries.put(opp.AccountId, new AccountSummary(opp.AccountId, opp.Account.Name));
            }
            
            AccountSummary summary = accountSummaries.get(opp.AccountId);
            summary.updateSummary(opp.StageName, opp.Amount);
        }
        
        // Send email with summary to each account's primary contact
        for (AccountSummary summary : accountSummaries.values()) {
            summary.sendEmail();
        }
    }
    
    global void finish(Database.BatchableContext bc) {}
    
    // Inner class to hold account summary details
    private class AccountSummary {
        Id accountId;
        String accountName;
        Decimal closedWonAmount;
        Decimal openAmount;
        Decimal closedLostAmount;
        
        AccountSummary(Id accountId, String accountName) {
            this.accountId = accountId;
            this.accountName = accountName;
            this.closedWonAmount = 0;
            this.openAmount = 0;
            this.closedLostAmount = 0;
        }
        
        void updateSummary(String stage, Decimal amount) {
            if (stage == 'Closed Won') {
                closedWonAmount += amount;
            } else if (stage == 'Closed Lost') {
                closedLostAmount += amount;
            } else {
                openAmount += amount;
            }
        }
        
        void sendEmail() {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{/* primary contact email */};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Summary for ' + accountName);
            mail.setPlainTextBody('Closed Won Amount: ' + closedWonAmount + '\n' +
                                  'Open Amount: ' + openAmount + '\n' +
                                  'Closed Lost Amount: ' + closedLostAmount);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }
}
