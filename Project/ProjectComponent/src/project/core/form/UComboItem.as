package project.core.form
{
    import project.core.controls.UComboBox;
    import project.core.entity.MenuItemData;
    import project.core.events.UIEvent;

    [Event(name="itemClick", type="project.core.events.UIEvent")]
    public class UComboItem extends UFormItemBase
    {
        public function UComboItem( ident:int = 0 )
        {
            super( ident );
        }

        private var _Combo:UComboBox;

        public function get DataProvider():Array
        {
            return _Combo.DataProvider;
        }

        public function set DataProvider( value:Array ):void
        {
            _Combo.DataProvider = value;
        }

        public function get SelectedIndex():int
        {
            return _Combo.SelectedIndex;
        }
		
		public function set SelectedIndex(value:int):void
		{
			_Combo.SelectedIndex = value;
		}

        public function get SelectedData():MenuItemData
        {
            return _Combo.SelectedData;
        }

        override protected function InitComponent():void
        {
            super.InitComponent();

            _Combo = new UComboBox();
			_Combo.BackgroundColor = _pBgColor;
            _Combo.width = 95;
            _Combo.addEventListener( UIEvent.ITEM_CLICK, Combo_OnChange );
            addChild( _Combo );
        }
		
		override public function set height( val:Number ):void
		{
			if ( height==val )
			{
				return;
			}
			
			if ( _Combo )
			{
				_Combo.height = val-this.BorderThickness;
			}
			super.height = val;
		}
		
		public function set ValueWidth( val:Number ):void
		{
			if ( _Combo.width==val )
			{
				return;
			}
			_Combo.width = val;
			ValidateSize();
//			RepaintForm();
		}

        private function Combo_OnChange( e:UIEvent ):void
        {
            this.dispatchEvent( new UIEvent( UIEvent.ITEM_CLICK, e.Data ));
        }
		
		public override function set Enabled(val:Boolean):void
		{
			super.Enabled = val;
			
			_Combo.Enabled = val;
		}
    }
}