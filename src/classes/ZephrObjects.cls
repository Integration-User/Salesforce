public without sharing class ZephrObjects {

    public abstract class SalesforceObject {
        public Id salesforceId;
        public String sObjectName;
        public String tenantName;
    } 

    public class Grant extends SalesforceObject {
        // paid subscription
        public List<ZephrProduct> publications;
        public ZephrUser user;
    }

    public class ZephrUser extends SalesforceObject {
        // contact, lead
        public String email;
        public String firstName;
        public String lastName;
        public String companyName; 
        public String jobTitle;
        public String city;
        public String id;
        public String country; 
        public String companyType; 
        public String seniority; 
        public String startDate;
        public String zephrId;
    }

    public class Trial extends SalesforceObject {
        // trial subscription
        public Date startDate;
        public Date endDate;
        public List<String> publicationNames;
        public String zephrGrantId;
        public ZephrUser user; // contact or lead
    }

    public class ZephrProduct extends SalesforceObject {
        // publication
        public String zephrAccountId;
        public String zephrGrantId;
        public String publicationName;
        public Integer numberOfUsersSold;

    }

    public class ZephrAccount extends SalesforceObject {
        // contract or order
        public Id accountId;
        public String zephrCompanyId;
        public String contractName;
        public String accountName;
        public List<ZephrProduct> publications;
        public String companyWebsiteAddress;
        public Date startDate;
        public Date endDate;
    }
}