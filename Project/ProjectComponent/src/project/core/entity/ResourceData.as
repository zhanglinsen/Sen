package project.core.entity
{
	/**
	 * 资源数据
	 */
	public class ResourceData
	{
		/**
		 * 资源内容，根据Type
		 * 1.BitmapData
		 * 2.ByteArray
		 * 3.Class
		 */
		public var Content:Object;
		public var Height:int;
		public var Width:int;
		public var Type:String;
	}
}