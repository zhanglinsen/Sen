package project.editors.events
{
	import flash.events.Event;
	
	public class ObjectEvent extends Event
	{
		public static const NEW_DATA:String = "newData";
		public static const DIRECTION:String = "direction";
		
		public var Data:Object;
		
		public function ObjectEvent(type:String, data:Object)
		{
			super(type);
			Data = data;
		}
	}
}