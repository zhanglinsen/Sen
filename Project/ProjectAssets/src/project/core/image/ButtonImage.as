package project.core.image
{
	import flash.geom.Rectangle;
	
	import org.bytearray.display.ScaleBitmap;

	public final class ButtonImage
	{
		public static function GetOverSkin():ScaleBitmap {
			var s:ScaleBitmap = new ScaleBitmap( new ButtonOverImage().bitmapData );
			s.scale9Grid = new Rectangle(11, 11, 56, 8);
			return s;
		} 
		public static function GetDownSkin():ScaleBitmap {
			var s:ScaleBitmap = new ScaleBitmap( new ButtonDownImage().bitmapData );
			s.scale9Grid = new Rectangle(11, 11, 56, 8);
			return s;
		} 
		public static function GetDisabledSkin():ScaleBitmap {
			var s:ScaleBitmap = new ScaleBitmap( new ButtonDisabledImage().bitmapData );
			s.scale9Grid = new Rectangle(11, 11, 56, 8);
			return s;
		} 
		public static function GetUpSkin():ScaleBitmap {
			var s:ScaleBitmap = new ScaleBitmap( new ButtonUpImage().bitmapData );
			s.scale9Grid = new Rectangle(11, 11, 56, 8);
			return s;
		} 
	}
}