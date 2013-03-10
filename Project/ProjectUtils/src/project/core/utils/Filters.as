package project.core.utils
{
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	
	/**
	 * 过滤器
	 */
	public final class Filters
	{
		/**
		 * 阴影
		 */
		public static const Shadow:DropShadowFilter=new DropShadowFilter( 2, 65, 0, 0.7, 4, 4, 1 );
		public static const RaiseTextGlow:GlowFilter = new GlowFilter(0x1a0000, 0.7, 61, 30, 1, BitmapFilterQuality.LOW);
		public static const RaiseTextStroke:GlowFilter = new GlowFilter(0x2f0404, 1, 2, 2, 4, 3);
		/**
		 * 文字外边框
		 */		
		public static const TextGlow:GlowFilter = new GlowFilter(0, 1, 2, 2, 4, 3);
		/**
		 * 军徽字体外高亮滤镜
		 * */
		public static const EmblemGlow:GlowFilter = new GlowFilter(0x6A2B00, 1, 2, 2, 4, 3);
		
		public static const WorkShopInfo:GlowFilter = new GlowFilter(0xFFCC00,0.8,2,2,4,3);
		/**
		 * 建筑外发光
		 */
		public static const MapObjectGlow:GlowFilter = new GlowFilter(0xffdd00, 1, 6, 6, 2, 1);
		/**
		 * 灰度
		 */
		private static var _GrayFilter:ColorMatrixFilter;
		public static function get Gray():ColorMatrixFilter {
			if( _GrayFilter==null ) { 
				var colorArray:Array = [1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,0,0, 0,0,1,0]; 
				colorArray[0] = (1-0)*0.3086+0; 
				colorArray[1] = (1-0)*0.6094; 
				colorArray[2] = (1-0)*0.0820; 
				
				colorArray[5] = (1-0)*0.3086; 
				colorArray[6] = (1-0)*0.6094+0; 
				colorArray[7] = (1-0)*0.0820; 
				
				colorArray[10] = (1-0)*0.3086; 
				colorArray[11] = (1-0)*0.6094; 
				colorArray[12] = (1-0)*0.0820+0; 
				
				colorArray[18] = 1; 
				_GrayFilter = new ColorMatrixFilter(colorArray);
			}
			return _GrayFilter;
		}
	}
}