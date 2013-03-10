package project.core.events
{
	import flash.events.Event;
	
	public class UIEvent extends Event
	{
		public static const TIMEOUT:String = "timeout";
		public static const CANCEL:String = "cancel";
		public static const OK:String = "ok";
		public static const HIDDEN:String = "hidden";
		public static const SHOWN:String = "shown";
		public static const STATE_CHANGED:String = "stateChanged";
		public static const INDEX_CHANGED:String = "indexChanged";
		public static const ITEM_CLICK:String = "itemClick";
		public static const BUTTON_CLICK:String = "buttonClick";
		public static const ENTER:String = "enter";
		public static const POSITION_CHANGE:String = "positionChange";
		public static const POPUP:String = "popup";
		public static const DRAG_DROP:String = "dragDrop";
		public static const RADIO_SELECT:String = "radioSelect";
		public static const SELECTE:String = "select";
		
		public var Data:Object;
		public function UIEvent(type:String, data:Object = null)
		{
			super(type);
			Data = data;
		}
	}
}