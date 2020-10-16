public class CaseHelper {
    //Comment 2323232323cc
    @InvocableMethod
    public static void caseTATCalculator(List<Id> caseIdList){
        
        final String INBOUND_ARG ='Inbound';
        final String OUTBOUND_ARG ='Outbound';
        final Integer INDEX_ONE = 1;
        final Integer INDEX_ZERO = 0;
        
        Map<Id, Case_Email_History__c> updateTATCalculatedFlagInboundMap = new Map<Id,Case_Email_History__c>();
        List<Case_Email_History__c> updateTATCalculationOutboundList = new List<Case_Email_History__c>();
        List<Case> caseMedianList = new List<Case>();
        
        
        
        if( NULL != caseIdList && caseIdList.size() > 0 ){
            for( Case caseObj : [SELECT Id, ( SELECT Id,Time_Stamp__c,TAT_Calculated__c, Communication_Type__c, TAT__c FROM Case_Email_Histories__r WHERE TAT_Calculated__c =FALSE ORDER BY CreatedDate ASC ) FROM CASE WHERE ID IN:caseIdList] ){                
                dateTime inboundDateTimeObj = NULL;
                set<Id> inboundIdSet = new Set<id>(); //
                List<dateTime> inboundDateTimeList = new List<dateTime>();//
                Boolean calculatetat;
                Id inboundId;
                Integer inboundCount = 0;//
                
                for( Case_Email_History__c caseEmailHistoryObj : caseObj.Case_Email_Histories__r ){
                    
                    if( caseEmailHistoryObj.Communication_Type__c == INBOUND_ARG ){
                        inboundDateTimeObj = caseEmailHistoryObj.Time_Stamp__c;
                        calculatetat = TRUE;
                        inboundId = caseEmailHistoryObj.Id; 
                        inboundIdSet.add(inboundId);//
                        inboundDateTimeList.add( inboundDateTimeObj );//
                        inboundCount+=1;//
                    }
                    
                        if( caseEmailHistoryObj.Communication_Type__c == OUTBOUND_ARG ){                        
                            if( inboundCount > 1 && inboundDateTimeList.size() > 0 && inboundIdSet.size() > 0 ){    //             
                                inboundDateTimeObj = inboundDateTimeList[INDEX_ZERO];//
                                for( Id key :  inboundIdSet ){//
                                    updateTATCalculatedFlagInboundMap.put( key, (new Case_Email_History__c(Id = key , TAT_Calculated__c = TRUE)));//
                                }    //
                            }//
                            
                            if( NULL != inboundDateTimeObj && caseEmailHistoryObj.Time_Stamp__c != NULL && calculatetat ){
                                decimal tatval = (caseEmailHistoryObj.Time_Stamp__c.getTime() - inboundDateTimeObj.getTime())/(1000*60) ;
                                updateTATCalculationOutboundList.add( new Case_Email_History__c(Id = caseEmailHistoryObj.Id, TAT__c = tatval ));
                                updateTATCalculatedFlagInboundMap.put( inboundId, new Case_Email_History__c(Id = inboundId, TAT_Calculated__c = TRUE));//
                                inboundId = NULL;
                                calculatetat = FALSE;
                                inboundDateTimeObj = NULL;
                                
                            }
                        }
                }
                
            }
            if( NULL != updateTATCalculationOutboundList && updateTATCalculationOutboundList.size() > 0 ){
                try{
                    update updateTATCalculationOutboundList;
                }catch(Exception error){
                    throw (error);
                }
            }
            
            if( NULL != updateTATCalculatedFlagInboundMap && updateTATCalculatedFlagInboundMap.size() > 0 ){//
                try{
                    update updateTATCalculatedFlagInboundMap.values();//
                }catch(Exception error){
                    throw (error);
                }
            }
            
            for( Case caseObj : [SELECT Id, ( SELECT Id,Time_Stamp__c,TAT_Calculated__c, Communication_Type__c, TAT__c FROM Case_Email_Histories__r WHERE TAT__c != null AND Communication_Type__c= :OUTBOUND_ARG  ORDER BY TAT__c ASC ) FROM CASE WHERE ID IN:caseIdList]){
                
                if( NULL != caseObj.Case_Email_Histories__r && caseObj.Case_Email_Histories__r.size() > 0 ){
                    
                    List<Decimal> tatvalues = new List<Decimal>();
                    
                    for( Case_Email_History__c caseEmailHistoryObj : caseObj.Case_Email_Histories__r ){
                        tatvalues.add(caseEmailHistoryObj.TAT__c);
                    }
                    
                    if( NULL != tatvalues && tatvalues.size() > 0 ){
                        
                        Integer sizeOfList = tatvalues.size();
                        Integer index = sizeOfList - 1;
                        Decimal median = 0.0;
                        
                        if (Math.mod(sizeOfList, 2) == 0) {
                            median = (tatvalues[(index-1)/2] + tatvalues[(index/2)+1])/2;
                        }else{
                            median = tatvalues[(index+1)/2];
                        }
                        
                        caseMedianList.add( new Case(Id = caseObj.Id, TAT_Median__c = median));
                    }
                    
                }
            }   
            
            if( NULL != caseMedianList && caseMedianList.size() > 0 ){
                try{
                    update caseMedianList;
                }catch(Exception error){
                    throw (error);
                }
            }
        }
    }
}
