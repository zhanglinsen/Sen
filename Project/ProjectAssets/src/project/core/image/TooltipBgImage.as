package project.core.image
{
	import flash.geom.Rectangle;
	import mx.core.BitmapAsset;
	import org.bytearray.display.ScaleBitmap;
	
	[Embed(source="/assets/Tooltip_Bg.png")]
	public final class TooltipBgImage extends BitmapAsset
	{
		public function TooltipBgImage()
		{
			super();
		}
		public static function GetImage():ScaleBitmap {
			var obj:ScaleBitmap = new ScaleBitmap( new TooltipBgImage().bitmapData );
			obj.scale9Grid = new Rectangle(8,8,38,38);
			return obj;
		} 
	}
}