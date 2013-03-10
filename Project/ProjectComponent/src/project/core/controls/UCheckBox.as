package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    import project.core.containers.UBox;
    import project.core.containers.UCanvas;
    import project.core.controls.UToggleButton;
    import project.core.global.AlignConst;
    import project.core.image.CheckImage;
    import project.core.reader.ReaderFactory;

    /**
     * 多选框
     * @author meibin
     */
    public class UCheckBox extends UToggleButton
    {
        /**
         * 
         * @param label 显示文字
         */
        public function UCheckBox( label:String = "" )
        {
            super( label, false );
			this.SoundEnabled = false;
			_pLabel.width = _pLabel.textWidth + 3;
			this.Align = AlignConst.LEFT;
            Background = false;
            OverSkin = DefaultOverSkin();
            DisabledSkin = DefaultDisabledSkin();
            UpSkin = DefaultUpSkin();
//			DownSkin = DefaultDownSkin();	
            SelectedOverSkin = DefaultOverSkin();
            SelectedDisabledSkin = DefaultDisabledSkin();
            SelectedUpSkin = DefaultUpSkin();
			_Icon = new CheckImage();
			_Icon.visible = false;
			_Icon.x = 2;
			_Icon.y = 2;
			addChild( _Icon );
//			SelectedDownSkin = DefaultSelectedDownSkin();	
        }
		protected var _Icon:DisplayObject;

        override public function set Selected( val:Boolean ):void
        {
			_Icon.visible = val;
            super.Selected = val;
        }

        override protected function ValidateTextPos():void
        {
            _pLabel.y = (this.height - _pLabel.height)/2;
            var b:Number = this.GetCurrStateSkin() ?  this.GetCurrStateSkin().width : 0;
            _pLabel.x = b + 2 + PaddingLeft;
        }

//		private function DefaultSelectedOverSkin():Shape
//		{
//			var selectedOverSkin:Shape = new Shape();
//			selectedOverSkin.graphics.lineStyle(1);
//			selectedOverSkin.graphics.moveTo(2, 2);
//			selectedOverSkin.graphics.lineTo(4, 12);
//			selectedOverSkin.graphics.lineTo(12, 1);
//			selectedOverSkin.graphics.lineStyle(1, 0x00ffff);
//			selectedOverSkin.graphics.drawRect(0, 0, 14, 14);
//			selectedOverSkin.graphics.beginFill(0x00bfff, 0.3);
//			selectedOverSkin.graphics.drawRect(0, 0, 14, 14);
//			selectedOverSkin.graphics.endFill();
//			return selectedOverSkin;
//		}
//		
//		private function DefaultSelectedUpSkin():Shape
//		{
//			var selectedUpSkin:Shape = new Shape();			
//			selectedUpSkin.graphics.lineStyle(1);
//			selectedUpSkin.graphics.drawRect(0, 0, 14, 14);
//			selectedUpSkin.graphics.beginFill(0xffffff);
//			selectedUpSkin.graphics.drawRect(0, 0, 14, 14);
//			selectedUpSkin.graphics.endFill();
//			selectedUpSkin.graphics.lineStyle(1);
//			selectedUpSkin.graphics.moveTo(2, 2);
//			selectedUpSkin.graphics.lineTo(4, 12);
//			selectedUpSkin.graphics.lineTo(12, 1);
//			return selectedUpSkin;
//		}	
//		private function DefaultSelectedDownSkin():Shape
//		{
//			var selectedDownSkin:Shape = new Shape();
//			selectedDownSkin.graphics.lineStyle(1);
//			selectedDownSkin.graphics.moveTo(2, 2);
//			selectedDownSkin.graphics.lineTo(4, 12);
//			selectedDownSkin.graphics.lineTo(12, 1);
//			selectedDownSkin.graphics.lineStyle(1, 0x00ffff);
//			selectedDownSkin.graphics.drawRect(0, 0, 14, 14);
//			selectedDownSkin.graphics.beginFill(0xffffff, 0.3);
//			selectedDownSkin.graphics.drawRect(0, 0, 14, 14);
//			selectedDownSkin.graphics.endFill();
//			return selectedDownSkin;
//		}

		/**
		 * 
		 * @return 
		 */
		protected function DefaultUpSkin():Shape
        {
            var skin:Shape = new Shape();
            skin.graphics.lineStyle( 2, 0x2C5159 );
            skin.graphics.beginFill( 0 );
            skin.graphics.drawRect( 0, 0, 16, 16 );
            skin.graphics.endFill();
            return skin;
        }

		/**
		 * 
		 * @return 
		 */
		protected function DefaultOverSkin():Shape
        {
            var skin:Shape = new Shape();
            skin.graphics.lineStyle( 2, 0x2C5159 );
            skin.graphics.beginFill( 0x282828 );
            skin.graphics.drawRect( 0, 0, 16, 16 );
            skin.graphics.endFill();
            return skin;
        }

//		private function DefaultDownSkin():Shape
//		{
//			var downSkin:Shape = new Shape();
//			downSkin.graphics.beginFill(0xdcdcdc);
//			downSkin.graphics.drawRect(0, 0, 14, 14);
//			downSkin.graphics.endFill();
//			downSkin.graphics.lineStyle(1);
//			downSkin.graphics.drawRect(0, 0, 14, 14);
//			return downSkin;
//		}

		/**
		 * 
		 * @return 
		 */
		protected function DefaultDisabledSkin():Shape
        {
            var skin:Shape = new Shape();
            skin.graphics.lineStyle( 2, 0x2C5159 );
            skin.graphics.beginFill( 0x474747 );
            skin.graphics.drawRect( 0, 0, 16, 16 );
            skin.graphics.endFill();
            return skin;
        }

//		private function DefaultSelectedDisabledSkin():Shape
//		{
//			var selectedDisabledSkin:Shape = new Shape();
//			selectedDisabledSkin.graphics.lineStyle(1);
//			selectedDisabledSkin.graphics.moveTo(2, 2);
//			selectedDisabledSkin.graphics.lineTo(4, 12);
//			selectedDisabledSkin.graphics.lineTo(12, 1);		
//			selectedDisabledSkin.graphics.beginFill(0xf5f5f5);
//			selectedDisabledSkin.graphics.drawRect(0, 0, 14, 14);
//			selectedDisabledSkin.graphics.endFill();
//			selectedDisabledSkin.graphics.lineStyle(1);
//			selectedDisabledSkin.graphics.drawRect(0, 0, 14, 14);
//			return selectedDisabledSkin;
//		}

//        public function set UpSkinIdent( val:int ):void
//        {
//            UpSkin = ReaderFactory.ImageSetReader.GetContentByIdent( val );
//
//        }
//
//        public function set DownSkinIdent( val:int ):void
//        {
//            DownSkin = ReaderFactory.ImageSetReader.GetContentByIdent( val );
//
//        }
//
//        public function set OverSkinIdent( val:int ):void
//        {
//            OverSkin = ReaderFactory.ImageSetReader.GetContentByIdent( val );
//        }
//
//        public function set SelectedUpSkinIdent( val:int ):void
//        {
//            SelectedUpSkin = ReaderFactory.ImageSetReader.GetContentByIdent( val );
//        }
//
//
//        public function set SelectedDownSkinIdent( val:int ):void
//        {
//            SelectedDownSkin = ReaderFactory.ImageSetReader.GetContentByIdent( val );
//        }
//
//
//        public function set SelectedOverSkinIdent( val:int ):void
//        {
//            SelectedOverSkin = ReaderFactory.ImageSetReader.GetContentByIdent( val );
//        }
//
//        public function set DisabledSkinIdent( val:int ):void
//        {
//            DisabledSkin = ReaderFactory.ImageSetReader.GetContentByIdent( val );
//        }
//
//        public function set SelectedDisabledSkinIdent( val:int ):void
//        {
//            SelectedDisabledSkin = ReaderFactory.ImageSetReader.GetContentByIdent( val );
//        }

        protected override function ValidateSize():void
        {
//			super.ValidateSize();
        }

        public override function get width():Number
        {
            return _pLabel.width + 3 + PaddingLeft + PaddingRight;
        }

        override public function set width( w:Number ):void
        {
            var b:Number = 16;
            this._pLabel.width = w - b - 3 - PaddingLeft - PaddingRight;
        }

        public override function get height():Number
        {
            var h:Number = 16;
            return h > _pLabel.textHeight ? h : _pLabel.textHeight;
        }
		override public function set Label(str:String):void {
			super.Label = str;
			if( width==-1 ) {
				width = _pLabel.textWidth + 3 + PaddingLeft + PaddingRight + 16;
			}
		}
    }
}