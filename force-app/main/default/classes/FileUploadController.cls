public class FileUploadController {  
    
    @AuraEnabled  
    public static void getClient(string accId){  
        
        String condDocId;  
        final Integer STATUS_CODE_SUCCESS= 200;
        
        Account acc =[Select id,Name,Client_Collateral_Folder_Id__c from Account where id =: accId limit 1];  
        
        List<ContentDocumentLink> conlink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: accId];  
        
        for(ContentDocumentLink conids : conlink){  
            condDocId = conids.ContentDocumentId;  
            
        }  
        
        ContentDocument contDoc = [Select Id ,Title,FileType  from ContentDocument Where Id =: condDocId];  
        
        ContentVersion conver = [SELECT VersionData,FileType FROM ContentVersion WHERE ContentDocumentId = :contDoc.Id];  
        
        GoogleDrive__c googleCusSetting = new GoogleDrive__c();  
        
        //Using SOQL as Custom setting is heirarchical type. {Does not support getallValues Function}
        googleCusSetting = [Select id,Client_Id__c,Client_secret__c,Refresh_Token__c,OAuthEndPoint__c,FileUploadEndPoint__c from GoogleDrive__c limit 1];  
        
        
        String accessToken;  
        Http h = new Http();  
        HttpRequest req = new HttpRequest();  
        string endPointValue = googleCusSetting.OAuthEndPoint__c;   
        req.setEndpoint(endPointValue);  
        string bodyRequest = 'client_id='+googleCusSetting.Client_Id__c+'&client_secret='+googleCusSetting.Client_secret__c+'&refresh_token='+googleCusSetting.Refresh_Token__c+'&grant_type=refresh_token';  
        
        
        system.debug('===bodyRequest==='+bodyRequest);  
        req.setBody(bodyRequest);       
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));   
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');  
        req.setMethod('POST');  
        req.setTimeout(10000);  
        HttpResponse res = h.send(req);    
        System.debug('Response Value:'+res.getBody());  
        if(res.getBody() != null && res.getStatusCode()== STATUS_CODE_SUCCESS){  
            
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());  
            System.debug(' ====You can parse the response to get the access token ==== ' + results);  
            accessToken=string.valueOf(results.get('access_token'));  
            system.debug('====accessToken==='+accessToken);  
        }  
        
        //this code is to upload image   
        if(conver.FileType == 'JPG' || conver.FileType == 'JPEG' || conver.FileType == 'PNG'){  
            
            String boundary = '----------9889464542212';  
            String delimiter = '\r\n--' + boundary + '\r\n';  
            String close_delim = '\r\n--' + boundary + '--';  
            system.debug('===================conver.VersionData======================='+conver.VersionData);  
            //Commented BY PRITESH TO TEST 8MB LIMIT
            //String bodyEncoded = EncodingUtil.base64Encode( conver.VersionData);  
            system.debug((EncodingUtil.base64Encode( conver.VersionData)));
            String body = delimiter + 
                'Content-Type: application/json\r\n\r\n' + '{ "name" : "' + acc.Name+'_' + system.now() + '",' + '"title" : "' + contDoc.Title + '",' + ' "mimeType" : "image/' + conver.FileType + '","parents" :[{"id":"'+'1m0Ah3aOAHNCdzfIToJQwBz60f_doeXcp'+'"}]}' + 
                delimiter + 'Content-Type: image/' + conver.FileType + '\r\n' + 
                'Content-Transfer-Encoding: base64\r\n' + '\r\n' + EncodingUtil.base64Encode( conver.VersionData)  + 
                close_delim;  
            system.debug('==================body======================'+body);  
            Http http2 = new Http();  
            HttpRequest req2 = new HttpRequest();  
            req2.setEndpoint(googleCusSetting.FileUploadEndPoint__c);  
            req2.setHeader('Authorization', 'Bearer ' + accessToken);  
            req2.setHeader('Content-Type', 'multipart/mixed; boundary="' + boundary + '"');  
            req2.setHeader('Content-length', String.valueOf(body.length()));  
            req2.setBody( body);  
            req2.setMethod('POST');  
            req2.setTimeout(60 * 1000);  
            HttpResponse resp2 = http2.send(req2);  
            system.debug('==============response================'+resp2);  
            
        }  
    }  
    
    public static String getAccessToken(){
        
        String condDocId;  
        final Integer STATUS_CODE_SUCCESS= 200;  
        GoogleDrive__c googleCusSetting = new GoogleDrive__c();  
        
        //Using SOQL as Custom setting is heirarchical type. {Does not support getallValues Function}
        googleCusSetting = [Select id,Client_Id__c,Client_secret__c,Refresh_Token__c,OAuthEndPoint__c,FileUploadEndPoint__c from GoogleDrive__c limit 1];  
        
        
        String accessToken;  
        Http h = new Http();  
        HttpRequest req = new HttpRequest();  
        string endPointValue = googleCusSetting.OAuthEndPoint__c;   
        req.setEndpoint(endPointValue);  
        string bodyRequest = 'client_id='+googleCusSetting.Client_Id__c+'&client_secret='+googleCusSetting.Client_secret__c+'&refresh_token='+googleCusSetting.Refresh_Token__c+'&grant_type=refresh_token';  
        
        
        system.debug('===bodyRequest==='+bodyRequest);  
        req.setBody(bodyRequest);       
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));   
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');  
        req.setMethod('POST');  
        req.setTimeout(10000);  
        HttpResponse res = h.send(req);    
        System.debug('Response Value:'+res.getBody());  
        if(res.getBody() != null && res.getStatusCode()== STATUS_CODE_SUCCESS){  
            
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());  
            System.debug(' ====You can parse the response to get the access token ==== ' + results);  
            accessToken=string.valueOf(results.get('access_token'));  
            system.debug('====accessToken==='+accessToken);  
        }else{
            accessToken ='';
        }  
        return accesstoken;
    }
    
    public static  Map<ContentVersion,String> getAccountContentVersionMap(Map< Id, Account> accMap){
        
        Map<Id,String> contentDocLinkAccoutNameMap = new Map<Id,String>();    
        Map<Id,String> contentDocAccoutNameMap = new Map<Id,String>();   
        Map<ContentVersion,String> ContentVersionAccoutNameMap = new Map<ContentVersion,String> (); 
        
        for(ContentDocumentLink conid : [SELECT Id,LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:accMap.keyset()]){  
            contentDocLinkAccoutNameMap.put(conid.ContentDocumentId,accMap.get(conid.LinkedEntityId).Name);
            
        }  
        
        if( null != contentDocLinkAccoutNameMap && contentDocLinkAccoutNameMap.size() > 0 )
            for(ContentDocument contDoc :[Select Id ,Title,FileType  from ContentDocument Where Id IN :contentDocLinkAccoutNameMap.keyset()]){
                contentDocAccoutNameMap.put(contDoc.Id,contentDocLinkAccoutNameMap.get(contDoc.Id) );
            }      
        
        
        if( null != contentDocAccoutNameMap && contentDocAccoutNameMap.size() > 0 )
            for(ContentVersion conver : [SELECT ContentDocumentId,VersionData,FileType FROM ContentVersion WHERE ContentDocumentId IN :contentDocAccoutNameMap.keyset()]){
                ContentVersionAccoutNameMap.put(conver,contentDocAccoutNameMap.get(conver.ContentDocumentId));
            }  
        
        return (null != ContentVersionAccoutNameMap && ContentVersionAccoutNameMap.size() > 0 ? ContentVersionAccoutNameMap: null);
    }
    
    public static Integer uploadToGoogleDrive(Map<ContentVersion,String> ContentVersionAccoutNameMap, String accessToken){
        
        GoogleDrive__c googleCusSetting = new GoogleDrive__c();  
        Integer StatusCode = 0;
        //Using SOQL as Custom setting is heirarchical type. {Does not support getallValues Function}
        googleCusSetting = [Select id,Client_Id__c,Client_secret__c,Refresh_Token__c,OAuthEndPoint__c,FileUploadEndPoint__c from GoogleDrive__c limit 1];  
        
        system.debug(ContentVersionAccoutNameMap);
        for(ContentVersion cnObj: ContentVersionAccoutNameMap.keyset()){  // Cannot club multiple content document files in one HTTP call as drive not accepting multipart body
            if(cnObj.FileType == 'JPG' || cnObj.FileType == 'JPEG' || cnObj.FileType == 'PNG'){  
                
                String boundary = '----------9889464542212';  
                String delimiter = '\r\n--' + boundary + '\r\n';  
                String close_delim = '\r\n--' + boundary + '--';  
                system.debug('===================conver.VersionData======================='+cnObj.VersionData);  
                String bodyEncoded = EncodingUtil.base64Encode( cnObj.VersionData);  
                String body = delimiter + 
                    'Content-Type: application/json\r\n\r\n' + '{ "name" : "' + ContentVersionAccoutNameMap.get(cnObj) +'_' + system.now() + '",' + '"title" : "' + ContentVersionAccoutNameMap.get(cnObj) + '",' + ' "mimeType" : "image/' + cnObj.FileType + '","parents" :[{"id":"'+'1m0Ah3aOAHNCdzfIToJQwBz60f_doeXcp'+'"}]}' + 
                    delimiter + 'Content-Type: image/' + cnObj.FileType + '\r\n' + 
                    'Content-Transfer-Encoding: base64\r\n' + '\r\n' + bodyEncoded + 
                    close_delim;  
                system.debug('==================body======================'+body);  
                Http http2 = new Http();  
                HttpRequest req2 = new HttpRequest();  
                req2.setEndpoint(googleCusSetting.FileUploadEndPoint__c);  
                req2.setHeader('Authorization', 'Bearer ' + accessToken);  
                req2.setHeader('Content-Type', 'multipart/mixed; boundary="' + boundary + '"');  
                req2.setHeader('Content-length', String.valueOf(body.length()));  
                req2.setBody( body);  
                req2.setMethod('POST');  
                req2.setTimeout(60 * 1000); 
                try{
                    HttpResponse resp2 = http2.send(req2);  
                    system.debug('==============response================'+resp2.getStatusCode());  
                    StatusCode  = resp2.getStatusCode();
                }catch(Exception e){
                    system.debug(e.getMessage());
                }
            }
        }
        return StatusCode;
    }
}