package project.core.controls
{
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.Keyboard;
    
    import project.core.containers.UCanvas;
    import project.core.entity.MenuItemData;
    import project.core.events.MenuEvent;
    import project.core.events.UIEvent;
    import project.core.factory.ClassFactory;
    import project.core.global.GlobalVariables;
    import project.core.image.ComboButtonDownImage;
    import project.core.image.ComboButtonOverImage;
    import project.core.image.ComboButtonUpImage;
    import project.core.navigators.UMenu;

    [Event(name="itemClick", type="project.core.events.UIEvent")]
    /**
     * 下拉框
     */
    public class UComboBox extends UCanvas
    {

        /**
         *
         * @param showDropdownBtn
         */
        public function UComboBox( showDropdownBtn:Boolean = true )
        {
            _ShowDropdownBtn = showDropdownBtn;
            super();
            height = 19;
            width = 111;
        }

        private var _DataProvider:Array;
        private var _DropdownBtn:UButton; //选择菜单按钮
        private var _DropdownMenu:UMenu;
        private var _Input:UInput; //内容项
        private var _SelectedData:MenuItemData;
        private var _SelectedIndex:int=-1;
        private var _ShowDropdownBtn:Boolean = true;

        override public function set BackgroundAlpha( value:Number ):void
        {
            _Input.BackgroundAlpha = value;
        }

        override public function set BackgroundColor( value:uint ):void
        {
            _Input.BackgroundColor = value;
        }

        override public function set BackgroundColorEnabled( value:Boolean ):void
        {
            _Input.BackgroundColorEnabled = value;
        }

        /**下拉数据*/
        public function get DataProvider():Array
        {
            return this._DropdownMenu.Items;
        }

        /**
         *
         * @param value
         */
        public function set DataProvider( value:Array ):void
        {
            this._DropdownMenu.Items = value;
            SelectedIndex = 0;
        }

        /**
         *
         * @return
         */
        public function get DefaultTextFormat():TextFormat
        {
            return this._Input.defaultTextFormat;
        }

        /**
         *
         * @param format
         */
        public function set DefaultTextFormat( format:TextFormat ):void
        {
            if ( !format.font )
            {
                format.font = GlobalVariables.Font;
            }

            if ( !format.size )
            {
                format.size = GlobalVariables.FontSize;
            }
            _Input.defaultTextFormat = format;
        }
		
		public function set TextColor(value:uint):void
		{
			_Input.TextColor = value;
		}

        override public function set Enabled( val:Boolean ):void
        {
            super.Enabled = val;

            _Input.Enabled = val;
            _DropdownBtn.Enabled = val;
        }

        /**
         *
         * @return
         */
        public function get Label():String
        {
            return this._Input.Text;
        }

        /**
         *
         * @param value
         */
        public function set Label( value:String ):void
        {
            this._Input.Text = value;
        }


        /**当前选择数据*/
        public function get SelectedData():MenuItemData
        {
            return this._SelectedData;
        }

        /**
         *
         * @return
         */
        public function get SelectedIndex():int
        {
            return _SelectedIndex;
        }

        /**
         *
         * @param val
         */
        public function set SelectedIndex( val:int ):void
        {
            if ( SelectedIndex == val )
            {
                return;
            }

            if ( DataProvider==null || val<0 || val>=DataProvider.length )
            {

                _SelectedIndex = -1;
                _SelectedData = null;
                Label = "";
            }
            else
            {
                _SelectedIndex = val;
                _SelectedData = DataProvider[ val ];
                Label = _SelectedData.Label;
            }

            this.dispatchEvent( new UIEvent( UIEvent.ITEM_CLICK ));
        }

        override public function SetBgColor( enabled:Boolean, color:uint = 0, alpha:Number = 1 ):void
        {
            _Input.SetBgColor( enabled, color, alpha );
        }


        override public function set height( h:Number ):void
        {
            _Input.height = h;
//            _DropdownBtn.height = h;
            super.height = h;
        }

        override public function set width( w:Number ):void
        {
//            if ( _DropdownBtn )
//            {
//                _Input.width = w - 3;
//            }
            _Input.width = w;
            super.width = w;
        }

        /**
         *
         * @param e
         */
        protected function DropdownMenu_OnSelect( e:MenuEvent ):void
        {
            if ( e.Index==SelectedIndex )
            {
                return;
            }
            this.Label = e.Item.Label;
            _SelectedData = e.Item;
            _SelectedIndex = e.Index;

            this.dispatchEvent( new UIEvent( UIEvent.ITEM_CLICK ));
        }

        /**在这里弹出菜单*/
        protected function DropdownMenu_Show( e:MouseEvent ):void
        {
            if ( this.Enabled )
            {
                var p:Point = this._Input.localToGlobal( new Point( this._Input.x, this._Input.y ));
                var py:Number = p.y + this._Input.height+1;

                if ( this._DropdownMenu.height+py > GlobalVariables.StageHeight )
                {
                    py = p.y - 3 - this._DropdownMenu.height;
                }
                this._DropdownMenu.Show( false, p.x, py );
            }
        }

        override protected function PreInit():void
        {
            _DropdownMenu = new UMenu();
            _DropdownMenu.ItemRenderer = new ClassFactory( UComboBoxDropDownItem );
            _DropdownMenu.addEventListener( MenuEvent.ITEM_CLICK, DropdownMenu_OnSelect );
            GlobalVariables.CurrStage.addEventListener( KeyboardEvent.KEY_UP, Stage_OnKeyUp );

            _Input = new UInput( new TextFormat( GlobalVariables.Font, GlobalVariables.FontSize, 0xE9E7CF, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 3 ));
            _Input.MarginTop = 2;
            _Input.Editable = false;
            _Input.Selectable = false;
            _Input.BackgroundColorEnabled = true;
            _Input.BackgroundColor = 0x0;
            _Input.addEventListener( MouseEvent.CLICK, DropdownMenu_Show );
            this.addChild( _Input );

            if ( _ShowDropdownBtn )
            {
                _DropdownBtn = new UButton( "", false );
//                _DropdownBtn.ToolTip = "请选择";
                _DropdownBtn.DownSkin = new ComboButtonDownImage();
                _DropdownBtn.OverSkin = new ComboButtonOverImage();
                _DropdownBtn.UpSkin = new ComboButtonUpImage();
                _DropdownBtn.addEventListener( MouseEvent.CLICK, DropdownMenu_Show );
                this.addChild( _DropdownBtn );
            }

            super.PreInit();
        }

        override protected function ValidateSize():void
        {
            super.ValidateSize();

            this._Input.x = this.PaddingLeft;
            this._Input.y = this.PaddingTop;

            if ( _DropdownBtn )
            {
                _DropdownMenu.ItemWidth = _Input.width;
//				_DropdownMenu.Items = _DataProvider;
                _DropdownBtn.x = this._Input.x + this._Input.width - _DropdownBtn.width - 1;
                _DropdownBtn.y = this.PaddingTop + (height-_DropdownBtn.height)*0.5;
            }
        }

        private function Stage_OnKeyUp( e:KeyboardEvent ):void
        {
            switch ( e.keyCode )
            {
                case Keyboard.ESCAPE:
                    _DropdownMenu.Hide();
                    break;
            }
        }
    }
}
