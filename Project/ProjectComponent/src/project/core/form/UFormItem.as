package project.core.form
{
    import flash.events.MouseEvent;
    
    import project.core.controls.ULink;
    import project.core.events.UIEvent;

    [Event(name="itemClick", type="project.core.events.UIEvent")]
    public class UFormItem extends UFormItemBase
    {
        public function UFormItem( ident:int = 0, valVisible:Boolean = true, autoSize:Boolean = false )
        {
            super( ident );
			
			_AutoSize = autoSize;
            if ( valVisible )
            {
                addChild( _pLink );
            }
//            this.RepaintForm();
        }
		private var _AutoSize:Boolean;

//		override public function set BorderThickness(val:int):void {
//			super.BorderThickness = val;
//			if( _pLink ) {
//				_pLink.y = 1-val;
//			}
//		}
        protected var _pLink:ULink;

        private var _Color:uint = 0xE9E7CF;

        public function get Color():uint
        {
            return _Color;
        }

        public function set Color( value:uint ):void
        {
            _Color = value;
            _pLink.TextColor = _Color;
            _pLink.OverTextColor = _Color;
            _pLink.DownTextColor = _Color;
            _pLink.DisabledTextColor = _Color;
        }

        override public function Destroy():void
        {
            _pLink.removeEventListener( MouseEvent.CLICK, Link_OnClick );
            super.Destroy();
        }

        public function get LinkEnabled():Boolean
        {
            return _pLink.Enabled;
        }

        public function set LinkEnabled( val:Boolean ):void
        {
            _pLink.Enabled = val;
        }
		
		public function set LinkUnderline( val:Boolean ):void {
			_pLink.UpUnderline = true;
		}


        public function set Tooltip( val:Object ):void
        {
            _pLink.ToolTip = val;
        }

        public function get Value():Object
        {
            return _pLink.Label;
        }

        public function set Value( value:Object ):void
        {
            if ( value == null )
            {
                value = "";
            }
            _pLink.Label = value.toString();
			
			if( _AutoSize ) {
				ValueWidth = _pLink.LabelWidth;
			}
        }
		public function get ValueNumLines():int {
			return _pLink.NumLines;
		}

        public function set ValueWidth( val:Number ):void
        {
            if ( _pLink.width==val )
            {
                return;
            }
            _pLink.width = val;
            ValidateSize();
//            RepaintForm();
        }
		
		public function get ValueWidth():Number {
			return _pLink.width;
		}
		public function get ValueTextWidth():Number {
			return _pLink.TextWidth;
		}
		
		public function set ValueWordWrap(val:Boolean):void {
			_pLink.WordWrap = val;
		}

        override public function set height( val:Number ):void
        {
            if ( height==val )
            {
                return;
            }

            if ( _pLink )
            {
                _pLink.height = val;//-this.BorderThickness;
            }
            super.height = val;
        }
		
		protected function CreateLink():void {
			_pLink = new ULink();
			_pLink.Background = true;
			_pLink.BgColor = 0;
			_pLink.DisabledBgColor = _pBgColor;
			_pLink.Enabled = false;
			_pLink.LabelFilters = null;
			_pLink.TextColor = _Color;
			_pLink.OverTextColor = _Color;
			_pLink.DownTextColor = _Color;
			_pLink.DisabledTextColor = _Color;
//			_pLink.y = 1-BorderThickness
		}
		public function set ValuePadding( val:Array ):void {
			_pLink.Padding = val;
		}
		public function set ValueFilters( val:Array ):void {
			_pLink.LabelFilters = val;
		}
		public function set ValueToolTip( val:Object ):void {
			if( _pLink ) {
				_pLink.ToolTip = val;
			}
		}
		public function set ValueBgColor( val:uint ):void {
			_pLink.BgColor = val;
			_pLink.OverBgColor = val;
			_pLink.DisabledBgColor = val;
			_pLink.DownBgColor = val;
		}
		public function get ValueBgColor():uint {
			return _pLink.BgColor;
		}
		public function set ValueBgEnabled( val:Boolean ):void {
			_pLink.Background = val;
		}
		public function get ValueBgEnabled():Boolean {
			return _pLink.Background;
		}
		public function set ValueAlign(val:String):void {
			_pLink.Align = val;
		}
		public function get ValueAlign():String {
			return _pLink.Align;
		}

        override protected function InitComponent():void
        {
            super.InitComponent();

			CreateLink();
            _pLink.width = 95;
            _pLink.height = height;
            _pLink.addEventListener( MouseEvent.CLICK, Link_OnClick );
        }

        protected function Link_OnClick( e:MouseEvent ):void
        {
            this.dispatchEvent( new UIEvent( UIEvent.ITEM_CLICK ));
        }
//		public function set ValueFilter(val:Array):void {
//			_pLink.filters = val;
//		}
    }
}