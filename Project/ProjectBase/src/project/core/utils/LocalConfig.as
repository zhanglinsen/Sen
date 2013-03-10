package project.core.utils
{
	import flash.net.SharedObject;

	public class LocalConfig
	{
		
		public static function Init( sharedKey:String ):void {
			_SharedObj = SharedObject.getLocal( sharedKey, "/" );
		}
		private static var _SharedObj:SharedObject;
		/**
		 * 
		 * @param key
		 * @return 
		 */
		public static function Get( key:String ):*
		{
			if ( _SharedObj )
			{
				return _SharedObj.data[key];
			}
			return null;
		}
		
		/**
		 * 
		 * @param key
		 * @param val
		 */
		public static function Save( key:String, val:* ):void
		{
			if ( _SharedObj && _SharedObj.data[key]!=val )
			{
				_SharedObj.data[key] = val;
				_SharedObj.flush();
			}
		}
	}
}