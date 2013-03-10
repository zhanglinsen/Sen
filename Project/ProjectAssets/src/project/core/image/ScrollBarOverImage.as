package project.core.image
{
	import flash.geom.Rectangle;
	import mx.core.BitmapAsset;
	import org.bytearray.display.ScaleBitmap;
	
	[Embed(source="/assets/e3_Over.png")]
	public final class ScrollBarOverImage extends BitmapAsset
	{
		public function ScrollBarOverImage()
		{
			super();
		}
		public static function GetImage():ScaleBitmap {
			var obj:ScaleBitmap = new ScaleBitmap( new ScrollBarOverImage().bitmapData );
			obj.scale9Grid = new Rectangle(6, 6, 8, 18);
			return obj;
		} 
	}
}