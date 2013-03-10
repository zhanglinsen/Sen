package project.core.reader
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import project.core.entity.StreamRequestInfo;

	/**
	 * 流数据读取接口
	 */
	public interface IStreamReader
	{
		
		/**
		 * 从数据流中读取数据
		 * @stream 数据流
		 * @reqInfo 请求信息
		 */
		function ReadStream( stream:URLStream, reqInfo:StreamRequestInfo ):String;
	}
}