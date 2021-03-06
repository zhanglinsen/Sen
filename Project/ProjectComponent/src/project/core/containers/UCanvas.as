package project.core.containers
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.system.System;
    import flash.ui.Keyboard;
    
    import project.core.controls.UScrollBar;
    import project.core.events.LoaderEvent;
    import project.core.events.UIEvent;
    import project.core.global.AlignConst;
    import project.core.global.BorderConst;
    import project.core.global.DirectionConst;
    import project.core.global.ScrollPolicy;
    import project.core.loader.ImageLoader;
    import project.core.utils.Utility;

	/**调整尺寸**/
    [Event(name="resize", type="flash.events.Event")]
    public class UCanvas extends UBox
    {
		/**
		 * 
		 * @param bgColorEnabled 绑定背景颜色
		 * @param bgColor	背景颜色
		 * @param bgColorAlpha	背景颜色透明度
		 * @param layout	对齐方式  
		 * @param gap	间隔
		 * @param w		宽度
		 * @param h		高度
		 * 
		 */		
        public function UCanvas( bgColorEnabled:Boolean=false, bgColor:uint=0x0, bgColorAlpha:Number=1, layout:String=DirectionConst.ABSOLUTE, gap:int=3, w:Number=-1, h:Number=-1 )
        {
            super(layout, gap, w, h);
            InitContentContainer();

            _BgColorEnabled = bgColorEnabled;
            _BgColor = bgColor;
            _BgColorAlpha = bgColorAlpha;
            PreInit();
        }
		public var BgAutoScale:Boolean = true;

        private var _Bg:DisplayObject;
        private var _BgColor:uint;
        private var _BgColorAlpha:Number = 1;
        private var _BgColorEnabled:Boolean;
        /**
         * 背景层
         */
        private var _BgContainer:Sprite = new Sprite();
        private var _BgUrl:String;
//		private var _BlankCorner:Shape;
        private var _BorderAlpha:Number=1;
        private var _BorderColor:uint=0;
        private var _BorderSides:int = BorderConst.LEFT| BorderConst.RIGHT| BorderConst.TOP| BorderConst.BOTTOM;
        private var _BorderThinkness:int=0;
        private var _ClipContent:Boolean = false;
		
        /**
         * 窗口容器
         */
        private var _ContentContainer:Sprite;
        protected var _pHScrollBar:UScrollBar;
        private var _HScrollPolicy:String = ScrollPolicy.AUTO;

        private var _ImgLoader:ImageLoader;
		private var _ImgThumbLoader:ImageLoader;
        private var _Initialized:Boolean = false;
        private var _OffsetX:Number;
        private var _OffsetY:Number;
        protected var _ScrollContentHeight:Number=0;
        protected var _ScrollContentWidth:Number=0;
        protected var _pVScrollBar:UScrollBar;
        private var _VScrollPolicy:String = ScrollPolicy.AUTO;

		override public function set mouseChildren(enable:Boolean):void {
			super.mouseChildren = enable;
			_BgContainer.mouseChildren = enable;
			_ContentContainer.mouseChildren = enable;
		}
		override public function set mouseEnabled(enable:Boolean):void {
			super.mouseEnabled = enable;
			_BgContainer.mouseEnabled = enable;
			_ContentContainer.mouseEnabled = enable;			
		}
        public function get Background():Object
        {
            return _Bg;
        }

        /**
         * 设置窗口背景，如果值为null，则会以默认样式填充背景
         */
        public function set Background( bg:Object ):void
        {
			if( bg==null ) {
				if( _ImgLoader ) {
					_ImgLoader.Load( null );
				}
				_BgUrl = null;
			}
            if ( bg is String )
            {
                this.BackgroundUrl = bg as String;
                return;
            }
			var cnt:int = 0;
            if ( bg is DisplayObject )
            {
                _Bg = bg as DisplayObject;
				cnt = 1;
            }
            else
            {
                _BgUrl = null;
                _Bg = null;
            }
            RepaintBG();
			
			while ( BgContainer.numChildren>cnt )
			{
				var obj:DisplayObject = BgContainer.removeChildAt(0);
				if( obj ) {
					if( obj is MovieClip ) {
						(obj as MovieClip).stop();
					} else if ( obj is Loader) {
						(obj as Loader).unload();
					}
					System.gc();
				}
//				EffectUtils.ClearEffect( BgContainer.getChildAt(0) );
				//                BgContainer.removeChildAt( 0 );
			}
        }
		public function get VScrollEnabled():Boolean {
			return this._pVScrollBar ? _pVScrollBar.ScrollEnabled : false;
		}
		public function get HScrollEnabled():Boolean {
			return this._pHScrollBar ? _pHScrollBar.ScrollEnabled : false;
		}
        /**
         * 背景的透明度
         */
        public function get BackgroundAlpha():Number
        {
            return this.BgContainer.alpha;
        }

        public function set BackgroundAlpha( value:Number ):void
        {
            this.BgContainer.alpha = value;
        }

        public function get BackgroundColor():uint
        {
            return this._BgColor;
        }

        /**
         * 设置背景颜色
         */
        public function set BackgroundColor( value:uint ):void
        {
            if ( BackgroundColor==value )
            {
                return;
            }
            this._BgColor = value;
            this.RepaintBG();
        }

        public function set BgBorderColor( value:int ):void
        {
            if ( BgBorderColor==value )
            {
                return;
            }
            this._BgBorderColor = value;
            this.RepaintBG();
        }

        public function get BgBorderColor():int
        {
            return _BgBorderColor;
        }
        private var _BgBorderColor:int=-1;

        public function get BackgroundColorAlpha():Number
        {
            return this._BgColorAlpha;
        }

        public function set BackgroundColorAlpha( value:Number ):void
        {
            this._BgColorAlpha = value;

            this.RepaintBG();
        }

        /**
         * 是否使用背景颜色
         */
        public function get BackgroundColorEnabled():Boolean
        {
            return this._BgColorEnabled;
        }

        public function set BackgroundColorEnabled( value:Boolean ):void
        {
            this._BgColorEnabled = value;

            this.RepaintBG();
        }

        public function get BackgroundUrl():String
        {
            return _BgUrl;
        }

        public function set BackgroundUrl( url:String ):void
        {
            _BgUrl = url;

            if ( url )
            {
                if ( _ImgLoader==null )
                {
                    _ImgLoader = GetImageLoader();
                    _ImgLoader.addEventListener( LoaderEvent.ALL_COMPLETED, Bg_OnLoadComplete );
                }
				if( url.indexOf("MapBg")!=-1 ) {
					if ( _ImgThumbLoader==null )
					{
						_ImgThumbLoader = GetImageLoader();
						_ImgThumbLoader.addEventListener( LoaderEvent.ALL_COMPLETED, BgThumb_OnLoadComplete );
					}
					_ImgThumbLoader.Load( url.replace( "MapBg", "MapBgThumb" ).replace(".swf",".jpg") );
				}
                _ImgLoader.Load( url );
            }
            else
            {
                Background = null;
            }
        }

        public function get BorderAlpha():uint
        {
            return _BorderAlpha;
        }

        public function set BorderAlpha( val:uint ):void
        {
            if ( _BorderAlpha==val )
            {
                return;
            }
            _BorderAlpha = val;
            RepaintBG();
        }

        public function get BorderColor():uint
        {
            return _BorderColor;
        }

        public function set BorderColor( val:uint ):void
        {
            if ( _BorderColor==val )
            {
                return;
            }
            _BorderColor = val;
            RepaintBG();
        }

        public function get BorderSides():int
        {
            return _BorderSides;
        }

        /**
         * 默认值：BorderConst.LEFT| BorderConst.RIGHT| BorderConst.TOP| BorderConst.BOTTOM
         */
        public function set BorderSides( val:int ):void
        {
            if ( _BorderSides==val )
            {
                return;
            }
            _BorderSides = val;
            RepaintBG();
        }

        public function get BorderThickness():int
        {
            return _BorderThinkness;
        }

        public function set BorderThickness( val:int ):void
        {
            if ( _BorderThinkness==val )
            {
                return;
            }
            _BorderThinkness = val;
            RepaintBG();
            RepaintMask();
        }

        /**
         * 是否使用遮罩
         */
        public function get ClipContent():Boolean
        {
            return this._ClipContent;
        }

        public function set ClipContent( value:Boolean ):void
        {
            if ( ClipContent == value )
            {
                return;
            }
            this._ClipContent = value;

//			if ( value )
//			{
//				RepaintMask();
////				ShowScrollBar();
//				ValidateScroll();
//			}
//			else
//			{
//				this.HideVScrollBar();
//				this.HideHScrollBar();
//			}
            ValidateScroll();
            RepaintMask();
        }

        public function get ContentHeight():Number
        {
            return height;
        }

        public function get ContentWidth():Number
        {
            return width;
        }

        /**
         * 销毁
         */
        public function Destroy():void
        {
            for ( var i:int=$numChildren-1; i>=0; i-- )
            {
                var obj:DisplayObject = $getChildAt( i );

                if ( obj is Sprite )
                {
                    var c:Sprite = obj as Sprite;

                    while ( c.numChildren>0 )
                    {
                        c.removeChildAt( 0 );
                    }
                }
                $removeChild( obj );
            }
        }

        public function get HScrollPolicy():String
        {
            return _HScrollPolicy;
        }

        public function set HScrollPolicy( val:String ):void
        {
            if ( _HScrollPolicy == val )
            {
                return;
            }
            _HScrollPolicy = val;
            this.CheckAutoHScroll();
        }

        public function get HScrollPosition():Number
        {
            return HScrollVisible ? _pHScrollBar.Position : 0;
        }

        public function set HScrollPosition( hpos:Number ):void
        {
            if ( HScrollVisible )
            {
				if( this._pHScrollBar.Position + this.width<(hpos+HScrollStep) ) {
					this._pHScrollBar.Position = hpos;
				} else if ( this._pHScrollBar.Position > hpos ) {
					this._pHScrollBar.Position = hpos;
				}
//                _pHScrollBar.Position = pos;
            }
        }

        public function get Initialized():Boolean
        {
            return _Initialized;
        }

        public function SetBgColor( enabled:Boolean, color:uint = 0, alpha:Number = 1 ):void
        {
            _BgColorEnabled = enabled;
            _BgColor = color;
            _BgColorAlpha = alpha;
            RepaintBG();
        }

        public function get VScrollPolicy():String
        {
            return _VScrollPolicy;
        }

        public function set VScrollPolicy( val:String ):void
        {
            //			this.removeEventListener(MouseEvent.MOUSE_WHEEL, OnMouseWheel);

            if ( _VScrollPolicy == val )
            {
                return;
            }
            _VScrollPolicy = val;
            this.CheckAutoVScroll();
        }

        public function get VScrollPosition():Number
        {
            return VScrollVisible ? _pVScrollBar.Position : 0;
        }

        public function set VScrollPosition( vpos:Number ):void
        {
            if ( VScrollVisible )
            {
//				if( this._pVScrollBar.Position + this.height<(vpos+VScrollStep) ) {
//					this._pVScrollBar.Position = vpos;
//				} 
//				else if ( this._pVScrollBar.Position > vpos ) {
//					this._pVScrollBar.Position = vpos;
//				}
				_pVScrollBar.Position = vpos;
            }
        }

        /**
         * 在窗口中添加内容
         */
        override public function addChild( child:DisplayObject ):DisplayObject
        {
            return addChildAt( child, numChildren );
        }

        /**
         * 在窗口中添加内容
         */
        override public function addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            if ( child.x+child.width>_ScrollContentWidth )
            {
                _ScrollContentWidth = child.x+child.width;
                this.CheckAutoHScroll();
            }

            if ( child.y+child.height>_ScrollContentHeight )
            {
                _ScrollContentHeight = child.y+child.height;
                this.CheckAutoVScroll();
            }
            child.addEventListener( Event.RESIZE, Child_OnResize );
            child = ContentContainer.addChildAt( child, index );
			ValidateScrollSize();
			ValidateSize();
			
			return child;
        }

        override public function contains( child:DisplayObject ):Boolean
        {
            return ContentContainer.contains( child );
        }

        override public function getBounds( targetCoordinateSpace:DisplayObject ):Rectangle
        {
            return ContentContainer.getBounds( targetCoordinateSpace );
        }

        override public function getChildAt( index:int ):DisplayObject
        {
            return ContentContainer.getChildAt( index );
        }

        override public function getChildByName( name:String ):DisplayObject
        {
            return ContentContainer.getChildByName( name );
        }

        override public function getChildIndex( child:DisplayObject ):int
        {
            return ContentContainer.getChildIndex( child );
        }

        override public function globalToLocal( point:Point ):Point
        {
            return ContentContainer.globalToLocal( point );
        }


        override public function get graphics():Graphics
        {
            return BgContainer.graphics;
        }

        /**
         * 窗口高度
         */
        override public function set height( h:Number ):void
        {
            if ( height==h )
            {
                return;
            }
            super.height = h;

            ValidateSize();
            this.dispatchEvent( new Event( Event.RESIZE ));
        }

        override public function hitTestObject( obj:DisplayObject ):Boolean
        {
            for ( var i:int=0; i<$numChildren; i++ )
            {
                if ( $getChildAt( i ).hitTestObject( obj ))
                {
                    return true;
                }
            }
            return false;
        }

        override public function hitTestPoint( x:Number, y:Number, shapeFlag:Boolean = false ):Boolean
        {
            if ( super.hitTestPoint( x, y, shapeFlag ))
            {
                return true;
            }

            for ( var i:int=0; i<numChildren; i++ )
            {
                var obj:DisplayObject = getChildAt( i );

                if ( obj.hitTestPoint( x-obj.x, y-obj.y, shapeFlag ))
                {
                    return true;
                }
            }
            return false;
        }

        override public function localToGlobal( point:Point ):Point
        {
            return ContentContainer.localToGlobal( point );
        }

        override public function get mask():DisplayObject
        {
            return ContentContainer.mask;
        }

        override public function set mask( value:DisplayObject ):void
        {
            ContentContainer.mask = value;
        }

        override public function get numChildren():int
        {
            return ContentContainer.numChildren;
        }

        private function Child_OnResize( e:Event ):void
        {
            ValidateScroll();
			if( this.Layout != DirectionConst.ABSOLUTE ) {
				this.ValidateSize();
			}
        }

        override public function removeChild( child:DisplayObject ):DisplayObject
        {
            child.removeEventListener( Event.RESIZE, Child_OnResize );
            var child:DisplayObject = ContentContainer.removeChild( child );
            ValidateScroll();
			ValidateSize();
            return child;
        }

        override public function removeChildAt( index:int ):DisplayObject
        {
            return removeChild( getChildAt( index ));
        }

        override public function setChildIndex( child:DisplayObject, index:int ):void
        {
            ContentContainer.setChildIndex( child, index );
			ValidateSize();
        }

        override public function swapChildren( child1:DisplayObject, child2:DisplayObject ):void
        {
            ContentContainer.swapChildren( child1, child2 );
        }

        override public function swapChildrenAt( index1:int, index2:int ):void
        {
            ContentContainer.swapChildrenAt( index1, index2 );
        }

        /**
         * 窗口宽度
         */
        override public function set width( w:Number ):void
        {
            if ( width==w )
            {
                return;
            }
            super.width = w;

            ValidateSize();
            this.dispatchEvent( new Event( Event.RESIZE ));
        }

        protected function get BgContainer():Sprite
        {
            return _BgContainer;
        }

        protected function CheckAutoHScroll():void
        {
            if ( !ClipContent )
            {
                HideHScrollBar();
                return;
            }

            switch ( HScrollPolicy )
            {
                case ScrollPolicy.AUTO:
                    if ( this.HScrollVisible )
                    {
                        this.ShowHScrollBar();
                    }
                    else
                    {
                        this.HideHScrollBar();
                    }
                    break;
                case ScrollPolicy.ON:
                    ShowHScrollBar();
                    break;
                case ScrollPolicy.OFF:
                    HideHScrollBar();
                    break;
            }
        }

        protected function CheckAutoVScroll():void
        {
            if ( !ClipContent )
            {
                HideVScrollBar();
                return;
            }

            switch ( VScrollPolicy )
            {
                case ScrollPolicy.AUTO:
                    if ( this.VScrollVisible )
                    {
                        this.ShowVScrollBar();
                    }
                    else
                    {
                        this.HideVScrollBar();
                    }
                    break;
                case ScrollPolicy.ON:
                    ShowVScrollBar();
                    break;
                case ScrollPolicy.OFF:
                    HideVScrollBar();
                    break;
            }
        }

        protected function get ContentContainer():Sprite
        {
            return _ContentContainer;
        }

        protected function set ContentContainer( c:Sprite ):void
        {
            var idx:int=-1;

            if ( ContentContainer!=null )
            {
                if ( ContentContainer.parent )
                {
                    idx = ContentContainer.parent.getChildIndex( ContentContainer );
                    ContentContainer.parent.removeChild( ContentContainer );
                }

                while ( ContentContainer.numChildren>0 )
                {
                    var obj:DisplayObject = ContentContainer.getChildAt( 0 );
                    ContentContainer.removeChild( obj );
                    c.addChild( obj );
                }
                _ContentContainer = null;
            }

            if ( idx!=-1 )
            {
                $addChildAt( c, idx );
            }
            _ContentContainer = c;
        }

        protected function CreateMask( w:Number, h:Number ):DisplayObject
        {
            var s:Shape = new Shape();
            s.graphics.beginFill( 0xFF0000 );

            if ( w==0 )
            {
                w=1;
            }

            if ( h==0 )
            {
                h=1;
            }
            s.graphics.drawRect( 0, 0, w, h );
            s.graphics.endFill();
            return s;
        }

        protected function PreInit():void
        {
            Init();
        }

		private var _BgAlign:String = AlignConst.CENTER;
		public function set BgAlign( val:String ):void {
			if( BgAlign==val ) return ;
			_BgAlign = val;
			PositionBg();
		}
		public function get BgAlign():String {
			return _BgAlign;
		}
		protected function PositionBg():void {
			if( !_Bg ) return ;
			var w:Number,h:Number;
			if( _Bg is Loader ) {
				w = (_Bg as Loader).contentLoaderInfo.width;
				h = (_Bg as Loader).contentLoaderInfo.height;
			} else {
				w = _Bg.width;
				h = _Bg.height;
			}
			var aligns:Array = BgAlign.split("|");
			for( var i:int=0; i<aligns.length; i++ ) {
				switch( aligns[i] ) {
					case AlignConst.CENTER:
						_Bg.x = Math.ceil( 0.5*( width-w ) );
						_Bg.y = Math.ceil( 0.5*( height-h ) );
						break;
					case AlignConst.LEFT:
						_Bg.x = 0;
						break;
					case AlignConst.TOP:
						_Bg.y = 0;
						break;
					case AlignConst.RIGHT:
						_Bg.x = width-w;
						break;
					case AlignConst.BOTTOM:
						_Bg.y = height-h;
						break;
				}
			}
		}
        protected function FillBg( bg:DisplayObject ):void
        {
			if( BgAutoScale ) {
//	            if ( bg.width!=0 && !(bg is Loader) )
//	            {
	                bg.width = width;
	                bg.height = height;
//	            }
			} else {
				
				PositionBg();
			}

            if ( !BgContainer.contains( bg ))
            {
                BgContainer.addChild( bg );
            }
        }

        /**
         * 填充默认背景
         */
        protected function FillEmptyBg():void
        {
            if ( BgBorderColor!=-1 )
            {
                graphics.lineStyle( 1, BgBorderColor );
            }
            this.graphics.beginFill( BackgroundColor, BackgroundColorAlpha );
            this.graphics.drawRect( this.BorderThickness, BorderThickness, width-BorderThickness*2, height-BorderThickness*2 );
            this.graphics.endFill();
        }

        protected function GetImageLoader():ImageLoader
        {
            return new ImageLoader();
        }

        protected function HideHScrollBar():void
        {
            if ( _pHScrollBar && _pHScrollBar.parent )
            {
                this.$removeChild( _pHScrollBar );
                this.ValidateScrollPos();
                RepaintMask();
            }
        }

        protected function HideVScrollBar():void
        {
            if ( _pVScrollBar && _pVScrollBar.parent )
            {
                this.removeEventListener( MouseEvent.MOUSE_WHEEL, OnMouseWheel );
				this.removeEventListener( KeyboardEvent.KEY_DOWN, OnKeyRollBar );
                this.$removeChild( _pVScrollBar );
                this.ValidateScrollPos();
                RepaintMask();
            }
        }

        /**
         * 初始化
         */
        protected function Init( e:Event = null ):void
        {
            if ( Initialized )
            {
                return;
            }
            _Initialized = true;
            $addChildAt( BgContainer, 0 );
            $addChildAt( ContentContainer, 1 );
            ValidateSize();
        }
		
		protected function setContainerIndex( c:Sprite, index:int ):void
		{
			$setChildIndex( c, index );
		}
		override public function get MaxItemHeight():Number
		{
			return super.MaxItemHeight + this.HScrollMaskHeight;
		}
		
		override public function get MaxItemWidth():Number
		{
			return super.MaxItemWidth + this.VScrollMaskWidth;
		}
		
        protected function InitContentContainer():void
        {
            ContentContainer = new Sprite();
        }
		
		protected function OnKeyRollBar( e:KeyboardEvent ):void {
			switch( e.keyCode ) {
				case Keyboard.DOWN:
					_pVScrollBar.Position = _pVScrollBar.Position+_pVScrollBar.ScrollStep;
					break;
				case Keyboard.UP:
					_pVScrollBar.Position = _pVScrollBar.Position-_pVScrollBar.ScrollStep;
					break;
			}
		}

        protected function OnMouseWheel( e:MouseEvent ):void
        {
            if ( _pVScrollBar && _pVScrollBar.visible )
            {
                e.stopPropagation();
                _pVScrollBar.Position = _pVScrollBar.Position-(e.delta<0?-1:1)*_pVScrollBar.ScrollStep;
            }
        }

		public function set PositionX( px:Number ):void
        {
            this.ContentContainer.x = Math.ceil(px);
        }

		public function get PositionX():Number
        {
            return this.ContentContainer.x;
        }

		public function set PositionY( py:Number ):void
        {
            this.ContentContainer.y = Math.ceil(py);
        }

		public function get PositionY():Number
        {
            return this.ContentContainer.y;
        }

        protected function RepaintBG():void
        {
            if ( !Initialized )
            {
                return;
            }
            graphics.clear();

            //			graphics.beginFill(0xFF0000, 0);
            //			graphics.drawRect(0, 0, this.width, this.height);
            //			graphics.endFill();

            if ( _Bg!=null )
            {
                FillBg( _Bg );
            }

            if ( this.BackgroundColorEnabled )
            {
                FillEmptyBg();
            }
            RepaintBorder();
        }

        protected function RepaintBorder():void
        {
            if ( !Initialized )
            {
                return;
            }

            //            this.ContentContainer.graphics.clear();

            if ( BorderThickness>0 )
            {
                var g:Graphics = this.graphics;
                g.lineStyle( BorderThickness, BorderColor, BorderAlpha );

                var w:Number = ContentWidth;
                var h:Number = ContentHeight;

                if ( BorderSides&BorderConst.LEFT )
                {
                    g.moveTo( 0, 0 );
                    g.lineTo( 0, h );
                        //					g.moveTo( -BorderThickness, -BorderThickness );
                        //					g.lineTo( -BorderThickness, h+BorderThickness );
                }

                if ( BorderSides&BorderConst.TOP )
                {
                    g.moveTo( 0, 0 );
                    g.lineTo( w, 0 );
                        //					g.moveTo( -BorderThickness, -BorderThickness );
                        //					g.lineTo( w+BorderThickness, -BorderThickness );
                }

                if ( BorderSides&BorderConst.RIGHT )
                {
                    g.moveTo( w, 0 );
                    g.lineTo( w, h );
                        //					g.moveTo( w+BorderThickness, -BorderThickness );
                        //					g.lineTo( w+BorderThickness, h+BorderThickness );
                }

                if ( BorderSides&BorderConst.BOTTOM )
                {
                    g.moveTo( 0, h );
                    g.lineTo( w, h );
                        //					g.moveTo( -BorderThickness, h+BorderThickness );
                        //					g.lineTo( w+BorderThickness, h+BorderThickness );
                }
                g.moveTo( 0, 0 );
            }
        }

        protected function get VScrollOffset():Number
        {
            return this.VScrollVisible&&_pVScrollBar ? height * _pVScrollBar.ScrollScale * ( _pVScrollBar.Position / VScrollBarMaxPosition ):0;
        }

        protected function get HScrollOffset():Number
        {
            return this.HScrollVisible&&_pHScrollBar ? width * _pHScrollBar.ScrollScale * ( _pHScrollBar.Position / HScrollBarMaxPosition ):0;
        }

        protected function get HScrollMaskHeight():Number
        {
            if ( HScrollVisible && _pHScrollBar )
            {
                return _pHScrollBar.height;
            }
            return 0;
        }

        protected function get VScrollMaskWidth():Number
        {
            if ( VScrollVisible && _pVScrollBar )
            {
                return _pVScrollBar.width + 1;
            }
            return 0;
        }

        protected function RepaintMask():void
        {
            if ( ClipContent )
            {
                var w:Number = (width>0?width-BorderThickness*3-PaddingLeft-PaddingRight-VScrollMaskWidth:0);
                var h:Number = (height>0?height-BorderThickness*3-PaddingTop-PaddingBottom-HScrollMaskHeight:0);

                if ( mask==null )
                {

                    mask = CreateMask( w, h );
                }
                else
                {
                    mask.width = w;
                    mask.height = h;
                }
                mask.x = PositionX+BorderThickness*2+HScrollOffset;
                mask.y = PositionY+BorderThickness*2+VScrollOffset;

                if ( !$contains( mask ))
                {
                    $addChildAt( mask, 0 );
                }
            }
            else
            {
                if ( mask!=null && mask.parent!=null )
                {
                    $removeChild( mask );
                }
                mask = null;
            }
        }

        protected function ShowHScrollBar():void
        {
            if ( _pHScrollBar && _pHScrollBar.parent )
            {
                return;
            }

            if ( HScrollVisible )
            {
                if ( !_pHScrollBar )
                {
                    _pHScrollBar = new UScrollBar( this, DirectionConst.HORIZONTAL );
					_pHScrollBar.ScrollStep = HScrollStep;
                    _pHScrollBar.addEventListener( UIEvent.POSITION_CHANGE, HScroll_OnPositionChange );
                }
                ValidateScrollPos();
                RepaintMask();

                if ( !this.BackgroundColorEnabled )
                {
                    this.SetBgColor( true, 0xffffff, 0 );
                }
                this.$addChild( _pHScrollBar );
            }
        }

