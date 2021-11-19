public with sharing class QueryBuilderController {

    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getAllObjects(){
        try {
            List<OptionWrapper> objectsByLabel = new List<OptionWrapper>();
            for(SObjectType objectType: Schema.getGlobalDescribe().values()){
                DescribeSObjectResult sObjectDescribe = objectType.getDescribe();
                if(sObjectDescribe.isAccessible() && sObjectDescribe.isQueryable()){
                    OptionWrapper objWrapper = new OptionWrapper();
                    objWrapper.label = sObjectDescribe.getLabel();
                    objWrapper.value = sObjectDescribe.getName();
                    objectsByLabel.add(objWrapper);
                }
            }
            return objectsByLabel;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getAllFields(String objApiName){
        try {
            List<OptionWrapper> fieldsByLabel = new List<OptionWrapper>();
            Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap();
            for(String fieldName: fieldMap.keySet()){
                DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                if(fieldDescribe.isAccessible()){
                    OptionWrapper fieldWrapper = new OptionWrapper();
                    fieldWrapper.label = fieldDescribe.getLabel();
                    fieldWrapper.value = fieldDescribe.getName();
                    fieldWrapper.type = String.valueOf(fieldDescribe.getType());
                    fieldsByLabel.add(fieldWrapper);
                }
            }
            return fieldsByLabel;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getAllOperators(String fieldType){
        try {
            List<OptionWrapper> operators = new List<OptionWrapper>();
            Map<String,String> inputTypeMapping = new Map<String,String>{
                'ID' => 'text',
                'STRING' => 'text',
                'ADDRESS' => 'text',
                'REFERENCE' => 'text',
                'PICKLIST' => 'picklist',
                'TEXTAREA' => 'text',
                'BOOLEAN' => 'text',
                'DATE' => 'date',
                'DATETIME' => 'datetime',
                'DOUBLE' => 'number',
                'INTEGER' => 'number'
            };
            String inputType = inputTypeMapping.get(fieldType);
            Map<String,Map<String,String>> operatorsByType = getOperatorsByType();
            for(String operator: operatorsByType.get(inputType).keySet()){
                OptionWrapper optWrapper = new OptionWrapper();
                optWrapper.label = operator;
                optWrapper.value = operatorsByType.get(inputType).get(operator);
                optWrapper.type = inputType;
                operators.add(optWrapper);
            }
            return operators;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class OptionWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public String type{get;set;}
    }

    @AuraEnabled
    public static List<OptionWrapper> getAllPicklistValues(String objectName, String fieldName){
        try {
            List<OptionWrapper> result = new List<OptionWrapper>();
            Schema.DescribeSObjectResult sObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
            Schema.DescribeFieldResult fieldResult = sObjectResult.fields.getMap().get(fieldName).getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry picklist: picklistEntries){
                OptionWrapper option = new OptionWrapper();
                option.label = picklist.getLabel();
                option.value = picklist.getValue();
                result.add(option);
            }
            return result;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Map<String,Map<String,String>> getOperatorsByType(){
        Map<String,Map<String,String>> operatorsByType = new Map<String,Map<String,String>>();
        Map<String,String> textOperators = new Map<String,String>{
            'equals' => 'equals',
            'starts with' => 'startsWith',
            'does not start with' => 'notStartWith',
            'ends with' => 'endsWith',
            'does not end with' => 'notEndWith',
            'contains' => 'contains',
            'does not contain' => 'notContain',
            'is empty' => 'isEmpty',
            'is null' => 'isNull'
        };
        operatorsByType.put('text',textOperators);
        Map<String,String> numberOperators = new Map<String,String>{
            'equals' => 'equals',
            'is greater than' => 'greaterThan',
            'is greater or equal' => 'greaterOrEqual',
            'is lower than' => 'lowerThan',
            'is lower or equal' => 'lowerOrEqual',
            'is null' => 'isNull'
        };
        Map<String,String> picklistOperators = new Map<String,String>{
            'equals' => 'equals'
        };
        operatorsByType.put('picklist',picklistOperators);
        operatorsByType.put('number',numberOperators);
        operatorsByType.put('date',numberOperators);
        operatorsByType.put('datetime',numberOperators);
        return operatorsByType;
    }
}
