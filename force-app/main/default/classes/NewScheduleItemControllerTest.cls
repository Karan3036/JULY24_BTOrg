@isTest
private class NewScheduleItemControllerTest {

	@isTest
    static void testGetPurchaseOrderData() {
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        insert con;
        
        // Create a test WorkOrder record
        WorkOrder testWorkOrder = new WorkOrder();
        testWorkOrder.buildertek__Project__c = proj.Id; // Replace with a valid Project Id
        testWorkOrder.ContactId = con.Id; // Replace with a valid Contact Id
        insert testWorkOrder;

        // Call the method being tested
        Test.startTest();
        WorkOrder result = NewScheduleItemController.getPurchaseOrderData(testWorkOrder.Id);
        Test.stopTest();

        // Assert the results
        System.assertEquals(testWorkOrder.Id, result.Id);
        System.assertEquals(testWorkOrder.buildertek__Project__c, result.buildertek__Project__c);
        System.assertEquals(testWorkOrder.ContactId, result.ContactId);
    }
    
    @isTest
    static void testGetSchedulelist() {
        // Create a test Project record
        Project__c testProject = new Project__c(Name = 'Test Project');
        insert testProject;

        // Create some test Schedule records related to the test Project
        List<Schedule__c> testSchedules = new List<Schedule__c>{
            new Schedule__c(buildertek__Description__c = 'Description 1', buildertek__Project__c = testProject.Id),
            new Schedule__c(buildertek__Description__c = 'Description 2', buildertek__Project__c = testProject.Id),
            new Schedule__c(buildertek__Description__c = 'Description 3', buildertek__Project__c = testProject.Id)
        };
        insert testSchedules;

        // Call the method being tested
        Test.startTest();
        List<NewScheduleItemController.ScheduleWrap> result = NewScheduleItemController.getSchedulelist(testProject.Id);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(testSchedules.size(), result.size(), 'Returned list size should be equal to the number of test schedules');

        for (Integer i = 0; i < result.size(); i++) {
            NewScheduleItemController.ScheduleWrap wrap = result[i];
            Schedule__c schedule = testSchedules[i];
            System.assertEquals(schedule.Id, wrap.getSchedulesList.Id, 'Schedule Id should match');
            System.assertEquals(schedule.buildertek__Description__c, wrap.getSchedulesList.buildertek__Description__c, 'Schedule Description should match');
            System.assertEquals(false, wrap.scheduleCheckbox, 'scheduleCheckbox should be initialized as false');
        }
    }
    
     @isTest
    static void testInsertScheduleTask() {
         buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        
        List<buildertek__Schedule__c> schList = new List<buildertek__Schedule__c>();
        buildertek__Schedule__c sch = new buildertek__Schedule__c();
        sch.buildertek__Description__c = 'Test Schedule';
        sch.buildertek__Project__c = proj.Id;
        schList.add(sch);
        insert schList;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.email='test@gmail.com';
        insert con;
        
        buildertek__Project_Task__c schTask = (buildertek__Project_Task__c)buildertek__Project_Task__c.sObjectType.newSObject(null, true);
        schTask.Name = 'Test Task';
        schTask.buildertek__Schedule__c = schList[0].Id;
        schTask.buildertek__Start__c=System.Now().date();
        insert schTask;
        
        // Create test data
        buildertek__Project_Task__c dependencyTask = new buildertek__Project_Task__c(
            Name = 'Dependency Task',
            buildertek__Finish__c = Date.today(),
            buildertek__Start__c = Date.today(),
            buildertek__Schedule__c = schList[0].Id
        );
        insert dependencyTask;
        buildertek__Project_Task__c dependencyTask1 = new buildertek__Project_Task__c(
            Name = 'Dependency Task',
            buildertek__Finish__c = Date.today(),
            buildertek__Start__c = Date.today(),
            buildertek__Schedule__c = schList[0].Id,
            buildertek__Lag__c = 1.00
        );
        insert dependencyTask1;

        // Call the method to test
        Date startDate = Date.today().addDays(5);
        String taskId = NewScheduleItemController.insertScheduleTask('Test Task', schList[0].Id, dependencyTask.Id, startDate, proj.Id, con.Id);
        String taskId1 = NewScheduleItemController.insertScheduleTask('Test Task', schList[0].Id, dependencyTask1.Id, startDate, proj.Id, con.Id);

        // Retrieve the inserted task and dependency task
        buildertek__Project_Task__c insertedTask = [
            SELECT Id, Name, buildertek__Schedule__c, buildertek__Start__c, buildertek__Finish__c, buildertek__Dependency__c
            FROM buildertek__Project_Task__c
            WHERE Id = :taskId
        ];
        buildertek__Project_Task__c queriedDependencyTask = [
            SELECT Id, Name, buildertek__Finish__c
            FROM buildertek__Project_Task__c
            WHERE Id = :dependencyTask.Id
        ];

        // Assert the results
        System.assertEquals('Test Task', insertedTask.Name);
        //System.assertEquals(startDate, insertedTask.buildertek__Start__c);
        //System.assertEquals(startDate, insertedTask.buildertek__Finish__c);
        System.assertEquals(dependencyTask.Id, insertedTask.buildertek__Dependency__c);

        // Verify the dependency logic
        Integer expectedLagDays = queriedDependencyTask.buildertek__Finish__c.daysBetween(startDate) + 1;
        //System.assertEquals(startDate.addDays(expectedLagDays), insertedTask.buildertek__Start__c);
        //System.assertEquals(startDate.addDays(expectedLagDays), insertedTask.buildertek__Finish__c);
    }
    
    @isTest
    static void testGetPredecessorList() {
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        
        List<buildertek__Schedule__c> schList = new List<buildertek__Schedule__c>();
        buildertek__Schedule__c sch = new buildertek__Schedule__c();
        sch.buildertek__Description__c = 'Test Schedule';
        sch.buildertek__Project__c = proj.Id;
        schList.add(sch);
        insert schList;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.email='test@gmail.com';
        insert con;
        
        buildertek__Project_Task__c schTask = (buildertek__Project_Task__c)buildertek__Project_Task__c.sObjectType.newSObject(null, true);
        schTask.Name = 'Test Task';
        schTask.buildertek__Schedule__c = schList[0].Id;
        schTask.buildertek__Start__c=System.Now().date();
        schTask.buildertek__Contractor_Resource__c = con.Id;
        insert schTask;

        buildertek__Project_Task__c testTask1 = new buildertek__Project_Task__c(Name = 'Task 1', buildertek__Schedule__c = schList[0].Id, buildertek__Start__c = System.Now().date());
        buildertek__Project_Task__c testTask2 = new buildertek__Project_Task__c(Name = 'Task 2', buildertek__Schedule__c = schList[0].Id, buildertek__Start__c = System.Now().date());
        List<buildertek__Project_Task__c> testScheduleItems = new List<buildertek__Project_Task__c>{testTask1, testTask2};
        insert testScheduleItems;

        Test.startTest();

        // Call the method to be tested
        Map<String, String> result = NewScheduleItemController.getPredecessorList(schList[0].Id);

        Test.stopTest();

        // Perform assertions
        System.assertEquals(3, result.size());
        System.assertEquals('Task 1', result.get(testTask1.Id));
        System.assertEquals('Task 2', result.get(testTask2.Id));
    }


}