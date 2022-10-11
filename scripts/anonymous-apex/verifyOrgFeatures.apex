final Boolean isContactsToMultipleAccounts = Schema.getGlobalDescribe().containsKey('AccountContactRelation');
System.debug(isContactsToMultipleAccounts);
System.assert(isContactsToMultipleAccounts, 'Org features are not enabled properly.');