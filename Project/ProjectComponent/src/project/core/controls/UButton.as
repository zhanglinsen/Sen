package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import project.core.global.GlobalVariables;
    import project.core.image.ButtonImage;
    import project.core.manager.EffectSoundManager;
    import project.core.utils.Filters;

    /**
     * 按钮
     * @author meibin
     */
    public class UButton extends UComponent
    {
        protected static const BUTTON_DOWN:int = 2;
        protected static const BUTTON_OVER:int = 3;
        protected static const BUTTON_UP:int = 1;

        /**
         * 构造函数
         * @param label 文字
         * @param defaultSkin 是否使用默认皮肤
         * @param w 宽度，默认为-1，根据文字大小自适应
         * @param h 高度，默认为-1，根据文字大小自适应
         */
        public function UButton( label:String = "", defaultSkin:Boolean = true, w:Number=-1,h:Number=-1 )
        {
            super();

            if ( defaultSkin )
            {
                _UpSkin = ButtonImage.GetUpSkin();
                _DisabledSkin = ButtonImage.GetDisabledSkin();
                _DownSkin = ButtonImage.GetDownSkin();
                _OverSkin = ButtonImage.GetOverSkin();

                _ButtonWidth = _UpSkin.width;
                _ButtonHeight = _UpSkin.height;
            }
            else
            {
				_ButtonWidth = w;
				_ButtonHeight = h;
                Background = true;
                Border = true;
            }
            _DefaultFormat = new TextFormat( GlobalVariables.Font, FontSize, null, Bold, Italic, Underline, null, null, Align );
			_DefaultFormat.leading = Leading;

            Padding = [4,0,4,0];
            buttonMode = true;
            useHandCursor = true;
			
			_pLabel.height = 16;
            _pLabel.filters = _LabelFilters;
            Label = label;

            InitComponent();

            this.addEventListener( Event.ADDED_TO_STAGE, OnAdded );
            this.addEventListener( Event.REMOVED_FROM_STAGE, OnRemoved );

            if ( stage )
            {
                OnAdded();
            }
        }

        /**
         * 背景色
         * @default 0x29363F
         */
        public var BgColor:uint=0x29363F;
        /**
         * 是否有边框
         * @default false 
         */
        public var Border:Boolean = false;
        /**
         * 边框颜色
         * @default 0x828792
         */
        public var BorderColor:uint = 0x828792;
        /**
         * 边框大小
         * @default 1
         */
        public var BorderWeight:int = 1;
        /**
         * 禁用状态背景色
         * @default 0xc0c0c0
         */
        public var DisabledBgColor:uint=0xc0c0c0;
        /**
         * 按下状态背景色
         * @default 
         */
        public var DownBgColor:uint=0x131E28;
        /**
         * 设置 Data时，获取标签文字的属性名
         * @default Label
         */
        public var LabelField:String="Label";
        /**
         * 鼠标经过时背色
         * @default 0x17202F
         */
        public var OverBgColor:uint=0x17202F;
		
        protected var _pLabel:TextField = new TextField();
        protected var _pShell:Sprite = new Sprite();
        protected var _pSkinLayer:Sprite = new Sprite();
        protected var _pState:int = BUTTON_UP;
		
        private var _Align:String = TextFormatAlign.CENTER;
        private var _Background:Boolean = false;
        private var _Bold:Boolean = false;
        private var _ButtonHeight:Number = -1;
        private var _ButtonWidth:Number = -1;
        private var _CurrSkin:DisplayObject;
        private var _DefaultFormat:TextFormat;
        private var _DisabledLabelFormat:TextFormat;
        private var _DisabledSkin:DisplayObject;
		private var _DisabledTextColor:uint=0xCCCCCC;
        private var _DownLabelFormat:TextFormat;
        private var _DownSkin:DisplayObject;
		private var _DownTextColor:uint=0xFFFFB0;
        private var _FontSize:int = GlobalVariables.FontSize;
        private var _Italic:Boolean = false;
		private var _Leading:int = 0;
        private var _LabelFilters:Array = [Filters.TextGlow];
        private var _OverLabelFormat:TextFormat;
        private var _OverSkin:DisplayObject;
		private var _OverTextColor:uint=0xFFFFFF;
        private var _TextColor:uint=0xFFFFB0;
        private var _Underline:Boolean = false;
        private var _UpLabelFormat:TextFormat;
        private var _UpSkin:DisplayObject;
		
		/**
		 * 文本宽度
		 * @return 
		 */
		public function get TextWidth():Number {
			return this._pLabel.textWidth;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get Leading():int
		{
			return _Leading;
		}
		/**
		 * 
		 * @param val
		 */
		public function set Leading( val:int ):void
		{
			if ( Leading == val )
			{
				return;
			}
			_Leading = val;
			_DefaultFormat.leading = val;
			if( val>0 ) {
				_pLabel.wordWrap = true;
				_pLabel.multiline = true;
			} else {
				_pLabel.wordWrap = false;
				_pLabel.multiline = false;
			}
			_pLabel.setTextFormat( LabelFormat );
		}
		/**
		 * 
		 * @param val
		 */
		public function set WordWrap(val:Boolean):void {
			_pLabel.wordWrap = val;
			_pLabel.multiline = val;
		}
		/**
		 * 
		 * @return 
		 */
		public function get Font():String {
			return _Font;
		}
		private var _Font:String;
		/**
		 * 
		 * @param font
		 */
		public function set Font( font:String ):void
		{
			if ( Font == font )
			{
				return;
			}
			_Font = font;
			_DefaultFormat.font = font;
			_pLabel.setTextFormat( LabelFormat );
		}
		
        /**
         * 
         * @return 
         */
        public function get Align():String
        {
            return _Align;
        }

        /**
         * 
         * @param align
         */
        public function set Align( align:String ):void
        {
            if ( Align == align )
            {
                return;
            }
            _Align = align;
            _DefaultFormat.align = align;
            _pLabel.setTextFormat( LabelFormat );
        }

        /**
         * 
         * @return 
         */
        public function get Background():Boolean
        {
            return _Background;
        }

        /**
         * 
         * @param val
         */
        public function set Background( val:Boolean ):void
        {
            if ( Background==val )
            {
                return;
            }
            _Background = val;

            if ( _CurrSkin==null )
            {
                this.DrawDefaultBg();
            }
        }

        /**
         * 
         * @return 
         */
        public function get Bold():Boolean
        {
            return _Bold;
        }

        /**
         * 
         * @param bold
         */
        public function set Bold( bold:Boolean ):void
        {
            if ( _Bold == bold )
            {
                return;
            }
            _Bold = bold;
            _DefaultFormat.bold = bold;
            _pLabel.setTextFormat( LabelFormat );
        }

        override public function set Data( val:Object ):void
        {
            if ( Data==val )
            {
                return;
            }
            super.Data = val;

			if( val ) {
	            if ( val is String )
	            {
	                this.Label = val.toString();
	            }
	            else if ( val.hasOwnProperty( LabelField ))
	            {
	                this.Label = val[LabelField];
	            }
				if( val.hasOwnProperty("ToolTip") ) {
					this.ToolTip = val.ToolTip;
				}
			}
        }

        /**
         * 禁用状态文本格式
         * @param fmt
         */
        public function set DisabledLabelFormat( fmt:TextFormat ):void
        {
            _DisabledLabelFormat = fmt;
            _pLabel.setTextFormat( LabelFormat );
        }

        /**
         * 禁用状态皮肤
         * @return 
         */
        public function get DisabledSkin():DisplayObject
        {
            return _DisabledSkin;
        }

        /**
         * 
         * @param skin
         */
        public function set DisabledSkin( skin:DisplayObject ):void
        {
            if ( _DisabledSkin==skin )
            {
                return;
            }

            if ( skin==null )
            {
                skin = UpSkin;
            }
            _DisabledSkin = skin;
            UpdateSkin();
        }
		/**
		 * 禁用状态文本颜色
		 * @return 
		 */
		public function get DisabledTextColor():uint {
			return _DisabledTextColor;
		}
		/**
		 * 
		 * @param val
		 */
		public function set DisabledTextColor( val:uint ):void {
			if( DisabledTextColor==val ) {
				return ;
			}
			_DisabledTextColor = val;
			_pLabel.textColor = GetCurrStateTextColor();
		}

        /**
         * 
         * @param fmt
         */
        public function set DownLabelFormat( fmt:TextFormat ):void
        {
            _DownLabelFormat = fmt;
            _pLabel.setTextFormat( LabelFormat );
        }

        /**
         * 
         * @return 
         */
        public function get DownSkin():DisplayObject
        {
            return _DownSkin;
        }

        /**
         * 
         * @param skin
         */
        public function set DownSkin( skin:DisplayObject ):void
        {
            if ( _DownSkin==skin )
            {
                return;
            }

            if ( skin==null )
            {
                skin = UpSkin;
            }
            _DownSkin = skin;
            UpdateSkin();
        }
		/**
		 * 
		 * @return 
		 */
		public function get DownTextColor():uint {
			return _DownTextColor;
		}
		/**
		 * 
		 * @param val
		 */
		public function set DownTextColor( val:uint ):void {
			if( DownTextColor==val ) {
				return ;
			}
			_DownTextColor = val;
			_pLabel.textColor = GetCurrStateTextColor();
		}

        override public function set Enabled( val:Boolean ):void
        {
            if ( Enabled==val )
            {
                return;
            }
            super.Enabled = val;

            buttonMode = val;
            useHandCursor = val;

//            this._pShell.mouseEnabled = val;
//            this.mouseEnabled = val;
            UpdateSkin();
        }

        /**
         * 
         * @return 
         */
        public function get FontSize():int
        {
            return _FontSize;
        }

        /**
         * 
         * @param size
         */
        public function set FontSize( size:int ):void
        {
            if ( _FontSize == size )
            {
                return;
            }
            _FontSize = size;
            _DefaultFormat.size = size;
            _pLabel.setTextFormat( LabelFormat );
        }

        /**
         * 
         * @return 
         */
        public function get Italic():Boolean
        {
            return _Italic;
        }

        /**
         * 
         * @param italic
         */
        public function set Italic( italic:Boolean ):void
        {
            if ( _Italic == italic )
            {
                return;
            }
            _Italic = italic;
            _DefaultFormat.italic = italic;
            _pLabel.setTextFormat( LabelFormat );
        }

        /**
         * 
         * @return 
         */
        public function get Label():String
        {
            return _pLabel.text;
        }

        /**
         * 
         * @param str
         */
        public function set Label( str:String ):void
        {
            _pLabel.text = str ? str : "";

            if ( str=="" )
            {
                return;
            }
            _pLabel.setTextFormat( LabelFormat );
            UpdateSkin();
        }
		/**
		 * 
		 * @return 
		 */
		public function get NumLines():int {
			return _pLabel.numLines;
		}

        /**
         * 
         * @param filters
         */
        public function set LabelFilters( filters:Array ):void
        {
            _LabelFilters = filters;
            _pLabel.filters = filters;
        }
		
		/**
		 * 
		 * @return 
		 */
		public function get DefaultLabelFormat():TextFormat {
			return _DefaultFormat;
		}
		/**
		 * 
		 * @return 
		 */
		public function get DownLabelFormat():TextFormat {
			return _DownLabelFormat ? _DownLabelFormat : _DefaultFormat;
		}
		/**
		 * 
		 * @return 
		 */
		public function get OverLabelFormat():TextFormat {
			return _OverLabelFormat ? _OverLabelFormat : _DefaultFormat;
		}
		/**
		 * 
		 * @return 
		 */
		public function get UpLabelFormat():TextFormat {
			return _UpLabelFormat ? _UpLabelFormat : _DefaultFormat;
		}

        /**
         * 
         * @return 
         */
        public function get LabelFormat():TextFormat
        {
            if ( this.Enabled )
            {
                switch ( _pState )
                {
                    case BUTTON_DOWN:
                        if ( _DownLabelFormat!=null )
                        {
                            return _DownLabelFormat;
                        }
                        break;
                    case BUTTON_OVER:
                        if ( _OverLabelFormat!=null )
                        {
                            return _OverLabelFormat;
                        }
                        break;
                    case BUTTON_UP:
                        if ( _UpLabelFormat!=null )
                        {
                            return _UpLabelFormat;
                        }
                        break;
                }
            }
            else if ( _DisabledLabelFormat!=null )
            {
                return _DisabledLabelFormat;
            }
            return _DefaultFormat;
        }

        /**
         * 
         * @return 
         */
        public function get LabelWidth():Number
        {
            return _pLabel.textWidth+4;
        }

        /**
         * 
         * @param fmt
         */
        public function set OverLabelFormat( fmt:TextFormat ):void
        {
            _OverLabelFormat = fmt;
            _pLabel.setTextFormat( LabelFormat );
        }

        /**
         * 
         * @return 
         */
        public function get OverSkin():DisplayObject
        {
            return _OverSkin;
        }

        /**
         * 
         * @param skin
         */
        public function set OverSkin( skin:DisplayObject ):void
        {
            if ( _OverSkin==skin )
            {
                return;
            }

            if ( skin==null )
            {
                skin = UpSkin;
            }
            _OverSkin = skin;
            UpdateSkin();
        }
		/**
		 * 
		 * @return 
		 */
		public function get OverTextColor():uint {
			return _OverTextColor;
		}
		/**
		 * 
		 * @param val
		 */
		public function set OverTextColor( val:uint ):void {
			if( OverTextColor==val ) {
				return ;
			}
			_OverTextColor = val;
			_pLabel.textColor = GetCurrStateTextColor();
		}
		/**
		 * 
		 * @return 
		 */
		public function get TextColor():uint {
			return _TextColor;
		}
		/**
		 * 
		 * @param val
		 */
		public function set TextColor( val:uint ):void {
			if( TextColor==val ) {
				return ;
			}
			_TextColor = val;
			_pLabel.textColor = GetCurrStateTextColor();
		}

        /**
         * 
         * @return 
         */
        public function get Underline():Boolean
        {
            return _Underline;
        }

        /**
         * 
         * @param underline
         */
        public function set Underline( underline:Boolean ):void
        {
            if ( _Underline == underline )
            {
                return;
            }
            _Underline = underline;
            _DefaultFormat.underline = underline;
            _pLabel.setTextFormat( LabelFormat );
        }

        /**
         * 
         * @param fmt
         */
        public function set UpLabelFormat( fmt:TextFormat ):void
        {
            _UpLabelFormat = fmt;
            _pLabel.setTextFormat( LabelFormat );
			this.TextColor = int(_UpLabelFormat.color);
        }

        /**
         * 
         * @return 
         */
        public function get UpSkin():DisplayObject
        {
            return _UpSkin;
        }

        /**
         * 
         * @param skin
         */
        public function set UpSkin( skin:DisplayObject ):void
        {
            if ( _UpSkin==skin )
            {
                return;
            }

//			if( hitArea==null ) {
//				var hit:Sprite = new Sprite();
//				hitArea = hit;
//				hit.visible = false;
//				hit.mouseEnabled = false;
//				this.mouseChildren = false;
//				addChild(hit);
//				
//				var bit:BitmapData = new BitmapData( skin.width, skin.height, true, 0x0 );
//				bit.draw( skin );
//				hitArea.graphics.clear();
//				hitArea.graphics.beginFill( 0 );
//				
//				for ( var x:int=0; x<bit.width; x++ )
//				{
//					for ( var y:int=0; y<bit.height; y++ )
//					{
//						if ( bit.getPixel32( x, y ))
//						{
//							hitArea.graphics.drawRect( x, y, 1, 1 );
//						}
//					}
//				}
//				//以graphics画出bit的无透明区域
//				hitArea.graphics.endFill();
//			}
            if ( _OverSkin==null )
            {
                _OverSkin = skin;
            }

            if ( _DisabledSkin==null )
            {
                _DisabledSkin = skin;
            }

            if ( _DownSkin==null )
            {
                _DownSkin = skin;
            }
            _UpSkin = skin;
            UpdateSkin();
        }

        override public function get height():Number
        {
            if ( _ButtonHeight==-1 )
            {
                if ( _CurrSkin!=null )
                {
                    return _CurrSkin.height;
                }
                else
                {
                    return _pLabel.textHeight+4+PaddingTop+PaddingBottom;
                }
            }
            return _ButtonHeight;
        }

        override public function set height( h:Number ):void
        {
            _ButtonHeight = h;
            ValidateSize();
        }

        override public function get width():Number
        {
            if ( _ButtonWidth==-1 )
            {
                if ( _CurrSkin==null || Label )
                {
                    return LabelWidth+PaddingLeft+PaddingRight;
                }
                else
                {
                    return _CurrSkin.width;
                }
            }
            return _ButtonWidth;
        }

        override public function set width( w:Number ):void
        {
            _ButtonWidth = w;
			//_Label.width = width - PaddingLeft - PaddingRight;
            ValidateSize();
//			_Label.setTextFormat( LabelFormat );
        }

        /**
         * 
         */
        protected function DrawDefaultBg():void
        {
            _pSkinLayer.graphics.clear();

            if ( this.Background || this.Border )
            {
                if ( this.Background )
                {
                    _pSkinLayer.graphics.beginFill( GetCurrStateBgColor());
                }

                if ( this.Border )
                {
                    _pSkinLayer.graphics.lineStyle( BorderWeight, BorderColor );
                }
                _pSkinLayer.graphics.drawRect( 0, 0, width, height );
                _pSkinLayer.graphics.endFill();
            }
        }

        /**
         * 获取当前状态对应的背景色
         */
        protected function GetCurrStateBgColor():uint
        {
            if ( !this.Enabled )
            {
                return this.DisabledBgColor;
            }

            switch ( _pState )
            {
                case BUTTON_DOWN:
                    return DownBgColor;
                case BUTTON_OVER:
                    return OverBgColor;
                case BUTTON_UP:
                    return BgColor;
            }
            return BgColor;
        }

        /**
         * 获取当前状态对应的皮肤
         */
        protected function GetCurrStateSkin():DisplayObject
        {
            if ( !this.Enabled )
            {
                return this.DisabledSkin;
            }

            switch ( _pState )
            {
                case BUTTON_DOWN:
                    return DownSkin;
                case BUTTON_OVER:
                    return OverSkin;
                case BUTTON_UP:
                    return UpSkin;
            }
            return null;
        }

        /**
         * 获取当前状态对应的文本颜色
         */
        protected function GetCurrStateTextColor():uint
        {
            if ( !this.Enabled )
            {
                return this.DisabledTextColor;
            }

            switch ( _pState )
            {
                case BUTTON_DOWN:
                    return DownTextColor;
                case BUTTON_OVER:
                    return OverTextColor;
                case BUTTON_UP:
                    return TextColor;
            }
            return TextColor;
        }

        /**
         * 
         */
        protected function InitComponent():void
        {

            _pLabel.mouseEnabled = false;
            _pLabel.multiline = true;

            _pSkinLayer.mouseEnabled = false;
            _pLabel.mouseEnabled = false;
            addChild( _pSkinLayer );
            addChild( _pLabel );
            addChild( _pShell );
        }

        /**
         * 
         * @param e
         */
        protected function OnAdded( e:Event = null ):void
        {
            this.addEventListener( MouseEvent.ROLL_OVER, OnRollOver );
            this.addEventListener( MouseEvent.ROLL_OUT, OnRollOut );
            this.addEventListener( MouseEvent.MOUSE_DOWN, OnMouseDown );
            this._pShell.addEventListener( MouseEvent.CLICK, OnMouseClick );
            UpdateSkin();
        }
		
		private var _LastClick:Array = [-1,-1,-1,-1];
//		private var _SameClickCount:int = 0;
//		private var _ClickTimes:Array = [];
//		private var _LastTime:int;
		/**
		 * 
		 * @default 
		 */
		public var MaxClickCount:int = 0;
        /**
         * 
         * @param e
         */
        protected function OnMouseClick( e:MouseEvent ):void
        {
			var sameTooMuch:Boolean = false;// _SameClickCount>MaxClickCount;
//			if( MaxClickCount>0 ) {
////				var t:int = flash.utils.getTimer();
////				if( _LastTime!=0 ) {
////					_ClickTimes.push( t - _LastTime );
////				}
////				_LastTime = t;
////				Debugger.Info("Click:" + e.stageX + "," + e.stageY);
////				Debugger.Info("Times:" + _ClickTimes.join(";") );
//				
//				var same:Boolean = false;
//				for( var i:int=0; i<_LastClick.length; i+=2 ) {
//					if( e.stageX==_LastClick[i] && e.stageY==_LastClick[i+1]) {
//						same = true;
//						break;
//					}
//				}
//				if( same ) {
//					if( (_SameClickCount-MaxClickCount)==1 ) {
//						Debugger.Error("Click " + MaxClickCount);
//						GlobalVariables.SameClick++;
//					}
//					_SameClickCount ++;
//				} else {
//					_LastClick.splice(0,2);
//					_LastClick.push(e.stageX);
//					_LastClick.push(e.stageY);
//					if( sameTooMuch ) {
//						Debugger.Error("Click Reset");
//						GlobalVariables.SameClick--;
//					}
//					_SameClickCount = 0;
//				}
//			} 
            if ( (!ClickEvtWhenDisabled && !Enabled) || (sameTooMuch) )
            {
                e.preventDefault();
                e.stopPropagation();
            }
        }
		/**
		 * 
		 * @default 
		 */
		public var ClickEvtWhenDisabled:Boolean = false;

        /**
         * 
         * @param e
         */
        protected function OnMouseDown( e:MouseEvent ):void
        {
            if ( Enabled )
            {
                GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_UP, OnMouseUp );
				_pState = BUTTON_DOWN;
				
				if( SoundEnabled ) {
					EffectSoundManager.Play(MouseClickSound);
				}
				UpdateSkin();
            }
        }
		public static var MouseClickSound:String = "";
		/**
		 * 
		 * @default 
		 */
		public var SoundEnabled:Boolean = false;
        /**
         * 
         * @param e
         */
        protected function OnMouseUp( e:MouseEvent ):void
        {
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_UP, OnMouseUp );

            if ( _pState==BUTTON_DOWN )
            {
                _pState = BUTTON_OVER;
            }
            UpdateSkin();
        }

        /**
         * 
         * @param e
         */
        protected function OnRemoved( e:Event = null ):void
        {
            this.removeEventListener( MouseEvent.ROLL_OVER, OnRollOver );
            this.removeEventListener( MouseEvent.ROLL_OUT, OnRollOut );
            this.removeEventListener( MouseEvent.MOUSE_DOWN, OnMouseDown );
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_UP, OnMouseUp );
            this._pShell.removeEventListener( MouseEvent.CLICK, OnMouseClick );
            _pState = BUTTON_UP;
            ResetSkin();
        }


        /**
         * 
         * @param e
         */
        protected function OnRollOut( e:MouseEvent ):void
        {
            _pState = BUTTON_UP;
            UpdateSkin();
        }

        /**
         * 
         * @param e
         */
        protected function OnRollOver( e:MouseEvent ):void
        {
            if ( e.buttonDown )
            {
                _pState = BUTTON_DOWN;
            }
            else
            {
//				if( Enabled && SoundEnabled ) {
////					EffectSoundManager.Play(GlobalVariables.GetSoundPath("3-Mouse_Over.mp3"));
//					EffectSoundManager.Play(GlobalVariables.GetSoundPath("4-Mouse_Click.mp3"));
//				}
                _pState = BUTTON_OVER;
            }
            UpdateSkin();
        }

        /**
         * 
         */
        protected function ResetSkin():void
        {
            while ( _pSkinLayer.numChildren>0 )
            {
                _pSkinLayer.removeChildAt( 0 );
            }
            _pSkinLayer.graphics.clear();
            _CurrSkin = null;
        }

