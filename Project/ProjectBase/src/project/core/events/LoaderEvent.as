package project.core.events
{
	import flash.events.Event;
	public class LoaderEvent extends Event
	{
		public static const ALL_COMPLETED:String = "allCompleted";
		public static const DATA_ERROR:String = "dataError";
		public static const RETRY:String = "retry";
		public var Data:Object;
		public var Source:String;
		public function LoaderEvent( type:String, data:Object=null )
		{
			super( type, false, false );
			Data = data;
		}
	}
}