//		protected function ShowScrollBar():void
//		{
//			this.ShowVScrollBar();
//			this.ShowHScrollBar();
//		}
		private var _VScrollStep:int = 16;
		private var _HScrollStep:int = 16;
		public function set VScrollStep(val:int):void {
			if( VScrollStep==val ) return ;
			if( _pVScrollBar ) {
				_pVScrollBar.ScrollStep = val;
			}
			_VScrollStep = val;
		}
		public function get VScrollStep():int {
			return _VScrollStep;
		}
		public function get VScrollStepReal():Number {
			return _pVScrollBar ? _pVScrollBar.ScrollStep : 0;
		}
		public function set HScrollStep(val:int):void {
			if( HScrollStep==val ) return ;
			if( _pHScrollBar ) {
				_pHScrollBar.ScrollStep = val;
			}
			_HScrollStep = val;
		}
		public function get HScrollStep():int {
			return _HScrollStep;
		}
		public function get HScrollStepReal():Number {
			return _pHScrollBar ? _pHScrollBar.ScrollStep : 0;
		}
        protected function ShowVScrollBar():void
        {
            if ( _pVScrollBar && _pVScrollBar.parent )
            {
                return;
            }

            if ( VScrollVisible )
            {
                if ( !_pVScrollBar )
                {
                    _pVScrollBar = new UScrollBar( this );
					_pVScrollBar.ScrollStep = VScrollStep;
                    _pVScrollBar.addEventListener( UIEvent.POSITION_CHANGE, VScroll_OnPositionChange );
                }
                ValidateScrollPos();
                RepaintMask();

                if ( !this.BackgroundColorEnabled )
                {
                    this.SetBgColor( true, 0xffffff, 0 );
                }
                this.addEventListener( MouseEvent.MOUSE_WHEEL, OnMouseWheel );
				this.addEventListener( KeyboardEvent.KEY_DOWN, OnKeyRollBar );
                this.$addChild( _pVScrollBar );
            }
        }

        protected function ValidateScrollPos():void
        {

            if ( HScrollVisible )
            {
                if ( _pHScrollBar )
                {
                    _pHScrollBar.x = /*PaddingLeft + */this.BorderThickness;
					_pHScrollBar.y = this.height - _pHScrollBar.height/* - PaddingBottom*/;
                }

            }

            if ( VScrollVisible )
            {
                if ( _pVScrollBar )
                {
                    _pVScrollBar.y = /*PaddingTop + */this.BorderThickness;
					_pVScrollBar.x = this.width - _pVScrollBar.width/* - PaddingRight*/;
                }
            }

            if ( HScrollVisible && VScrollVisible )
            {

                if ( _pVScrollBar&&_pHScrollBar )
                {
                    _pHScrollBar.width = width - _pVScrollBar.width /*- PaddingRight*/ - _pHScrollBar.x-BorderThickness;
                    _pVScrollBar.height = height - _pHScrollBar.height /*- PaddingBottom*/ - _pVScrollBar.y-BorderThickness;
                }
//				if ( _BlankCorner==null )
//				{
//					_BlankCorner = new Shape();
//					_BlankCorner.graphics.beginFill( 0xc0c0c0 );
//					_BlankCorner.graphics.drawRect( 0, 0, _pVScrollBar.width+1, _pHScrollBar.height+1 );
//					_BlankCorner.graphics.endFill();
//				}
//				_BlankCorner.x = _pVScrollBar.x;
//				_BlankCorner.y = _pHScrollBar.y;
//				$addChild( _BlankCorner );
            }
            else
            {
                if ( VScrollVisible )
                {
                    if ( _pVScrollBar )
                    {
                        _pVScrollBar.height = height /*- PaddingBottom*/ - _pVScrollBar.y-BorderThickness;
                    }
                }
                else if ( HScrollVisible )
                {
                    if ( _pHScrollBar )
                    {
                        _pHScrollBar.width = width /*- PaddingRight*/ - _pHScrollBar.x-BorderThickness;
                    }
                }
            }
        }

        protected function ValidateScrollContent():void
        {
            var w:Number=width-PaddingLeft-PaddingRight-BorderThickness*2;
            var h:Number=height-PaddingTop-PaddingBottom-BorderThickness*2;

            for ( var i:int=0; i<numChildren; i++ )
            {
                var obj:DisplayObject = getChildAt( i );

                if ( obj.x+obj.width>w )
                {
                    w = obj.x+obj.width;
                }

                if ( obj.y+obj.height>h )
                {
                    h = obj.y+obj.height;
                }
            }
            _ScrollContentWidth = w+ PaddingLeft + PaddingRight;
            _ScrollContentHeight = h+ PaddingTop + PaddingBottom;
        }

        protected function ValidateScrollSize():void
        {
            if ( this.ClipContent )
            {
                if ( this._pVScrollBar )
                {
                    _pVScrollBar.ContentWidth = _ScrollContentWidth;
                    _pVScrollBar.ContentHeight = _ScrollContentHeight;
                }

                if ( this._pHScrollBar )
                {
                    _pHScrollBar.ContentWidth = _ScrollContentWidth;
                    _pHScrollBar.ContentHeight = _ScrollContentHeight;
                }
            }
        }

        override protected function ValidateSize():void
        {
            if ( !Initialized )
            {
                return;
            }
			super.ValidateSize();

            if ( this.VScrollVisible || this.HScrollVisible )
            {
                ValidateScrollPos();
//				this.VScroll_OnPositionChange(null);
//				this.HScroll_OnPositionChange(null);
            }
            else
            {
                PositionY = PaddingTop;
                PositionX = PaddingLeft;
            }
            RepaintBG();
            RepaintMask();
            ValidateScroll();
        }

        protected function ValidateScroll():void
        {
            if ( !this.ClipContent )
            {
                return;
            }
            ValidateScrollContent();
            this.CheckAutoHScroll();
            this.CheckAutoVScroll();
            ValidateScrollSize();
        }
		public var BgScale9Grid:Rectangle;

        private function Bg_OnLoadComplete( e:LoaderEvent ):void
        {
			e.Data.name = Utility.GetFileName( e.Source );
			if( BgScale9Grid ) {
				e.Data.scale9Grid = BgScale9Grid;
			}
            this.Background = e.Data;
        }
		private function BgThumb_OnLoadComplete( e:LoaderEvent ):void
		{
			var str:String = Utility.GetFileName( e.Source );
			if( Background && Background.name==str ) {
				return ;
			}
			e.Data.width = width;
			e.Data.height = height;
				
			e.Data.name = str + "Thumb";
			this.Background = e.Data;
		}

		protected function get HScrollVisible():Boolean
        {
            if ( !ClipContent || HScrollPolicy==ScrollPolicy.OFF )
            {
                return false;
            }

            if ( this.HScrollPolicy==ScrollPolicy.AUTO )
            {
                //检查
                if ( width==-1 ||  this._ScrollContentWidth<=width )
                {
                    return false;
                }
            }
            return true;
        }

        private function HScroll_OnPositionChange( e:UIEvent ):void
        {
            if ( HScrollVisible )
            {
//				var pos:Number = e==null ? _pHScrollBar.Position : Number( e.Data );
                PositionX = PaddingLeft-HScrollOffset;
            }
            else
            {
                PositionX = PaddingLeft;
            }
        }

        public function get VScrollBarMaxPosition():Number
        {
            return _pVScrollBar ? _pVScrollBar.MaxPosition : 0;
        }

        public function get HScrollBarMaxPosition():Number
        {
            return _pHScrollBar ? _pHScrollBar.MaxPosition : 0;
        }

        protected function get VScrollVisible():Boolean
        {
            if ( !ClipContent || VScrollPolicy==ScrollPolicy.OFF )
            {
                return false;
            }

            if ( this.VScrollPolicy==ScrollPolicy.AUTO )
            {
                //检查
                if ( height==-1 || _ScrollContentHeight<=height )
                {
                    return false;
                }
            }
            return true;
        }

        private function VScroll_OnPositionChange( e:UIEvent ):void
        {
            if ( VScrollVisible )
            {
//				var pos:Number = e==null ? _pVScrollBar.Position : Number( e.Data );
                PositionY = PaddingTop-VScrollOffset;
            }
            else
            {
                PositionY = PaddingTop;
            }
        }
    }
}