@isTest
public class PublicFileShareControllerTest {

    @isTest
    static void testGetContentDocuments() {
        // Create test records as needed
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a ContentDocumentLink related to the test record
        ContentVersion testContentVersion = new ContentVersion();
        testContentVersion.Title = 'Test Content.txt';
        testContentVersion.VersionData = Blob.valueOf('Test Content Body');
        testContentVersion.PathOnClient = 'txt';
        insert testContentVersion;

        ContentDocumentLink testLink = new ContentDocumentLink(
            LinkedEntityId = testAccount.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert testLink;

        // Call the method to be tested
        Test.startTest();
        List<ContentDocumentLink> result = PublicFileShareController.getContentDocuments(testAccount.Id);
        PublicFileShareController.getFolderList();
        PublicFileShareController.createPublicFolder('Fname','Fdesc');
        Test.stopTest();

        // Perform assertions
        System.assertEquals(1, result.size());
       // System.assertEquals('Test Content', result[0].ContentDocument.Title);
    }
}