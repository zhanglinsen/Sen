package project.core.entity
{
	public class MenuItemData
	{
		public var EventID:int;
		public var Label:String;
		public var Value:Object;
		public var ToolTip:Object;
		public var Enabled:Boolean = true;
		public var SkinID:String = "21";
		public var TxtColor:uint = 0;
		
		/**
		 * Jack
		 * 2010-9-16
		 * 添加构造函数
		*/
		public function MenuItemData(eventID:int = -1, label:String = "", value:Object = null, toolTip:Object = null)
		{
			this.EventID = eventID;
			this.Label = label;
			this.Value = value;
			this.ToolTip = toolTip;
		}
	}
}