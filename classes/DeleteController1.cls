/**
 * An apex page controller tto delete
 */
public with sharing class DeleteController1 {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
    //This is comment2
 //and im changing comment
// by adding multiple comment lines
    public DeleteController1() {}
}