package project.core.tooltip
{
	import flash.display.InteractiveObject;

	public interface IToolTipUI
	{
		function Show(target:InteractiveObject):void;
		function Hide():void;
		function get Data():Object;
		function set Data( obj:Object ):void;
		function get OffsetX():int;
		function get OffsetY():int;
		function set OffsetX( x:int ):void;
		function set OffsetY( y:int ):void;

	}
}