package project.core.text
{
	import flash.display.Bitmap;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public interface IText
	{
		function set Text(val:String):void;
		function get Text():String;
		function toString(params:Object=null):String;
		function Parse( xml:* ):void;
		function ToTextField( txt:TextField, filters:Array = null, txtFormat:TextFormat = null, params:Object=null, fitSize:Boolean=true ):void;
		function ToBitmap( filters:Array = null, txtFormat:TextFormat = null, params:Object=null, bgEnabled:Boolean=false ):Bitmap;
		function ToHtml(params:Object=null):String;		
	}
}