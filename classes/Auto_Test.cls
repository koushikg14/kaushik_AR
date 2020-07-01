Public class Auto_Test{
    
    Public Point_Audit__c point;
    Public Test__mdt t1;
    Public Account accpoint;
    Public Auto_Test(ApexPages.StandardController controller){
        point=new Point_Audit__c();
    }
    public Point_Audit__c getpoint(){
        return point;
    }

    Public PageReference NewPoint(){
    accpoint.test__c='test';
    PageReference pdf = Page.Auto_Test;
        insert point;
         PageReference ref = new PageReference('https://cs5.salesforce.com/a02/o');
        ref.setRedirect(true);
        return ref;
    }
}