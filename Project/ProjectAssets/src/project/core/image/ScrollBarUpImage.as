package project.core.image
{
	import flash.geom.Rectangle;
	import mx.core.BitmapAsset;
	import org.bytearray.display.ScaleBitmap;
	
	[Embed(source="/assets/e3_Up.png")]
	public final class ScrollBarUpImage extends BitmapAsset
	{
		public function ScrollBarUpImage()
		{
			super();
		}
		public static function GetImage():ScaleBitmap {
			var obj:ScaleBitmap = new ScaleBitmap( new ScrollBarUpImage().bitmapData );
			obj.scale9Grid = new Rectangle(6, 6, 8, 18);
			return obj;
		} 
	}
}