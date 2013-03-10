package project.core.utils
{
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	
	public final class HtmlUtils
	{
		
		/**
		 * 获取地址栏参数
		 */
		public static function GetParams():Object
		{
			var param:Object = new Object();
			
			var query:String = ExternalInterface.call( "function getURL(){return window.location.search;}" );
			
			var keys:Array = HtmlUtils.GetCookie("wly_key");
			var loginKey:String = "";
			for( var k:int=keys.length-1; k>=0; k-- ) {
				if( keys[k]!="eJwryUzOTi2xVUtMTs5MAVN5ibmptmolxSWJuQW2asVFZdmplbYAG/EORw%3d%3d" ) {
					loginKey = keys[k];
					break;
				}
			}
			
			loginKey = unescape(loginKey);
			//			var loginKey:String = loaderInfo.parameters.session;
			var bytes:ByteArray = Base64Decoder.decode( loginKey );
			bytes.uncompress();
			var vars:String = bytes.readMultiByte(bytes.length,"utf-8");
			if( !query ) {
				query = vars;
			} else {
				query = query.substr(1);
				query = vars + "&" + query;
			}
			if( query ) {	
				var pairs:Array = query.split( "&" );
				
				for ( var i:uint = 0; i < pairs.length; i++ )
				{
					var pos:int = pairs[i].indexOf( "=" );
					
					if ( pos != -1 )
					{
						var arg:String = pairs[i].substring( 0, pos ).toLowerCase();
						if( param[arg]!=null && arg!="server") {
							continue ;
						}
						var value:String = pairs[i].substring( pos+1 );
						param[arg] = value;
					}
				}
			}
			return param;
		}
		/**
		 * 获取cookie值 
		 */
		public static function GetCookie(key:String):Array {  
			if (!ExternalInterface.available) {  
				return [];  
			}  
			var cookieStr:String = ExternalInterface.call("function(){return window.document.cookie;}");
			var cookies:Array = [];
			if( cookieStr ) {
				var arr:Array = cookieStr.split(";");
				for( var i:int=0; i<arr.length; i++ ) {
					if( arr[i].indexOf( key+"=" )!=-1 ) {
						var offset:int = arr[i].indexOf("=")+1;
						cookies.push( arr[i].substr(offset) );
					}
				}
			}
			return cookies;            
		}  
		
		/**
		 * 将&lt;,&gt;,",'转义
		 */
		public static function HtmlFilter(value:String):String
		{
			if(value && value.length > 0)
			{
				return value.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&apos;").replace(/\n/g, "");
			}
			
			return value;
		}		
	}
}