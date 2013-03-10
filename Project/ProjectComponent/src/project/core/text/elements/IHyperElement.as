package project.core.text.elements
{
	import flash.text.TextFormat;

	public interface IHyperElement 
	{
		function Parse( node:XML ):void;
		function get Content():String;
		function set Content(str:String):void;
		function get ContentFormat():TextFormat;
		function set ContentFormat(fmt:TextFormat):void;
		function get IsDynamic():Boolean;
		function get NodeName():String;
	}
}