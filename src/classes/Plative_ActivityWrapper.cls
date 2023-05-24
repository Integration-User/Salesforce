//Wrapper class for displaying events and tasks in the same list
public class Plative_ActivityWrapper  {
	@AuraEnabled
	public String subject{get;set;}
    @AuraEnabled
	public Date dueDate{get;set;}
    @AuraEnabled
	public String status{get;set;}
    @AuraEnabled
	public String assignedToOwner{get;set;}
    @AuraEnabled
	public string sobjName{get;set;}
    @AuraEnabled
	public Id recordId{get;set;}
    @AuraEnabled
	public string contactName{get;set;}
    @AuraEnabled
	public String  type{get;set;}

	public Plative_ActivityWrapper(Task tsk){
		subject = tsk.Subject;
		dueDate = tsk.ActivityDate;
		status = tsk.Status;
		assignedToOwner = tsk.Owner.Name;
		sobjName = 'Task';
		recordId = tsk.Id;
		contactName = tsk.Who.Name;
		type = tsk.Type;
	}

	public Plative_ActivityWrapper(Event evt){
		subject = evt.Subject;
		dueDate = evt.ActivityDate;
		status =  '';
		assignedToOwner = evt.Owner.Name;
		sobjName = 'Event';
		recordId = evt.Id;
		contactName = evt.Who.Name;
		type = evt.Type;
	}

}