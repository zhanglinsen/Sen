package project.core.loader
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import org.bytearray.display.ScaleBitmap;
	
	import project.core.events.LoaderEvent;
	import project.core.global.GlobalVariables;

	[Event(name="allCompleted", type="project.core.events.LoaderEvent")]
	public class ImageLoader extends EventDispatcher
	{
		public static const MAX_ERROR_TRY:int = 3;

		public function ImageLoader(ctx:LoaderContext=null)
		{
			super();
			_pContext = ctx;
//			_pLoader = new Loader();
		}
		
		/**
		 * 背景动画目录，根据 <code>GlobalVariables.BgAniOn</code>的值来开关此目录下的动画
		 * @default /MapBg/ 
		 */
		public static var BgAniFolder:String = "/MapBg/";
		/**
		 * 是否动画，当值为false时，如果加载的内容是动画，为转成静态图像
		 * @default false 
		 */
		public var IsAnimation:Boolean = false;
		public function get Context():LoaderContext {
			return _pContext;
		}
//		protected var _pLoader:Loader;
		protected var _pContext:LoaderContext;
		private var _ErrorTry:int = 0;
		private var _Stream:URLStream;
		
		private var _Url:String;
		
		private var _CurrHost:String;
		public function Load(url:String):void {
			_Url = url;
			if( _Stream==null ) {
				_Stream = new URLStream();
				_Stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, Icon_OnLoadError);
				_Stream.addEventListener(IOErrorEvent.IO_ERROR, Icon_OnLoadError );
				_Stream.addEventListener(Event.COMPLETE, Icon_OnLoadComplete );
			}
			try{
				_Stream.close();
			}catch(e:Error){}
			if( url ) {
				_CurrHost = null;
				var host:String = GlobalVariables.ResHost;
				if(host) {
					if( url.indexOf("://")==-1 ) {
						url = host+url;
					}
					_Url = url;
					
					if( url.indexOf( host )!=-1 ) {
						_CurrHost = host;
					}
				}
				_Stream.load(new URLRequest( url ));
			}
		}
		public function LoadBytes(fileName:String, bytes:ByteArray):void {
			_Url = fileName;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, Loader_OnComplete);
			loader.loadBytes(bytes, _pContext);
		}
		public function get Url():String {
			return _Url;
		}
		private static var _ScaleMap:Dictionary = new Dictionary();
		/**
		 * 添加加载图片默认拉伸的范围
		 * <pre>
		 * //在 Item/ 目录下面的图片加载完都设置拉伸
		 * ImageLoader.AddDefaultScale("/Item/", new Rectangle(2,2,40,40) );
		 * </pre>
		 */
		public static function AddDefaultScale( folder:String, rect:Rectangle ):void {
			_ScaleMap[folder] = rect;
		}
		protected function CreateContent(ld:Loader):Object {
			var b:BitmapData;
			if ( Url.indexOf( ".swf" )!=-1 )
			{
				if( IsAnimation ) {
					return ld;
				}
				if( (GlobalVariables.BgAniOn && Url.indexOf(BgAniFolder)!=-1) ) {
					return ld;
				}
				b = new BitmapData( ld.contentLoaderInfo.width, ld.contentLoaderInfo.height, true, 0 );
				b.draw( ld.content );
				ld.unload();
			}
			else
			{
				b = (ld.content as Bitmap).bitmapData;
			}
			var sb:ScaleBitmap = new ScaleBitmap(b);
			for( var folder:String in _ScaleMap ) {
				if( Url.indexOf( folder )!=-1 ) {
					sb.scale9Grid = _ScaleMap[folder];
					break;
				}
			}
//			if( Url.indexOf("/General/")!=-1 || Url.indexOf("/Item/")!=-1 ) {
//				sb.scale9Grid = new Rectangle(2,2, b.width-4,b.height-4);
//			}
			
			return sb;
		}
		private function Icon_OnLoadComplete( e:Event ):void
		{
//			_Stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, Icon_OnLoadError );
//			_Stream.removeEventListener(IOErrorEvent.IO_ERROR, Icon_OnLoadError );
//			_Stream.removeEventListener(Event.COMPLETE, Icon_OnLoadComplete );
			var bytes:ByteArray = new ByteArray();
			_Stream.readBytes(bytes);
			
			var ld:Loader = new Loader();
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE, Loader_OnComplete);
			ld.loadBytes(bytes, _pContext);
		}
		private function Icon_OnLoadError( e:ErrorEvent ):void
		{
			if( _ErrorTry>=GlobalVariables.ResHostList.length*2 ) {
				this.dispatchEvent(new LoaderEvent(LoaderEvent.DATA_ERROR));
//				_Stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, Icon_OnLoadError );
//				_Stream.removeEventListener(IOErrorEvent.IO_ERROR, Icon_OnLoadError );
//				_Stream.removeEventListener(Event.COMPLETE, Icon_OnLoadComplete );
			} else {
				_ErrorTry++;
				
				if( _CurrHost ) {
					GlobalVariables.NextResHost();
					_Url = GlobalVariables.ResHost + _Url.replace(_CurrHost,"");
					_CurrHost = GlobalVariables.ResHost;
				}
				flash.utils.setTimeout( Retry, 300, _ErrorTry>=GlobalVariables.ResHostList.length );
			}
		}
		private function Loader_OnComplete( e:Event ):void
		{			
			var ldi:LoaderInfo = e.currentTarget as LoaderInfo;
			ldi.removeEventListener( Event.COMPLETE, Loader_OnComplete );
			
			var evt:LoaderEvent = new LoaderEvent(LoaderEvent.ALL_COMPLETED);
			evt.Data = CreateContent( ldi.loader );
			evt.Source = Url;
			this.dispatchEvent( evt );
		}
		private function Retry(noCache:Boolean=true):void {
			_Stream.load(new URLRequest( Url+(noCache?"?t="+new Date().getTime():"") ));
		}
	}
}