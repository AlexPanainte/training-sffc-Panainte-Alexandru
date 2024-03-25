trigger UpdatePrimaryContactPhone on Contact (after insert, after update) {
    // List to store Account Ids that need to be updated
    Set<Id> accountIdsToUpdate = new Set<Id>();
    
    // Map to store Primary Contact Phone for each Account
    Map<Id, String> accountPrimaryContactPhones = new Map<Id, String>();
    
    // Loop through all the contacts being inserted or updated
    for(Contact con : Trigger.new) {
        // Check if the contact has been marked as primary
        if(con.IsPrimary__c && con.AccountId != null) {
            // Add Account Id to the set for updating later
            accountIdsToUpdate.add(con.AccountId);
            
            // Update the map with Primary Contact Phone for this Account
            accountPrimaryContactPhones.put(con.AccountId, con.Phone);
        }
    }
    
    // List to store Contacts to be updated asynchronously
    List<Contact> contactsToUpdateAsync = new List<Contact>();
    
    // Loop through the contacts related to the accounts that need to be updated
    for(Contact con : [SELECT Id, AccountId, Phone FROM Contact WHERE AccountId IN :accountIdsToUpdate]) {
        // Update the Phone field only if it's different from the Primary Contact Phone
        if(accountPrimaryContactPhones.containsKey(con.AccountId) && 
           con.Phone != accountPrimaryContactPhones.get(con.AccountId)) {
            con.Phone = accountPrimaryContactPhones.get(con.AccountId);
            contactsToUpdateAsync.add(con);
        }
    }
    
    // Update contacts asynchronously
    if(!contactsToUpdateAsync.isEmpty()) {
        Database.SaveResult[] results = Database.update(contactsToUpdateAsync, false);
        
        // Handle any errors
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                // Handle failure, log or notify the appropriate stakeholders
            }
        }
    }
}
