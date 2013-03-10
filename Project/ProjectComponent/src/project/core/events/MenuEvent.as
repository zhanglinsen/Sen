package project.core.events
{
	import flash.events.Event;
	
	import project.core.entity.MenuItemData;
	
	public class MenuEvent extends Event
	{
		public static const ITEM_CLICK:String = "itemClick";
		public var Index:int;
		public var Item:MenuItemData;
		public function MenuEvent(type:String, index:int, item:MenuItemData)
		{
			super(type, false, false);
			this.Index = index;
			this.Item = item;
		}
	}
}