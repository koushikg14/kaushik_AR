public class TaskUtil {
    public static String getTaskPriority(String leadState) {
        // Validate inputdduhkhjk
        if (String.isBlank(leadState) || leadState.length() > 2) {
            return null;
        }
            
        String taskPriority;
        
        if (leadState == 'CA') {
             taskPriority = 'High'; 
        } else if(leadState == 'AU') {
             taskPriority = 'Normal';
        }
        
        else {
            taskPriority = 'Major';
        }
        
        return taskPriority;
    }
}