//		private var _StateChanged:Boolean = true;
        /**
         * 
         */
        protected function UpdateSkin():void
        {
            var skin:DisplayObject = GetCurrStateSkin();

            if ( _CurrSkin==null || skin!=_CurrSkin )
            {
                ResetSkin();

                if ( skin!=null )
                {
                    _CurrSkin = skin;
					_CurrSkin.y = this.MarginTop;
                    _pSkinLayer.addChild( skin );
                }
                else
                {
                    _CurrSkin = null;
                }
                ValidateSize();
            } else {
				ValidateTextSize();
			}
            ValidateText();
        }
		
		override public function set MarginTop(value:int):void {
			super.MarginTop = value;
			if( _CurrSkin ) {
				_CurrSkin.y = this.MarginTop;
			}
		}

        override protected function ValidateSize():void
        {
            super.ValidateSize();
//			_StateChanged = false;
            var w:Number=width, h:Number=height;

            if ( _CurrSkin!=null )
            {
//                if ( _CurrSkin.scale9Grid!=null )
//                {
                _CurrSkin.width = w;
                _CurrSkin.height = h;
//                }
            }
            else
            {
                DrawDefaultBg();
            }

            _pShell.graphics.clear();
            _pShell.graphics.beginFill( 0xffffff, 0 );
            _pShell.graphics.drawRect( 0, 0, w+BorderWeight, h+BorderWeight );
            _pShell.graphics.endFill();
			
			
			ValidateTextSize();
			
        }
		private function ValidateTextSize():void {
			var w:Number = width - PaddingLeft - PaddingRight;
//			if( !OverflowHidden ) {
//				w = LabelWidth > w ? LabelWidth : w;
//			}
			_LabelX = NaN;
			if( !OverflowHidden && w<_pLabel.textWidth+4 ) {
				w = _pLabel.textWidth+4;
				_LabelX = 0.5*(width - w); 
			}
			_pLabel.width = w;
			ValidateTextPos();
		}
		private var _OverflowHidden:Boolean = false;
		/**
		 * 
		 * @param val
		 */
		public function set OverflowHidden(val:Boolean):void {
			_OverflowHidden = val;
			ValidateTextSize();
		}
		/**
		 * 
		 * @return 
		 */
		public function get OverflowHidden():Boolean {
			return _OverflowHidden;
		}
        /**
         * 
         */
        protected function ValidateText():void
        {
//            if ( this._UpLabelFormat==null )
            {
                _pLabel.textColor = GetCurrStateTextColor();
            }
//            else
//            {
//                _Label.textColor = uint( LabelFormat.color );
//            }
//			_Label.border = true;
//			_Label.borderColor = 0xff0000;
			_pLabel.height = _pLabel.textHeight + 4;
//            _Label.height = _Label.textHeight + 4;
//            _Label.width = _Label.textWidth + 4;
            ValidateTextPos();
        }
		private var _LabelX:Number = NaN;
		/**
		 * 
		 * @return 
		 */
		public function get LabelX():Number {
			return isNaN(_LabelX) ? PaddingLeft : _LabelX;
		}
        /**
         * 
         */
        protected function ValidateTextPos():void
        {
			_pLabel.x = LabelX;
//            _Label.x = (width - _Label.width - PaddingLeft - PaddingRight)/2 + PaddingLeft;
            _pLabel.y = (height - _pLabel.height - PaddingTop - PaddingBottom + 1)/2 + PaddingTop;
        }
    }
}