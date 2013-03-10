package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import project.core.events.UIEvent;

    [Event(name="indexChanged", type="project.core.events.UIEvent")]
    /**Item列表*/
    public class UTileList extends UListBase
    {

        public function UTileList( bgColorEnabled:Boolean = false, bgColor:uint = 0 )
        {
            super( bgColorEnabled, bgColor );
            this.ClipContent = true;
            this.FocusBorderThinkness = 1;
        }

        protected var _ColumnCount:int = -1; //指定的列数  水平方向排列(默认方向)
        protected var _RowCount:int = -1; //指定的行数  垂直方向排列
        private var _HGap:Number = 2; //水平间距
        private var _VGap:Number = 2; //垂直间距

        /**设置列数 大于0侧水平排列 如果都不设置侧水平默认排列*/
        public function get ColumnCount():int
        {
            return _ColumnCount;
        }

        public function set ColumnCount( value:int ):void
        {
            _ColumnCount = value;

            if ( _ColumnCount > 0 )
            {
                _RowCount = -1;
            }
        }

        /**数据源*/
        override public function set DataProvider( value:Array ):void
        {
            super.DataProvider = value;
            LayoutItems();
            DrawSelectedItem();
        }

        /**Item水平间距*/
        public function get HGap():Number
        {
            return this._HGap;
        }

        public function set HGap( value:Number ):void
        {
            this._HGap = value;
        }

        /**排列Item*/
        public function LayoutItems():void
        {
            if ( this.numChildren==0 )
            {
                return;
            }

            var r:int = 1;
            var c:int = 0;

            if ( this.RowCount > 0 )
            {
                r = this.RowCount;
                c = numChildren / r;
                c += numChildren % r;
            }
            else if ( this.ColumnCount > 0 )
            {
                c = this.ColumnCount;
                r = numChildren / c;
                r += numChildren % c;
            }
            else
            {
                c = numChildren;
            }

            var child:DisplayObject;
            var sx:Number = MarginLeft; //this.PaddingLeft;
            var sy:Number = MarginTop; //this.PaddingTop;
            var selectable:Boolean;
            var j:int = 0;

//			var firstSelectable:int=-1;
            for ( var k:int = 0; k < numChildren; k++ )
            {
                child = getChildAt( k );
                child.x = sx;
                child.y = sy;
//				if( firstSelectable==-1 && IsSelectable(child)) {
//					firstSelectable = k;
//				}

                j++;

                if ( j < c )
                {
                    sx += child.width + this.HGap;
                }
                else
                {
                    j = 0;
                    sx = MarginLeft;
                    sy += child.height + this.VGap;
                }
            }

            child = null;

            ValidateScroll();
        }


        /**设置行数  大于0侧垂直方向显示*/
        public function get RowCount():int
        {
            return _RowCount;
        }

        public function set RowCount( value:int ):void
        {
            _RowCount = value;

            if ( _RowCount > 0 )
            {
                _ColumnCount = -1;
            }
        }

        override public function set SelectedIndex( idx:int ):void
        {
            if ( SelectedIndex==idx )
            {
                return;
            }
            super.SelectedIndex = idx;
        }

        /**Item垂直间距*/
        public function get VGap():Number
        {
            return this._VGap;
        }

        public function set VGap( value:Number ):void
        {
            this._VGap = value;
        }

//		protected function FireSelectEvent():void
//		{
//			var idx:int = _SelectedIndex;
//			
//			this._SelectedIndex = this._pItems.indexOf(this._SelectedItem);
//			
//			var evt:UIEvent = new UIEvent( UIEvent.INDEX_CHANGED);
//			evt.Data = {NewIndex: _SelectedIndex , OldIndex: idx};
//			this.dispatchEvent( evt );
//			
//			evt.stopPropagation();
//		}


        /**删除单一项目*/
        override public function removeChild( child:DisplayObject ):DisplayObject
        {
            super.removeChild( child );
            LayoutItems();
            return child;
        }

        protected function Paint():void
        {
            var g:Graphics = $graphics;
            g.clear();

            g.beginFill( 0xff0000, 0.0 );
            g.drawRect( 0, 0, width, height );
        }

        override protected function ValidateSize():void
        {
            super.ValidateSize();

            Paint();
        }
    }
}