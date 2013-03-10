package project.core.text
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    
    import project.core.global.GlobalVariables;
    import project.core.loader.ClassLoader;
    import project.core.text.elements.IHyperElement;
    import project.core.utils.Filters;
    import project.core.utils.Utility;

    public class HyperText extends SimpleText
    {
        public function HyperText()
        {
            super();
            _DefaultFmt = new TextFormat( GlobalVariables.Font, GlobalVariables.FontSize, 0xE9E7CF );
			_DefaultFmt.leading = 3;
        }

        public var BackgroundColor:uint = 0x252E35;
		public var TextColorCustom:Boolean = false;
        private var _CustomFmt:TextFormat;
        private var _DefaultFmt:TextFormat;
        private var _Elements:Array = [];
		
		override public function ToBitmap( filters:Array = null, txtFormat:TextFormat = null, params:Object=null, bgEnabled:Boolean=false ):Bitmap
		{
			var txt:TextField = new TextField();
			ToTextField( txt, filters, txtFormat, params );
			
			var b:BitmapData = new BitmapData( txt.width, txt.height, true, 0x0 );
			txt.background = bgEnabled;
			txt.backgroundColor = BackgroundColor;
			b.draw( txt );
			return new Bitmap( b );
		}
		private var _IsXML:Boolean = false;
        override public function Parse( xml:* ):void
        {
			if( xml is XML ) {
				_IsXML = true;
				TextColorCustom = false;
	            var list:XMLList = xml.children();
	            _pText = "";
	
	            for ( var i:int=0; i<list.length(); i++ )
	            {
	                ParseElement( list[ i ]);
	            }
	            _CustomFmt = Utility.ParseTextFormat( xml );
	
	            if ( xml.@bgColor.toString())
	            {
	                BackgroundColor = xml.@bgColor;
	            }
				if ( xml.@color.toString())
				{
					TextColorCustom = true;
				}
			} else {
				_pText = xml;
			}
        }

        override public function ToTextField( txt:TextField, filters:Array = null, txtFormat:TextFormat = null, params:Object=null, fitSize:Boolean=true ):void
        {
			var fmt:TextFormat = Utility.CloneTextFormatTo( _CustomFmt, txtFormat==null?_DefaultFmt:txtFormat );
			txt.selectable = false;
			
			if( !params ) {
				params = DefaultParams;
			}
			var str:String = "";
			
			if(!_IsXML) {
				if( !params.KeepText ) {
					txt.htmlText = "";
				}
				str = _pText;
				if ( params.DynamicString ) {
					if ( !(params.DynamicString is Array))
					{
						params.DynamicString=[params.DynamicString];
					}
					for ( var i:int=params.DynamicString.length-1; i>=0; i-- )
					{
						str = str.replace( new RegExp( "{"+i+"}", "gi" ), params.DynamicString[ i ]);
					}
					
					for ( var i:int=10; i>=0; i-- )
					{
						str = str.replace( new RegExp( "{"+i+"}", "gi" ), "");
					}
				}
				
				if( params.Replace ) {
					str = str.replace( params.Replace[0], params.Replace[1] ); 
				}
				txt.htmlText += str;
				txt.setTextFormat( fmt );
				txt.filters = filters==null ? [Filters.TextGlow] : filters;
				if( fitSize ) {
					txt.width = txt.textWidth + 4;
					txt.height = txt.textHeight + 4 + (txt.numLines>1?fmt.leading:0);
				}
				return ;
			}
			
            var fmts:Array = [];
			var availabLen:int = 0; 
			if( params.KeepText ) {
				availabLen = txt.text.length; 
			} else {
				txt.text = "";
			}
			
			var dynamicCnt:Dictionary = new Dictionary();
            for ( var i:int=0; i<_Elements.length; i++ )
            {
                var el:IHyperElement = _Elements[i] as IHyperElement;
                var len:int = availabLen + str.length;
				
				if( el.IsDynamic ) {
					var cont:Object = params[el.NodeName];
					if(dynamicCnt[el.NodeName]!=null) {
						dynamicCnt[el.NodeName]++;
					} else {
						dynamicCnt[el.NodeName] = 0;
					}
					if( cont ) {
						if( cont is Array ) {
							if( cont.length>dynamicCnt[el.NodeName] ) {
								str+=cont[dynamicCnt[el.NodeName]];
							}
						} else {
							str+=cont.toString();
						}
					} else {
						str += el.Content;
					}
				} else {
					str += el.Content;
				}
                if ( el.ContentFormat!=null && (len-availabLen)<str.length)
                {
					el.ContentFormat.leading = fmt.leading;
					el.ContentFormat.align = fmt.align;
                    fmts.push([ el.ContentFormat, len, str.length+availabLen ]);
                }
            }
			if( params.Replace ) {
				str = str.replace( params.Replace[0], params.Replace[1] ); 
			}
            txt.appendText( str );
			if( !params.KeepText ) {
				txt.setTextFormat( fmt );
			}

            for ( var k:int = 0; k<fmts.length; k++ )
            {
                var fmtArgs:Array = fmts[k];
                txt.setTextFormat( fmtArgs[ 0 ], fmtArgs[ 1 ], fmtArgs[ 2 ]);
                delete fmtArgs[0];
                fmts[k] = null;
            }
            txt.filters = filters==null ? [Filters.TextGlow] : filters;
			if( fitSize ) {
	            txt.width = txt.textWidth + 4;
	            txt.height = txt.textHeight + 4 + (txt.numLines>1?fmt.leading:0);
			}
        }

        protected function ParseElement( node:XML ):void
        {
			var ele:IHyperElement = ClassLoader.GetInstance( "uqee.core.text.elements."+node.localName()+"Element" );

            if ( ele )
            {
                ele.Parse( node );
				AddElement( ele );
            }
        }
		public function AddElement( ele:IHyperElement ):void {
			_Elements.push( ele );
			_pText += ele.Content;
		}
		public var DefaultParams:Object={};
		
		/**
		 * 动态字符串
		 * @param param Array或者单一的字符串
		 * 
		 */		
		public function set DynamicString(param:Object):void
		{
			DefaultParams.DynamicString = param;
		}
		
		public function get DynamicString():Object
		{
			return DefaultParams.DynamicString;
		}
		
		override public function toString(params:Object=null):String {
			var str:String = "";
			if( !params ) {
				params = DefaultParams;
			}
			
			if(!_IsXML) {
				str = _pText;
				if ( params.DynamicString ) {
					if ( !(params.DynamicString is Array))
					{
						params.DynamicString=[params.DynamicString];
					}
					for ( var i:int=params.DynamicString.length-1; i>=0; i-- )
					{
						str = str.replace( new RegExp( "{"+i+"}", "gi" ), params.DynamicString[ i ]);
					}
					for ( var i:int=10; i>=0; i-- )
					{
						str = str.replace( new RegExp( "{"+i+"}", "gi" ), "");
					}
				}
//				str = str.replace(new RegExp("(<br/>|<b>|</b>|</font>)", "gi"), "" );
//				str = str.replace(new RegExp("<font[\\s\\S]+>", "gi"), "" );
				return str;
			}
			var dynamicCnt:Dictionary = new Dictionary();
			for ( var i:int=0; i<_Elements.length; i++ )
			{
				var el:IHyperElement = _Elements[i] as IHyperElement;
				var len:int = str.length;
				
				if( el.IsDynamic ) {
					var cont:* = params[el.NodeName];
					if(dynamicCnt[el.NodeName]!=null) {
						dynamicCnt[el.NodeName]++;
					} else {
						dynamicCnt[el.NodeName] = 0;
					}
					if( cont!=undefined ) {
						if( cont is Array ) {
							str+=cont[dynamicCnt[el.NodeName]];
						} else {
							str+=cont.toString();
						}
					} else {
						str += el.Content;
					}
				} else {
					str += el.Content;
				}
			}
			return str;
		}
		override public function ToHtml(params:Object=null):String {
			var str:String = "";
			if( !params ) {
				params = DefaultParams;
			}
			if(!_IsXML) {
				str = _pText;
				if ( params.DynamicString ) {
					if ( !(params.DynamicString is Array))
					{
						params.DynamicString=[params.DynamicString];
					}
					for ( var i:int=params.DynamicString.length-1; i>=0; i-- )
					{
						str = str.replace( new RegExp( "{"+i+"}", "gi" ), params.DynamicString[ i ]);
					}
					for ( var i:int=10; i>=0; i-- )
					{
						str = str.replace( new RegExp( "{"+i+"}", "gi" ), "");
					}
				}
				return str;
			}
			var dynamicCnt:Dictionary = new Dictionary();
			for ( var i:int=0; i<_Elements.length; i++ )
			{
				var el:IHyperElement = _Elements[i] as IHyperElement;
				var len:int = str.length;
				var html:String;
				if( el.IsDynamic ) {
					var cont:Object = params[el.NodeName];
					if(dynamicCnt[el.NodeName]!=null) {
						dynamicCnt[el.NodeName]++;
					} else {
						dynamicCnt[el.NodeName] = 0;
					}
					if( cont ) {
						if( cont is Array ) {
							html=cont[dynamicCnt[el.NodeName]];
						} else {
							html=cont.toString();
						}
					} else {
						html=el.Content;
					}
				} else {
					html=el.Content;
				}
				
				if ( el.ContentFormat!=null && html.length>0)
				{
					var style:String = "";
					if( el.ContentFormat.color ) {
						style += " color='#" + uint(el.ContentFormat.color).toString(16) + "'";
					}
					if( el.ContentFormat.size ) {
						style += " size='" + el.ContentFormat.size + "'";
					}
					if( style.length>0 ) {
						html = "<font" + style + ">" + html + "</font>";
					}
					
					if( el.ContentFormat.bold ) {
						html = "<b>" + html + "</b>";
					}
					if( el.ContentFormat.italic ) {
						html = "<i>" + html + "</i>";
					}
					if( el.ContentFormat.underline ) {
						html = "<u>" + html + "</u>";
					}
				}
				if( TextColorCustom ) {
					html = "<font color='#"+ uint(_CustomFmt.color).toString(16)+"'>" + html + "</font>";
				}
				str += html;
			}
			return str;
			
		}
    }
}