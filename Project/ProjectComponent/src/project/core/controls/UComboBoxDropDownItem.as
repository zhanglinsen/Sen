package project.core.controls
{
	
	public class UComboBoxDropDownItem extends UButton
	{
		public function UComboBoxDropDownItem()
		{
			super("", false);
			this.BgColor = 0x1c2422;
			this.OverBgColor = 0x233f38;
			this.TextColor = 0xffffff;
			this.OverTextColor = 0xffffff;
			
			this.BorderColor = 0x2c5158;
			this.BorderWeight = 1;
			this.Border = true;
		}
		override public function set Data(data:Object):void {
			super.Data = data;
			if(data.TxtColor && data.TxtColor != 0)
				OverTextColor = TextColor =  data.TxtColor;
			Label = data.Label;
			ToolTip = data.ToolTip;
			this.Enabled = data.Enabled;
		}
	}
}