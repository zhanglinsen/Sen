package project.core.reader
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import project.core.entity.StreamRequestInfo;
	import project.core.global.GlobalVariables;
	
	/**
	 * XML数据解析器
	 */
	public class AbstractXmlDataReader extends AbstractDataReader
	{
		override public function ReadStream( stream:URLStream, reqInfo:StreamRequestInfo ):String
		{
			if( !reqInfo.IsConfusion ) {
				var xbytes:ByteArray = new ByteArray();
				stream.readBytes( xbytes, 0, len );
				xbytes.position = 0;
				Store( reqInfo.FileName, new XML( xbytes ) );
				return null;
			}
			while( stream.bytesAvailable>0 ) {
				var len:int = stream.readInt();
				var fileName:String;
				if( len==0 ) {
					fileName = reqInfo.FileName.replace("_"+GlobalVariables.Lang,"");
					len = stream.bytesAvailable;
				} else {
					var nameBytes:ByteArray = new ByteArray();
					stream.readBytes( nameBytes, 0, len );
					nameBytes.uncompress();
					nameBytes.position = 0;
					fileName = nameBytes.readMultiByte( nameBytes.length, 'gbk' );
					len = stream.readInt();
				}
				var mixCount:int;
				if( reqInfo.Version ) {
					mixCount = int( reqInfo.Version.substr(reqInfo.Version.lastIndexOf(".")+1));
				} else {
					var urlParts:Array = reqInfo.Url.replace("_"+GlobalVariables.Lang,"").split( "/" );
					mixCount = urlParts[ urlParts.length-1 ].indexOf( "." );
				}
//				var bytes:ByteArray = this.ReadCompressStream(stream,len,mixCount);
//				var xml:String = bytes.readUTFBytes(bytes.length);
				Store( fileName, new XML( ReadCompressStream(stream,len,mixCount) ) );
				
//				bytes.uncompress();
//				bytes.position = 0;
//				var str:String = bytes.readMultiByte( bytes.length, 'utf-8' );
//				Store( fileName, new XML( bytes ) );
			}
			return null;
		}
		
		protected function Store( fileName:String, xml:XML ):void {
			
		}
	}
}