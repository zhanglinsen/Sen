package project.editors.utils
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import mx.collections.Sort;
    import mx.collections.SortField;
    import mx.collections.XMLListCollection;
    import mx.controls.Alert;

    public class FileUtils
    {

        public static function GetFileName( url:String ):String
        {
			if( !url ) return "";
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
            return url.substring( idx );
        }
        public static function IsImage( ext:String ):Boolean
        {
            ext = ext.toLowerCase();
            return ext=="gif" || ext=="png" || ext=="jpg" || ext=="swf";
        }
		public static function IsSound( ext:String ):Boolean
		{
			ext = ext.toLowerCase();
			return ext=="wav" || ext=="mp3" || ext=="wma";
		}
		/**保存资源到本地*/
		public static function SaveStream( file:File, bytes:ByteArray ):Boolean {
			var fs:FileStream = new FileStream();
			
			try
			{
				fs.open( file, FileMode.WRITE );
				fs.writeBytes(bytes);
			}
			catch ( ex:Error )
			{
				Alert.show( file.nativePath + "目标文件无法写入，请稍候再试。\n"+ex.message );
				return false;
			}
			finally
			{
				fs.close();
			}
			return true;
		}
		public static function SaveFile( file:File, str:String ):Boolean {
			var fs:FileStream = new FileStream();
			
			try
			{
				fs.open( file, FileMode.WRITE );
				fs.writeUTFBytes( str );
			}
			catch ( ex:Error )
			{
				Alert.show( file.nativePath + "目标文件无法写入，请稍候再试。\n"+ex.message );
				return false;
			}
			finally
			{
				fs.close();
			}
			return true;
		}
		public static function SortAttrs( node:XML ):void {
			
			var attrs:XMLList = node.attributes();
			
			var sort:Sort = new Sort();
			sort.compareFunction = AttrCompare;
			var xlc:XMLListCollection = new XMLListCollection();
			xlc.sort = sort;
			xlc.source = attrs.copy();
			
			for( var k:int=0; k<attrs.length(); k++ ) {
				delete node.@[attrs[k].localName()];
			}
			for( var j:int=0; j<xlc.length; j++ ) {
				node.@[ xlc[j].localName() ] = xlc[j].toString();
			}
			
			var list:XMLList = node.elements();
			for( var i:int=0; i<list.length(); i++ ) {
				SortAttrs( list[i] );
			}
		}
		private static function AttrCompare(a:XML, b:XML, fields:Array = null):int {
			var val1:String = a.localName().toString().toLowerCase();
			var val2:String = b.localName().toString().toLowerCase();
			for( var i:int=0; i<val1.length; i++ ) {
				if( i>=val2.length ) {
					//a>b
					return 1;
				}
				var char1:Number = val1.charCodeAt(i);
				var char2:Number = val2.charCodeAt(i);
				if( char1==char2 ) {
					continue ;
				}
				if( char1>char2 ) {
					return 1;
				} else {
					return -1;
				}
			}
			//a<b
			return -1;
		};
        public static function SaveXml( file:File, xml:XML ):Boolean
        {
			SortAttrs( xml );
			var str:String = '<?xml version="1.0" encoding="UTF-8"?>'+xml.toXMLString();
//			if( !XML.prettyPrinting ) 
			{
//				trace( xml.replace( /\/>/ig, "/>\n\t" ).replace( /<\/[a-zA-Z0-9]{1,20}>/ig, "$&\n\t" ) );
				str = FormatXml(str);
			}
			
			if( !SaveFile( file, str ) ) {
				return false;
			}
			
//			if( file.nativePath.indexOf("zh_CN")!=-1 ){
//			
//				fs.open( file, FileMode.READ );
//				var newXml:XML = new XML( fs.readUTFBytes( fs.bytesAvailable ));
//				
//				fs.close();
//				if( newXml.name()!="Text" ) {
//					for( var i:int=0; i<LangList.length; i++ ) {
//						if( LangList[i].indexOf("zh")!=-1 ) continue;
//						_LangIdx = i;
//						var path:String = file.nativePath.replace("zh_CN", LangList[i]);
//						var toFile:File = new File( path );
//						if( toFile.exists ) {
//							var toXml:XML = GetXml(path);
//							if( toXml.@sync.toString()!="false" ) {
//								SyncAttr( newXml, toXml );
//								SyncNode( newXml, toXml );
//								SaveXml( toFile, toXml.toXMLString() );
//							}
//						} else {
//							SaveXml( toFile, xml );
//						}
//					}
//				}
//				_LangIdx = 0;
//			}
			
            return true;
        }
		public static function FormatXml(text:String):String
		{
			/*
			* 功能：去掉多余的空格
			* 
			* $0为正则表达式/(<\w+)(\s.*?>)/g匹配到的字符串
			* name为正则表达式(<\w+)匹配到的字符串
			* props为正则表达式(\s.*?>)匹配到的字符串
			*/
			text = '\n' + text.replace(/(<\w+)(\s.*?>)/g,function($0:*, name:*, props:*):*{
				//alert('$0='+$0+', name='+name+', props='+props);
				//alert(name + ' ' + props.replace(/\s+(\w+)/g," $1"));
				return name + props.replace(/\s+(\w+)/g," $1");
			}).replace(/>\s*?</g,">\n<");
			
			//把注释编码
			text = text.replace(/\n/g,'\r').replace(/<!--(.+?)-->/g,function($0:*, text:*):*
			{
//				var ret = '<!--' + escape(text) + '-->';
				//alert(ret);
				return '<!--' + escape(text) + '-->';
			}).replace(/\r/g,'\n');
			
			//调整格式
			var rgx:RegExp = /\n(<(([^\?]).+?)(?:\s|\s*?>|\s*?(\/)>)(?:.*?(?:(?:(\/)>)|(?:<(\/)\2>)))?)/mg;
			var nodeStack:Array = [];
			var output:String = text.replace(rgx,function($0:*,all:*,name:*,isBegin:*,isCloseFull1:*,isCloseFull2:*,isFull1:*,isFull2:*):*{
				var isClosed:Boolean = (isCloseFull1 == '/') || (isCloseFull2 == '/' ) || (isFull1 == '/') || (isFull2 == '/');
				//alert([all,isClosed].join('='));
				var prefix:String = '';
				if(isBegin == '!')
				{
					prefix = GetXmlIndent(nodeStack.length);
				}
				else 
				{
					if(isBegin != '/')
					{
						prefix = GetXmlIndent(nodeStack.length);
						if(!isClosed)
						{
							nodeStack.push(name);
						}
					}
					else
					{
						nodeStack.pop();
						prefix = GetXmlIndent(nodeStack.length);
					}
					
					
				}
				return '\n' + prefix + all;
			});
			
			var prefixSpace:int = -1;
			var outputText:String = output.substring(1);
			//alert(outputText);
			
			//把注释还原并解码，调格式
			outputText = outputText.replace(/\n/g,'\r').replace(/(\s*)<!--(.+?)-->/g,function($0:*, prefix:*, text:*):*
			{
				//alert(['[',prefix,']=',prefix.length].join(''));
				if(prefix.charAt(0) == '\r')
					prefix = prefix.substring(1);
				text = unescape(text).replace(/\r/g,'\n');
//				var ret = '\n' + prefix + '<!--' + text.replace(/^\s*/mg, prefix ) + '-->';
				//alert(ret);
				return '\n' + prefix + '<!--' + text.replace(/^\s*/mg, prefix ) + '-->';
			});
			
			return outputText.replace(/\s+$/g,'').replace(/\r/g,'\r\n') + "\r\n";
			
		}
		
		private static function GetXmlIndent(prefixIndex:int):String
		{
			var span:String = '    ';
			var output:Array = [];
			for(var i:int = 0 ; i < prefixIndex; ++i)
			{
				output.push(span);
			}
			
			return output.join('');
		}
		/**
		 * includeChn 同步时是否把中文一起同步
		 */
		private static function SyncNode( node:XML, toNode:XML, inCn:Boolean=false ):Boolean {
			var includeChn:Boolean = inCn || node.@translate=="false";
			var subList:XMLList = node.children();
			var toSubList:XMLListCollection = new XMLListCollection( toNode.children() );
			var i:int;
			var j:int;
			//删除不存在的节点
			
			var map:Dictionary = new Dictionary();
			for( j=toSubList.length-1; j>=0; j-- ) {
				var toSubNode:XML = toSubList[j];
				var attrs:XMLList = toSubNode.attributes();
				
				if( toSubNode.nodeKind()=="element" ) {
					var tag:String = toSubNode.localName().toString();
					
					var found:Boolean = false;
					var foundNode:XML = null;
					var matchAttr:String = "ident";
					if(  toSubNode.@ident.length()==0  ) {
						if( toSubNode.@index.length()!=0 ) {
							matchAttr = "index";
						} else if ( toSubNode.localName()=="Attr"  ) {
							matchAttr = "effectType";
						} else if ( toSubNode.localName()=="DropItem" ) {
							matchAttr = "itemId";
						} else if ( toSubNode.localName()=="Reward" ) {
							matchAttr = "costType";
						} else {
							matchAttr = "";
						}
					}
					if( matchAttr!="" ) {
						var attrVal:String = toSubNode.@[matchAttr].toString();
						if( node[tag].(@[matchAttr]==attrVal).length() >= toNode[tag].(@[matchAttr]==attrVal).length() ) {
							for( i=0; i < subList.length(); i++ ) {
								if( subList[i].@[matchAttr].toString()==toSubNode.@[matchAttr].toString() && subList[i].localName().toString()==toSubNode.localName().toString() ) {
									found = true;
									foundNode = subList[i];
									break;
								} 
							}
						}
					} else {
						if( node[tag].length()==0 ) {
							found = false;
						} else {
							var list:XMLList = node[tag];
							found = list.length() == toNode[tag].length();
							if( found ) {
								if( list.length()==1 ) {
									found = true;
									foundNode = list[0];
								} else if ( list.length()>1 ) {
									if( map[tag] ) {
										map[tag]++;
									} else {
										map[tag] = 1;
									}
									foundNode = list[map[tag]-1];
								}
							}
						}
//						found = j<subList.length();
					}
					
					if( found ) {
						for( var mm:int=0; mm<attrs.length(); mm++ ) {
							var attrName:String = attrs[mm].localName();
							if( foundNode.@[attrName].length()==0 ) {
								delete toSubNode.@[attrName];
							}
						}
					} else {
						toSubList.removeItemAt(j);
					}
				}
			}
			
			var len:int = 0;
			var map2:Dictionary = new Dictionary();
			for( j=0; j < subList.length(); j++ ) {
				var sub:XML = subList[j];
				if( sub.nodeKind()=="element" ) {
					var toSub:XML = null;
					
					var tag2:String = sub.localName().toString();
					if( map2[tag2] ) {
						map2[tag2]++;
					} else {
						map2[tag2] = 1;
					}
					var list2:XMLList = toNode[tag2];
					if( list2.length()==1 ) {
						toSub = list2[0];
					} else if ( list2.length()>1 ) {
						toSub = list2[map2[tag2]-1];
					}
//					var matchAttr2:String = "ident";
//					if( sub.@ident.length()==0 ) {
//						if( sub.@index.length()!=0 ) {
//							matchAttr2 = "index";
//						} else if ( toSubNode.localName()=="Attr"  ) {
//							matchAttr2 = "effectType";
//						} else if ( toSubNode.localName()=="DropItem" ) {
//							matchAttr2 = "itemId";
//						} else if ( toSubNode.localName()=="Reward" ) {
//							matchAttr2 = "costType";
//						} else {
//							//查找唯一属性
//							var attrList:XMLList = sub.attributes();
//							matchAttr2 = "";
//							for( var c:int = 0; c<attrList.length(); c++ ) {
//								var attr2:String = attrList[i].localName();
//								var val:String = attrList[i].toString();
//								if( node[tag2].(@[attr2]==val).length()==1 ) {
//									matchAttr2 = attr2;
//									break;
//								}
//							}
//						}
//					}
//					if( matchAttr2!="" ) {
//						for( i=0; i<toSubList.length; i++ ) {
//							if( toSubList[i].@[matchAttr2].toString()==sub.@[matchAttr2].toString() && toSubList[i].localName().toString()==tag2 ) {
//								toSub = toSubList[i];
//								break;
//							} 
//						}
//					} /*else if( toSubList.length>j ){
//						toSub = toSubList[j];
//					}*/
//					else {
//						var list2:XMLList = toNode[tag2];
//						if( list2.length()==1 ) {
//							toSub = list2[0];
//						} else if ( list2.length()>1 ) {
//							toSub = list2[map2[tag2]-1];
//						}
//					}
//					if( sub.@[matchAttr2].length()==0 ) {
//						continue ;
//					} 
					
					if(!toSub) {
						toSub = sub.copy();
						toSubList.addItemAt( toSub, j );
					} else {
						SyncAttr( sub, toSub, includeChn || sub.@translate.length()>0 );
						if( SyncNode(sub, toSub, includeChn) ) {
							var txt:String = sub.text();
							if( includeChn || !HasChinese(txt) ) {
								if( txt ) {
									toSub.setChildren( txt );
								}
//								var child:XMLList = toSub.children();
//								for( var k:int=child.length()-1; k>=0; k-- ) {
//									delete toSub[i];
//								}
//								toSub.appendChild( sub.text() );
							}
						}
					}
					len++;
				}
			}
			return len==0;
		}
		private static function SyncAttr( node:XML, toNode:XML, includeChn:Boolean=false ):void {
			var map:XMLList = node.attributes();
			for( var i:int=0; i<map.length(); i++ ) {
				var attr:String = map[i].localName();
				if( includeChn || !HasChinese(map[i].toString()) ) {
					toNode.@[attr] = map[i].toString();
				}
			}
			if( node.localName()=="Troop" && node.@armys.length()>0 ) {
				var val:String = node.@armys;
				for( var k:int=0; k<_ArmyNames.length; k++ ) {
					val = val.replace( new RegExp("[" + _ArmyNames[k][0] + "]", "g"), _ArmyNames[k][_LangIdx]);
				}
				toNode.@armys = val;
			}
		}
		private static var _LangIdx:int;
		public static var LangList:Array = ["zh_CN", "zh_TW", "vi_VN", "ja_JP", "ko_KR", "th_TH", "en_US"];
		private static var _ArmyNames:Array = [ ["术", "术","Thuật", "術", "shu", "วิชา", "shu"], 
												["步","步","Bộ", "歩", "bu", "ขั้น", "bu"], 
												["骑","骑", "Kỵ", "騎", "qi", "ขี่", "qi"], 
												["枪","枪", "Thương", "槍", "qiang", "ปืน", "qiang"], 
												["弓","弓", "Cung","弓", "gong", "ธนู", "gong"]];
		public static function HasChinese( str:String ):Boolean {
			var arr:Array = str.match( /[\u4e00-\u9fa5]+/g );
			return arr.length>0;
		}
		
		public static function GetXml( path:String ):XML {
			var xml:XML = GetXmlFile( new File( path ) );
			if( !xml ) {
				xml = <xml />;
			}
			return xml;
		}
		public static function GetXmlFile( file:File ):XML {
			if( !file.exists ) {
				return null;
			}
			try {
				var fs:FileStream = new FileStream();
				fs.open( file, FileMode.READ );
				var str:String = fs.readUTFBytes( fs.bytesAvailable );
				str = str.replace( /[\r\n\t]/ig, "" );
				var xml:XML = new XML( str );
				fs.close();
				return xml;
			}catch(e:Error) {
				Alert.show(file.nativePath +"\n"+e.message);
			}
			return null;
		}
		public static function GetFileText( file:File ):String {
			if( !file.exists ) {
				return "";
			}
			try {
				var fs:FileStream = new FileStream();
				fs.open( file, FileMode.READ );
				var txt:String = fs.readUTFBytes( fs.bytesAvailable )
				fs.close();
				return txt;
			}catch(e:Error) {
				Alert.show(e.message);
			}
			return "";
		}
    }
}