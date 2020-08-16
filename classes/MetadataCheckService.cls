public with sharing class MetadataCheckService {

    /**
     * Namespace of the managed variables to check
     */
    private String namespace = 'LLC_BI';

    /**
     * Map of Object API names to a List of Field API Names to check against
     */
    private Map<String, List<String>> objectFieldMap = new Map<String, List<String>> {
        'Account' => new List<String> {
            'LLC_BI__Last_Review_Date__c',
            'LLC_BI__Risk_Rating_Review_Date_Decisioned__c',
            'LLC_BI__Risk_Rating_Review_Grade__c',
            'LLC_BI__Risk_Rating_Review_Status__c',
            'LLC_BI__Total_Participation_Amount__c'
        },
        'Contact' => new List<String> {
            'LLC_BI__Identity_Verification_Date__c',
            'LLC_BI__Identity_Verification_Status__c'
        },
        'LLC_BI__Collateral__c' => new List<String> {
            'LLC_BI__Full_Address_NE__c',
            'LLC_BI__Full_Address_PE__c',
            'LLC_BI__Collateral_Rollup_Count__c',
            'LLC_BI__Depth__c',
            'LLC_BI__Highest__c',
            'LLC_BI__Is_Copy__c',
            'LLC_BI__Is_Leased_Asset__c',
            'LLC_BI__Total_Collateral_Rollup_Lendable_Value__c',
            'LLC_BI__Total_Collateral_Rollup_Value__c'
        },
        'LLC_BI__Lien__c' => new List<String> {
            'LLC_BI__Active__c'
        },
        'LLC_BI__Loan__c' => new List<String> {
            'LLC_BI__Allocated_Facility_Amount__c',
            'LLC_BI__Booked_Date__c',
            'LLC_BI__Product_Line__c',
            'LLC_BI__Product_Type__c',
            'LLC_BI__Product__c',
            'LLC_BI__Product_Reference__c',
            'LLC_BI__Balloon__c',
            'LLC_BI__Balloon_Product_Structure__c',
            'LLC_BI__Closed_Date__c',
            'LLC_BI__Is_Modification__c',
            'LLC_BI__Is_Original_Inactive_Loan__c',
            'LLC_BI__IsRenewal__c',
            'LLC_BI__lookupkey__c',
            'LLC_BI__OriginalParentLoan__c',
            'LLC_BI__Original_Total_Lendable_Value__c',
            'LLC_BI__Product__c',
            'LLC_BI__Product_Line__c',
            'LLC_BI__Product_Reference__c',
            'LLC_BI__Product_Type__c',
            'LLC_BI__Total_Prior_Lien_Amount__c'
        },
        'LLC_BI__Loan_Collateral2__c' => new List<String> {
            'LLC_BI__Active__c',
            'LLC_BI__Collateral_Full_Address_PE__c',
            'LLC_BI__Collateral_Value__c',
            'LLC_BI__Current_Lendable_Value__c',
            'LLC_BI__First_Lien_Position_Value__c',
            'LLC_BI__Is_Excluded__c',
            'LLC_BI__Original_Lendable_Value__c',
            'LLC_BI__Other_Lien_Position_Value__c',
            'LLC_BI__Pledged_Rollup_Count__c',
            'LLC_BI__Second_Lien_Position_Value__c',
            'LLC_BI__Third_Lien_Position_Value__c',
            'LLC_BI__Total_Pledged_Rollup_Lendable_Value__c',
            'LLC_BI__Total_Pledged_Rollup_Value__c',
            'LLC_BI__Total_Prior_Lien_Amount__c',
            'LLC_BI__Unique_Id__c'
        },
        'LLC_BI__Product_Package__c' => new List<String> {
            'LLC_BI__Loan_Facilities_Count__c',
            'LLC_BI__Reviewable_Loan_Facilities_Count__c',
            'LLC_BI__Original_LTV__c',
            'LLC_BI__Reviewable_Loan_Facilities_Count__c',
            'LLC_BI__Total_Loan_Facilities_Amount__c'
        }
    };

    /**
     * List of Metadata types to check dependencies against
     */
    private List<String> metadataTypeList = new List<String> {
        'ApexClass',
        'Flow',
        'WorkflowFieldUpdate'
    };

    /**
     * Map of 18 character Field ID to ObjectName.FieldName
     */
    private Map<String, String> fieldIdMap;

    /**
     * Map of 15 character Object ID.15 character Field ID to ObjectName.FieldName
     */
    private Map<String, String> objectFieldIdMap;

    /**
     * Show the pretty serialized JSON of callout responses
     */
    private Boolean showDebug = false;

    /**
     * Blank constructor
     */
    public MetadataCheckService() { }

    /**
     * Constructor to turn on or off debugging the callout response
     * @param  inDebug TRUE to show callout response, FALSE to hide it
     */
    public MetadataCheckService(Boolean inDebug) {
        this.showDebug = inDebug;
    }

    /**
     * Generates the mapping of Id's to Field names
     */
    public void getFieldMap() {

        this.fieldIdMap = new Map<String, String>();
        this.objectFieldIdMap = new Map<String, String>();

        // Get all of the Custom Object API names, removing the namespace and extension
        List<String> customObjectList = new List<String>();
        for (String key : objectFieldMap.keySet()) {
            if (key.contains(this.namespace + '__')) {
                customObjectList.add(key.replace(this.namespace + '__', '').replace('__c', ''));
            }
        }

        // Bulkified query to get the ID's of the Custom Objects in this org
        String objQuery = 'SELECT Id, NamespacePrefix, DeveloperName, ManageableState FROM CustomObject';
        objQuery += ' WHERE NamespacePrefix = \'' + this.namespace + '\' AND ManageableState = \'installed\'';
        objQuery += '   AND DeveloperName IN (\'' + String.join(customObjectList, '\',\'') + '\')';
        Map<String, Object> objBody = doToolingQuery(objQuery, this.showDebug);

        if (objBody == null) {
            return;
        }

        // Map of Object ID's to their API Name, with the namespace and extensions added on
        Map<String, String> objectIdMap = new Map<String, String>();
        List<Object> objRecordList = (List<Object>)objBody.get('records');
        for (Object o : objRecordList) {
            Map<String, Object> r = (Map<String, Object>)o;
            objectIdMap.put(this.namespace + '__' + (String)r.get('DeveloperName') + '__c', (String)r.get('Id'));
        }

        // Loop through each object, standard and custom, and get the ID's of the fields we're looking for
        for (String key : objectFieldMap.keySet()) {
            String tableEnumOrId = '';
            if (key.contains(this.namespace + '__')) {
                tableEnumOrId = objectIdMap.get(key);
            } else {
                tableEnumOrId = key;
            }

            // Callouts in for loops are generally bad, but we're not bulkifying this query for the PoC
            // You would bulkify this by also having an IN on TableEnumOrId, and then retrieving the TableEnumOrId in the SELECT
            // Then, as you're looping through, you'll need to match up the fields with their object to make sure you're
            // getting the right field. Example: Is_Active__c may exist on Loan__c and Lien__c, but we only care about it on Loan
            // So we'd want to discard the Lien field and not process it
            String fieldList = String.join(objectFieldMap.get(key), '\',\'').replace(this.namespace + '__', '').replace('__c', '');
            String fieldQuery = 'SELECT Id, DeveloperName FROM CustomField WHERE TableEnumOrId = \'' + tableEnumOrId + '\' AND NamespacePrefix = \'' + this.namespace + '\' AND DeveloperName IN (\'' + fieldList + '\')';
            Map<String, Object> fieldBody = doToolingQuery(fieldQuery, this.showDebug);
            List<Object> records = (List<Object>)fieldBody.get('records');
            for (Object o : records) {
                Map<String, Object> r = (Map<String, Object>)o;
                String objectId = tableEnumOrId.left(15);
                String fieldId = ((String)r.get('Id')).left(15);

                // MetadataComponentDependency uses 18-character ID's
                this.fieldIdMap.put((String)r.get('Id'), key + '.' + this.namespace + '__' + (String)r.get('DeveloperName') + '__c');
                // WorkflowFieldUpdate uses 15-character ID's
                this.objectFieldIdMap.put(objectId + '.' + fieldId, key + '.' + this.namespace + '__' + (String)r.get('DeveloperName') + '__c');
            }
        }

    }

    /**
     * Utilize the MetadataComponentDependency Tooling API to check if fields are referenced
     * @return   A Set of Strings, one for each unique reference
     */
    public Set<String> checkDependency() {

        if (this.fieldIdMap == null) {
            this.getFieldMap();
        }

        Set<String> foundSet = new Set<String>();

        String query = 'SELECT MetadataComponentId, MetadataComponentName, MetadataComponentType,';
        query += ' RefMetadataComponentId, RefMetadataComponentName';
        query += ' FROM MetadataComponentDependency';
        query += ' WHERE RefMetadataComponentType = \'CustomField\' AND RefMetadataComponentNamespace = \'' + this.namespace + '\'';
        query += '   AND RefMetadataComponentId IN (\'' + String.join((Iterable<String>)this.fieldIdMap.keySet(), '\',\'') + '\')';
        query += '   AND MetadataComponentNamespace = \'\'';
        query += '   AND (';

        Boolean addOr = false;
        for (String md : this.metadataTypeList) {
            if (addOr) {
                query += ' OR ';
            }
            query += 'MetadataComponentType = \'' + md + '\'';
            addOr = true;
        }
        query += ')';

        Map<String, Object> body = doToolingQuery(query, this.showDebug);

        if (body != null) {
            List<Object> records = (List<Object>)body.get('records');
            for (Object o : records) {
                Map<String, Object> r = (Map<String, Object>)o;
                String refComponentId = (String)r.get('RefMetadataComponentId');
                if (this.fieldIdMap.keySet().contains(refComponentId)) {
                    String fieldName = this.fieldIdMap.get(refComponentId);
                    foundSet.add(fieldName + ' REFERENCED in ' + (String)r.get('MetadataComponentType') + ' ' + (String)r.get('MetadataComponentName'));
                }
            }
        }

        return foundSet;

    }

    /**
     * Utilize the WorkflowFieldUpdate Tooling API to check if fields are updated
     * @return   A Set of Strings, one for each unique reference
     */
    public Set<String> checkWorkflowFieldUpdates() {

        if (this.objectFieldIdMap == null) {
            this.getFieldMap();
        }

        Set<String> foundSet = new Set<String>();

        String query = 'SELECT Id, NamespacePrefix, Name, FieldDefinitionId FROM WorkflowFieldUpdate';
        query += ' WHERE FieldDefinitionId IN (\'' + String.join((Iterable<String>)this.objectFieldIdMap.keySet(), '\',\'') + '\')';

        Map<String, Object> body = doToolingQuery(query, this.showDebug);

        if (body != null) {
            List<Object> records = (List<Object>)body.get('records');
            for (Object o : records) {
                Map<String, Object> r = (Map<String, Object>)o;
                String fieldDefinitionId = (String)r.get('FieldDefinitionId');
                if (this.objectFieldIdMap.keySet().contains(fieldDefinitionId)) {
                    String fieldName = this.objectFieldIdMap.get(fieldDefinitionId);
                    foundSet.add(fieldName + ' UPDATED in WorkflowFieldUpdate ' + (String)r.get('Name'));
                }
            }
        }

        return foundSet;

    }

    /**
     * Launches a Queueable to check for field metadata existing
     */
    public void checkFieldMetadata() {

        // Get all of the custom fields that are not namespaced (local to this org)
        String fieldQuery = 'SELECT Id, DeveloperName, TableEnumOrId FROM CustomField WHERE NamespacePrefix = \'\'';
        Map<String, Object> fieldBody = doToolingQuery(fieldQuery, this.showDebug);

        if (fieldBody == null) {
            return;
        }

        Set<String> objectIds = new Set<String>();
        Set<String> fieldIds = new Set<String>();

        List<Object> fieldRecords = (List<Object>)fieldBody.get('records');
        for (Object o : fieldRecords) {
            Map<String, Object> r = (Map<String, Object>)o;
            String tableEnumOrId = (String)r.get('TableEnumOrId');
            if (tableEnumOrId.startsWith('01I')) {
                objectIds.add(tableEnumOrId);
            }
            fieldIds.add((String)r.get('Id'));
        }

        // Get the name of their accompanying custom objects
        String objectQuery = 'SELECT Id, NamespacePrefix, DeveloperName FROM CustomObject WHERE Id IN (\'' + String.join((Iterable<String>)objectIds, '\',\'') + '\')';
        Map<String, Object> objectBody = doToolingQuery(objectQuery, this.showDebug);

        if (objectBody == null) {
            return;
        }

        Map<String, String> objectIdMap = new Map<String, String>();

        List<Object> objectRecords = (List<Object>)objectBody.get('records');
        for (object o : objectRecords) {
            Map<String, Object> r = (Map<String, Object>)o;
            String namespace = (String)r.get('NamespacePrefix');
            if ((namespace != null) && (!String.isEmpty(namespace))) {
                namespace += '__';
            } else {
                namespace = '';
            }
            objectIdMap.put((String)r.get('Id'), namespace + (String)r.get('DeveloperName') + '__c');
        }

        MetadataCheckQueueable mcq = new MetadataCheckQueueable(objectIdMap, fieldIds);
        System.enqueueJob(mcq);

    }

    /**
     * Do a Tooling API query with the current Session ID
     * @param  query     SOQL Query
     * @param  showDebug TRUE if we want to show the response to the debug log
     * @return           Deserialized JSON of the output
     */
    public static Map<String, Object> doToolingQuery(String query, Boolean showDebug) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v48.0/tooling/query/?q=' + query.replace(' ', '+'));
        HttpResponse resp = http.send(req);

        Map<String, Object> body;
        try {
            body = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
            if (showDebug) {
                System.debug(JSON.serializePretty(body));
            }
        } catch (Exception e) {
            System.debug('Could not parse: ' + resp.getBody());
        }
        
        return body;

    }

    public static map<String, Object> doToolingQuery(String query) {
        return doToolingQuery(query, false);
    }

}