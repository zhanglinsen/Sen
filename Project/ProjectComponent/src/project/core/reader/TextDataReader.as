package project.core.reader
{
	import flash.utils.Dictionary;
	
	import project.core.manager.Debugger;
	import project.core.text.HyperText;
	import project.core.text.IText;
	import project.core.text.SimpleText;
	
	/**
	 * XML数据解析器
	 */
	public class TextDataReader extends AbstractXmlDataReader
	{
//		public function Read( xml:XML ):void {
//			Store("", xml);
//		}
		private static var _TextMap:Dictionary=new Dictionary();
		public function AddText( text:String ):void
		{
			text = text.replace(new RegExp("(\r\n)", "gi"), "\n" );
			text = text.replace(new RegExp("(\r)", "gi"), "\n" );
			text = text.replace(new RegExp("(\n\n)", "gi"), "\n" );
			var buff:Array=text.split( "\n" );
			
			for ( var k:int=buff.length - 1; k >= 0; k-- )
			{
				var str:String=buff[k];
				
				if ( str.length>0 && str.indexOf( "#" )!=0 )
				{
					var len:int = str.indexOf("=");
					
					var arr:Array = [str.substr(0, len), str.substr(len+1)];
					_TextMap[arr[0]]=arr[1];
				}
			}
		}
		override protected function Store( fileName:String, xml:XML ):void {
			AddText( xml.toString() );
//			var key:String;
//			var list:XMLList = xml.HyperText;
//			for( var i:int=0; i<list.length(); i++ ){
//				var hyperText:XML = list[i];
////				var htParser:HyperText = new HyperText();
////				htParser.Parse( hyperText );
//				key = hyperText.@ident.toString();
//				if( _pHyperCache[ key ] ) {
//					Debugger.Error("HyperText key double:"+key);
//				}
//				_pHyperCache[ key ] = hyperText;
//			}
//			
//			list = xml.SimpleText;
//			for( var j:int=0; j<list.length(); j++ ){
//				var simpleText:XML = list[j];
////				var stParser:SimpleText = new SimpleText();
////				stParser.Parse( simpleText );
//				key = simpleText.@ident.toString();
//				if( _pSimpleCache[ key ] ) {
//					Debugger.Error("SimpleText key double:"+key);
//				}
//				_pSimpleCache[ key ] = simpleText;
//			}
			
//			XML.ignoreWhitespace = true;
		}
		protected var _pHyperCache:Dictionary = new Dictionary();
		protected var _pSimpleCache:Dictionary = new Dictionary();

		public function GetText( ident:String ):IText
		{
			var str:String=_TextMap[ident];
			if( str ) {
				var ht:HyperText = new HyperText();
				ht.Parse(str);
				return ht;
			}
//			var xml:XML = _pHyperCache[ ident ];
//			if( xml ) {
//				var htParser:HyperText = new HyperText();
//				htParser.Parse( xml );
//				return htParser;
//			}
//			xml = _pSimpleCache[ident];
//			if( xml ) {
//				var st:SimpleText = new SimpleText();
//				st.Parse( xml );
//				return st;
//			}
			Debugger.Error("[text]" + ident + " not found.");
			return null;
		}
		
		public function Clear():void {
			for( var key:String in _pHyperCache ) {
				_pHyperCache[key] = null;
			} 
			_pHyperCache = new Dictionary();
			for( var key2:String in _pSimpleCache ) {
				_pSimpleCache[key2] = null;
			} 
			_pSimpleCache = new Dictionary();
		}
	}
}