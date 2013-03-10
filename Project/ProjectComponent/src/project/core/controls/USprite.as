package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.system.System;

	/**
	 * USprite容器，基础容器类
	 * @param w 容器宽度 
	 * @param h 容器高度
	 */
    public class USprite extends Sprite
    {
        public function USprite(w:Number=0, h:Number=0)
        {
            super();
			_Width = w;
			_Height = h;
        }
//		override public function set x(value:Number):void {
//			super.x = Math.round(value);
//		}
//		override public function set y(value:Number):void {
//			super.y = Math.round(value);
//		}
        private var _Height:Number=0;
        private var _Ident:int;
		
        private var _MarginBottom:int;
        private var _MarginLeft:int;
        private var _MarginRight:int;
        private var _MarginTop:int;

        private var _PaddingBottom:Number = 0;
        private var _PaddingLeft:Number = 0;
        private var _PaddingRight:Number = 0;
        private var _PaddingTop:Number = 0;
		
        private var _Sides:Array = ["Left","Top", "Right", "Bottom"];
        private var _Width:Number=0;

        public function get Ident():int
        {
            return _Ident;
        }

        public function set Ident( ident:int ):void
        {
            _Ident = ident;
        }

        /**
         * [left, top, right, bottom]
         */
        public function set Margin( val:Array ):void
        {
            for ( var i:int=0; i<val.length; i++ )
            {
                this["_Margin" + _Sides[i]] = val[i];
            }
			ValidateSize();
        }

        public function get MarginBottom():int
        {
            return _MarginBottom;
        }

        public function set MarginBottom( value:int ):void
        {
			if( MarginBottom==value ) {
				return ;
			}
            _MarginBottom = value;
			ValidateSize();
        }

        public function get MarginLeft():int
        {
            return _MarginLeft;
        }

        public function set MarginLeft( value:int ):void
        {
			if( MarginLeft==value ) {
				return ;
			}
            _MarginLeft = value;
			ValidateSize();
        }

        public function get MarginRight():int
        {
            return _MarginRight;
        }

        public function set MarginRight( value:int ):void
        {
			if( MarginRight==value ) {
				return ;
			}
            _MarginRight = value;
			ValidateSize();
        }

        public function get MarginTop():int
        {
            return _MarginTop;
        }

        public function set MarginTop( value:int ):void
        {
			if( MarginTop==value ) {
				return ;
			}
            _MarginTop = value;
			ValidateSize();
        }

        public function get Padding():Array
        {
            return [_PaddingLeft,_PaddingTop,_PaddingRight,_PaddingBottom];
        }

        /**
         * [left, top, right, bottom]
         */
        public function set Padding( val:Array ):void
        {
            for ( var i:int=0; i<val.length; i++ )
            {
                this["_Padding" + _Sides[i]] = val[i];
            }
            ValidateSize();
        }

        public function get PaddingBottom():Number
        {
            return _PaddingBottom;
        }

        public function set PaddingBottom( value:Number ):void
        {
            if ( PaddingBottom==value )
            {
                return;
            }
            _PaddingBottom = value;
            ValidateSize();
        }

        public function get PaddingLeft():Number
        {
            return _PaddingLeft;
        }

        public function set PaddingLeft( value:Number ):void
        {
            if ( PaddingLeft==value )
            {
                return;
            }
            _PaddingLeft = value;
            ValidateSize();
        }

        public function get PaddingRight():Number
        {
            return _PaddingRight;
        }

        public function set PaddingRight( value:Number ):void
        {
            if ( PaddingRight==value )
            {
                return;
            }
            _PaddingRight = value;
            ValidateSize();
        }

        public function get PaddingTop():Number
        {
            return _PaddingTop;
        }

        public function set PaddingTop( value:Number ):void
        {
            if ( PaddingTop==value )
            {
                return;
            }
            _PaddingTop = value;
            ValidateSize();
        }
		
		public function Refresh():void {
			ValidateSize();
		}
		
		public function RemoveAllChildren():void {
			while( this.numChildren>0 ) {
				var child:DisplayObject = removeChildAt( 0 );
				child.filters = null;
				child = null;
			}
			System.gc();
		}

        override public function get height():Number
        {
            return _Height;
        }

        override public function set height( value:Number ):void
        {
			value = Math.round( value );
            if ( height==value )
            {
                return;
            }
            _Height = value;
            this.dispatchEvent( new Event( Event.RESIZE ));
        }

        override public function hitTestPoint( x:Number, y:Number, shapeFlag:Boolean = false ):Boolean
        {
            return x>=0 && y>=0 && x<=width && y<=height;
            //			return this._Container.hitTestPoint(x,y,shapeFlag);
        }

        override public function get width():Number
        {
            return _Width;
        }

        override public function set width( value:Number ):void
        {
			value = Math.round( value );
            if ( width==value )
            {
                return;
            }
            _Width = value;
            this.dispatchEvent( new Event( Event.RESIZE ));
        }

        protected function ValidateSize():void
        {
        }
    }
}