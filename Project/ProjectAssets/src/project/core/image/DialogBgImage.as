package project.core.image
{
	import flash.geom.Rectangle;
	import mx.core.BitmapAsset;
	import org.bytearray.display.ScaleBitmap;
	
	[Embed(source="/assets/Dialog_Bg.png")]
	public final class DialogBgImage extends BitmapAsset
	{
		public function DialogBgImage()
		{
			super();
		}
		public static function GetImage():ScaleBitmap {
			var obj:ScaleBitmap = new ScaleBitmap( new DialogBgImage().bitmapData );
			obj.scale9Grid = new Rectangle(14,18,220,41);
			return obj;
		} 
	}
}