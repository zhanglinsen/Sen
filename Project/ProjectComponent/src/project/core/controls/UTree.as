package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import project.core.events.UIEvent;
    import project.core.global.DirectionConst;

    /**
     * 树状显示控件
     * @author meibin
     */
    public class UTree extends UList
    {
        /**
         * 
         * @param gap
         */
        public function UTree( gap:int = 3 )
        {
            super( DirectionConst.VERTICAL, gap );
        }

//		override public function PositionByIndex(idx:int):void {
//			VScrollPosition = this.getChildAt(idx).y;
//		}
        private var _SelectedNode:UTreeItem;

        override public function Clear( begin:int = 0 ):void
        {
            SelectedNode = null;
            super.Clear();
        }

        /**
         * 收缩第几个节点
         * @param idx
         */
        public function CollapseAt( idx:int ):void
        {
            (this.getChildAt( idx ) as UTreeItem).Collapse();
        }

        /**
         * 根据ID折叠节点，-1折叠全部
         */
        public function CollapseByID( nodeId:int = -1 ):void
        {
            for ( var i:int=0; i<this.numChildren; i++ )
            {
                var item:UTreeItem = this.getChildAt( i ) as UTreeItem;

                if ( nodeId==-1 )
                {
                    item.Collapse();
                }
                else if ( item.Ident == nodeId )
                {
                    item.Collapse();
                    break;
                }
            }
        }

        /**
         * 展开第几个节点
         * @param idx
         */
        public function ExpandAt( idx:int ):void
        {
            (this.getChildAt( idx ) as UTreeItem).Expand();
        }

        /**
         * 根据ID展开节点，-1展开全部
         */
        public function ExpandByID( nodeId:int = -1 ):void
        {
            for ( var i:int=0; i<this.numChildren; i++ )
            {
                var item:UTreeItem = this.getChildAt( i ) as UTreeItem;

                if ( nodeId==-1 )
                {
                    item.Expand();
                }
                else
                {
                    item = item.GetNodeByID( nodeId );

                    if ( item )
                    {
                        item.Expand();
                    }
                    break;
                }
            }
        }

        /**
         * 选中指定的节点
         * @param nodeId
         */
        public function SelectNode( nodeId:int ):void
        {
            for ( var i:int=0; i<this.numChildren; i++ )
            {
                var item:UTreeItem = this.getChildAt( i ) as UTreeItem;
                item = item.GetNodeByID( nodeId );

                if ( item )
                {
                    SelectedNode = item;
                    item.Expand();
                    var pos:int = globalToLocal( item.localToGlobal( new Point())).y;
                    this.PositionByIndex(( pos+Gap )/VScrollStep );
                    break;
                }
            }
        }

        override public function get SelectedData():Object
        {
            return _SelectedNode ? _SelectedNode.Data : null;
        }

        override public function get SelectedIndex():int
        {
            if ( !SelectedItem )
            {
                return -1;
            }
            return this.getChildIndex( _SelectedNode.Root );
        }

        override public function set SelectedIndex( idx:int ):void
        {
            for ( var i:int=0; i<this.numChildren; i++ )
            {
                var item:UTreeItem = this.getChildAt( i ) as UTreeItem;

                if ( i==idx )
                {
                    this.SelectedNode = item;
                    return;
                }
            }
        }

        override public function get SelectedItem():DisplayObject
        {
            return _SelectedNode;
        }

        /**
         * 选中的节点
         * @return 
         */
        public function get SelectedNode():UTreeItem
        {
            return _SelectedNode;
        }

        /**
         * 
         * @param node
         */
        public function set SelectedNode( node:UTreeItem ):void
        {
            if ( node==SelectedNode )
            {
                return;
            }

            var oldIdx:int = SelectedIndex;

            if ( SelectedNode )
            {
                SelectedNode.Selected = false;
            }
            _SelectedNode = node;

            if ( node )
            {
                node.Selected = true;
            }

            var evt:UIEvent = new UIEvent( UIEvent.INDEX_CHANGED );
            evt.Data = { NewIndex: SelectedIndex, OldIndex: oldIdx};
//			PositionByIndex(SelectedIndex);
            this.dispatchEvent( evt );
        }

        override public function addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            child.removeEventListener( UIEvent.STATE_CHANGED, Node_OnChange );
            child.addEventListener( UIEvent.STATE_CHANGED, Node_OnChange );
            return super.addChildAt( child, index );
        }

        override public function removeChild( child:DisplayObject ):DisplayObject
        {
            child.removeEventListener( UIEvent.STATE_CHANGED, Node_OnChange );
            return super.removeChild( child );
        }

        override protected function get DefaultItemWrap():DisplayObject
        {
            return new UTreeItem();
        }

        override protected function Item_OnClick( e:MouseEvent ):void
        {
        }

        /**
         * 
         * @param e
         */
        protected function Node_OnChange( e:UIEvent ):void
        {
            this.SelectedNode = e.Data as UTreeItem;
        }
    }
}
