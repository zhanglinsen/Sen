package  project.core.global
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Stage;
    import flash.external.ExternalInterface;
    import flash.utils.escapeMultiByte;
    
    import project.core.utils.HtmlUtils;

    public final class GlobalVariables
    {
		public static var DefaultHost:String = "";
		public static function Init():void {
			Protocol = ExternalInterface.call( "function getURL(){return window.location.protocol + '//';}" );
			UrlParams = HtmlUtils.GetParams();
			
			var url:String = ExternalInterface.call( "function getURL(){return window.location.href;}" );
			url = url.substr( 0, url.lastIndexOf("/") );
			GameUrl = url;
		}
		
		public static function get StageWidth():int {
			return CurrStage.stageWidth;
		}
		public static function get StageHeight():int {
			return CurrStage.stageHeight;
		}
		
		/**背景动画开关*/
        public static var BgAniOn:Boolean = true;
        /**
         * 当前程序使用的Stage
         */
        public static var CurrStage:Stage;
		/**默认字体*/
		public static var Font:String = "";
		/**默认字体大小*/
		public static var FontSize:int = 12;
		/**游戏地址*/
        public static var GameUrl:String;
		/**防沉迷提交地址*/
        public static var IndulgePostUrl:String;
		
        public static var InitGeneralID:int = 511;
		/**是否第一次进入游戏*/
        public static var IsFirst:Boolean = false;
		/**是否加密通讯*/
        public static var IsSave:Boolean=true;
		/**日志等级,NONE:0,INFO:1,ERROR:2,DEBUG:3*/
        public static var LogLevel:int = 0;
		/**登录背景目录*/
        public static var Logo:String;
        /**
         * 已登陆
         */
        public static var Logon:Boolean = false;
		/**官网地址*/
        public static var MainSite:String;
		/**等级开放限制,0不限制*/
		public static var MaxLevel:int = 0;
		/**
		 * 模块与资源配置
		 */
		public static var ModAndResConfig:XML;
		/**关服提示信息*/
        public static var Msg:String;
		/**登录平台*/
        public static var Platform:String = "";
		/**是否在登录前先跟服务器请求连接*/
        public static var PreAsk:String = "";
		/**浏览网页使用的协议:http,https*/
        public static var Protocol:String;
		/**战报地址*/
        public static var ReportUrl:String;
		/**资源加载地址列表*/
        public static var ResHostList:Array = [];
        /**
         * 当前程序的顶层窗口
         */
        public static var Root:DisplayObjectContainer;
        public static var RootParent:DisplayObjectContainer;
		/**
		 * 服务器配置
		 */
		private static var _ServerConfig:XML;
		public static function get ServerConfig():XML {
			return _ServerConfig;
		}
		private static function MakeUrl(url:String, defaultUrl:String=null):String {
			if( url.length==0 || url.charAt(0)=="/" ) {
				if( !defaultUrl ) {
					return url;
				}
				url = defaultUrl + url;
			}
			if( url.length>0 && url.indexOf( "://" )==-1 ) {
				url = Protocol + url;
			}
			return url;
		}
		public static function set ServerConfig( xml:XML ):void {
			_ServerConfig = xml;
			if( UrlParams.lang ) {
				Lang = UrlParams.lang;
			} else {
				var lng:String = ServerConfig.@lang;
				if( !lng ) {
					lng = "zh_CN";
				}
				Lang = lng;
			}
			Logo = xml.@logo;
			MaxLevel = xml.@maxLv;
			if(!Logo) {
				Logo = Lang;
			}			
			
			
			WelcomeMsg = xml.Main.@welcome;
			MainSite = MakeUrl(xml.Main.@url, GameUrl);
			LoginUrl = MakeUrl(xml.Main.@loginUrl, MainSite);
			PayUrl = MakeUrl(xml.Pay.@url, MainSite);
			IndulgeUrl = MakeUrl(xml.Indulge.@url);
			IndulgePostUrl = MakeUrl(xml.Indulge.@postUrl);
			
			
			var custom:Boolean = false;
			var resHost:String = "";
			if( UrlParams.d_l && int(UrlParams.d_l)==3 ) {
				//调试版可指定ip
				var host:String = UrlParams.host;
				if( host ) {
					custom = true;
					
					LogLevel = 3;
					Msg = "";
					ReportUrl = MakeUrl( UrlParams.report, GameUrl );
					ServerHost = host;
					var port:String = UrlParams.port ? UrlParams.port : "9118,443";
					ServerPortList = port.split(",");
					
					resHost = UrlParams.res ? UrlParams.res : "";
					
					if( UrlParams.save=='0') {
						IsSave = false;
					}
					if( UrlParams.platform ) {
						Platform = UrlParams.platform;
					}
					if( UrlParams.preask ) {
						PreAsk = UrlParams.preask;
					}
				}
			}
			if(!custom ) {
				
				var cfg:XMLList;
				
				if( UrlParams.server ) {
					cfg = xml.Server.(@name==UrlParams.server);
				}
				if(!cfg || cfg.length()==0) {
					cfg = xml.Server.(@name==xml.@defaultServer.toString());
				}
				
				if( cfg.@save.toString()=="0" ) {
					IsSave = false;
				}
				PreAsk = cfg.@preask;
				Platform = cfg.@platform;
				LogLevel = UrlParams.d_l ? UrlParams.d_l : cfg.@log;
				Msg = cfg.@msg;
				ReportUrl = MakeUrl( cfg.@report, GameUrl );
				ServerHost = cfg.@host;			
				ServerPortList = cfg.@port.toString().split(",");
				resHost = cfg.@resHost.toString();
			}
			//			ServerPort = cfg.@port;
			//			ServerPort2 = cfg.@port2;			
			
			if(!resHost) {
				resHost = GameUrl;
			} else {
				resHost += ","+GameUrl;
			}
			var res:Array = resHost.split(",");
			for( var k:int=0; k<res.length; k++ ) {
				if( res[k].charAt(res[k].length-1)!="/" ) {
					res[k] += "/";
				}
				ResHostList.push( MakeUrl(res[k], GameUrl) );
			}
		}
//        public static var SameClick:int = 0;
        /**
         * 服务端IP
         */
        public static var ServerHost:String;
		/**服务器ID*/
        public static var ServerID:String = "";
		/**服务器端口*/
        public static var ServerPortList:Array = [];
		/**词间是否有空格，如中文没有，英文，越南文有*/
        public static var Space:String = "";
		/**URL传递的参数集*/
        public static var UrlParams:Object;
		/**欢迎信息*/
        public static var WelcomeMsg:String;
		/**防沉迷地址*/
        private static var _IndulgeUrl:String;
		/**语言是否中文*/
        private static var _IsChinese:Boolean = true;
		/**语言是否日文*/
        private static var _IsJapanese:Boolean = false;
		/**是否韩文**/
		private static var _IsKorea:Boolean = false;
		/**语言是否都为字母，注音之类的*/
        private static var _IsLetter:Boolean = false;
		/**是否是英语**/
		private static var _IsEnglish:Boolean = false;
		/**是否印尼语**/
		private static var _IsIndonesia:Boolean = false;
		/**语言*/
        private static var _Lang:String;
		/**登录跳转地址*/
        private static var _LoginUrl:String;
		/**充值地址*/
        private static var _PayUrl:String;
		/**读取第几个资源地址*/
        private static var _ResIdx:int=0;

        public static function FormatUrl( url:String ):String
        {
//			var str:String = "";
            url = url.replace( "<qid>", "{accid}" ).replace( "<server_id>", "{serverid}" );
            var keys:Array = ["accid", "serverid", "accname"];

            for ( var i:int=0; i<keys.length; i++ )
            {
                if ( url.indexOf( "{"+keys[ i ]+"}" )!=-1 )
                {
					var val:String = UrlParams[ keys[i]];
					val = escapeMultiByte(val);
//					str += UrlParams[keys[i]];
                    url = url.replace( "{"+keys[ i ]+"}", val);
                }
            }
//			var tick:String = Utility.HashTick( str + "1" + SECURITY_TICKET);
//			if( url.indexOf("{md5}") ) {
//				url = url.replace( "{md5}", tick );
//			}
            return url;
        }
		
		public static var ResImageFolder:String;
		public static var ResSoundFolder:String;
		
		/**获取资源图片的路径*/
		public static function GetResourcePath( path:String ):String
		{
			return ResHost + ResImageFolder + path;
		}
		/**获取声音的路径*/
		public static function GetSoundPath( path:String ):String
		{
			return ResHost + ResSoundFolder + path;
		}

        public static function get IndulgeUrl():String
        {
            return FormatUrl( _IndulgeUrl );
        }

        public static function set IndulgeUrl( val:String ):void
        {
            _IndulgeUrl = val;
        }

        public static function get IsChinese():Boolean
        {
            return _IsChinese;
        }

        public static function get IsJapanese():Boolean
        {
            return _IsJapanese;
        }
		
		public static function get IsKorea():Boolean
		{
			return _IsKorea;
		}

        public static function get IsLetter():Boolean
        {
            return _IsLetter;
        }
		
		public static function get IsIndonesia():Boolean
		{
			return _IsIndonesia;
		}
		
		public static function get IsEnglish():Boolean
		{
			return _IsEnglish;
		}

        public static function get Lang():String
        {
            return _Lang;
        }

        public static function set Lang( val:String ):void
        {
            _Lang = val;
            _IsLetter = val!="zh_TW" && val!="zh_CN" && val!="ja_JP" && val!="ko_KR" && val!="debug";

            if ( val!="zh_TW" && val!="zh_CN" && val!="debug" )
            {
                Space = " ";
                _IsChinese = false;
                _IsJapanese = val=="ja_JP";
				_IsKorea = val == "ko_KR";
				_IsIndonesia = val == "id_ID";
				_IsEnglish = val == "en_US";
            }
            else
            {
                _IsChinese = true;
            }
			switch( val ) {
				case "debug":
				case "zh_CN":
				case "zh_TW":
					Font = "宋体";
					break;
				case "ja_JP":
					Font = "MS Gothic";
					break;
				case "th_TH":
					FontSize = 11;
					Font = "Microsoft Sans Serif";
					break;
//				case "ko_KR":
//					Font = "dotumche";
//					break;
				case "en_US":
					FontSize = 9;
					Font = "Tahoma";
					break;
				default:
					FontSize = 11;
					Font = "Tahoma";
					break;
			}
			if(_ServerConfig) {
				var font:String = _ServerConfig.@font;
				var size:int = _ServerConfig.@fontsize;
				if( size>0 ) {
					FontSize = size;
				}
				if( font ) {
					Font = font;
				}
			}
        }

        public static function get LoginUrl():String
        {
            return FormatUrl( _LoginUrl );
        }

        public static function set LoginUrl( val:String ):void
        {
            _LoginUrl = val;
        }

        public static function NextResHost():void
        {
            _ResIdx++;
        }

        public static function get PayUrl():String
        {
            return FormatUrl( _PayUrl );
        }

        public static function set PayUrl( val:String ):void
        {
            _PayUrl = val;
        }

        public static function get ResHost():String
        {
            if ( _ResIdx>=ResHostList.length )
            {
                _ResIdx = 0;
            }
            return ResHostList[_ResIdx];
        }
    }
}