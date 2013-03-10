package project.core.form
{
    import flash.display.DisplayObject;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import project.core.containers.UCanvas;
    import project.core.controls.UInput;
    import project.core.global.DirectionConst;
    import project.core.global.GlobalVariables;
    import project.core.utils.Filters;

    public class UFormItemBase extends UCanvas
    {
		protected var  _pBgColor:uint = 0x0;
        public function UFormItemBase( ident:int = 0 )
        {
            super(false,0,1,DirectionConst.HORIZONTAL, 1);
			AutoAlign = false;
            Ident = ident;
        }
		
		private var _FitLabel:Boolean = false;
		public function set FitLabel( val:Boolean ):void {
			_FitLabel = val;
			
			if( FitLabel ) {
				LabelWidth = _Label.TextWidth + 3;
			}
		}
		public function get FitLabel():Boolean {
			return _FitLabel;
		}
		
//		private var _Border:Boolean = true;
		
		private var _IconWrap:UCanvas;
		private var _Icon:DisplayObject;

		private var _Label:UInput;

//		public function get Border():Boolean {
//			return _Border;
//		}
//		public function set Border(val:Boolean):void {
//			if( Border==val ) return ;
//			_Border = val;
//			RepaintForm();
//		}
        public function get DefaultLabelFormat():TextFormat
        {
            return _Label.defaultTextFormat;
        }

        public function set DefaultLabelFormat( fmt:TextFormat ):void
        {
            _Label.defaultTextFormat = fmt;
            _Label.SetTextFormat( fmt );
        }

        override public function Destroy():void
        {		
			_IconWrap.RemoveAllChildren();
//			_Icon.Background = null;
			super.Destroy();
        }
		
//		override public function set Gap( gap:Number ):void {
//			super.Gap = gap;
//			this.RepaintForm();
//		}
		
		public function get Icon():DisplayObject
		{
			return _Icon;//.Background as DisplayObject;
		}
		
		public function set Icon( val:DisplayObject ):void
		{
			if( Icon==val ) {
				return ;
			}
			if( Icon ) {
				_IconWrap.removeChild( Icon );
			}
			_Icon = val;
//			_Icon.Background = val;
			if( val ) {
				if( val.y==0 ) {
					val.y = Math.round( (height-val.height)*0.5 + 1);
				}
				SetIconSize(_IconW, _IconH);
				_IconWrap.addChild( Icon );
				addChildAt( _IconWrap, 0 );
			}
		}
		private var _IconW:Number = 20;
		private var _IconH:Number = -1;
		public function SetIconSize( w:Number=-1, h:Number=-1 ):void {
			_IconW = w;
			_IconH = h;
			if( !_Icon || !_IconWrap) {
				return ;
			}
			if( w==-1 ) {
				_IconWrap.width = _Icon.width;
			} else {
				_IconWrap.width = w;
			}
			if( h==-1 ) {
				_IconWrap.height = _Icon.height;
			} else {
				_IconWrap.height = h;
			}
		}

        public function get Label():String
        {
            return _Label.Text;
        }

        public function set Label( value:String ):void
        {
            if ( Label==value )
            {
                return;
            }
            _Label.Text = value;
			
			if( FitLabel ) {
				LabelWidth = _Label.TextWidth + 3;
			}
        }
		
		public function set LabelAlign(val:String):void {
			_Label.TextAlign = val;
		}
		public function get LabelColor():uint {
			return _Label.TextColor;
		}
		public function set LabelColor(val:uint):void {
			_Label.TextColor = val;
		}
		
		/**标签提示*/
		public function get LabelToolTip():Object
		{
			return this._Label.ToolTip;
		}
		
		public function set LabelToolTip(tip:Object):void
		{
			this._Label.ToolTip = tip;
		}
		
//		public override function set width(value:Number):void
//		{
//			super.width = value;
//			
//			if ( _Label )
//			{
//				_Label.height = value;
////				ValidateSize();
//				RepaintBg();
//			}
//		}

		private var _LabelVisible:Boolean = true;
        public function get LabelVisible():Boolean
        {
            return _LabelVisible;
        }

        public function set LabelVisible( val:Boolean ):void
        {
            if ( val==LabelVisible )
            {
                return;
            }
			_LabelVisible = val;

			this.RepaintBG();
//            this.RepaintForm();
        }
		public function set LabelInclude(val:Boolean):void {
			_Label.visible = val;
			this.Refresh();
		}
		public function get LabelInclude():Boolean {
			return _Label.visible;
		}
		
		public function get LabelWidth():Number
		{
			if(!_Label)
			{
				return 0;
			}
			return _Label.width;
		}

        public function set LabelWidth( val:Number ):void
        {
            if ( _Label.width==val )
            {
                return;
            }
            _Label.width = val;
            ValidateSize();
//            RepaintForm();
        }
		
		public function get TextAlign():String {
			return _Label.TextAlign;
		}
		
		override public function get height():Number {
			return super.height>0?super.height:20;
		}
		
        override public function set height(value:Number ):void
        {
            if ( height==value )
            {
                return;
            }
			
            if ( _Label )
            {
                _Label.height = value;
//				ValidateSize();
//				RepaintForm();
            }
			super.height = value;
        }

        override protected function PreInit():void
        {
			
			_IconWrap = new UCanvas();
			this.BorderColor = 0x2C5158;
			this.BorderThickness = 1;
			this.BackgroundColor = 0x0A1215;
			InitComponent();
			
			super.PreInit();
//			RepaintForm();
        }
		
		protected function InitComponent():void {
			
			_Label = new UInput();
			_Label.Selectable = false;
			_Label.Editable = false;
			_Label.tabChildren = false;
			_Label.tabEnabled = false;
			//            _Label.BackgroundColorEnabled = true;
			//            _Label.Background = 0x4A4A4A;
			_Label.width = 60;
			_Label.height = height;
			_Label.filters = [Filters.TextGlow];
			
			_Label.defaultTextFormat = new TextFormat(GlobalVariables.Font,GlobalVariables.FontSize, 0xCCF0C1, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 3);;
			
			addChild( _Label );
		}
		
		public function set LabelFilter( arr:Array ):void {
			_Label.filters = arr;
		}
		
		public function get LabelFilter():Array {
			return _Label.filters;
		}
        override protected function RepaintBG():void
        {
            this.graphics.clear();
			
			if( this.width > 0 && this.height > 0)
			{
				if( this.BackgroundColorEnabled ) {
					this.graphics.beginFill( this.BackgroundColor, this.BackgroundColorAlpha );
				}
				if( this.BorderThickness>0 ){
					this.graphics.lineStyle(BorderThickness, BorderColor);
				}
				if( this.LabelVisible ) {
					this.graphics.drawRect(0, -BorderThickness, width, height + BorderThickness);
				} else {
					this.graphics.drawRect(_Label.width, -BorderThickness, width-_Label.width, height+BorderThickness);
				}
				RepaintFormBorder();
			}
        }
		protected function RepaintFormBorder():void {
			if( BorderThickness>0 ) {
				this.graphics.lineStyle(BorderThickness, BorderColor);
				var count:int = this.numChildren - 1;
				for(var i:int=0; i<count; i++) {
					var child:DisplayObject = this.getChildAt(i);
					if( child.visible ) {
						var px:Number = child.width+child.x;
						this.graphics.moveTo(px, 0);
						this.graphics.lineTo(px, height);
					}
				}
			}
		}
    }
}