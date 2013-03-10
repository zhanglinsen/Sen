package project.core.entity
{
	/**
	 * 数据请求信息
	 */
	public class StreamRequestInfo
	{
		public var UID:String;
		public var Folder:String;
		public var FileName:String;
		public var LabelVersion:String;
		public var Label:String;
		private var _Url:String;
		public function get Url():String {
			return _Url;
		}
		private var _ResHost:String = null;
		public function get ResHost():String {
			return _ResHost;
		}
		public function set ResHost( val:String ):void {
			if( _ResHost && _ResHost==val ) return ;
			_ResHost = val;
			_Url = ResHost + Folder + Suffix;
		}
		public var Custom:Boolean = false;
		public var Version:String;
		public var Suffix:String;
		/**
		 * 不缓存，每次都从服务上读取
		 */
		public var NoCache:Boolean;
		public var IsConfusion:Boolean = true;
		public var Type:String;
	}
}