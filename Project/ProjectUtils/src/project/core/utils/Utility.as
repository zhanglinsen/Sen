package project.core.utils
{
    import com.hurlant.crypto.hash.MD5;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.IBitmapDrawable;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.net.SharedObject;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    
    import project.core.global.GlobalVariables;

    public final class Utility
    {
		
		private static var _Restrict:String;
		
		/**
		 * 获取可输入文字的限制
		 * @param ext 增加限制
		 * @return 
		 */
		public static function GetRestrict( ext:String="" ):String {
			if( !_Restrict ) {
				//				var U_0FFF:String = "\u0021-\u007e\u00A1-\u0233\u0250-\u02A8\u0386\u0388\u0389\u038A\u038C\u038E-\u03A1\u03A3-\u03F6\u0400-\u0486\u0490-\u04C4\u04C7\u04C8\u04CB\u04CC\u04D0-\u04EB\u04EE-\u04F5\u04F8\u04F9\u0531-\u0556\u0559-\u055F\u0561-\u0586\u0589\u05D0-\u05F4\u060C\u061B\u061F\u0621-\u063A\u0640-\u0652\u0660-\u066C\u0670-\u06B0\u06BA-\u06BE\u06c0-\u06CE\u06D0-\u06D5\u06F0-\u06F9\u0E00-\u0E36\u0E3F-\u0E46\u0E4F-\u0E5B";
				var U_0FFF:String = "\u00A1-\u06F9\u0E01-\u0E5B";
				var U_1FFF:String = "\u10A0-\u1ffe";
				var U_2FFF:String = "\u2100-\u237A";
				var cn:String = "\u2E80-\u9Fa5\uA000-\uA4FF\uAC00-\uFFE6";
				//\uAA00-\uAB2F
				_Restrict = "[,_0-9a-zA-Z " + ext + U_0FFF + U_1FFF + U_2FFF + cn + "]";
			}
			return _Restrict;
		}
		/**
		 * 按照字节长度截取字符串
		 * 如果bytesLen为3,val为两个中文，则会截取第一个中文返回
		 * 截取的字符串长度不会超过bytesLen
		 * <pre>
		 * 	CutString( "my name is abc.", 13, true ); //"my name is";
		 * 	CutString( "my name is abc.", 13, false );//"my name is ab";
		 * </pre>
		 * @param val 字符串
		 * @param bytesLen 字节长度
		 * @param wordIntact 是否保存完整单词。<br/>
		 * 	在英文之类的拉丁字母语言中，按照空格分隔单词，如果单词超过字节长度，则整个单词不保留。<br/>
		 * @return 
		 */
		public static function CutString( val:String, bytesLen:int, wordIntact:Boolean=false ):String {
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte(val, "gbk");
			var cnt:int = bytes.length-bytesLen;
			if( cnt>0 ) {
				var arr:Array = val.split(" ");
				if( wordIntact && arr.length>1 ) {
					arr.pop();
					return CutString( arr.join(" "), bytesLen );
				} else {
					if( val.length==bytes.length ) {
						//全单字节的内容
						val = val.substr( 0, val.length-cnt);
					} else {
						var len:int = Math.ceil(cnt * 0.5);
						return CutString( val.substr(0, val.length-len), bytesLen );
					}
				}
			}
			return val;
		}
		/**
		 * 格式化时间
		 * @param second 秒
		 * @param format 时间格式 ，默认是返回 hh:mm:ss,天:dd,小时:hh,分:mm,秒:ss
		 * @param showZeroHour 小时为0是否显示，如果显示则返回 00:mm:ss,否则返回 mm:ss
		 * @return 
		 */
		public static function FormatTime(second:uint, format:String="hh:mm:ss", showZeroHour:Boolean=false):String
		{
			var hour:int=int(second / 3600);
			second=second % 3600;
			var minute:int=int(second / 60);
			second=second % 60;
			
			if( format=="hh:mm:ss" ) {
				var m:String = minute.toString();
				var s:String = second.toString();
				if( m.length==1 ) {
					m = "0" + m;
				}
				if( s.length==1 ) {
					s = "0" + s;
				}
				var h:String = "";
				if( hour>0 ) {
					h = hour + ":";
				}
				if( showZeroHour ) {
					if( h.length==0 ) {
						h = "00:";
					} else if( h.length==2 ) {
						h = "0" + h;
					}
				}
				return h +  m + ":" + s;
			}
			var day:int;
			var fmt:String;
			var params:Array = [];
			if( hour<24 ) {
				if( hour>0 ) {
					format = format.substr( format.indexOf( "hh" ) );
//					fmt = "common.fmt.dt.hhmmss";
//					params.push( hour );
//					params.push( minute );
//					params.push( second );
				} else if(minute>0){
					format = format.substr( format.indexOf( "mm" ) );
//					fmt = "common.fmt.dt.mmss";
//					params.push( minute );
//					params.push( second );
				} else {
					format = format.substr( format.indexOf( "ss" ) );
//					fmt = "common.fmt.dt.ss";
//					params.push( second );
				}
			} else {
				day = int(hour/24);
				hour = int(hour%24);
//				fmt = "common.fmt.dt.ddhhmmss";
//				params.push( int(hour/24) );
//				params.push( int(hour%24) );
//				params.push( minute );
//				params.push( second );
			}
			return format.replace("dd", day).replace("hh", hour).replace("mm",minute).replace("ss",second);
//			return XmlUtils.GetText(fmt, {DynamicString:params});
		}
		/**
		 * 去掉字符串前后空格
		 * @param str
		 * @return 
		 */
		public static function TrimString( str:String ):String {
			return str.replace( /^\s+|\s+$/g, "" );
		}
		/**
		 * 填充字符
		 * <pre>
		 * FillString( "ffcc", 6, "0", false );//00ffcc
		 * FillString( "ffcc", 6, "0", true )://ffcc00
		 * </pre>
		 * @param str 原字符串
		 * @param len 将str填充到指定的长度
		 * @param fillStr 填充的字符
		 * @param fillAfter 是否填充在原字符串的最后，否则填充在前端
		 * 
		 * @return 
		 */
		public static function FillString( str:String, len:int, fillStr:String, fillAfter:Boolean=false ):String {
			var cnt:int = len-str.length;
			for( var i:int=0; i<cnt; i++ ) {
				if( fillAfter ) {
					str += fillStr;
				} else {
					str = fillStr + str;
				}
			}
			return str;
		}
		
		/**
		 * 
		 * @param str
		 * @param params
		 * @return 
		 */
		public static function GetFormatString( str:String, ... params ):String {
			var arr:Array = str.match(/{\d+}/ig);
			if( arr ) {
				for( var i:int=0; i<arr.length; i++ ) {
					var idx:int = int(arr[i].match(/\\d+/ig)[0]);
					str = str.replace( arr[i], params[idx] );
				}
			}
			return str;
		}
		/**
		 * 屏幕截图
		 * @param obj 要截取的对象
		 * @param clipRect 截取的范围
		 * @return 截取后的图象
		 */
		public static function ScreenShot( obj:DisplayObject, clipRect:Rectangle):Bitmap {
			var bd:BitmapData = new BitmapData( obj.width, obj.height, true, 0 );
			bd.draw( obj, null , null, null, clipRect );
			
			var bd2:BitmapData = new BitmapData( clipRect.width, clipRect.height, true, 0 );
			bd2.copyPixels( bd, clipRect, new Point() );
			
			return new Bitmap(bd2);
		}
        private static var idCard_CN:Object = {11:"北京",12:"天津",13:"河北",14:"山西",15:"内蒙古",21:"辽宁",22:"吉林",23:"黑龙江",31:"上海",32:"江苏",33:"浙江",34:"安徽",35:"福建",36:"江西",37:"山东",41:"河南",42:"湖北",43:"湖南",44:"广东",45:"广西",46:"海南",50:"重庆",51:"四川",52:"贵州",53:"云南",54:"西藏",61:"陕西",62:"甘肃",63:"青海",64:"宁夏",65:"新疆",71:"台湾",81:"香港",82:"澳门",91:"国外"};

        /**
         * 
         * @param dict
         */
        public static function ClearDict( dict:Dictionary ):void
        {
            for ( var key:* in dict )
            {
                dict[key] = null;
            }
            dict = new Dictionary();
        }


        /**
         * 
         * @param fmt
         * @return 
         */
        public static function CloneTextFormat( fmt:TextFormat ):TextFormat
        {
            return new TextFormat( fmt.font?fmt.font:GlobalVariables.Font, fmt.size?fmt.size:GlobalVariables.FontSize, fmt.color, fmt.bold, fmt.italic, fmt.underline, fmt.url, fmt.target, fmt.align, fmt.leftMargin, fmt.rightMargin, fmt.indent, fmt.leading );
        }

        /**
         * 
         * @param fmt
         * @param toFmt
         * @return 
         */
        public static function CloneTextFormatTo( fmt:TextFormat, toFmt:TextFormat ):TextFormat
        {
            toFmt = CloneTextFormat( toFmt );

            if ( fmt==null )
            {
                return toFmt;
            }

            if ( fmt.font )
            {
                toFmt.font = fmt.font;
            }

            if ( fmt.size )
            {
                toFmt.size = fmt.size;
            }

            if ( fmt.color )
            {
                toFmt.color = fmt.color;
            }

            if ( fmt.bold )
            {
                toFmt.bold = fmt.bold;
            }

            if ( fmt.italic )
            {
                toFmt.italic = fmt.italic;
            }

            if ( fmt.underline )
            {
                toFmt.underline = fmt.underline;
            }

            if ( fmt.url )
            {
                toFmt.url = fmt.url;
            }

            if ( fmt.target )
            {
                toFmt.target = fmt.target;
            }

            if ( fmt.align )
            {
                toFmt.align = fmt.align;
            }

            if ( fmt.leftMargin )
            {
                toFmt.leftMargin = fmt.leftMargin;
            }

            if ( fmt.rightMargin )
            {
                toFmt.rightMargin = fmt.rightMargin;
            }

            if ( fmt.indent )
            {
                toFmt.indent = fmt.indent;
            }

            if ( fmt.leading )
            {
                toFmt.leading = fmt.leading;
            }
            return toFmt;
        }

        /**
         * 
         * @param value
         * @return 
         */
        public static function Copy( value:Object ):Object
        {
            var buffer:ByteArray = new ByteArray();
            buffer.writeObject( value );
            buffer.position = 0;
            var result:Object = buffer.readObject();
            return result;
        }

        /**
         * 
         * @param dict
         * @return 
         */
        public static function DictValues( dict:Dictionary ):Array
        {
            var temp:Array = [];

            for each ( var val:* in dict )
            {
                temp.push( val );
            }
            return temp;
        }


        /**
         * 取文件名
         * @url 路径
         * @includeExt 是否包含扩展名
         */
        public static function GetFileName( url:String, includeExt:Boolean = false ):String
        {
            if ( !url )
            {
                return "";
            }
            var idx:int = url.lastIndexOf( "/" );

            if ( idx==-1 )
            {
                idx = url.lastIndexOf( "\\" );
            }

            if ( idx==-1 )
            {
                idx=0;
            }
            else
            {
                idx++;
            }
            url = url.substring( idx );

            if ( !includeExt )
            {
                idx = url.lastIndexOf( "." );

                if ( idx==-1 )
                {
                    idx=url.length;
                }
                url = url.substring( 0, idx );
            }
            return url;
        }

        /**
         * 
         * @param container
         * @return 
         */
        public static function GetMouseOverObject( mouseX:Number, mouseY:Number, container:DisplayObjectContainer ):DisplayObject
        {
            var tmp:DisplayObject;
            var p:Point = new Point( mouseX, mouseY );
            var local:Point;

            for ( var i:int = container.numChildren - 1; i >= 0; i-- )
            {
                tmp = container.getChildAt( i );

                if ( tmp == null || !tmp.visible )
                {
                    continue;
                }
                local = tmp.globalToLocal( p );

                if ( tmp.hitTestPoint( local.x, local.y ))
                {
                    return tmp;
                }
                tmp = null;
            }
            return null;
        }

        /**
         * 
         * @param tick
         * @return 
         */
        public static function HashTick( tick:String ):String
        {
            var src:ByteArray = new ByteArray();
            src.writeUTFBytes( tick );

            src = new MD5().hash( src );
            src.position = 0;
            src.endian = Endian.BIG_ENDIAN;
            var ticket:String = "";

            while ( src.bytesAvailable )
            {
                var t:String = src.readUnsignedInt().toString( 16 );
                ;
                ticket+=Utility.FillString( t, 8, "0" );
            }
            return ticket;
        }
        /**
         * 
         * @param sId
         * @return 
         */
        public static function IsIdCard( sId:String ):int
        {
            var iSum:int=0;
            var info:String="";

            var reg:RegExp = /^\d{17}(\d|x)$/i;

            if ( !reg.test( sId ))
            {
                return 1;
            }
            sId=sId.replace( /x$/i, "a" );

            if ( !idCard_CN[sId.substr( 0, 2 )])
            {
                return 2;
            }
//			var list:XMLList = idCardXml.Type.(@ident==parseInt( sId.substr( 0, 2 )));
//            if ( list.length()==0 )
//            {
//                return 2;
//            }
            var sBirthday:String = sId.substr( 6, 4 )+"-"+Number( sId.substr( 10, 2 ))+"-"+Number( sId.substr( 12, 2 ));
            var d:Date =new Date( sBirthday.replace( /-/g, "/" )) ;

            if ( sBirthday!=(d.getFullYear()+"-"+ (d.getMonth()+1) + "-" + d.getDate()))
            {
                return 3;
            }

            for ( var i:int = 17; i>=0; i -- )
            {
                iSum += (Math.pow( 2, i ) % 11) * parseInt( sId.charAt( 17-i ), 11 );
            }

            if ( iSum%11!=1 )
            {
                return 4;
            }
            return 0;
        }

        /**
         * 将文字转为竖向
         * @param width 新对象的宽
         * @param height 新对象的高
         * @param str 文本内容
         * @param fmt 文本格式
         * @param textColor 文本颜色
         * @param bg 旋转后合成的背景，可为空
         */
        public static function MixVerText( width:Number, height:Number, str:String, fmt:TextFormat, textColor:uint, bg:IBitmapDrawable = null, filters:Array = null ):DisplayObject
        {
            var txt:TextField = new TextField();
            txt.defaultTextFormat = fmt;
            txt.textColor = textColor;
            txt.text = str;
            txt.width = txt.textWidth + 3;
            txt.height = txt.textHeight + 3;
            txt.filters = filters;
            var bd:BitmapData = new BitmapData( txt.width, txt.height, true, 0 );
            bd.draw( txt );
            var b:Bitmap = new Bitmap( bd );

            var mat:Matrix = new Matrix();
            mat.rotate( 90*( Math.PI/180 ));
            var ox:int = (GlobalVariables.IsChinese) ? 2 : 1;

            switch ( fmt.align )
            {
                case TextFormatAlign.CENTER:
                    mat.translate( txt.height-ox+0.5*( width-bd.height ), 0.5*( height-bd.width ));
                    break;
                case TextFormatAlign.LEFT:
                    mat.translate( txt.height-ox+0.5*( width-bd.height ), 0 );
                    break;
                case TextFormatAlign.RIGHT:
                    mat.translate( txt.height-ox+0.5*( width-bd.height ), height-bd.width );
                    break;
            }
            var bd2:BitmapData = new BitmapData( width, height, true, 0 );

            if ( bg )
            {
                bd2.draw( bg );
            }
            bd2.draw( b, mat );

            bd.dispose();
            return new Bitmap( bd2 );
        }

        /**
         * 将xml文件中的文本格式转为TextFormat对象
         * @node xml节点
         * @fmt 以默认样式为基础修改node节点设置的样式
         */
        public static function ParseTextFormat( node:XML, fmt:TextFormat = null ):TextFormat
        {
            var customFmt:Boolean = false;
            var defaultFmt:TextFormat;

            if ( fmt==null )
            {
                defaultFmt = new TextFormat( GlobalVariables.Font, GlobalVariables.FontSize, 0xffffff, false, false, false, null, null, TextFormatAlign.LEFT );
                defaultFmt.leading = 3;
            }
            else
            {
                defaultFmt = CloneTextFormat( fmt );
            }

            if ( node.@leading.toString())
            {
                customFmt = true;
                defaultFmt.leading = node.@leading;
            }

            if ( node.@font.toString())
            {
                customFmt = true;
                defaultFmt.font = node.@font;
            }

            if ( node.@size.toString())
            {
                customFmt = true;
                defaultFmt.size = node.@size;
            }

            if ( node.@color.toString())
            {
                customFmt = true;
                defaultFmt.color = node.@color;
            }

            if ( node.@bold == 'true' )
            {
                customFmt = true;
                defaultFmt.bold = node.@bold;
            }

            if ( node.@italic == 'true' )
            {
                customFmt = true;
                defaultFmt.italic = node.@italic;
            }

            if ( node.@underline == 'true' )
            {
                customFmt = true;
                defaultFmt.underline = node.@underline;
            }

            if ( node.@align.toString())
            {
                customFmt = true;
                defaultFmt.align = node.@align;
            }

            if ( customFmt )
            {
                return defaultFmt;
            }
            return fmt;
        }

    }
}