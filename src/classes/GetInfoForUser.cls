global class GetInfoForUser{
    
    @InvocableMethod(label='Get user info' description='Get the info of user based on department' category='User info')
    public static List<UserCreateInfoOutput> getUserInfo(List<UserCreateInfoInput> userCreateInfo){
    
        List<UserCreateInfoOutput> listOutput = new List<UserCreateInfoOutput>();
        UserCreateInfoOutput output = new UserCreateInfoOutput();
        system.debug('***userCreateInfo'+userCreateInfo);
        
        List<User_info_Mapping__mdt> userInfoList = [Select Id,Profle_Id__c,Permission_Set_Group__c, Role__c 
                FROM User_info_Mapping__mdt where MasterLabel =: userCreateInfo[0].department];
        
        if(userInfoList != null && userInfoList.size() > 0){
        
            UserRole roleToUsed = [SELECT id,developername from UserRole where developername =: userInfoList[0].Role__c];
            List<PermissionSetGroup> permissionGroupList = [SELECT Id,DeveloperName,MasterLabel 
                        FROM PermissionSetGroup WHERE MasterLabel =: userInfoList[0].Permission_Set_Group__c];
            
            if(roleToUsed == null || permissionGroupList == null || userInfoList[0].Profle_Id__c == null){
                output.errorMessage = 'Role or permission for department is not available';    
            } else {
                if (permissionGroupList != null && permissionGroupList.size() > 0) 
                    output.permissionSetId = permissionGroupList[0].id; 
                if(roleToUsed != null) {
                    output.profileId =  userInfoList[0].Profle_Id__c;
                    output.roleId = roleToUsed.id; 
                } 
            }
        }
        listOutput.add(output);
        
        return listOutput;
        
    }
    
    global class UserCreateInfoInput{
        @InvocableVariable(required=true)
        global String department;
    }
    
    global class UserCreateInfoOutput{
        @InvocableVariable
        global String profileId;
        @InvocableVariable
        global String roleId;
        @InvocableVariable
        global String permissionSetId;
        @InvocableVariable
        global String errorMessage;
    }
    
    
}