@isTest
public class CaseHelperTest {
    
    static testMethod void TaTcalculatorTest() {
        
        Test.startTest();
        Case caseObj = new Case(Priority='High');
        insert caseObj;
        
        //Incoming
        EmailMessage emIncoming = new emailmessage(ParentId=caseObj.Id, relatedToId=caseObj.Id,incoming=true, messagedate=system.now());
        insert emIncoming;
        
        
        //outbound
        EmailMessage emOutgoing = new emailmessage(ParentId=caseObj.Id, relatedToId=caseObj.Id,incoming=false, messagedate=system.now() + 1);
        insert emOutgoing;
        
         EmailMessage emIncoming2 = new emailmessage(ParentId=caseObj.Id, relatedToId=caseObj.Id,incoming=true, messagedate=system.now() + 2);
        insert emIncoming2;
        
        EmailMessage emOutgoing2 = new emailmessage(ParentId=caseObj.Id, relatedToId=caseObj.Id,incoming=false, messagedate=system.now() + 2);
        insert emOutgoing2;
        
        Case ReqCase = [Select Id, TAT_Median__c FROM Case LIMIT 1];
       // CaseHelper.caseTATCalculator(new List<Id>{ReqCase.Id});
        Test.stopTest();
    }
    
}