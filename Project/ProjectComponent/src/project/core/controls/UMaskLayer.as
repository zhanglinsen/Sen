package project.core.controls
{
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.utils.Dictionary;
    
    import project.core.events.LoaderEvent;
    import project.core.global.GlobalVariables;
    import project.core.loader.ClassLoader;
    import project.core.loader.ImageLoader;
    import project.core.utils.EffectUtils;
    import project.core.utils.Utility;
    import project.core.utils.XmlUtils;

    public class UMaskLayer extends Sprite
    {
        public function UMaskLayer( w:Number, h:Number )
        {
            super();
            _Width = w;
            _Height = h;
            _MaskBitmapData = new BitmapData( w, h, true, 0 );

            _Mask = new Shape();
            this.mask = _Mask;
            addChild( _Mask );
            this.graphics.beginFill( 0x000100, 0.3 );
            this.graphics.drawRect( 0, 0, _Width, _Height );
            this.graphics.endFill();

            _PaintLayer = new Sprite();
            addChild( _PaintLayer );
        }

		public var LineColor:int = 0xff0000;
        public var LineThickness:int = 2;
        private var _Height:Number;
        private var _Mask:Shape;
        private var _MaskBitmapData:BitmapData;
        private var _PaintLayer:Sprite;
        private var _Width:Number;
		private var _ImageList:Dictionary = new Dictionary();
        public function Clear():void
        {
			for( var key:Object in _ImageList ) {
				_ImageList[key] = null;
			}
			_ImageList = new Dictionary();
			while(_PaintLayer.numChildren>0){
				var obj:DisplayObject = _PaintLayer.getChildAt(0);
				EffectUtils.ClearEffect( obj );
			}
            _PaintLayer.graphics.clear();
            _MaskBitmapData = new BitmapData( _Width, _Height, true, 0 );
//            _MaskBitmapData.floodFill( 0, 0, 0 );
            _Mask.graphics.clear();
        }
		private var _ImgLoader:ImageLoader;
		private var _ClsLoader:ClassLoader;
		public function AddImage( px:Number, py:Number, w:Number, h:Number, src:String ):void {
			src = GlobalVariables.GetResourcePath( src );
			_ImageList[src] = {x:px, y:py, w:w, h:h};
			if( _ImgLoader==null ) {
				_ImgLoader = new ImageLoader();
				_ImgLoader.addEventListener(LoaderEvent.ALL_COMPLETED, Loader_OnComplete );
			}
			_ImgLoader.Load( src );
		}
		public function AddMovieClip( px:Number, py:Number, w:Number, h:Number, src:String ):void {
			src = GlobalVariables.GetResourcePath( src );
			_ImageList[src] = {x:px, y:py, w:w, h:h, clazz: Utility.GetFileName(src)};
			if( _ClsLoader==null ) {
				_ClsLoader = new ClassLoader();
				_ClsLoader.addEventListener(LoaderEvent.ALL_COMPLETED, Loader_OnComplete );
			}
			_ClsLoader.Load( src );
		}
		private function Loader_OnComplete(e:LoaderEvent ):void {
			var pos:Object = _ImageList[e.Source];			
			if( pos ) {
				var obj:Object;
				if( pos.clazz ) {
					var cls:* = _ClsLoader.GetClass( pos.clazz );
					if( cls ) {
						obj = new cls();
					}
				} else {
					obj = e.Data;
				}
				if( obj ) {
					obj.x = pos.x;
					obj.y = pos.y;
					if( !isNaN(pos.w) ) {
						obj.width = pos.w;
					}
					if( !isNaN(pos.h) ) {
						obj.height = pos.h;
					}
					_PaintLayer.addChild( obj as DisplayObject );
				}
			}
		}

        public function Create():void
        {
            _Mask.graphics.clear();
            _Mask.graphics.beginFill( 0xffffff );

            for ( var j:int=0; j<_Height; j++ )
            {
                var bx:int=0;
                var by:int=j;
                var ignore:Boolean = false;

                for ( var i:int=0; i<_Width; i++ )
                {
                    if ( _MaskBitmapData.getPixel32( i, j )!=0 )
                    {
                        if ( !ignore )
                        {
                            _Mask.graphics.drawRect( bx, by, i-bx, 1 );
                        }
                        bx = i;
                        ignore = true;
                    }
                    else
                    {
                        ignore = false;
                    }
                }
                _Mask.graphics.drawRect( bx, by, _Width-bx, 1 );
            }
            _Mask.graphics.endFill();
        }

        public function DrawCircle( mask:Boolean, px:Number, py:Number, radius:Number ):void
        {
			if( isNaN(radius) || radius<MIN_SIZE*0.5 ) {
				radius = MIN_SIZE*0.5;
			}
            _PaintLayer.graphics.lineStyle( LineThickness, LineColor );
            _PaintLayer.graphics.drawCircle( px, py, radius );

            if ( mask )
            {
                var sp:Shape = new Shape();
                sp.graphics.beginFill( 0xffffff );
                sp.graphics.drawCircle( px+1, py, radius-LineThickness );
                sp.graphics.endFill();

                _MaskBitmapData.draw( sp );
            }
        }

        public function DrawEllipse( mask:Boolean, px:Number, py:Number, w:Number, h:Number ):void
        {
			if( isNaN(w) || w<MIN_SIZE ) {
				w = MIN_SIZE;
			}
			if( isNaN(h) || h<MIN_SIZE ) {
				h = MIN_SIZE;
			}
            _PaintLayer.graphics.lineStyle( LineThickness, LineColor );
            _PaintLayer.graphics.drawEllipse( px, py, w, h );

            if ( mask )
            {
                var sp:Shape = new Shape();
                sp.graphics.beginFill( 0xffffff );
                sp.graphics.drawEllipse( px+LineThickness, py+LineThickness, w-LineThickness, h-LineThickness );
                sp.graphics.endFill();

                _MaskBitmapData.draw( sp );
            }
        }
		private const MIN_SIZE:int = 5;
        public function DrawRect( mask:Boolean, px:Number, py:Number, w:Number, h:Number ):void
        {
			if( isNaN(w) || w<MIN_SIZE ) {
				w = MIN_SIZE;
			}
			if( isNaN(h) || h<MIN_SIZE ) {
				h = MIN_SIZE;
			}
            _PaintLayer.graphics.lineStyle( LineThickness, LineColor );
            _PaintLayer.graphics.drawRect( px, py, w, h );

            if ( mask )
            {
                var sp:Shape = new Shape();
                sp.graphics.beginFill( 0xffffff );
                sp.graphics.drawRect( px+LineThickness, py+LineThickness-1, w-LineThickness, h-LineThickness );
                sp.graphics.endFill();

                _MaskBitmapData.draw( sp );
            }
        }

        public function DrawRoundRect( mask:Boolean, px:Number, py:Number, w:Number, h:Number, ellipseWidth:Number, ellipseHeight:Number ):void
        {
			if( isNaN(w) || w<MIN_SIZE ) {
				w = MIN_SIZE;
			}
			if( isNaN(h) || h<MIN_SIZE ) {
				h = MIN_SIZE;
			}
            _PaintLayer.graphics.lineStyle( LineThickness, LineColor );
            _PaintLayer.graphics.drawRoundRect( px, py, w, h, ellipseWidth, ellipseHeight );

            if ( mask )
            {
                var sp:Shape = new Shape();
                sp.graphics.beginFill( 0xffffff );
                sp.graphics.drawRoundRect( px+LineThickness, py+LineThickness-1, w-LineThickness, h-LineThickness, ellipseWidth, ellipseHeight );
                sp.graphics.endFill();

                _MaskBitmapData.draw( sp );
            }
        }

        public function get IsEmptyPixel():Boolean
        {
            return _MaskBitmapData.getPixel32( mouseX, mouseY )!=0&& _MaskBitmapData.getPixel32( mouseX-1, mouseY )!=0;
        }
    }
}