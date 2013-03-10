package project.core.reader
{
	import flash.utils.Dictionary;
	
	/**
	 * XML数据解析器
	 */
	public class XmlDataReader extends AbstractXmlDataReader
	{
		override protected function Store( fileName:String, xml:XML ):void {
			_pXmlMap[fileName.toLowerCase()] = xml;
		}
		protected var _pXmlMap:Dictionary = new Dictionary();

		public function GetXml( fileName:String ):XML
		{
			var xml:XML =  _pXmlMap[ fileName.toLowerCase() ];
			if( !xml ) {
				trace("[xml]" + fileName + " not found.");
			}
			return xml;
		}
		
		public function Keys():Array {
			var list:Array = [];
			for( var key:String in _pXmlMap ) {
				list.push( key );
			}
			return list;
		}
		
		public function Clear():void {
			for( var key:String in _pXmlMap ) {
				_pXmlMap[key] = null;
			} 
			_pXmlMap = new Dictionary();
		}
	}
}