package
{
	public class Config
	{
		// FDT does not compile CONFIG::debug   http://bugs.powerflasher.com/jira/browse/FDT-60
		public static var debug:Boolean = true;  
		public static var online:Boolean = true;
		public static var crossdomainUrl:String = 
										"http://184.172.142.46:8080"; 
										// "http://localhost:8080";  
		public static var levels:Array = ["NEWB", "MSFT", "GOOG"];
		// Levels are appended to later.
		public static var tutorLevelsLength:int = 2;  
		
	}
}

