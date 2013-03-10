package project.core.controls
{
	public interface ISelectable
	{
		/**选中*/
		function get Selected():Boolean;
		function set Selected(value:Boolean):void;
		/**能否被选中*/
		function get Selectable():Boolean;
		function set Selectable(value:Boolean):void;
	}
}