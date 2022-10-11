/**
 * Created by tomas.chour on 10.10.2022.
 */

public with sharing class MultipleContactsCreateController {

    @AuraEnabled
    public static void saveContact(Contact con) {
        try {
            insert con;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Saving Contact error: ' + e.getMessage());
        }
    }
}