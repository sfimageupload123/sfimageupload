public class MassFileDownloadController {
    
    @AuraEnabled
    public static List<Id> getContentDocumentIdsApex(String dateSelected){
        
        system.debug(dateSelected);
        Date dateSelectedObj = Date.valueOf(dateSelected);
        set<Id> ContentDocumentIdSet = new Set<Id>();
        List<Id> ContentDocumentIdSetFiltered = new List<Id>();
      /*  for(contentdocument cd :[ SELECT Id,ParentId FROM ContentDocument WHERE DAY_ONLY(CreatedDate) =:dateSelectedObj AND ContentSize > 100  ] ){
            ContentDocumentIdSet.add(cd.Id);
        }
        
        system.debug(ContentDocumentIdSet);
        if( null != ContentDocumentIdSet && ContentDocumentIdSet.size() >  0 )
        {*/
            for(ContentdocumentLink cdlObj : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink 
                                              WHERE LinkedEntityId 
                                              IN (SELECT Id FROM Account)
                                              AND DAY_ONLY(ContentDocument.CreatedDate) =:dateSelectedObj AND ContentDocument.ContentSize > 100]){
                ContentDocumentIdSetFiltered.add(cdlObj.ContentDocumentId);
            }
     //   }
        system.debug('ContentDocumentIdSetFiltered'+ ContentDocumentIdSetFiltered);
        return ( (null != ContentDocumentIdSetFiltered && ContentDocumentIdSetFiltered.size() >  0 ) ? ContentDocumentIdSetFiltered : null);
    }
}