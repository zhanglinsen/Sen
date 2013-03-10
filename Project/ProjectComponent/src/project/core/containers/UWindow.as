package project.core.containers
{
    import flash.display.Sprite;
    import flash.events.Event;
    
    import project.core.global.DirectionConst;
    import project.core.global.GlobalVariables;

    /**
     * 窗口
     */
    public class UWindow extends UCanvas
    {
        public function UWindow( w:Number = -1, h:Number = -1, modal:Boolean = false )
        {
            super( false, 0, 1, DirectionConst.ABSOLUTE, 3, w, h );
            Modal = modal;
        }

        /**
         * 是否模式窗口
         */
        private var _Modal:Boolean=false;
        /**
         * 模式窗口屏蔽其他内容的透明度
         */
        private var _ModalAlpha:Number = 0;
        private var _ModalMC:Sprite = new Sprite();
        private var _OffsetX:Number=0;
        private var _OffsetY:Number=0;
        private var _X:Number=-1;
        private var _Y:Number=-1;

        /**
         * 是否模式窗口
         */
        public function get Modal():Boolean
        {
            return _Modal;
        }

        public function set Modal( modal:Boolean ):void
        {
            if ( _Modal==modal )
            {
                return;
            }
            _Modal = modal;

            if ( Modal )
            {
                DrawModalMC();
                $addChildAt( _ModalMC, 0 );
            }
            else
            {
                $removeChild( _ModalMC );
            }
        }

        /**
         * 模式窗口屏蔽层的透明度
         */
        public function get ModalAlpha():Number
        {
            return _ModalAlpha;
        }

        public function set ModalAlpha( alpha:Number ):void
        {
            _ModalAlpha = alpha;
            DrawModalMC();
        }

        public function get OffsetX():Number
        {
            return _OffsetX;
        }

        public function set OffsetX( x:Number ):void
        {
			BgContainer.x = PositionX = BgContainer.x - OffsetX + x;
            _OffsetX = x;
            ValidatePosition();
        }

        public function get OffsetY():Number
        {
            return _OffsetY;
        }

        public function set OffsetY( y:Number ):void
        {
			BgContainer.y = PositionY = BgContainer.y - OffsetY + y;
            _OffsetY = y;
            ValidatePosition();
        }

        /**
         * 窗口高度
         */
        override public function get height():Number
        {
            return super.height==-1?GlobalVariables.StageHeight:super.height;
        }

        /**
         * 窗口宽度
         */
        override public function get width():Number
        {
            return super.width==-1?GlobalVariables.StageWidth:super.width;
        }

        override public function get x():Number
        {
            return _X==-1?ContentContainer.x:_X;
        }

        override public function set x( value:Number ):void
        {
            if ( _X==value )
            {
                return;
            }
            _X = value;
            ValidatePosition();
        }

        override public function get y():Number
        {
            return _Y==-1?ContentContainer.y:_Y;
        }

        override public function set y( value:Number ):void
        {
            if ( _Y==value )
            {
                return;
            }
            _Y = value;
            ValidatePosition();
        }

        protected function get $x():Number
        {
            return _X;
        }

        protected function get $y():Number
        {
            return _Y;
        }

        override protected function PreInit():void
        {
            if ( stage )
            {
                Init();
            }
            else
            {
                addEventListener( Event.ADDED_TO_STAGE, Init );
            }
        }

        /**
         * 绘制模式窗口的屏蔽层
         */
        protected function DrawModalMC():void
        {
            if ( Modal )
            {
                _ModalMC.graphics.clear();
                _ModalMC.graphics.beginFill( 0x0, _ModalAlpha );
                _ModalMC.graphics.drawRect( 0, 0, GlobalVariables.StageWidth, GlobalVariables.StageHeight );
                _ModalMC.graphics.endFill();
            }
        }

        /**
         * 初始化
         */
        override protected function Init( e:Event = null ):void
        {
            super.Init();

            if ( Modal )
            {
                setContainerIndex( _ModalMC, 0 );
            }
            removeEventListener( Event.ADDED_TO_STAGE, Init );
            Stage_OnResize( null );
            stage.addEventListener( Event.RESIZE, Stage_OnResize );
        }

        /**
         * 大小改变时的动作
         */
        protected function Stage_OnResize( e:Event ):void
        {
            ValidatePosition();
            DrawModalMC();
        }

        protected function ValidatePosition():void
        {
            if ( !Initialized )
            {
                return;
            }
            BgContainer.x = PositionX = _X!=-1?_X:OffsetX + (GlobalVariables.StageWidth - width) * 0.5;
            BgContainer.y = PositionY = _Y!=-1?_Y:OffsetY + (GlobalVariables.StageHeight - height) * 0.5;
            this.ValidateScrollPos();
        }

        override protected function ValidateSize():void
        {
            super.ValidateSize();
            ValidatePosition();
        }
    }
}