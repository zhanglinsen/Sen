package project.core.controls
{
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.events.MouseEvent;
    import flash.text.TextFormatAlign;

    import project.core.image.RadioImage;

    /**
     * 单选框。可设置组，同一组内的单选框不可重复选中
     * @author chenwei
     */
    public class URadio extends UCheckBox
    {

        /**
         *
         * @param label
         * @param groupName
         */
        public function URadio( label:String = "", groupName:String = "" )
        {
            super( label );
            GroupName = groupName;

            if ( _Icon )
            {
                removeChild( _Icon );
            }
            _Icon = new RadioImage();
            _Icon.visible = false;
            _Icon.x = 3;
            _Icon.y = 3;
            addChild( _Icon );
            Align = TextFormatAlign.LEFT;
        }

        private var _GroupName:String;

        /**
         *
         * @return
         */
        public function get GroupName():String
        {
            return _GroupName;
        }

        /**
         *
         * @param value
         */
        public function set GroupName( value:String ):void
        {
            _GroupName = value;
        }

        override protected function DefaultDisabledSkin():Shape
        {
            var skin:Shape = new Shape();
            var g:Graphics = skin.graphics;
            g.lineStyle( 1, 0xd6d6d6 );
            g.beginFill( 0xd3d3d3 );
            g.drawCircle( 9, 9, 6 );
            g.endFill();
            return skin;
        }

        override protected function DefaultOverSkin():Shape
        {
            var skin:Shape = new Shape();
            var g:Graphics = skin.graphics;
            g.lineStyle( 1, 0x00FFFF );
            g.beginFill( 0x0c2522 );
            g.drawCircle( 9, 9, 6 );
            g.endFill();
            return skin;
        }

        override protected function DefaultUpSkin():Shape
        {
            var skin:Shape = new Shape();
            var g:Graphics = skin.graphics;
            g.lineStyle( 1, 0x325f55 );
            g.beginFill( 0x0c2522 );
            g.drawCircle( 9, 9, 6 );
            g.endFill();
            return skin;
        }

//		override public function set Selected(val:Boolean):void
//		{
//			super.Selected = val;
//			if(Selected)
//				UpdateRadios();
//		}

        override protected function OnMouseUp( e:MouseEvent ):void
        {
            if ( Selected )
            {
                return;
            }
            super.OnMouseUp( e );
            UpdateRadios();
        }

        override protected function ValidateTextPos():void
        {
            super.ValidateTextPos();
            _pLabel.y = (this.height - _pLabel.height)/2+1;
        }

        private function UpdateRadios():void
        {
            var obj:Object;

            for ( var i:int = 0; i < parent.numChildren; i++ )
            {
                obj = parent.getChildAt( i );

                if ( obj is URadio && obj["GroupName"] == GroupName && obj != this )
                {
                    obj["Selected"] = false;
                }
            }
        }
    }
}
