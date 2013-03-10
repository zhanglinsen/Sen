package project.core.navigators
{
	import project.core.entity.MenuItemData;
	import project.core.controls.UButton;

	public class UMenuItem extends UButton
	{
		public function UMenuItem(data:MenuItemData=null)
		{
			super();
			this.BgColor = 0x252E35;
			this.DisabledBgColor = 0x252E35;
			this.OverBgColor = 0x2C1408;
			this.BorderColor = 0xffffff;
			this.OverTextColor = 0xCCBBAC;
			this.DisabledTextColor = 0x4C443A;
			Data = data;
		}
		override public function set Data(data:Object):void {
			super.Data = data;
			if( data ) {
				if(data.TxtColor && data.TxtColor != 0)
					TextColor =  data.TxtColor;
				Label = data.Label;
				ToolTip = data.ToolTip;
				this.Enabled = data.Enabled;
			}
		}
	}
}