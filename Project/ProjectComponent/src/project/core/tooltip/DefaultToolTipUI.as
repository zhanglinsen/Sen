package project.core.tooltip
{
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    import project.core.global.GlobalVariables;

    public class DefaultToolTipUI extends AbstractToolTipUI
    {
        public function DefaultToolTipUI()
        {
            super();
            _pText = new TextField();
            _pText.multiline = true;
//            _pText.wordWrap = true;
            addChild( _pText );
        }
		private var _DefautFmt:TextFormat = new TextFormat(GlobalVariables.Font, GlobalVariables.FontSize, 0xF3F3DA, false, false, false, null, null, null, null, null, null, 3);
        protected var _pLabelFormat:TextFormat = null;

        protected var _pText:TextField;
        private var _Leading:int;
        private var _MaxTextHeight:Number = -1;
        private var _MaxTextWidth:Number = -1;
        private var _TextHeight:Number=-1;
        private var _TextWidth:Number=-1;

        override public function set Data( obj:Object ):void
        {
			_pText.wordWrap = false;
            TextData = obj;

            if ( obj==null )
            {
                _MaxTextWidth = -1;
                _MaxTextHeight = -1;

                _TextWidth = -1;
                _TextHeight = -1;
            }
            else
            {
                if ( obj.hasOwnProperty( "MaxTextWidth" ))
                {
                    _MaxTextWidth = obj.MaxTextWidth;
                } else {
					_MaxTextWidth = -1;
				}

                if ( obj.hasOwnProperty( "MaxTextHeight" ))
                {
                    _MaxTextHeight = obj.MaxTextHeight;
                } else {
					_MaxTextHeight = -1;
				}
                ValidateText();
            }
            super.Data = obj;

        }

        public function set TextHeight( val:Number ):void
        {
            _TextHeight = val;
            _pText.height = val;
        }

        public function set TextWidth( val:Number ):void
        {
            _TextWidth = val;
            _pText.width = val;
        }

        protected function set TextData( obj:Object ):void
        {
            var str:String = "";

            if ( obj )
            {
                str = obj.hasOwnProperty( "Text" ) ? obj.Text : obj.toString();
            }

            if ( _pText.text==str )
            {
                return;
            }

            _pText.text = str;
            var fmt:TextFormat = _pLabelFormat==null ? _DefautFmt : _pLabelFormat;
            _pText.setTextFormat( fmt );
            _Leading = _pText.numLines>1?int( fmt.leading ):0;
        }

        protected function ValidateText():void
        {
            if ( _TextWidth==-1 )
            {
                _pText.width = _pText.textWidth+4;

                if ( _MaxTextWidth!=-1 && _MaxTextWidth<_pText.width )
                {
					_pText.wordWrap = true;
                    _pText.width = _MaxTextWidth;
                }
            }

            if ( _TextHeight==-1 )
            {
                _pText.height = _pText.textHeight+4 + _Leading;

                if ( _MaxTextHeight!=-1 && _MaxTextHeight<_pText.height )
                {
                    _pText.height = _MaxTextHeight;
                }
            }
            width = _pText.width+PaddingLeft+PaddingRight;

            height = _pText.height+PaddingTop+PaddingBottom+(_pText.numLines>1?2:0);
            _pText.y = PaddingTop;
            _pText.x = PaddingLeft;
        }
    }
}