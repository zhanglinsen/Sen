package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    import project.core.containers.UCanvas;
    import project.core.events.UIEvent;
    import project.core.global.DirectionConst;
    import project.core.global.GlobalVariables;
    import project.core.image.DownBtnOverImage;
    import project.core.image.DownBtnUpImage;
    import project.core.image.ScrollBarOverImage;
    import project.core.image.ScrollBarUpImage;
    import project.core.image.UpBtnOverImage;
    import project.core.image.UpBtnUpImage;

    [Event(name="positionChange", type="project.core.events.UIEvent")]
    /**
     * 滚动条
     * @author meibin
     */
    public class UScrollBar extends Sprite
    {
        /**
         * 
         * @param target 滚动条影响的对象
         * @param direction 滚动条方向
         */
        public function UScrollBar( target:DisplayObject, direction:String = DirectionConst.VERTICAL )
        {
            super();
            _Target = target;
            _Width = target.width;
            _Height = target.height;

            _MinusBtn = new UButton( "", false );
            _MinusBtn.Background = false;
            _MinusBtn.Border = false;
            _MinusBtn.OverSkin = new UpBtnOverImage();
            _MinusBtn.UpSkin = new UpBtnUpImage();
            _MinusBtn.width = BAR_SIZE_W;
            _MinusBtn.height = BAR_SIZE_W;
            _MinusBtn.addEventListener( MouseEvent.MOUSE_DOWN, Minus_OnPress );

            _PlusBtn = new UButton( "", false );
            _PlusBtn.Background = false;
            _PlusBtn.Border = false;
            _PlusBtn.OverSkin = new DownBtnOverImage();
            _PlusBtn.UpSkin = new DownBtnUpImage();
            _PlusBtn.width = BAR_SIZE_W;
            _PlusBtn.height = BAR_SIZE_W;
            _PlusBtn.addEventListener( MouseEvent.MOUSE_DOWN, Plus_OnPress );

            _BarBtn = new UButton( "", false );
            _BarBtn.SoundEnabled = false;
            _BarBtn.Background = false;
            _BarBtn.Border = false;

            _BarBtn.OverSkin = ScrollBarOverImage.GetImage();
            _BarBtn.UpSkin = ScrollBarUpImage.GetImage();

            _BarBtn.width = BAR_SIZE_W;
            _BarBtn.height = BAR_SIZE_H;
            _BarBtn.addEventListener( MouseEvent.MOUSE_DOWN, Bar_OnMouseDown );

            this._BarBtn.visible = false;
            this._MinusBtn.Enabled = false;
            this._PlusBtn.Enabled = false;

            addChild( _MinusBtn );
            addChild( _PlusBtn );
            addChild( _BarBtn );

            Direction = direction;
        }

        private const BAR_SIZE_H:int = 30;
        private const BAR_SIZE_W:int = 20;
        private var _AutoScrollTimer:Timer = null;

        private var _AutoStep:Number;

        private var _AutoTimeID:uint;

        private var _BarBtn:UButton;
        private var _ContentHeight:Number=0;

        private var _ContentWidth:Number=0;
        private var _Direction:String;
        private var _Gap:int = 1;
        private var _Height:Number;
        private var _MaxPos:Number=0;
        private var _MinusBtn:UButton;
        private var _OriPos:Number;
        private var _PlusBtn:UButton;

        private var _Pos:Number=0;
        private var _ScaleChange:Boolean = false;
        private var _ScrollScale:Number=1;

        private var _ScrollSize:Number=0;

        private var _ScrollStep:Number = 3;
        private var _StartX:Number;
        private var _StartY:Number;
        private var _Target:DisplayObject;
        private var _Width:Number;

        /**
         * 
         * @return 
         */
        public function get ContentHeight():Number
        {
            return (_ContentHeight==0?_Target.height:_ContentHeight); //-_Target.PaddingTop-_Target.PaddingBottom;
        }

        /**
         * 
         * @param val
         */
        public function set ContentHeight( val:Number ):void
        {
            if ( _ContentHeight==val )
            {
                return;
            }
            _ContentHeight = val;

//			_ContentHeight = val-_Target.PaddingTop-_Target.PaddingBottom;
            if ( this.Direction==DirectionConst.VERTICAL )
            {
                MeasureVSize();
                this.Position = this.Position;
//				this.ValidateSize();
            }
        }

        /**
         * 
         * @return 
         */
        public function get ContentWidth():Number
        {
            return (_ContentWidth==0?_Target.width:_ContentWidth); //-_Target.PaddingLeft-_Target.PaddingRight;
        }

        /**
         * 
         * @param val
         */
        public function set ContentWidth( val:Number ):void
        {
            if ( _ContentWidth==val )
            {
                return;
            }
            _ContentWidth = val;

//			_ContentWidth = val-_Target.PaddingLeft-_Target.PaddingRight;
            if ( this.Direction==DirectionConst.HORIZONTAL )
            {
                MeasureHSize();
                this.Position = this.Position;
//				this.ValidateSize();
            }
        }

        /**
         * 
         * @return 
         */
        public function get Direction():String
        {
            return _Direction;
        }

        /**
         * 
         * @param dir
         */
        public function set Direction( dir:String ):void
        {
            if ( Direction==dir )
            {
                return;
            }
            _Direction = dir;

            Repaint();
        }

        /**
         * 
         * @return 
         */
        public function get MaxPosition():Number
        {
            return _MaxPos;
        }

        /**
         * 
         * @return 
         */
        public function get MinPosition():Number
        {
            return 0;
        }

        /**
         * 
         * @return 
         */
        public function get Position():Number
        {
            return _Pos; //*_ScrollScale;
        }

        /**
         * 
         * @param val
         */
        public function set Position( val:Number ):void
        {
            if ( val<MinPosition )
            {
                val = MinPosition;
            }
            else if ( val>MaxPosition )
            {
                val = MaxPosition;
            }

            if ( _Pos == val && !_ScaleChange )
            {
                return;
            }
            _ScaleChange = false;
            _Pos = val;
            var evt:UIEvent = new UIEvent( UIEvent.POSITION_CHANGE );
            evt.Data = Position*_ScrollScale;
            this.dispatchEvent( evt );
            ValidatePosition();
        }

        /**
         * 
         * @return 
         */
        public function get ScrollEnabled():Boolean
        {
            return _BarBtn.visible;
        }

        /**
         * 
         * @return 
         */
        public function get ScrollScale():Number
        {
            return _ScrollScale;
        }

        /**
         * 
         * @return 
         */
        public function get ScrollStep():Number
        {
            return ContentHeight==height ? 0 :_ScrollStep*MaxPosition/(ContentHeight-height);
        }

        /**
         * 
         * @param val
         */
        public function set ScrollStep( val:Number ):void
        {
            _ScrollStep = val;
        }

//        /**
//         * 
//         * @return 
//         */
//        public function get Target():DisplayObject
//        {
//            return _Target;
//        }
//        /**
//         * 
//         * @param target
//         */
//        public function set Target( target:DisplayObject ):void
//        {
//            if ( _Target == target )
//            {
//                return;
//            }
//            _Target = target;
//
//            Repaint();
//        }

        override public function get height():Number
        {
            return _Height;
        }

        override public function set height( value:Number ):void
        {
            if ( _Height==value )
            {
                return;
            }
            _Height = value;

            var pos:Number = this.Position/this.MaxPosition;
            ValidateSize();

            if ( this.Direction==DirectionConst.VERTICAL )
            {
                Position = pos * this.MaxPosition;
            }
        }

        override public function get width():Number
        {
            return _Width;
        }

        override public function set width( value:Number ):void
        {
            if ( _Width==value )
            {
                return;
            }
            _Width = value;

            var pos:Number = this.Position/this.MaxPosition;
            ValidateSize();

            if ( this.Direction==DirectionConst.HORIZONTAL )
            {
                Position = pos * this.MaxPosition;
            }
        }

        /**
         * 
         */
        protected function MeasureHSize():void
        {
            if ( width==0 )
            {
                return;
            }
            _ScrollSize = width - BAR_SIZE_W*2 - _Gap*2;
//			var targetWidth:int = _Target.width-_Target.PaddingLeft-_Target.PaddingRight;
            var scale:Number = (int( ContentWidth )-width) / width;

            if ( _ScrollScale==scale )
            {
                return;
            }
            _ScrollScale = scale;
            _MaxPos = _ScrollSize - BAR_SIZE_H;

            var scalable:Boolean = scale>0;
            this._BarBtn.visible = scalable;
            this._MinusBtn.Enabled = scalable;
            this._PlusBtn.Enabled = scalable;
            _ScaleChange = true;
        }

        /**
         * 
         */
        protected function MeasureVSize():void
        {
            if ( height==0 )
            {
                return;
            }
            _ScrollSize = height - BAR_SIZE_W*2 - _Gap*2;
//			var targetHeight:int = _Target.height-_Target.PaddingTop-_Target.PaddingBottom;
            var scale:Number = (int( ContentHeight )-height) / height;

            if ( _ScrollScale==scale )
            {
                return;
            }
            _ScrollScale = scale;
            _MaxPos = _ScrollSize - BAR_SIZE_H;

            var scalable:Boolean = scale>0;
            this._BarBtn.visible = scalable;
            this._MinusBtn.Enabled = scalable;
            this._PlusBtn.Enabled = scalable;
            _ScaleChange = true;
        }

        /**
         * 
         */
        protected function Repaint():void
        {
            if ( Direction==DirectionConst.HORIZONTAL )
            {
                _Width = _Target.width;
                _Height= BAR_SIZE_W;
            }
            else
            {
                _Width= BAR_SIZE_W;
                _Height = _Target.height;
            }
            ValidateSize();
            ValidatePosition();
        }

        /**
         * 
         */
        protected function ValidatePosition():void
        {
            var pos:Number = Position + BAR_SIZE_W + _Gap;

            if ( this.Direction==DirectionConst.HORIZONTAL )
            {
                _BarBtn.x = pos;
                _BarBtn.y = 0;
            }
            else
            {
                _BarBtn.x = 0;
                _BarBtn.y = pos;
            }
        }

        /**
         * 
         */
        protected function ValidateSize():void
        {
            var w:Number;
            var h:Number;

            if ( this.Direction==DirectionConst.HORIZONTAL )
            {
                MeasureHSize();
                _BarBtn.height = BAR_SIZE_W;
                _BarBtn.width = BAR_SIZE_H;
                _PlusBtn.x = width - _PlusBtn.width;
                w = width;
                h = BAR_SIZE_W;
            }
            else
            {
                MeasureVSize();
                _BarBtn.width = BAR_SIZE_W;
                _BarBtn.height = BAR_SIZE_H;
                _PlusBtn.y = height - _PlusBtn.height;
                w = BAR_SIZE_W;
                h = height;
            }
            this.graphics.clear();
            this.graphics.beginFill( 0x0, 0.25 );
            this.graphics.drawRect( 0, 0, w, h );
            this.graphics.endFill();
        }

        private function AutoScroll():void
        {
            if ( _AutoScrollTimer==null )
            {
                _AutoScrollTimer = new Timer( 70, int.MAX_VALUE );
                _AutoScrollTimer.addEventListener( TimerEvent.TIMER, AutoScroll_OnTimer );
            }
            _AutoScrollTimer.reset();
            _AutoScrollTimer.start();
        }

        private function AutoScroll_OnTimer( e:TimerEvent ):void
        {
            this.Position = Position + _AutoStep;

            if ( Position==this.MinPosition || Position==this.MaxPosition )
            {
                _AutoScrollTimer.stop();
            }
        }

        private function Bar_OnDrag( e:MouseEvent ):void
        {
            if ( this.Direction==DirectionConst.HORIZONTAL )
            {
                this.Position = _OriPos + e.stageX - _StartX;
            }
            else
            {
                this.Position = _OriPos + e.stageY - _StartY;
            }
        }

        private function Bar_OnMouseDown( e:MouseEvent ):void
        {
            GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_UP, Bar_OnRelease );
            GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_MOVE, Bar_OnDrag );
            _OriPos = Position;
            _StartX = e.stageX;
            _StartY = e.stageY;
        }

        private function Bar_OnRelease( e:MouseEvent ):void
        {
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_UP, Bar_OnRelease );
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_MOVE, Bar_OnDrag );
        }

        private function DelayAutoScroll( step:Number ):void
        {
            _AutoStep = step;
            GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_UP, StopAutoScroll );
            _AutoTimeID = setTimeout( AutoScroll, 400 );
        }

        private function Minus_OnPress( e:MouseEvent ):void
        {
            this.Position = Position - ScrollStep;
            DelayAutoScroll( -ScrollStep );
        }

        private function Plus_OnPress( e:MouseEvent ):void
        {
            this.Position = Position + ScrollStep;
            DelayAutoScroll( ScrollStep );
        }

        private function StopAutoScroll( e:MouseEvent ):void
        {
            clearTimeout( _AutoTimeID );

            if ( _AutoScrollTimer!=null )
            {
                _AutoScrollTimer.stop();
            }
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_UP, StopAutoScroll );
        }
    }
}
