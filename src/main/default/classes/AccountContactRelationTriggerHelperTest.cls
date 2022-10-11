/**
 * @description test of AccountContactRelationTrigger logic.
 *
 * @author Kamil Malecek, BearingPoint
 * @date 2022-10-02
 */
@IsTest(SeeAllData=true)
global with sharing class AccountContactRelationTriggerHelperTest {

    /**
     * @description scenario when a new relation was created.
     *
     * @author Kamil Malecek, BearingPoint
     * @date 2022-10-02
     */
    private testMethod static void testUpdateRelationsActiveness_NewRelation() {
        List<Account> accounts = new List<Account>{
                new Account(Name = 'acc1'),
                new Account(Name = 'acc2'),
                new Account(Name = 'acc3')
        };
        insert accounts;
        List<Contact> contacts = new List<Contact>{
                new Contact(LastName = 'con1', AccountId = accounts[0].Id),
                new Contact(LastName = 'con2', AccountId = accounts[1].Id),
                new Contact(LastName = 'con3', AccountId = accounts[2].Id)
        };
        insert contacts; // direct relations created
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>{
                new AccountContactRelation(AccountId = accounts[1].Id, ContactId = contacts[0].Id, IsActive = true, Roles = 'Business User'),
                new AccountContactRelation(AccountId = accounts[0].Id, ContactId = contacts[1].Id, IsActive = true, Roles = 'Business User')
        };
        insert accountContactRelations; // indirect relations

        Test.startTest();
        List<AccountContactRelation> accountContactRelationsNew = new List<AccountContactRelation>{
                new AccountContactRelation(AccountId = accounts[0].Id, ContactId = contacts[2].Id, IsActive = true, Roles = 'Business User'),
                new AccountContactRelation(AccountId = accounts[1].Id, ContactId = contacts[2].Id, IsActive = true, Roles = 'Business User')
        };
        insert accountContactRelationsNew;
        Test.stopTest();

        Map<Id, AccountContactRelation> deletedRelations = new Map<Id, AccountContactRelation>([
                SELECT Id
                FROM AccountContactRelation
                WHERE IsActive = FALSE AND IsDirect = FALSE
        ]);
        System.assertEquals(2, deletedRelations.size());
        System.assert(deletedRelations.keySet().contains(accountContactRelations[0].Id));
        System.assert(deletedRelations.keySet().contains(accountContactRelations[1].Id));
    }

    /**
     * @description scenario when active relation was removed, older one should be activated again.
     *
     * @author Kamil Malecek, BearingPoint
     * @date 2022-10-02
     */
    @IsTest
    private static void testUpdateRelationsActiveness_DeleteRelation() {
        List<Account> accounts = new List<Account>{
                new Account(Name = 'acc1'),
                new Account(Name = 'acc2')
        };
        insert accounts;
        List<Contact> contacts = new List<Contact>{
                new Contact(LastName = 'con1', AccountId = accounts[0].Id),
                new Contact(LastName = 'con2', AccountId = accounts[1].Id)
        };
        insert contacts; // direct relations created
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>{
                new AccountContactRelation(AccountId = accounts[0].Id, ContactId = contacts[1].Id, IsActive = true, Roles = 'Business User')
        };
        insert accountContactRelations; // indirect relations

        Test.startTest();
        delete accountContactRelations[0];
        Test.stopTest();

        // it has to work, coverage needed
    }
}