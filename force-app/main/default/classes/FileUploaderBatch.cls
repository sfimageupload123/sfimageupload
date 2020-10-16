/*------------------------------------------------------------------------
Author: 
Company: 
Test Class: 
Class: FileUploaderBatch
History:
<Date>         <Authors Name>        <Brief Description of Change>

---------------------------------------------------------------------------*/
public with sharing class FileUploaderBatch implements Database.batchable<sObject>,Database.AllowsCallouts{ 
    
    public static final String queryString ='Select ID,NAME,Client_Collateral_Folder_Id__c FROM ACCOUNT';//SOQL QUery for Accounts
    public static String accessToken = fileUploadController.getAccessToken(); // get Access Token For call.
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext info, List<Account> scope){
        Map<Id,Account> accMap= new Map<id, Account>();
        Integer StatusCode =0;
        
        Map<ContentVersion,String> ContentVersionAccoutNameMap = new Map<ContentVersion,String>();
        for(Account acc: scope){
            accMap.put(acc.Id, acc); //Create Account Id Map
        }
        
        if(null != accMap && accMap.size() > 0){
            ContentVersionAccoutNameMap = FileUploadController.getAccountContentVersionMap(accMap); // Create a map of Contnetversion with account Name. Needed for file Naming convention
        }
        
        system.debug('api :::' + (limits.getLimitCallouts() - limits.getCallouts()));
        if(  null != ContentVersionAccoutNameMap && ContentVersionAccoutNameMap.size() > 0 && (limits.getLimitCallouts() - limits.getCallouts()  > 0 ))
        	StatusCode = fileUploadController.uploadToGoogleDrive(ContentVersionAccoutNameMap,accessToken); // Callout to pass base 64 encoded data to Google Drive
        
        
        //Call for fetch New access token if access token expires
        while( StatusCode != 200 &&  (limits.getLimitCallouts() - limits.getCallouts()  > 0 && (null != ContentVersionAccoutNameMap && ContentVersionAccoutNameMap.size() > 0))){
            try{
                accessToken = fileUploadController.getAccessToken();
                StatusCode = fileUploadController.uploadToGoogleDrive(ContentVersionAccoutNameMap,accessToken);
            }catch(Exception e){
                system.debug('error' + e.getMessage());
                
            }
        }           
    }
    
    public void finish(Database.BatchableContext info){  
        //NO IMPLEMENTATION CURRENTLY
    } 
    
}