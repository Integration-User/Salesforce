/**
 * Wrapper for Salesloft email activities API response.
 * Strongly‑typed deserialization of the response from
 * GET /v2/activities/emails
 */
public class SalesloftEmailActivityResponse {
    public Metadata metadata;
    public List<ActivityData> data;

    public class Metadata {
        public Paging paging;
    }

    public class Paging {
        public Integer per_page;	//100
		public Integer current_page;	//1
		public Integer next_page;	//2
		public Integer total_pages;	//1318
		public Integer total_count;	//131717
    }

    public class ActivityData {
        public ActivityCounts counts;
        public String message_id;
    }

    public class ActivityCounts {
        public Integer clicks;
        public Integer views;
        public Integer replies;
        public Integer uniqueDevices;
        public Integer uniqueLocations;
        public Integer attachments;
    }
}