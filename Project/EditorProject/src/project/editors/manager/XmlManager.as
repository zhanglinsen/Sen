package project.editors.manager
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class XmlManager
	{
//		private static var _Dispatcher:EventDispatcher = new EventDispatcher();
//		public static function AddListener( fileName:String, listener:Function ):void {
//			_Dispatcher.addEventListener( fileName, listener );
//		}
		public static function Load(path:String):void {
			LoadFile( new File(path) );
		}
		public static function LoadFile( file:File ):void {
			var key:String = file.name.replace(".xml", "");
			if( _Cache[key] ) {
				delete _Cache[key];
			}

			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var xml:XML = new XML(fs.readUTFBytes(fs.bytesAvailable));
			fs.close();

			Update(key, xml);
		}
		public static function Update( fileName:String, xml:XML ):void {
			var key:String = fileName.replace(".xml", "");
			_Cache[key] = xml;
//			_Dispatcher.dispatchEvent( new Event(fileName) );
		}
		private static var _Cache:Dictionary = new Dictionary();
		
		public static function GetXml(fileName:String):XML
		{
			var key:String = fileName.replace(".xml", "");
			return _Cache[ key ];
		}
		
		public static function Clear():void {
			for( var key:String in _Cache ) {
				delete _Cache[key];
			} 
		}
	}
}