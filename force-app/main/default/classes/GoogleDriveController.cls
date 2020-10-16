public class GoogleDriveController  

 {  

   //Fetched from URL  

   public String accessToken;  
   public String refreshToken;  
   private String code ;  
   private string key ;  
   private string secret ;  
   private string redirect_uri ;  
   GoogleDrive__c googleCusSetting = new GoogleDrive__c();  
   public void SaveToken()  

   {  

     code = ApexPages.currentPage().getParameters().get('code') ;  
     //Get the access token once we have code  
     if(code != '' && code != null)  
     { system.debug('Get the access token once we have code');  
      getToken();  
     }  

   }  

   public PageReference init()  

   { //Authenticating  

     googleCusSetting = [Select id,Client_Id__c,Client_secret__c,Refresh_Token__c,Access_token__c,GoogleAccountDomain__c,Redirect_Url__c from GoogleDrive__c limit 1];  
     key = googleCusSetting.Client_Id__c;  
     secret = googleCusSetting.Client_secret__c;  
     redirect_uri = googleCusSetting.Redirect_Url__c;  
     code = ApexPages.currentPage().getParameters().get('code') ;  
     //Get the access token once we have code  
     PageReference pg;  

     if(code == '' || code == null){  

       pg = new PageReference(GoogleDriveAuthUri (key , redirect_uri)) ;  

     }  

     return pg ;  

   }  

   public String GoogleDriveAuthUri(String Clientkey,String redirect_uri)  

   {  

     String key = EncodingUtil.urlEncode(Clientkey,'UTF-8');  

     String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');  

     String authuri = '';  

     authuri = 'https://accounts.google.com/o/oauth2/auth?'+  

       'client_id='+key+  

       '&response_type=code'+  

       '&scope=https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.appdata https://www.googleapis.com/auth/drive.file'+  

       '&redirect_uri='+uri+  

       '&state=security_token%3D138r5719ru3e1%26url%3Dhttps://oa2cb.example.com/myHome&'+  

       '&login_hint=jsmith@example.com&'+  

       'access_type=offline';  

     return authuri;  

   }  

   public void getToken()  

   {  

     //Getting access token from google  

     HttpRequest req = new HttpRequest();  

     req.setMethod('POST');  

     req.setEndpoint('https://accounts.google.com/o/oauth2/token');  

     req.setHeader('content-type', 'application/x-www-form-urlencoded');  

     String messageBody = 'code='+code+'&client_id='+key+'&client_secret='+secret+'&redirect_uri='+redirect_uri+'&grant_type=authorization_code';  

     req.setHeader('Content-length', String.valueOf(messageBody.length()));  

     req.setBody(messageBody);  

     req.setTimeout(60*1000);  

     Http h = new Http();  

     String resp;  

     HttpResponse res = h.send(req);  

     resp = res.getBody();  

     if(res.getBody() != null && res.getStatusCode()==200){  

       //You can parse the response to get the Access token and Refresh token  

       Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());  

       //Access Token   

       if(results.get('access_token') != null){  

         accessToken=string.valueOf(results.get('access_token'));   

         googleCusSetting.Access_token__c = accessToken;  

       }  
           //Refresh Token  

       if(results.get('refresh_token') != null){  

         refreshToken=string.valueOf(results.get('refresh_token'));  

         googleCusSetting.Refresh_Token__c = refreshToken;   

       }  

       update googleCusSetting;  

     }  

   }  

 }