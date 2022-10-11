/**
 * @description AccountContactRelation trigger.
 *
 * @author Kamil Malecek, BearingPoint
 * @date 2022-10-02
 */
trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after update, after delete) {

    try {
        switch on Trigger.operationType {
            when AFTER_INSERT {
                updateRelationsActiveness(Trigger.newMap);
            }
            when AFTER_UPDATE {
                updateRelationsActiveness(Trigger.newMap);
            }
            when AFTER_DELETE {
                updateRelationsActiveness(Trigger.newMap);
            }
        }
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'AccountContactRelationTrigger error: ' + e.getMessage());
    }

    /**
     * @description apart from direct relations, we do not want to have more than 1 active indirect relation per role per account,
     * therefore, we deactivate old ones. For workshop purpose we consider Roles as a picklist, not multipicklist.
     *
     * @param newMap from trigger context
     *
     * @author Kamil Malecek, BearingPoint
     * @date 2022-10-02
     */
    private static void updateRelationsActiveness(Map<Id, AccountContactRelation> newMap) {
        final Map<Id, Set<String>> accountIdToActiveRoles = new Map<Id, Set<String>>();
        for (AccountContactRelation relation : newMap.values()) {
            if (!relation.IsDirect && relation.IsActive) {
                if (!accountIdToActiveRoles.containsKey(relation.AccountId)) {
                    accountIdToActiveRoles.put(relation.AccountId, new Set<String>());
                }
                accountIdToActiveRoles.get(relation.AccountId).add(relation.Roles);
            }
        }

        final List<AccountContactRelation> relationsToUpdate = new List<AccountContactRelation>();
        for (AccountContactRelation relation : [ // candidates to be deactivated
                SELECT Id, AccountId, Roles, IsActive
                FROM AccountContactRelation
                WHERE Id NOT IN :newMap.keySet() AND AccountId IN :accountIdToActiveRoles.keySet() AND IsDirect = FALSE AND IsActive = TRUE
        ]) {
            if (accountIdToActiveRoles.containsKey(relation.AccountId)) {
                if (accountIdToActiveRoles.get(relation.AccountId).contains(relation.Roles)) {
                    relation.IsActive = false; // deactivate old ones
                    relationsToUpdate.add(relation);
                }
            }
        }

        update relationsToUpdate;
    }
}