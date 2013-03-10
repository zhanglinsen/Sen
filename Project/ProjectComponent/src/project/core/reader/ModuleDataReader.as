package project.core.reader
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import project.core.entity.StreamRequestInfo;
	import project.core.loader.ClassLoader;

	/**
	 * 模块数据解析器
	 */
	public class ModuleDataReader extends AbstractDataReader
	{
		public function ModuleDataReader()
		{
			super();

		}

		override public function ReadStream( stream:URLStream, reqInfo:StreamRequestInfo ):String
		{
			var bytes:ByteArray = new ByteArray();
			//添加swf前三个字节
			bytes.writeByte( 0x43 );
			bytes.writeByte( 0x57 );
			bytes.writeByte( 0x53 );
			ReadConfusionStream( stream, stream.bytesAvailable, bytes, int( reqInfo.Version.substr(reqInfo.Version.lastIndexOf(".")+1)));
			ClassLoader.Instance.LoadClass( bytes );
			
			return null;
		}
	}
}