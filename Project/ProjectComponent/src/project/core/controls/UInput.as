package project.core.controls
{
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.TextEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.system.IME;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;

    import project.core.containers.UCanvas;
    import project.core.events.UIEvent;
    import project.core.global.GlobalVariables;
    import project.core.global.ScrollPolicy;
    import project.core.utils.Utility;

    [Event(name="textInput", type="flash.events.TextEvent")]
    [Event(name="change", type="flash.events.Event")]
    [Event(name="keyUp", type="flash.events.KeyboardEvent")]
    [Event(name="enter", type="project.core.events.UIEvent")] //回车事件 @Jack
    public class UInput extends UCanvas
    {
        private static const byteToPerc:Number = 1 / 0xff;

        private static function SplitRGB( color:uint ):Array
        {
            return [color >> 16 & 0xff, color >> 8 & 0xff, color & 0xff];
        }

        public function UInput( defaultFmt:TextFormat = null )
        {
            super();
            _ColorFilter = new ColorMatrixFilter();
            this.VScrollPolicy = ScrollPolicy.OFF;
            this.HScrollPolicy = ScrollPolicy.OFF;
            Padding = [0,0,0,0];

            if ( defaultFmt )
            {
                _DefaultTextFormat = Utility.CloneTextFormat( defaultFmt );
            }
            else
            {
                _DefaultTextFormat = new TextFormat( GlobalVariables.Font, GlobalVariables.FontSize );
            }
            _Text.height = 16;
            _Text.defaultTextFormat = _DefaultTextFormat;
            _Text.selectable = true;

            Editable = true;
            UpdateFilter();
        }

        public var MultiByteCheck:Boolean = false;

        private var _ColorFilter:ColorMatrixFilter;
        private var _DefaultTextFormat:TextFormat;
        private var _Editable:Boolean = false;
        private var _IMEEnabled:Boolean = true;
        private var _SelectedColor:uint=0xffffff;
        private var _SelectionColor:uint=0x0000ff;
        private var _Text:TextField = new TextField();

        override public function get ClipContent():Boolean
        {
            return true;
        }

        public function get Editable():Boolean
        {
            return this._Editable;
        }

        public function set Editable( value:Boolean ):void
        {
            if ( _Editable == value )
            {
                return;
            }

            this._Editable = value;

            _Text.removeEventListener( TextEvent.TEXT_INPUT, Text_OnInput );
            _Text.removeEventListener( Event.CHANGE, Text_OnChange );
            _Text.removeEventListener( KeyboardEvent.KEY_UP, Text_OnEnter );

            if ( Editable )
            {
                _Text.type = TextFieldType.INPUT;
                _Text.addEventListener( TextEvent.TEXT_INPUT, Text_OnInput );
                _Text.addEventListener( Event.CHANGE, Text_OnChange );
                _Text.addEventListener( KeyboardEvent.KEY_DOWN, Text_OnEnter );
                Selectable = true;
            }
            else
            {
                _Text.type = TextFieldType.DYNAMIC;
            }

            ValidateText();
        }

        public function get HtmlText():String
        {
            return _Text.htmlText;
        }

        public function set HtmlText( val:String ):void
        {
            _Text.htmlText = val;

            //			if(!_Text.styleSheet && _DefaultTextFormat)
            //			{
            //				_Text.setTextFormat(_DefaultTextFormat);
            //			}

            ValidateText();
        }

        public function get IMEEnabled():Boolean
        {
            return _IMEEnabled;
        }

        public function set IMEEnabled( val:Boolean ):void
        {
            if ( _IMEEnabled==val )
            {
                return;
            }
            _IMEEnabled = val;

            if ( val )
            {
                _Text.removeEventListener( FocusEvent.FOCUS_OUT, Text_OnFocusOut );
                _Text.removeEventListener( FocusEvent.FOCUS_IN, Text_OnFocus );
            }
            else
            {
                _Text.addEventListener( FocusEvent.FOCUS_IN, Text_OnFocus );
                _Text.addEventListener( FocusEvent.FOCUS_OUT, Text_OnFocusOut );
            }
        }

        public function get MaxChars():int
        {
            return _Text.maxChars;
        }

        public function set MaxChars( val:int ):void
        {
            _Text.maxChars = val;
        }

        public function get Multiline():Boolean
        {
            return this._Text.multiline;
        }

        public function set Multiline( value:Boolean ):void
        {
            this._Text.multiline = value;
            ValidateText();
        }

        public function get Restrict():String
        {
            return _Text.restrict;
        }

        public function set Restrict( val:String ):void
        {
            _Text.restrict = val;
        }

        public function get Selectable():Boolean
        {
            return this._Text.selectable;
        }

        public function set Selectable( value:Boolean ):void
        {
            if ( Selectable==value )
            {
                return;
            }
            this._Text.selectable = value;
            UpdateFilter();
        }

        public function get SelectedColor():uint
        {
            return _SelectedColor;
        }

        public function set SelectedColor( c:uint ):void
        {
            if ( SelectedColor==c )
            {
                return;
            }
            _SelectedColor = c;
            UpdateFilter();
        }

        public function get SelectionColor():uint
        {
            return _SelectionColor;
        }

        public function set SelectionColor( c:uint ):void
        {
            if ( SelectionColor==c )
            {
                return;
            }
            _SelectionColor = c;
            UpdateFilter();
        }

        public function SetTextFormat( format:TextFormat, beginIndex:int = -1, endIndex:int = -1 ):void
        {
            this._Text.setTextFormat( format, beginIndex, endIndex );
        }

        public function get Text():String
        {
            return _Text.text;
        }

        public function set Text( val:String ):void
        {
            _Text.text = val;

            if ( _DefaultTextFormat )
            {
                _Text.setTextFormat( _DefaultTextFormat );
            }
            ValidateText();
        }

        public function get TextAlign():String
        {
            return _DefaultTextFormat.align;
        }

        public function set TextAlign( val:String ):void
        {
            if ( _DefaultTextFormat.align==val )
            {
                return;
            }
            _DefaultTextFormat.align = val;
            _Text.setTextFormat( _DefaultTextFormat );
        }

        public function get TextColor():uint
        {
            return uint( _DefaultTextFormat.color );
        }

        public function set TextColor( val:uint ):void
        {
            if ( _DefaultTextFormat.color==val )
            {
                return;
            }
            _DefaultTextFormat.color = val;
            _Text.setTextFormat( _DefaultTextFormat );
            UpdateFilter();
        }

        public function get TextFont():String
        {
            return _DefaultTextFormat.font;
        }

        public function set TextFont( val:String ):void
        {
            if ( _DefaultTextFormat.font==val )
            {
                return;
            }
            _DefaultTextFormat.font = val;
            _Text.setTextFormat( _DefaultTextFormat );
        }

        public function get TextSize():int
        {
            return int( _DefaultTextFormat.size );
        }

        public function set TextSize( val:int ):void
        {
            if ( _DefaultTextFormat.size==val )
            {
                return;
            }
            _DefaultTextFormat.size = val;
            _Text.setTextFormat( _DefaultTextFormat );
        }

        public function get TextWidth():Number
        {
            return _Text.textWidth;
        }

        public function get WordWrap():Boolean
        {
            return this._Text.wordWrap;
        }

        public function set WordWrap( value:Boolean ):void
        {
            this._Text.wordWrap = value;
        }

        public function get defaultTextFormat():TextFormat
        {
            return this._DefaultTextFormat;
        }

        public function set defaultTextFormat( format:TextFormat ):void
        {
            _DefaultTextFormat = Utility.CloneTextFormat( format );
            _Text.setTextFormat( _DefaultTextFormat );
            _Text.defaultTextFormat = _DefaultTextFormat;
        }

        public function get styleSheet():StyleSheet
        {
            return this._Text.styleSheet;
        }

        public function set styleSheet( value:StyleSheet ):void
        {
            this._Text.styleSheet = value;
        }

        override protected function Init( e:Event = null ):void
        {
            super.Init();
            //            var fmt:TextFormat = new TextFormat( TextFont, TextSize );
            //            fmt.align = TextAlign;
            //            _Text.defaultTextFormat = fmt;
            //			_Text.setTextFormat(fmt);
            _Text.type = TextFieldType.INPUT;
//			_Text.autoSize = TextFieldAutoSize.NONE;
            //			_Text.background = true;
            //			_Text.backgroundColor = 0xff0000;
            _Text.addEventListener( TextEvent.TEXT_INPUT, Text_OnInput );
            _Text.addEventListener( Event.CHANGE, Text_OnChange );
            _Text.addEventListener( KeyboardEvent.KEY_DOWN, Text_OnEnter );
            addChild( _Text );
            Editable = this._Editable;
        }

        override protected function ValidateSize():void
        {
            super.ValidateSize();
            ValidateText();
        }

        protected function ValidateText():void
        {
            _Text.x = this.MarginLeft;

            _Text.width = width - MarginLeft - MarginRight;

            if ( this._Text.multiline )
            {
                _Text.height = height - MarginTop - MarginBottom;
                _Text.y = this.MarginTop;
            }
            else
            {
                _Text.height = _Text.textHeight + 4;
                this._Text.y = Math.ceil( MarginTop+( height - MarginTop - MarginBottom - this._Text.height + 1 + (_DefaultTextFormat?_DefaultTextFormat.leading:0))*0.5 );
            }

//			if(this._Text.multiline)
//			{//多行文本时设置大小 Jack 2010-9-27
//				//				_Text.height = height - MarginTop - MarginBottom;
//			}
//			else
//			{//单行时居中
////				_Text.height = this._Text.textHeight+4;
//				this._Text.y = (height - this._Text.textHeight - 4)/2;
//			}
        }

        private function Text_OnChange( e:Event ):void
        {
//			UpdateFilter();
            if ( MultiByteCheck && _Text.maxChars>0 )
            {
                _Text.text = Utility.CutString( _Text.text, _Text.maxChars*2/3 );
            }

            if ( _DefaultTextFormat )
            {
                _Text.setTextFormat( _DefaultTextFormat );
            }
            ValidateText();
            this.dispatchEvent( e );
        }

        private function Text_OnEnter( e:KeyboardEvent ):void
        {
            if ( e.keyCode == Keyboard.ENTER )
            {
                if ( !GlobalVariables.IsJapanese || (GlobalVariables.IsJapanese && e.ctrlKey))
                {
                    this.dispatchEvent( new UIEvent( UIEvent.ENTER ));
                }
            }
            this.dispatchEvent( new KeyboardEvent( KeyboardEvent.KEY_UP ));
        }

        private function Text_OnFocus( e:FocusEvent ):void
        {
            IME.enabled = IMEEnabled;
        }

        private function Text_OnFocusOut( e:FocusEvent ):void
        {
            IME.enabled = true;
        }

        private function Text_OnInput( e:TextEvent ):void
        {
            this.dispatchEvent( e );
        }

        private function UpdateFilter():void
        {
            if ( !Selectable )
            {
                _Text.filters = [];
                return;
            }
//			$textField.textColor = 0xff0000;

            var o:Array = SplitRGB( SelectionColor );
            var r:Array = SplitRGB( TextColor );
            var g:Array = SplitRGB( SelectedColor );

            var ro:int = o[0];
            var go:int = o[1];
            var bo:int = o[2];

            var rr:Number = ((r[0] - 0xff) - o[0]) * byteToPerc + 1;
            var rg:Number = ((r[1] - 0xff) - o[1]) * byteToPerc + 1;
            var rb:Number = ((r[2] - 0xff) - o[2]) * byteToPerc + 1;

            var gr:Number = ((g[0] - 0xff) - o[0]) * byteToPerc + 1 - rr;
            var gg:Number = ((g[1] - 0xff) - o[1]) * byteToPerc + 1 - rg;
            var gb:Number = ((g[2] - 0xff) - o[2]) * byteToPerc + 1 - rb;

            _ColorFilter.matrix = [rr, gr, 0, 0, ro, rg, gg, 0, 0, go, rb, gb, 0, 0, bo, 0, 0, 0, 1, 0];

            _Text.filters = [_ColorFilter];

        }
    }
}
