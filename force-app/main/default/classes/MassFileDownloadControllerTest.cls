@isTest
public class MassFileDownloadControllerTest {
    
    static testMethod void testmassFileDownload() {
        
        String dateval = '2020-09-11';
        List<Id> returnedIds = new List<Id>();
        Test.startTest();
        returnedIds = MassFileDownloadController.getContentDocumentIdsApex(dateval);
        system.assert(returnedIds == NULL);
        Test.stopTest();
        
    }
    
}