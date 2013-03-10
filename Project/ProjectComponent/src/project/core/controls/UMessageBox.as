package project.core.controls
{
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import project.core.containers.UBox;
    import project.core.containers.UPopupWindow;
    import project.core.events.UIEvent;
    import project.core.global.GlobalVariables;
    import project.core.manager.Debugger;
    import project.core.text.IText;

    /**
     * 弹出信息框
     * @author meibin
     */
    public class UMessageBox extends UPopupWindow
    {
        /**
         *
         * @default
         */
        public static const CANCEL:uint = 2;
        /**
         *
         * @default
         */
        public static var CancelText:String = "cancel";
        /**
         *
         * @default
         */
        public static var MinHeight:int = 110;
        /**
         *
         * @default
         */
        public static var MinWidth:int = 120;
        /**
         *
         * @default
         */
        public static const OK:uint = 1;
        /**
         *
         * @default
         */
        public static var OkText:String = "ok";

//        private static var _Instance:UMessageBox = new UMessageBox();

        /**
         * 弹出对话框
         * @msg 对话框内容
         * @title 对话框标题
         * @modal 是否模式对话框
         * @flag 对话框按钮。如：UMessageBox.OK|UMessageBox.CANCEL
         * @defaultFlag 默认选中的按钮，当按下回车键时触发。
         */
        public static function Show( msg:*, title:String = null, modal:Boolean = true, callback:Function = null, flags:uint = 1, defaultFlag:uint = 1, alawaysShow:Boolean = false ):void
        {
            var alert:UMessageBox = new UMessageBox();
            alert.IgnoreClear = alawaysShow;
            alert.Modal = modal;
            alert.Title = title;
            alert.Message = msg;
            alert.ButtonFlags = flags;
            alert.DefaultButtonFlag = defaultFlag;
            alert.Callback = callback;
            alert.Show();
        }

        /**
         *
         */
        public function UMessageBox()
        {
            super( 0, 0 );
            this.DragEnabled = true;
            Padding = [15,3,15,10];
            _ButtonGroup.Gap = 10;
            _Message.multiline = true;
            _Message.selectable = false;
            _Message.mouseEnabled = false;
            _Message.defaultTextFormat = _DefaultFmt;
        }

        /**
         *
         * @default
         */
        public var Callback:Function;
        /**
         *
         * @default
         */
        public var DefaultButtonFlag:uint=OK;
        /**
         * 按钮之间的空隙
         */
        public var HorGap:Number = 5;
        /**
         * 标题、内容、按钮之间的空隙
         */
        public var VerGap:Number = 5;
        /**
         *
         * @default
         */
        protected var _ButtonGroup:UBox = new UBox();
        /**
         *
         * @default
         */
        protected var _Message:TextField = new TextField();
        private var _ButtonFlags:uint = 1;
        private var _CancelButton:UButton;
        private var _DefaultFmt:TextFormat = new TextFormat( GlobalVariables.Font, GlobalVariables.FontSize, 0xE9E7CF, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 3 );
        private var _OkButton:UButton;

        /**
         *
         * @param flag
         */
        public function set ButtonFlags( flag:uint ):void
        {
            _ButtonFlags= flag;
        }

        /**
         *
         */
        public function DoEnter():void
        {
			Hide();
            if ( Callback!=null )
            {
                Callback( this.DefaultButtonFlag );
                Callback = null;
            }
        }

        override public function Esc():void
        {
			Hide();
            if ( Callback!=null )
            {
                if ((_ButtonFlags&CANCEL)!=0 )
                {
                    Callback( CANCEL );
                }
                else
                {
                    Callback( OK );
                }
                Callback = null;
            }
        }

        override public function Hide():void
        {
			this.Background = null;
			if(_OkButton) {
				_OkButton.removeEventListener( MouseEvent.CLICK, Button_OnClick );
			}
			if( _CancelButton ) {
				_CancelButton.removeEventListener( MouseEvent.CLICK, Button_OnClick );
			}
            while ( _ButtonGroup.numChildren>0 )
            {
                _ButtonGroup.removeChildAt( 0 );
            }
			_OkButton = null;
			_CancelButton = null;
            super.Hide();
        }

        /**
         *
         * @return
         */
        public function get Message():*
        {
            return _Message.text;
        }

        /**
         *
         * @param val
         */
        public function set Message( val:* ):void
        {
			if ( val!=null && val is IText )
			{
				(val as IText).ToTextField( _Message, null, _DefaultFmt );
			} else 
            {
                _Message.htmlText = val==null?"":val.toString();
                _Message.width = _Message.textWidth+4;
                _Message.height = _Message.textHeight+4;
            }
            
        }

        override public function Show( autoHide:Boolean = true ):void
        {
            if ((_ButtonFlags&OK)!=0 )
            {
                _ButtonGroup.addChild( _OkButton );
            }

            if ((_ButtonFlags&CANCEL)!=0 )
            {
                _ButtonGroup.addChild( _CancelButton );
            }

            var btnHeight:Number = CalculateButtonGroupHeight();
            var titHeight:Number = CalculateTitleHeight();
            var h:Number = titHeight+_Message.height+btnHeight;
            var w:Number = Math.max( _pTitle.width, _Message.width, _ButtonGroup.width )+PaddingLeft + PaddingRight;

            Resize( w, h );

            w = width-PaddingLeft-PaddingRight;
            _Message.x = Math.round( PaddingLeft+( w-_Message.width )*0.5 );
            _Message.y = Math.round( titHeight+( height-h )*0.5 );

            //计算按钮位置
            _ButtonGroup.y = height - PaddingBottom - _OkButton.height;
            _ButtonGroup.x = (w - _ButtonGroup.width)*0.5 + PaddingLeft;

            _pTitle.x = Math.round(( w - _pTitle.width )*0.5+PaddingLeft );
            _pTitle.y = PaddingTop+2;

            ValidatePosition();
            RepaintBG();
            super.Show( autoHide );
        }

        /**
         *
         * @return
         */
        protected function CalculateButtonGroupHeight():Number
        {
            return _OkButton.height+VerGap+PaddingBottom;
        }

        /**
         *
         * @return
         */
        protected function CalculateTitleHeight():Number
        {
            return _pTitle.height+PaddingTop+VerGap;
        }

        /**
         *
         * @param label
         * @return
         */
        protected function CreateButton( label:String ):UButton
        {
            return new UButton( label );
        }

        override protected function PreInit():void
        {
            _CancelButton = CreateButton( CancelText );
            _CancelButton.name = "cancel";
            _OkButton = CreateButton( OkText );
            _OkButton.name = "ok";

            if ( !Background )
            {
				
				var b:UImage = new UImage("resource/Image/UI/common_win_bg.jpg");
				b.scale9Grid = new Rectangle(63,30,321,250);
				
//                var b:ScaleBitmap = WinBgImage.GetImage();
                MinWidth = Math.max( MinWidth, 446-b.scale9Grid.width );
                MinHeight = Math.max( MinHeight, 312-b.scale9Grid.height );
                this.Background = b;
            }
            addChild( _Message );

            _OkButton.name = UIEvent.OK;
            _CancelButton.name = UIEvent.CANCEL;
            _OkButton.addEventListener( MouseEvent.CLICK, Button_OnClick );
            _CancelButton.addEventListener( MouseEvent.CLICK, Button_OnClick );

            addChild( _ButtonGroup );

            super.PreInit();
            _pTitle.height = 20;
        }

        /**
         *
         * @param w
         * @param h
         */
        protected function Resize( w:Number, h:Number ):void
        {
            if ( w<MinWidth )
            {
                width = MinWidth;
            }
            else
            {
                width = w;
            }

            if ( h<MinHeight )
            {
                height = MinHeight;
            }
            else
            {
                height = h;
            }
        }

        override protected function ValidateTitle():void
        {
            super.ValidateTitle();
            _pTitle.height = 20;
        }

        private function Button_OnClick( e:MouseEvent ):void
        {
			Hide();
            if ( Callback!=null )
            {
                switch ( e.currentTarget.name )
                {
                    case UIEvent.OK:
                        Callback( OK );
                        break;
                    case UIEvent.CANCEL:
                        Callback( CANCEL );
                        break;
                }
                Callback = null;
            }
        }
    }
}
