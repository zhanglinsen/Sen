package project.core.reader
{
	import apparat.lzma.LZMADecoder;
	
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import project.core.entity.StreamRequestInfo;
	
	/**
	 * 混殽数据解析器
	 */
	public class AbstractDataReader implements IStreamReader
	{

		/**
		 * 从数据流中读取数据
		 * @stream 数据流
		 * @bytes 读取数据存放的对象
		 * @params 混殽字节数(int)
		 */
		protected function ReadConfusionStream( stream:URLStream, len:int, bytes:ByteArray, mixCount:int ):void
		{
			var mixLimit:int = 10;
			var ubyte:int = mixCount % mixLimit + mixCount/mixLimit+mixLimit;
			var maxMix:uint = ubyte%(mixLimit*mixLimit);
			if(maxMix==0) {
				maxMix = 24;
			}

			var offset:int = bytes.length;
			mixCount = mixCount % maxMix;

			if ( mixCount <= 0 )
			{
				mixCount = maxMix;
			}
			stream.readBytes( bytes, offset, mixCount );
			var skipBytes:ByteArray = new ByteArray();
			stream.readBytes( skipBytes, 0, mixCount );
			
			stream.readBytes( bytes, mixCount+offset, len-mixCount*2-( maxMix -mixCount ));
			
			stream.readBytes( skipBytes, 0, maxMix - mixCount );
			bytes.position = 0;
		}
		protected function ReadCompressStream( stream:URLStream, len:int, mixCount:int ):ByteArray {
			var bytes:ByteArray = new ByteArray();
			bytes.writeByte(0x5D);
			bytes.writeByte(0x0);
			bytes.writeByte(0x0);
			bytes.writeByte(0x80);
			bytes.writeByte(0x0);
//				bytes.writeByte( 0x78 );
			
			ReadConfusionStream( stream, len, bytes, mixCount );
			var out:ByteArray = new ByteArray();
			var dec:LZMADecoder = new LZMADecoder();
			var i:int=0;
			var properties:Array = [];
			while (i < 5)
			{
				properties.push( bytes.readUnsignedByte() );
				i = (i + 1);
			}
			dec.setDecoderProperties( properties );
			var outSize:uint;
			var j:int=0;
			while (j < 8)
			{
				outSize = outSize | bytes.readUnsignedByte() << 8 * j;
				j++;
			}
			dec.code(bytes,out,outSize);
			out.position = 0;
			return out;
		}
		public function ReadStream( stream:URLStream, reqInfo:StreamRequestInfo ):String{
			return null;
		}
	}
}