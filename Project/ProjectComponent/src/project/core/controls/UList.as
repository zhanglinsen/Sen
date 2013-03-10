package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    import project.core.entity.DragSource;
    import project.core.events.UIEvent;
    import project.core.global.DirectionConst;
    import project.core.global.GlobalVariables;

    [Event(name="indexChanged", type="project.core.events.UIEvent")]
    [Event(name="dragDrop", type="project.core.events.UIEvent")]
    /**
     * 列表控件
     * @author meibin
     */
    public class UList extends UListBase
    {
        /**
         * 
         * @param direction
         * @param gap
         */
        public function UList( direction:String = DirectionConst.VERTICAL, gap:int = 3 )
        {
            super( false, 0, 1, direction, gap );
        }

        /**
         * 可放置拖动的列表项
         * @default true
         */
        public var DropEnabled:Boolean = true;
		
        private var _DragData:Object;
        private var _DragSrc:DragSource;
        private var _Draggable:Boolean = false;
        private var _PreDragObj:DisplayObject;
        private var _Rule:UComponent;

        /**
         * @return 列表项是否可拖动
         */
        public function get Draggable():Boolean
        {
            return _Draggable;
        }

        /**
         * 
         * @param val
         */
        public function set Draggable( val:Boolean ):void
        {
            if ( Draggable==val )
            {
                return;
            }
            _Draggable = val;

            if ( !Draggable )
            {
                Item_OnMouseUp( null );
                DisabledDrag();
            }
            else
            {
                if ( !_DragSrc )
                {
                    _DragSrc = new DragSource();
                    _DragSrc.Data = {};
                }
                RepaintRule();
                EnabledDrag();
            }
        }

        /**
         * 将滚动条定位到第几个列表项
         * @param idx
         */
        public function PositionByIndex( idx:int ):void
        {
            switch ( this.Layout )
            {
                case DirectionConst.VERTICAL:
                    VScrollPosition = idx * this.VScrollStepReal;
                    break;
                case DirectionConst.HORIZONTAL:
                    HScrollPosition = idx * this.VScrollStepReal;
                    break;
            }
        }

        override public function addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            super.addChildAt( child, index );

            if ( Draggable )
            {
                child.addEventListener( MouseEvent.MOUSE_DOWN, Item_OnMouseDown );
            }
            return child;
        }

        override public function removeChild( child:DisplayObject ):DisplayObject
        {
            if ( Draggable )
            {
                child.removeEventListener( MouseEvent.MOUSE_DOWN, Item_OnMouseDown );
            }
            return super.removeChild( child );
        }

        /**
         * 
         */
        protected function DisabledDrag():void
        {
            for ( var i:int=0; i<this.numChildren; i++ )
            {
                this.getChildAt( i ).removeEventListener( MouseEvent.MOUSE_DOWN, Item_OnMouseDown );
            }
            this.removeEventListener( Event.REMOVED_FROM_STAGE, OnRemoved );
        }

        /**
         * 
         */
        protected function EnabledDrag():void
        {
            for ( var i:int=0; i<this.numChildren; i++ )
            {
                this.getChildAt( i ).addEventListener( MouseEvent.MOUSE_DOWN, Item_OnMouseDown );
            }

            this.addEventListener( Event.REMOVED_FROM_STAGE, OnRemoved );
        }

        override protected function InitItem( item:DisplayObject, data:Object ):void
        {
            super.InitItem( item, data );
            this.VScrollStep = item.height + Gap;
            this.HScrollStep = item.width + Gap;
        }

        override protected function ValidateSize():void
        {
            super.ValidateSize();
            this.RepaintRule();
        }

        private function Item_OnDrag( e:MouseEvent ):void
        {
            var px:Number = GlobalVariables.CurrStage.mouseX-_DragSrc.Data.OffsetX;

            if ( px<_DragSrc.Data.Start.x )
            {
                px=_DragSrc.Data.Start.x;
            }
            else if ( px>_DragSrc.Data.End.x - _DragSrc.DragObj.width )
            {
                px = _DragSrc.Data.End.x - _DragSrc.DragObj.width;
            }
            _DragSrc.DragObj.x = px;

            var py:Number = GlobalVariables.CurrStage.mouseY-_DragSrc.Data.OffsetY;

            if ( py<_DragSrc.Data.Start.y )
            {
                py=_DragSrc.Data.Start.y;
            }
            else if ( py>_DragSrc.Data.End.y-_DragSrc.DragObj.height )
            {
                py = _DragSrc.Data.End.y - _DragSrc.DragObj.height;
            }
            _DragSrc.DragObj.y = py;

            var idx:int=0;

            switch ( Layout )
            {
                case DirectionConst.HORIZONTAL:
                    idx = int(((px-_DragSrc.Data.Start.x + (ItemWidth+Gap)*0.5))/( ItemWidth+Gap ));
                    break;
                case DirectionConst.VERTICAL:
                    idx = int(((py-_DragSrc.Data.Start.y + (ItemHeight+Gap)*0.5))/( ItemHeight+Gap ));
                    break;
            }

            if ( idx>=this.numChildren )
            {
                idx = this.numChildren-1;
            }
            this.setChildIndex( _Rule, idx );
        }

        private function Item_OnMouseDown( e:MouseEvent ):void
        {
            if ( _DragSrc.DragObj || _PreDragObj )
            {
                return;
            }
            var obj:DisplayObject = e.currentTarget as DisplayObject;

            if ( obj.parent!=this.ContentContainer )
            {
                return;
            }
            _PreDragObj = obj;
            GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_UP, Item_OnMouseUp );
            GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_MOVE, Item_OnStartDrag );
        }

        private function Item_OnMouseUp( e:MouseEvent ):void
        {
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_MOVE, Item_OnStartDrag );
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_MOVE, Item_OnDrag );
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_UP, Item_OnMouseUp );

            if ( _DragSrc.DragObj )
            {
                var idx:int = this.getChildIndex( _Rule );
                removeChildAt( idx );
                GlobalVariables.CurrStage.removeChild( _DragSrc.DragObj );
                _DragSrc.DragObj.alpha = 1;
                _DragSrc.DragObj.x = _DragSrc.Data.OriX;
                _DragSrc.DragObj.y = _DragSrc.Data.OriY;
                var dataIdx:int;

                if ( !this.DropEnabled )
                {
                    dataIdx = _DragSrc.Data.ChildIndex;
                    addChildAt( _DragSrc.DragObj, _DragSrc.Data.ChildIndex );
                }
                else
                {
                    dataIdx = idx;
                    addChildAt( _DragSrc.DragObj, idx );
                }

                if ( this.DataProvider )
                {
                    DataProvider.splice( dataIdx, 0, _DragData );
                }
                SelectedIndex = dataIdx;
                this.dispatchEvent( new UIEvent( UIEvent.DRAG_DROP, { NewIndex:idx,OldIndex:_DragSrc.Data.ChildIndex }));
                _DragSrc.DragObj = null;
            }
            _PreDragObj = null;
        }

        private function Item_OnStartDrag( e:MouseEvent ):void
        {
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_MOVE, Item_OnStartDrag );

            if ( !_PreDragObj )
            {
                return;
            }
            _DragSrc.Data.Start = parent.localToGlobal( new Point( x, y ));
            _DragSrc.Data.End = new Point( _DragSrc.Data.Start.x+width, _DragSrc.Data.Start.y+height );

            _PreDragObj.alpha = 0.6;
            _DragSrc.DragObj = _PreDragObj;
            _DragSrc.Data.ChildIndex = this.getChildIndex( _PreDragObj );
            _DragSrc.Data.OffsetX = _PreDragObj.mouseX;
            _DragSrc.Data.OffsetY = _PreDragObj.mouseY;
            _DragSrc.Data.OriX = _PreDragObj.x;
            _DragSrc.Data.OriY = _PreDragObj.y;
            _DragData = DataProvider[_DragSrc.Data.ChildIndex];
            removeChildAt( _DragSrc.Data.ChildIndex );
            this.SelectedIndex = -1;
            DataProvider.splice( _DragSrc.Data.ChildIndex, 0, _DragData );
//			DataProvider[_DragSrc.Data.ChildIndex] = _DragData;
            addChildAt( _Rule, _DragSrc.Data.ChildIndex );
            Item_OnDrag( e );
            GlobalVariables.CurrStage.addChild( _PreDragObj );
            GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_MOVE, Item_OnDrag );

            _PreDragObj = null;
        }

        private function OnRemoved( e:Event ):void
        {
            Item_OnMouseUp( null );
        }

        private function RepaintRule():void
        {
            if ( !Draggable )
            {
                return;
            }

            if ( !_Rule )
            {
                _Rule = new UComponent();
            }
            _Rule.graphics.clear();
            _Rule.graphics.beginFill( 0xc0c0c0 );

            switch ( Layout )
            {
                case DirectionConst.HORIZONTAL:
                    _Rule.graphics.drawRect( 0, -2, 2, height+2 );
                    _Rule.width = 2;
                    _Rule.height = height+4;
                    break;
                case DirectionConst.VERTICAL:
                    _Rule.graphics.drawRect( -2, 0, width+2, 2 );
                    _Rule.width = width+4;
                    _Rule.height = 2;
                    break;
            }

            _Rule.graphics.endFill();
        }
    }
}
