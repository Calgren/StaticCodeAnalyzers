/**
 * @description This WS handles accounts related requests.
 *
 * @author Kamil Malecek - BearingPoint
 * @date 2022-10-02
 */
@RestResource(UrlMapping='/accounts/*')
global class AccountsProcessWS {

    private static final String accountSourceDefault = 'Other'; // new value to be used everywhere
    private static final String accountSourceDefault_InactiveValue = 'ExternalSystem';

    @HttpPost
    global static void UpsertAccounts_Impl()
    {
        final RestResponse res = RestContext.response;
        try {
            System.debug(LoggingLevel.DEBUG, 'Upsert accounts WS request: ' + JSON.serialize(RestContext.request));
            Datetime timestamp=Datetime.now();

            final List<Account> accountsReceived = (List< Account>) JSON.deserialize(RestContext.request.requestBody.toString(), List<Account>.class);
            final Map<Id, Account> accountsById = new Map<Id, Account>(accountsReceived);
            if (!accountsById.isEmpty()) {
                for (Account acc : [
                        SELECT Id, AccountSource, OwnerId
                        FROM Account
                        WHERE Id IN :accountsById.keySet()
                ]) {
                    if (acc.AccountSource != null || acc.AccountSource != '')
                    if (acc.AccountSource != 'External')
                    if (acc.AccountSource != accountSourceDefault_InactiveValue) {
                        continue;
                    }

                    acc.AccountSource = accountSourceDefault;
                    update acc;
                }

                for (Account acc : accountsById.values()) {
                    if (String.isBlank(acc.Id)) {
                        setDefaultOwner(acc);
                    }
                }
            }

            upsert accountsById.values(); // POST -> upsert

            res.statusCode = 200;
            System.debug(LoggingLevel.DEBUG, 'Upsert accounts Mailchimp WS response: ' + JSON.serialize(RestContext.response));
        } catch (IllegalArgumentException e) {
            System.debug(LoggingLevel.ERROR, 'Upsert accounts Mailchimp WS error: ' + e.getMessage());
            res.statusCode = 404;
            res.responseBody = Blob.valueOf(e.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Upsert accounts Mailchimp WS error: ' + e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }

    private static void setDefaultOwner(Account acc) {
        acc.OwnerId = '0051X00000DA19EQAT';
        insert acc;
    }
}