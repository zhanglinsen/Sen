package project.core.navigators
{
	import project.core.controls.UToggleButton;

	public class UTabItem extends UToggleButton
	{
		public function UTabItem()
		{
			super();
		}
		override public function set Data(val:Object):void {
			super.Data = val;
			if( val ) {
				if(val.hasOwnProperty("Label")) Label = val.Label;
				if(val.hasOwnProperty("Tooltip")) ToolTip = val.Tooltip;
				if(val.hasOwnProperty("Ident")) Ident = val.Ident;
			} else {
				Label = "";
				ToolTip = null;
				Ident = -1;
			}
		}
	}
}