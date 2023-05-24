@IsTest(seealldata=true)
public class GetInfoForUserTest{

    @isTest
    public static void getInforForUser(){
        List<GetInfoForUser.UserCreateInfoInput> listInput = new List<GetInfoForUser.UserCreateInfoInput>();
        GetInfoForUser.UserCreateInfoInput input = new GetInfoForUser.UserCreateInfoInput();
        input.department = 'Advisory';
        listInput.add(input);
        List<GetInfoForUser.UserCreateInfoOutput> listOutput = GetInfoForUser.getUserInfo(listInput);
        
    }
}