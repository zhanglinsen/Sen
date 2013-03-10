package project.core.tooltip
{
//	import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    
    import project.core.controls.USprite;
    import project.core.global.GlobalVariables;
    import project.core.image.TooltipBgImage;
    import project.core.manager.ToolTipManager;
    import project.core.utils.Filters;

    public class AbstractToolTipUI extends USprite implements IToolTipUI
    {
        public function AbstractToolTipUI()
        {
            super();
            this.BackgroundImage = TooltipBgImage.GetImage();
            Padding = [5,4,4,1];
            mouseEnabled = false;
            mouseChildren = false;
            this.filters = [Filters.Shadow];
        }

        public var EllipseHeight:int = 8;
        public var EllipseWidth:int = 8;
        private var _BgAlpha:Number = 1;

//		private var _BgBitmapData:BitmapData;
        private var _BgColor:uint = 0xE6EBA7;
        private var _BgImage:DisplayObject=null;
        private var _Data:Object;
        private var _Height:Number;
        private var _OffsetX:int = 4;
        private var _OffsetY:int = 20;
        private var _Width:Number;

        public function get BackgroundAlpha():Number
        {
            return _BgAlpha;
        }

        public function set BackgroundAlpha( alpha:Number ):void
        {
            _BgAlpha = alpha;
        }

        public function get BackgroundColor():uint
        {
            return _BgColor;
        }

        public function set BackgroundColor( color:uint ):void
        {
            _BgColor = color;
        }

        public function get BackgroundImage():DisplayObject
        {
            return _BgImage;
        }

        public function set BackgroundImage( img:DisplayObject ):void
        {
            if ( _BgImage==img )
            {
                return;
            }
            _BgImage = img;

//			_BgBitmapData = new BitmapData( img.width, img.height, true, 0 );
//			_BgBitmapData.draw( img );

        }

        public function get Data():Object
        {
            return _Data;
        }

        public function set Data( obj:Object ):void
        {
            _Data = obj;

            if ( !obj )
            {
                Hide();
            }
            else
            {
                if ( parent )
                {
                    UpdateUI();
                }
            }
        }


        public function Hide():void
        {
            if ( parent!=null )
            {
                parent.removeChild( this );
            }
        }

        public function get OffsetX():int
        {
            return _OffsetX;
        }

        public function set OffsetX( x:int ):void
        {
            _OffsetX = x;
        }

        public function get OffsetY():int
        {
            return _OffsetY;
        }

        public function set OffsetY( y:int ):void
        {
            _OffsetY=y;
        }

        public function Show( target:InteractiveObject ):void
        {
            if ( !Data )
            {
                return;
            }
            UpdateUI();
            var px:Number = GlobalVariables.Root.mouseX;
            var py:Number = GlobalVariables.Root.mouseY;
            var mx:Number = px + OffsetX + width;

            if ( mx>GlobalVariables.StageWidth )
            {
                //超过显示范围
                px -= width+1;
            }
            else
            {
                px += OffsetX;
            }
            var my:Number = py + OffsetY + height;

            if ( my>GlobalVariables.StageHeight )
            {
                //超过显示范围
                py -= height+1;
            }
            else
            {
                py += OffsetY;
            }
            this.x = px;
            this.y = py;
            ToolTipManager.Root.addChild( this );
        }

        override public function get height():Number
        {
            return _Height;
        }

        override public function set height( value:Number ):void
        {
            _Height = value;

            if ( BackgroundImage )
            {
                BackgroundImage.height = height;
            }
        }

        override public function get width():Number
        {
            return _Width;
        }

        override public function set width( value:Number ):void
        {
            _Width = value;

            if ( BackgroundImage )
            {
                BackgroundImage.width = width;
            }
        }

        protected function UpdateUI():void
        {
            if ( BackgroundImage )
            {
                BackgroundImage.width = width;
                BackgroundImage.height = height;
                addChildAt( BackgroundImage, 0 );
                return;
            }
            this.graphics.clear();

//			if ( _BgBitmapData==null )
//			{
            this.graphics.beginFill( BackgroundColor, BackgroundAlpha );
//			}
//			else
//			{
//				this.graphics.beginBitmapFill( _BgBitmapData );
//			}
            this.graphics.drawRoundRect( 0, 0, width, height, EllipseWidth, EllipseHeight );
            this.graphics.endFill();
        }
    }
}