package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    
    import project.core.events.UIEvent;
    import project.core.global.GlobalVariables;

    [Event(name="stateChanged", type="project.core.events.UIEvent")]
    public class UToggleButton extends UButton
    {
        public function UToggleButton( label:String = "", defaultSkin:Boolean = true )
        {
            super( label, defaultSkin );
			
			this.TextColor = 0xF3F3DA;
        }

        public var SelectedBgColor:uint=0x4D6366;
        public var SelectedDisabledBgColor:uint=0xCCCCCC;
        public var SelectedDisabledTextColor:uint=0xffffff;
        public var SelectedDownBgColor:uint=0x4FBCE0;
        public var SelectedDownTextColor:uint=0xFFFFB0;
        public var SelectedOverBgColor:uint=0xB0DFEF;
        public var SelectedOverTextColor:uint=0xffffff;
        public var SelectedTextColor:uint=0xFFFFB0;

        private var _Selected:Boolean = false;
        private var _SelectedDisabledSkin:DisplayObject;
        private var _SelectedDownSkin:DisplayObject;

        private var _SelectedOverSkin:DisplayObject;
        private var _SelectedUpSkin:DisplayObject;

        public function get Selected():Boolean
        {
            return _Selected;
        }

        public function set Selected( val:Boolean ):void
        {
//            if ( !Enabled )
//            {
//                return;
//            }
            this._Selected = val;
            super.OnMouseUp( null );
        }

        public function get SelectedDisabledSkin():DisplayObject
        {
            return _SelectedDisabledSkin;
        }

        public function set SelectedDisabledSkin( skin:DisplayObject ):void
        {
            if ( _SelectedDisabledSkin==skin )
            {
                return;
            }

            if ( skin==null )
            {
                skin = SelectedUpSkin == null ? UpSkin : SelectedUpSkin;
            }
            _SelectedDisabledSkin = skin;
            UpdateSkin();
        }

        public function get SelectedDownSkin():DisplayObject
        {
            return _SelectedDownSkin;
        }

        public function set SelectedDownSkin( skin:DisplayObject ):void
        {
            if ( _SelectedDownSkin==skin )
            {
                return;
            }

            if ( skin==null )
            {
                skin = SelectedUpSkin == null ? UpSkin : SelectedUpSkin;
            }
            _SelectedDownSkin = skin;
            UpdateSkin();
        }

        public function get SelectedOverSkin():DisplayObject
        {
            return _SelectedOverSkin;
        }

        public function set SelectedOverSkin( skin:DisplayObject ):void
        {
            if ( _SelectedOverSkin==skin )
            {
                return;
            }

            if ( skin==null )
            {
                skin = SelectedUpSkin == null ? UpSkin : SelectedUpSkin;
            }
            _SelectedOverSkin = skin;
            UpdateSkin();
        }

        public function get SelectedUpSkin():DisplayObject
        {
            return _SelectedUpSkin;
        }

        public function set SelectedUpSkin( skin:DisplayObject ):void
        {
            if ( _SelectedUpSkin==skin )
            {
                return;
            }

            if ( skin==null )
            {
                skin = UpSkin;
            }

            if ( _SelectedOverSkin==null )
            {
                _SelectedOverSkin = skin;
            }

            if ( _SelectedDisabledSkin==null )
            {
                _SelectedDisabledSkin = skin;
            }

            if ( _SelectedDownSkin==null )
            {
                _SelectedDownSkin = skin;
            }
            _SelectedUpSkin = skin;
            UpdateSkin();
        }

        override public function set UpSkin( skin:DisplayObject ):void
        {
            super.UpSkin = skin;

            if ( _SelectedUpSkin==null )
            {
                SelectedUpSkin = skin;
            }
        }


        /**
         * 获取当前状态对应的背景色
         */
        override protected function GetCurrStateBgColor():uint
        {
            if ( this.Enabled && this.Selected )
            {
                switch ( _pState )
                {
                    case BUTTON_DOWN:
                        return SelectedDownBgColor;
                    case BUTTON_OVER:
                        return SelectedOverBgColor;
                    case BUTTON_UP:
                        return SelectedBgColor;
                }
            }
            return super.GetCurrStateBgColor();
        }

        /**
         * 获取当前状态对应的皮肤
         */
        override protected function GetCurrStateSkin():DisplayObject
        {
            if ( this.Enabled && this.Selected )
            {
                switch ( _pState )
                {
                    case BUTTON_DOWN:
                        return SelectedDownSkin;
                    case BUTTON_OVER:
                        return SelectedOverSkin;
                    case BUTTON_UP:
                        return SelectedUpSkin;
                }
            }
            else if ( !this.Enabled && this.Selected )
            {
                return this.SelectedDisabledSkin;
            }
            return super.GetCurrStateSkin();
        }

        /**
         * 获取当前状态对应的文本颜色
         */
        override protected function GetCurrStateTextColor():uint
        {
            if ( this.Enabled && this.Selected )
            {
                switch ( _pState )
                {
                    case BUTTON_DOWN:
                        return SelectedDownTextColor;
                    case BUTTON_OVER:
                        return SelectedOverTextColor;
                    case BUTTON_UP:
                        return SelectedTextColor;
                }
            }
            return super.GetCurrStateTextColor();
        }

        private var _ToggleDown:Boolean=false;

        override protected function OnMouseDown( e:MouseEvent ):void
        {
			if(!Enabled || !visible) return ;
            _ToggleDown = true;
            super.OnMouseDown( e );
        }

        override protected function OnMouseUp( e:MouseEvent ):void
        {
            if ( _ToggleDown && ( e.target==this || this.contains(e.target as DisplayObject) ) )
            {
				if( !(LockSelected && Selected) ) {
	                this.Selected = !Selected;
	                this.dispatchEvent( new UIEvent( UIEvent.STATE_CHANGED ));
				}
            } else {
				GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_UP, OnMouseUp );
			}
			_ToggleDown = false;
        }
		public var LockSelected:Boolean = false;
    }
}