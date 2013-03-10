package project.core.loader
{
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import project.core.events.LoaderEvent;

	/**
	 * 类加载器
	 */
	public class ClassLoader extends ImageLoader
	{
		public static var Instance:ClassLoader = new ClassLoader();
		
		public function ClassLoader()
		{
			super(new LoaderContext( false, ApplicationDomain.currentDomain));
		}
		
		public static function GetInstance( className:String ):* {
			var cls:Class = Instance.GetClass( className );
			if(!cls){
				return null;
			}
			return new cls();
		}

		/**
		 * 指定应用程序的作用域
		 * @param domain   作用域
		 */		
		public function set Domain( domain:ApplicationDomain ):void
		{
			if( _pContext && _pContext.applicationDomain==domain ) {
				return ;
			}
			this._pContext = new LoaderContext( false, domain );
		}

		public function GetClass( className:String ):Class
		{
			try{
				return _pContext.applicationDomain.getDefinition( className ) as Class;
			}catch(e:Error) {
			}
			return null;
		}
		
		override public function Load(url:String):void {
//			Debugger.Debug( "load url:" + url, 0xffffff);
			
			var stream:MyUrlStream = new MyUrlStream();
			stream.name = url;
			stream.addEventListener( Event.COMPLETE, Stream_OnComplete );
			stream.addEventListener( IOErrorEvent.IO_ERROR, Stream_OnError );
			stream.addEventListener( SecurityErrorEvent.SECURITY_ERROR, Stream_OnError );
			stream.load( new URLRequest( url ) );
			
//			var loader:Loader = new Loader();
//			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, Loader_OnComplete);
//			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, Loader_OnError);
//			loader.name = Utility.GetFileName(url);
//			loader.load(new URLRequest( url ), _pContext);
		}
		private function Stream_OnComplete( e:Event ):void {
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, Stream_OnError);
			e.currentTarget.removeEventListener(Event.COMPLETE, Stream_OnComplete);
			
			var bytes:ByteArray = new ByteArray();
			var stream:MyUrlStream = e.currentTarget as MyUrlStream;
			stream.readBytes(bytes);
			this.LoadClass( bytes, stream.name );
		}
		private function Stream_OnError( e:ErrorEvent ):void {
			
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, Stream_OnError);
			e.currentTarget.removeEventListener(Event.COMPLETE, Stream_OnComplete);
//			Debugger.Error( "Load url error:"+e.text );
		}
		private function Loader_OnError( e:IOErrorEvent ):void {
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, Loader_OnError);
			e.currentTarget.removeEventListener(Event.COMPLETE, Loader_OnComplete);
//			Debugger.Error( "Load url error:"+e.text );
		}
		/**
		 * 读取类对象
		 */
		public function LoadClass( bytes:ByteArray, name:String=null ):void
		{
			bytes.position = 0;
			var loader:Loader = new Loader();
			if( name ) {
				loader.name = name;
			}
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, LoaderBytes_OnError);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, Loader_OnComplete);
			loader.loadBytes( bytes, _pContext );
		}
		private function LoaderBytes_OnError( e:IOErrorEvent ):void {
//			Debugger.Debug( "Load bytes:"+e.text, 0xffffff );
			e.currentTarget.removeEventListener(Event.COMPLETE, Loader_OnComplete);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, LoaderBytes_OnError);
		}
		private function Loader_OnComplete(e:Event):void {
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, Loader_OnError);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, LoaderBytes_OnError);
			e.currentTarget.removeEventListener(Event.COMPLETE, Loader_OnComplete);
//			Debugger.Debug( "load url complete:" + e.currentTarget.loader.name, 0xffffff);
			var evt:LoaderEvent = new LoaderEvent(LoaderEvent.ALL_COMPLETED );
			evt.Source = e.currentTarget.loader.name;
			this.dispatchEvent( evt );
		}
		
		override protected function CreateContent(ld:Loader):Object {
			var className:String = GetFileName( Url );
			var cls:Class = GetClass( className );
			if( cls ) {
				return new cls();
			}
			return null;
		}
		/**
		 * 取文件名
		 * @url 路径
		 * @includeExt 是否包含扩展名
		 */
		private function GetFileName( url:String ):String
		{
			if ( !url )
			{
				return "";
			}
			var idx:int = url.lastIndexOf( "/" );
			
			if ( idx==-1 )
			{
				idx = url.lastIndexOf( "\\" );
			}
			
			if ( idx==-1 )
			{
				idx=0;
			}
			else
			{
				idx++;
			}
			url = url.substring( idx );
			
			idx = url.lastIndexOf( "." );
			
			if ( idx==-1 )
			{
				idx=url.length;
			}
			url = url.substring( 0, idx );
			return url;
		}
	}
}
import flash.net.URLStream;

class MyUrlStream extends URLStream {
	public var name:String;
}