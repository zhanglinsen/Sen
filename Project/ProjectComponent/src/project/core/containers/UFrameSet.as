package project.core.containers
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import project.core.controls.UImage;
    import project.core.global.GlobalVariables;
    import project.core.utils.Filters;

    public class UFrameSet extends UCanvas
    {
        public function UFrameSet( title:String = "" )
        {
			_Title = new TextField();
			_Title.x = 2;
//			_Title.textColor = 0xffff99;
			_Title.selectable = false;
			_Title.filters = [Filters.TextGlow];
			_Title.defaultTextFormat = new TextFormat(GlobalVariables.Font, GlobalVariables.FontSize, 0xFFFFB0, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 3);
            super(/*true, 0x242E36*/);
            Title = title;
        }
        private var _Title:TextField=new TextField();
        private var _TitleHeight:Number = -1;
		private var _TitleSprite:Sprite;		
		
		override public function get ContentHeight():Number {
			return height-ContentContainer.y;
		}
        public function set Title( val:String ):void
        {
            if ( _Title.text == val || val==null )
            {
                return;
            }
            _Title.text = val;
			_Title.height = _Title.textHeight+3;
			_Title.y = (TitleHeight - _Title.height)/2+2;// - 7;
        }

        public function get Title():String
        {
            return _Title.text
        }

        public function get TitleHeight():Number
        {
            return _TitleHeight;
        }

        public function set TitleHeight( h:Number ):void
        {
            _TitleHeight = h;
//            _Title.height = h;
			_Title.y = (TitleHeight - _Title.height)/2;// - 7;
			RepaintBorder();
        }
		override public function get PaddingTop():Number {
			return super.PaddingTop< TitleHeight ? TitleHeight : super.PaddingTop;
		}
		
		override public function set width(w:Number):void {
			super.width = w;
			_Title.width = w - 2;
		}

        override public function hitTestPoint( x:Number, y:Number, shapeFlag:Boolean = false ):Boolean
        {
            if ( x<0 || y<0 )
            {
                return _Title.hitTestPoint( x-_Title.x, y-_Title.y, shapeFlag );
            }
            return super.hitTestPoint( x, y, shapeFlag );
        }

		public function addTitleChild(obj:DisplayObject):void
		{
			_TitleSprite.addChild(obj);
		}

        /**
         * 初始化
         */
        override protected function PreInit():void
        {
            super.PreInit();
			
			var img:UImage = new UImage("resource/Image/UI/common_win_bg.jpg");
			img.scale9Grid = new Rectangle(63,30,321,250);
			Background = img;
//            _Title.background = true;
//            _Title.backgroundColor = 0x2C1705;
//            _Title.border = true;
//            _Title.borderColor = 0xffffff;	
			_TitleSprite = new Sprite();
			_TitleSprite.addChild(_Title);
			if( TitleHeight==-1 ) {
				TitleHeight = 23;
			}
            $addChild( _TitleSprite );
        }
    }
}