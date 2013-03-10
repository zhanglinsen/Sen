package project.core.text
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import project.core.global.GlobalVariables;
    import project.core.utils.Filters;

    public class SimpleText implements IText
    {
        public function SimpleText()
        {
            super();
        }

        protected var _pText:String;
		
		public function set Text(val:String):void {
			_pText = val;
		}
		public function get Text():String {
			return _pText;
		}

        public function Parse( xml:* ):void
        {
			if( xml is XML ) {
	            _pText = xml.text();
				if ( xml.@color.toString())
				{
					_TextColorCustom = true;
					_TextColor = xml.@color;
				}
			} else {
				_pText = xml;
				_IsXml = true;
			}
        }
		private var _IsXml:Boolean = false;;
		private var _TextColor:uint;
		private var _TextColorCustom:Boolean = false;

        public function ToBitmap( filters:Array = null, txtFormat:TextFormat = null, params:Object=null, bgEnabled:Boolean=false ):Bitmap
        {
            var txt:TextField = new TextField();
            ToTextField( txt, filters, txtFormat, params );

            var b:BitmapData = new BitmapData( txt.width, txt.height, true, 0x0 );
            b.draw( txt );
            return new Bitmap( b );
        }
		
        public function toString(params:Object=null):String
        {
            return _pText;
        }
		public function ToHtml(params:Object=null):String {
			var html:String = _pText;
			if( _TextColorCustom ) {
				html = "<font color='#"+ _TextColor.toString(16)+"'>" + html + "</font>";
			}
			return html;
		}

        public function ToTextField( txt:TextField, filters:Array = null, txtFormat:TextFormat = null, params:Object=null, fitSize:Boolean=true ):void
        {
            txt.text = toString();
            if ( txtFormat!=null )
            {
                txt.setTextFormat( txtFormat );
            }
            else
            {
                txt.setTextFormat( new TextFormat(GlobalVariables.Font, GlobalVariables.FontSize, 0xDDDCCC, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 3) );

                if ( filters==null )
                {
                    filters = [Filters.TextGlow];
                }
            }

            if ( filters!=null )
            {
                txt.filters = filters;
            }
			if( fitSize ) {
				txt.width = txt.textWidth + 4;
				txt.height = txt.textHeight + 4;
			}
        }
    }
}