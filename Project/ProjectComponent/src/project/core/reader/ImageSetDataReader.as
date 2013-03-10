package project.core.reader
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.bytearray.display.ScaleBitmap;
	
	import project.core.controls.ULoader;
	import project.core.entity.ResourceData;
	import project.core.entity.StreamRequestInfo;
	import project.core.global.GlobalVariables;
	import project.core.loader.ClassLoader;
	import project.core.manager.Debugger;
	import project.core.utils.Utility;

	/**
	 * 图像数据解析器
	 */
	public class ImageSetDataReader implements IStreamReader
	{
		private static const CLASS:String = "class";
		private static const SWF:String = "swf";
		private static const IMAGE:String = "image";

		protected var _pDataKeyMap:Dictionary = new Dictionary();
		protected var _pDataMap:Dictionary = new Dictionary();
		
		public function GetContentByIdent( ident:int, className:String = null, flip:Boolean=false ):DisplayObject
		{
			return GetContent( _pDataKeyMap[ ident ], className, flip);
		}
		
		public function GetTileContent( fileName:String, width:Number=0, height:Number=0, borderThinkness:int=0, borderColor:uint=0x689D8B):DisplayObject {
			if( width==0 || height==0 ) {
				return GetContent(fileName);
			}
			if( !fileName ) return null;
			var res:ResourceData = _pDataMap[fileName.toLowerCase()];
			
			if(!res)
			{
				Debugger.Error("加载的资源:"+fileName+"不存在");
				return null;
			}
			var b:DisplayObject = null;
			switch ( res.Type )
			{
				case IMAGE:
					var dat:BitmapData = res.Content as BitmapData;
					var sp:Sprite = new Sprite();
					sp.graphics.beginBitmapFill(dat);
					if( borderThinkness>0 ) {
						sp.graphics.lineStyle(borderThinkness, borderColor);
					}
					sp.graphics.drawRect(0, 0, width, height);
					sp.graphics.endFill();

					b = sp;
					break;
				case SWF:
				case CLASS:
					b = GetContent(fileName);
					break;
			}

			return b;
		}
		
		public function GetContent( fileName:String, className:String = null, flip:Boolean=false ):DisplayObject
		{
			if( !fileName ) return null;
			var res:ResourceData = _pDataMap[fileName.toLowerCase()];
			
			if(!res)
			{
//				Debugger.Error("加载的资源:"+ fileName+",className:"+ className+"不存在");
				return ClassLoader.GetInstance(className?className:Utility.GetFileName(fileName));
			}
			var b:DisplayObject = null;
			switch ( res.Type )
			{
				case IMAGE:
					b = new ScaleBitmap(res.Content as BitmapData);
					break;
				case SWF:
					var ld:ULoader = new ULoader();
					ld.width = res.Width;
					ld.height = res.Height;
					ld.loadBytes( res.Content as ByteArray );
					b = ld;
					break;
				case CLASS:
					if ( !className )
					{
						className = Utility.GetFileName(fileName);
					} else {
						res = _pDataMap[className];
						if( !res ) {
							res = new ResourceData();
							res.Type = CLASS;
						}
					}
					if ( res.Content==null )
					{
						res.Content = ClassLoader.Instance.GetClass( className );
						if( !res.Content ) {
							return null;
						}
					}
					b = new res.Content();
					break;
			}
			if( b && flip ) {
				b.scaleX = -1;
			}
			return b;
		}
		
		public function ReadStream( stream:URLStream, reqInfo:StreamRequestInfo ):String
		{
			while ( stream.bytesAvailable>0 )
			{
				var res:ResourceData = new ResourceData();
				var bytes:ByteArray = new ByteArray();
				var name:String;
				
				if( reqInfo.Type ) {
					stream.readBytes( bytes );
					
					name = reqInfo.Folder.replace(GlobalVariables.ResImageFolder,"").replace("_"+GlobalVariables.Lang,"")+reqInfo.FileName;
					
					res.Type = reqInfo.Type;
				} else {
					res.Type = stream.readUTF();
					var ident:int = stream.readInt();
					name = reqInfo.FileName.replace("_"+GlobalVariables.Lang,"")+"/"+stream.readUTF();
					res.Width = stream.readInt();
					res.Height = stream.readInt();
					var size:int = stream.readInt();
					stream.readBytes( bytes, 0, size );
					_pDataKeyMap[ident] = name;
				}
				_pDataMap[name.toLowerCase()] = res;

				switch ( res.Type )
				{
					case IMAGE:
						var ld:Loader = new Loader();
						ld.contentLoaderInfo.addEventListener( Event.COMPLETE, LoadImage_OnComplete );
						ld.name = name.toLowerCase();
						ld.loadBytes( bytes );
						break;
					case SWF:
						res.Content = bytes;
						break;
					case CLASS:
						ClassLoader.Instance.LoadClass( bytes );
						break;
				}
			}
			return null;
		}

		private function LoadImage_OnComplete( e:Event ):void
		{
			var ldi:LoaderInfo = e.currentTarget as LoaderInfo;
			ldi.removeEventListener( Event.COMPLETE, LoadImage_OnComplete );
			var res:ResourceData = _pDataMap[ldi.loader.name];
			
			res.Width = ldi.width;
			res.Height = ldi.height;
			if ( ldi.loader.name.indexOf( ".swf" )!=-1 )
			{
				var b:BitmapData = new BitmapData( ldi.width, ldi.height, true, 0 );
				b.draw( ldi.content );
				res.Content = b;
				ldi.loader.unload();
			}
			else
			{
				res.Content = (ldi.content as Bitmap).bitmapData;
			}
		}
	}
}