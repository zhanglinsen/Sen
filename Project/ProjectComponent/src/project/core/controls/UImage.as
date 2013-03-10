package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
    
    import project.core.events.LoaderEvent;
    import project.core.loader.ImageLoader;
    import project.core.utils.EffectUtils;

    /**
     * 图片显示控件，可以是链接地址，也可以是DiplayObject
     * @author meibin
     */
    public class UImage extends UComponent
    {
        public function UImage(src:*=null)
        {
            super();
		    if( src ) {
				Source = src;
		    }
        }

		/**
		 * 是否动画，当值为false时，如果加载的内容是动画，为转成静态图像
		 * @default false 
		 */
		public var IsAnimation:Boolean = false;
		/**
		 * 缩放比例限制与原比例相同
		 * @default false
		 */
		public var ScaleRestraint:Boolean = false;
		private var _Height:int;
        private var _Img:DisplayObject;
        private var _Loader:ImageLoader;
		private var _ScaleRect:Rectangle;

		private var _Source:String;
		private var _Width:int;

        /**
         * 图片源
         * @param val
         */
        public function set Source( val:* ):void
        {
            if ( val is String )
            {
				if( _Source==val ) {
					return ;
				}
				SetImage( null );
				_Source = val;
                if ( _Loader==null )
                {
                    _Loader = new ImageLoader();
                    _Loader.addEventListener( LoaderEvent.ALL_COMPLETED, Img_OnComplete );
                }
				_Loader.IsAnimation = IsAnimation;
                _Loader.Load( val );
            }
            else
            {
				_Source = null;
                SetImage( val );
            }
        }

        override public function get height():Number
        {
            return _Img ? _Img.height : _Height;
        }
        override public function set height( value:Number ):void
        {
			_Height = value;
            if ( _Img )
            {
                _Img.height = value;
            }
        }
		override public function set scale9Grid(innerRectangle:Rectangle):void {
			_ScaleRect = innerRectangle;
			if(_Img){
				_Img.scale9Grid = _ScaleRect;
			}
		}
		override public function get scale9Grid():Rectangle {
			return  _ScaleRect;
		}

        override public function get width():Number
        {
            return _Img ? _Img.width : _Width;
        }

        override public function set width( value:Number ):void
        {
			_Width = value;
            if ( _Img )
            {
                _Img.width = value;
            }
        }
        private function Img_OnComplete( e:LoaderEvent ):void
        {
            SetImage( e.Data as DisplayObject );
        }
        private function SetImage( val:DisplayObject ):void
        {
			EffectUtils.ClearEffect( _Img );
			_Img = null;
			if( val ) {
	            _Img = val;
				_Img.scale9Grid = _ScaleRect;
				
				var mw:Number = _Img.width;
				var mh:Number = _Img.height;
				if( _Width>0 ) {
					mw = _Width;
				}
				if( _Height>0 ) {
					mh = _Height;
				}
				if( _Img.width>mw || _Img.height>mh ) {
					if( ScaleRestraint ){
						if( _Img.width/mw>=_Img.height/mh ) {
							mh = _Img.height * mw / _Img.width;
						} else {
							mw = _Img.width * mh / _Img.height;
						}
					}
				} 

				_Img.width = mw;
				_Img.height = mh;
	            addChild( _Img );
	            this.dispatchEvent( new LoaderEvent( LoaderEvent.ALL_COMPLETED ));
			}
        }
    }
}