package project.core.reader
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import project.core.entity.ResourceData;
	import project.core.entity.StreamRequestInfo;
	import project.core.loader.ClassLoader;

	/**
	 * MovieClip数据解析器
	 */
	public class MovieClipDataReader implements IStreamReader
	{
		public function ReadStream( stream:URLStream, reqInfo:StreamRequestInfo ):String
		{
			var res:ResourceData = new ResourceData();
			var bytes:ByteArray = new ByteArray();
			stream.readBytes( bytes );
			ClassLoader.Instance.LoadClass( bytes );
			return null;
		}
	}
}