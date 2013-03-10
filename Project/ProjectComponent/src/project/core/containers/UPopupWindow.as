package project.core.containers
{
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.system.System;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import project.core.controls.UButton;
    import project.core.events.UIEvent;
    import project.core.global.GlobalVariables;
    import project.core.image.CloseDownImage;
    import project.core.image.CloseOverImage;
    import project.core.image.CloseUpImage;
    import project.core.manager.PopupManager;
    import project.core.utils.Filters;

    [Event(name="hidden", type="project.core.events.UIEvent")]
    [Event(name="shown", type="project.core.events.UIEvent")]
    /**
     * 弹出窗口
     * @author meibin
     */
    public class UPopupWindow extends UWindow
    {
        /**
         * 默认 弹出窗口群组
         * @default
         */
        public static const UI_POPUP_GROUP:String = "UIWindow";

        /**
         * 弹出窗口
         * @param w 宽度
         * @param h 高度
         * @param modal 是否模式对话框
         * @param popupGroup 非模式对话框，相同群组的只能同时显示一个，自动把已显示的关掉
         * @param showClose 是否显示关闭按钮,按钮显示与否跟 CloseEnable的值是否可以关闭窗口无关
         */
        public function UPopupWindow( w:Number, h:Number, modal:Boolean = false, popupGroup:String = null, showClose:Boolean = false )
        {
            PopupGroup = popupGroup;
            _ShowClose = showClose;
            super( w, h, modal );
        }

        /**
         * 值为true时，PopupManager执行clear操作时不会将窗口关闭
         * 一般情况下在场景切换时会执行一次PopupManager.Clear()，如果希望保留窗口，则要将值设置为true
         * @default
         */
        public var IgnoreClear:Boolean = false;
        /**
         * 同组的弹出窗口只允许弹出一个,null为不限制
         */
        public var PopupGroup:String = null;
        /**
         *
         * @default
         */
        protected var _pCloseButton:UButton;
        /**
         *
         * @default
         */
        protected var _pTitle:TextField;
        private var _CloseEnable:Boolean = true;
        private var _CloseX:Number = -1;
        private var _CloseY:Number = -1;
        private var _DragEnabled:Boolean = false;
        private var _OffsetBgX:int;
        private var _OffsetBgY:int;
        private var _OffsetX:int;
        private var _OffsetY:int;
        private var _ShowClose:Boolean = false;

        /**
         * 是否可以关闭窗口，通过按钮或键盘。
         * 如果值为true，键盘esc和点关闭按钮可将窗口关闭
         * 此值与是否显示关闭按钮无关
         * @return
         */
        public function get CloseEnabled():Boolean
        {
            return _CloseEnable;
        }

        /**
         *
         * @param val
         */
        public function set CloseEnabled( val:Boolean ):void
        {
            _CloseEnable = val;

            if ( _pCloseButton )
            {
                _pCloseButton.visible = val;
            }
        }

        /**
         * 关闭按钮坐标X
         * @return
         */
        public function get CloseX():Number
        {
            return _CloseX;
        }

        /**
         *
         * @param value
         */
        public function set CloseX( value:Number ):void
        {
            if ( _CloseX==value )
            {
                return;
            }
            _CloseX = value;

            if ( _pCloseButton )
            {
                _pCloseButton.x = value==-1?width - _pCloseButton.width - 10:value;
            }
        }

        /**
         * 关闭按钮坐标Y
         * @return
         */
        public function get CloseY():Number
        {
            return _CloseY;
        }

        /**
         *
         * @param value
         */
        public function set CloseY( value:Number ):void
        {
            if ( _CloseY==value )
            {
                return;
            }
            _CloseY = value;

            if ( _pCloseButton )
            {
                _pCloseButton.y = value==-1?0:value;
            }
        }

        /**
         * 窗口是否可拖动，默认为false
         * @return
         */
        public function get DragEnabled():Boolean
        {
            return _DragEnabled;
        }

        /**
         * 窗口是否可拖动，默认为false
         * @param val
         */
        public function set DragEnabled( val:Boolean ):void
        {
            if ( DragEnabled==val )
            {
                return;
            }
            _DragEnabled = val;

            if ( val )
            {
                this.addEventListener( MouseEvent.MOUSE_DOWN, Win_OnDragStart );
            }
            else
            {
                this.removeEventListener( MouseEvent.MOUSE_DOWN, Win_OnDragStart );
                GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_UP, Win_OnDragEnd );
                GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_MOVE, Win_OnDragging );
            }
        }

        /**
         * 关闭窗口
         */
        public function Esc():void
        {
            Hide();
        }

        /**
         * 关闭窗口
         */
        public function Hide():void
        {
            if ( parent!=null )
            {
                parent.removeChild( this );
                this.dispatchEvent( new UIEvent( UIEvent.HIDDEN ));
                System.gc();
            }
        }

        /**
         * 显示窗口
         */
        public function Show( autoHide:Boolean = true ):void
        {
            if ( parent==null )
            {
                PopupManager.Show( this );
                this.dispatchEvent( new UIEvent( UIEvent.SHOWN ));
            }
            else if ( autoHide )
            {
                this.Hide();
            }
            else
            {
                PopupManager.ToTop( this );
            }
        }

        /**
         * 窗口标题
         * @return
         */
        public function get Title():String
        {
            return this._pTitle.text;
        }

        /**
         *
         * @param value
         */
        public function set Title( value:String ):void
        {
            _pTitle.text = value==null?"":value;
            ValidateTitle();
        }

        /**
         * 标题字体格式
         * @param fmt
         */
        public function set TitleFormat( fmt:TextFormat ):void
        {
            _pTitle.defaultTextFormat = fmt;
            _pTitle.setTextFormat( fmt );
            ValidateTitle();
        }

        /**
         * 标题坐标y
         * @param value
         */
        public function set TitleY( value:Number ):void
        {
            _pTitle.y = value;
        }

        override public function addChild( child:DisplayObject ):DisplayObject
        {
            if ( _pCloseButton && _pCloseButton.parent )
            {
                return addChildAt( child, this.getChildIndex( _pCloseButton ));
            }
            return ContentContainer.addChild( child );
        }

        override public function addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            if ( index>=this.numChildren &&_pCloseButton && _pCloseButton.parent )
            {
                index = this.getChildIndex( _pCloseButton );
            }
            return ContentContainer.addChildAt( child, index );
        }

        override public function set width( w:Number ):void
        {
            super.width = w;
            _pTitle.x = Math.round(( width - _pTitle.width )*0.5+PaddingLeft );
        }

        /**
         *
         * @param e
         */
        protected function Close_OnClick( e:MouseEvent ):void
        {
            this.Hide();
        }

        protected function InitCloseButton():void
        {
            var skin:Bitmap = new CloseUpImage();
            _pCloseButton = new UButton( "", false, skin.width, skin.height );
            _pCloseButton.Border = false;
            _pCloseButton.Background = false;
            _pCloseButton.DownSkin = new CloseDownImage();
            _pCloseButton.OverSkin = new CloseOverImage();
            _pCloseButton.UpSkin = skin;
        }

        override protected function PreInit():void
        {
            if ( _ShowClose )
            {
                InitCloseButton();
                _pCloseButton.addEventListener( MouseEvent.CLICK, Close_OnClick );
                addChild( _pCloseButton );
            }
            _pTitle = new TextField();
            _pTitle.mouseEnabled = false;
            _pTitle.selectable = false;
            _pTitle.defaultTextFormat = new TextFormat( GlobalVariables.Font, GlobalVariables.FontSize, 0xFFFFB0, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 3 );
            _pTitle.filters = [Filters.TextGlow];
            _pTitle.y = 10;
            addChild( _pTitle );
            super.PreInit();
        }

        override protected function Stage_OnResize( e:Event ):void
        {
            super.Stage_OnResize( e );

            if ( _pCloseButton )
            {
                _pCloseButton.x = this.CloseX==-1 ? width - _pCloseButton.width - 20: this.CloseX;
                _pCloseButton.y = this.CloseY==-1 ? 15 :this.CloseY;
            }
        }

        /**
         *
         */
        protected function ValidateTitle():void
        {
            _pTitle.width = _pTitle.textWidth+4;
            _pTitle.height = _pTitle.textHeight+4;
            _pTitle.x = Math.round(( width - _pTitle.width )*0.5 );
        }

        private function Win_OnDragEnd( e:MouseEvent ):void
        {
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_MOVE, Win_OnDragging );
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_UP, Win_OnDragEnd );
        }

        private function Win_OnDragStart( e:MouseEvent ):void
        {
            _OffsetX = e.stageX - PositionX;
            _OffsetY = e.stageY - PositionY;

            if ( _OffsetX>=0 && _OffsetY>=0 && _OffsetX<=this.width &&_OffsetY<=this.height )
            {
                _OffsetBgX = e.stageX - BgContainer.x - _OffsetX;
                _OffsetBgY = e.stageY - BgContainer.y - _OffsetY;
                GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_MOVE, Win_OnDragging );
                GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_UP, Win_OnDragEnd );
            }
        }

        private function Win_OnDragging( e:MouseEvent ):void
        {
            var ox:Number = e.stageX;
            var oy:Number = e.stageY;
            var px:Number = ox - _OffsetX;

            if ( px < 0 )
            {
                px = 0;
            }
            else if ( px+width>GlobalVariables.StageWidth )
            {
                px = GlobalVariables.StageWidth - width;
            }
            this.PositionX = px;
            var py:Number = oy - _OffsetY;

            if ( py < 0 )
            {
                py = 0;
            }
            else if ( py+height>GlobalVariables.StageHeight )
            {
                py = GlobalVariables.StageHeight - height;
            }
            this.PositionY = py;

            this.BgContainer.x = px - _OffsetBgX;
            this.BgContainer.y = py - _OffsetBgY;
        }
    }
}
