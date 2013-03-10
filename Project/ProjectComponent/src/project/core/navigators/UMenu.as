package project.core.navigators
{
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import project.core.containers.UCanvas;
    import project.core.controls.UComponent;
    import project.core.entity.MenuItemData;
    import project.core.events.MenuEvent;
    import project.core.factory.ClassFactory;
    import project.core.global.DirectionConst;
    import project.core.global.GlobalVariables;
    import project.core.manager.MenuManager;

    [Event(name="itemClick", type="project.core.events.MenuEvent")]
    public class UMenu extends UCanvas
    {
        /**
         * @stageCloseAble 在菜单外点击的是否自动关闭
         * @itemCloseAble 在点击菜单项后是否自动关闭
        */
        public function UMenu( stageCloseAble:Boolean = true, itemCloseAble:Boolean = true )
        {
            super( false, 0, 1, DirectionConst.VERTICAL, 0 );
            this.addEventListener( MouseEvent.MOUSE_UP, Menu_OnClick );

            //Jack 2010-9-16
            this._StageCloseAble = stageCloseAble;
            this._ItemCloseAble = itemCloseAble;
            this._Items = [];
        }

        public var ItemRenderer:ClassFactory;
        private var _IsEventTrigger:Boolean=false;
        //在菜单项点击后能否关闭
        private var _ItemCloseAble:Boolean = true;

        private var _Items:Array;
        //能否在舞台上关闭菜单
        private var _StageCloseAble:Boolean = true;

        /**
         * Jack
         * 2010-9-16
         * 添加返回
        */
        public function AddItem( data:MenuItemData, idx:int = -1, child:DisplayObject = null ):DisplayObject
        {
            if ( idx==-1 )
            {
                //2010-9-16 顺序交换了
                idx = _Items.length;
                _Items.push( data );
            }
            else
            {
                _Items.splice( idx, 0, data );
            }

            if ( !child )
            {
                child = CreateMenuItem( data );
            }

            super.addChildAt( child, idx );

            return child;
        }

        /**
         * Jack
         * 2010-9-16
         * 隐藏菜单
        */
        public function Hide():void
        {
            MenuManager.HideMenu( this, _IsEventTrigger );
            _IsEventTrigger = false;
            GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_DOWN, Stage_OnClick );
        }

        public function get Items():Array
        {
            return _Items;
        }

        /**
         * 设置菜单内容
         */
        public function set Items( list:Array ):void
        {
            if ( list==null )
            {
                list = [];
            }
            _Items = list;

            while ( this.numChildren>0 )
            {
                super.removeChildAt( 0 );
            }

            for ( var i:int=0; list && i<list.length; i++ )
            {
                super.addChildAt( CreateMenuItem( list[ i ]), i );
            }

            ValidateSize();
        }

        public function RemoveItemAt( index:int ):void
        {
            _Items.splice( index, 1 );
            super.removeChildAt( index );
        }

        /**
         * Jack
         * 2010-9-16
         * 弹出菜单
         * @autoPosition 是否自动位置
        */
        public function Show( autoPosition:Boolean = true, x:Number = 0, y:Number = 0 ):void
        {
            MenuManager.PopupMenu( this );

            if ( !autoPosition )
            {
                this.x = x;
                this.y = y;
            }

            if ( this._StageCloseAble && GlobalVariables.CurrStage )
            {
                GlobalVariables.CurrStage.removeEventListener( MouseEvent.MOUSE_DOWN, Stage_OnClick );
                GlobalVariables.CurrStage.addEventListener( MouseEvent.MOUSE_DOWN, Stage_OnClick, false, 0, true );
            }
        }

        override public function addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            return child;
        }

        override public function removeChildAt( index:int ):DisplayObject
        {
            return null;
        }

        protected function CreateMenuItem( data:MenuItemData ):DisplayObject
        {
            var item:DisplayObject;

            if ( ItemRenderer )
            {
                item = ItemRenderer.NewInstance();

                if ( item is UComponent )
                {
                    item['Data'] = data;
                }
            }
            else
            {
                item = new UMenuItem( data );
            }
            return item;
        }

        override protected function ValidateItemSize():void
        {
            super.ValidateItemSize();

            for ( var i:int = 0; i<this.numChildren; i++ )
            {
                var item:DisplayObject = this.getChildAt( i );
                item.width = this.MaxItemWidth;
                item.height = this.MaxItemHeight;
            }
        }

        private function Menu_OnClick( e:MouseEvent ):void
        {
            var mx:Number = mouseX-PaddingLeft;
            var my:Number = mouseY-PaddingTop;
            var w:Number = width - PaddingLeft - PaddingRight;
            var h:Number = height - PaddingTop - PaddingBottom;

            if ( mx>=0 && mx<=w &&
                my>=0 && my<=h )
            {
                var idx:int = int(( my-PaddingTop )/( this.ItemHeight+this.Gap ));

                if ( idx>=0 && idx<_Items.length )
                {
                    this.dispatchEvent( new MenuEvent( MenuEvent.ITEM_CLICK, idx, _Items[ idx ]));

                    //点击菜单项后关闭菜单
                    if ( this._ItemCloseAble )
                    {
                        this.Hide();
                    }
                }
            }
//            e.stopImmediatePropagation();
            e.preventDefault();
        }

        private function Stage_OnClick( e:MouseEvent ):void
        {
            var p:Point = this.localToGlobal( new Point( this.x, this.y ));

            if ( this._StageCloseAble && this.mouseX != e.localX )
            {
                _IsEventTrigger = true;
                this.Hide();
            }
        }
    }
}
