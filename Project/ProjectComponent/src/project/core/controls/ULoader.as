package project.core.controls
{
	import flash.display.Loader;
	
	public class ULoader extends Loader
	{
		private var _Width:Number;
		private var _Height:Number;
		override public function get width():Number {
			return _Width;
		}
		override public function set width(value:Number):void {
			_Width = value;
		}
		override public function get height():Number {
			return _Height;
		}
		override public function set height(value:Number):void {
			_Height = value;
		}
	}
}