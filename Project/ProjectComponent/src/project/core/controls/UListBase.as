package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.system.System;
    import flash.text.TextField;
    
    import project.core.containers.UCanvas;
    import project.core.events.UIEvent;
    import project.core.factory.IFactory;
    import project.core.global.DirectionConst;

    public class UListBase extends UCanvas
    {
        public function UListBase( bgColorEnabled:Boolean = false, bgColor:uint = 0x0, bgColorAlpha:Number = 1, layout:String = DirectionConst.ABSOLUTE, gap:int = 3, w:Number = -1, h:Number = -1 )
        {
            super( bgColorEnabled, bgColor, bgColorAlpha, layout, gap, w, h );
        }

        public var ItemRenderProperties:Array = null; //属性

        public var LabelField:String = "Label";
        private var _AutoSelect:Boolean = true; //自动选择

        private var _AutoSelectedIndex:int = -1;
        private var _DataProvider:Array = [];
        private var _FocusBg:DisplayObject;
        private var _FocusBgOffset:Point = new Point();
        private var _FocusBorderColor:uint = 0xD4D415; //选中边框颜色
        private var _FocusBorderThinkness:int = 0; //选中边框粗细
        private var _FocusIcon:DisplayObject;
        private var _FocusOffset:Point = new Point();
        private var _FocusShape:Sprite;

        private var _IdxChanged:Boolean = false;
        private var _ItemRenderer:IFactory;
        private var _SelectedIndex:int = -1;

        public function AddData( data:Object, idx:int = -1 ):DisplayObject
        {
//			if ( !_DataProvider )
//			{
//				_DataProvider = [];
//				_AutoSelectedIndex = -1;
//				_SelectedIndex = -1;
//			}
            if ( idx<0 || idx>_DataProvider.length )
            {
                idx = _DataProvider.length;
            }

            var item:DisplayObject = numChildren>_DataProvider.length && idx<numChildren ? getChildAt( idx ) : null;

            if ( !item )
            {
                item = ItemRenderer ? ItemRenderer.NewInstance() : DefaultItemWrap;

                if ( !item )
                {
                    return null;
                }

                item.addEventListener( MouseEvent.CLICK, Item_OnClick );


            }
            _DataProvider.splice( idx, 0, data );

            InitItem( item, data );

            if ( item.parent==null )
            {
                if ( idx>=_DataProvider.length )
                {
                    this.addChild( item );
                }
                else
                {
                    this.addChildAt( item, idx );
                }
            }

            if ( AutoSelect && _AutoSelectedIndex==-1 && IsSelectable( item ))
            {
                _IdxChanged = true;
                _AutoSelectedIndex = idx;
                SelectedIndex = idx;
            }

            return item;
        }

        /**
         * 是否自动选择
         * 目前在设置数据集前设置有效
         */
        public function get AutoSelect():Boolean
        {
            return _AutoSelect;
        }

        public function set AutoSelect( value:Boolean ):void
        {
            _AutoSelect = value;
        }

        /**清空项目*/
        public function Clear( begin:int = 0 ):void
        {
            _IdxChanged = false;
            this._DataProvider = [];

            while ( this.numChildren > begin )
            {
                var child:DisplayObject = super.removeChild( getChildAt( begin ));
                child.removeEventListener( MouseEvent.CLICK, Item_OnClick );
            }

            if ( SelectedIndex==-1 || SelectedIndex>=begin )
            {
                this._FocusShape.graphics.clear();
                this._SelectedIndex = -1;

                if ( _AutoSelectedIndex!=-1 )
                {
                    _AutoSelectedIndex = begin-1;
                }
            }

            System.gc();
        }


        public function get DataProvider():Array
        {
            return _DataProvider;
        }

        public function set DataProvider( value:Array ):void
        {
            this.Clear( value==null?0:value.length );

            for ( var j:int = 0; value && j < value.length; j++ )
            {
                AddData( value[ j ], j );
            }

            if ( !_IdxChanged )
            {
                if ( AutoSelect && _AutoSelectedIndex==-1 )
                {
                    for ( var k:int = 0; k < numChildren; k++ )
                    {
                        var child:DisplayObject = getChildAt( k );

                        if ( IsSelectable( child ))
                        {
                            _AutoSelectedIndex = k;
                            break;
                        }
                    }
                }
                _SelectedIndex = -2;
                SelectedIndex = _AutoSelectedIndex;
            }
        }

        public function set FocusBg( val:DisplayObject ):void
        {
            if ( _FocusBg )
            {
                BgContainer.removeChild( _FocusBg );
                _FocusBg = null;
            }
            _FocusShape.graphics.clear();
            _FocusBg = val;

            if ( _FocusBg )
            {
                BgContainer.addChild( val );

                if ( SelectedItem )
                {
                    _FocusBg.visible = true;
                    _FocusBg.x = SelectedItem.x + _FocusBgOffset.x;
                    _FocusBg.y = SelectedItem.y + _FocusBgOffset.y;
                }
                else
                {
                    _FocusBg.visible = false;
                }
            }
        }

        public function set FocusBgOffset( p:Point ):void
        {
            if ( p )
            {
                _FocusBgOffset = p;
            }
            else
            {
                _FocusBgOffset = new Point();
            }
        }

        /**选中边框颜色*/
        public function get FocusBorderColor():uint
        {
            return this._FocusBorderColor;
        }

        public function set FocusBorderColor( value:uint ):void
        {
            this._FocusBorderColor = value;
        }

        /**选中边框粗细*/
        public function get FocusBorderThinkness():int
        {
            return this._FocusBorderThinkness;
        }

        public function set FocusBorderThinkness( value:int ):void
        {
            this._FocusBorderThinkness = value;
            DrawSelectedItem();
        }

        public function set FocusIcon( val:DisplayObject ):void
        {
            if ( _FocusIcon )
            {
                _FocusShape.removeChild( _FocusIcon );
                _FocusIcon = null;
            }
            _FocusShape.graphics.clear();
            _FocusIcon = val;

            if ( _FocusIcon )
            {
                _FocusShape.addChild( val );

                if ( SelectedItem )
                {
                    _FocusIcon.visible = true;
                    _FocusIcon.x = SelectedItem.x + _FocusOffset.x;
                    _FocusIcon.y = SelectedItem.y + _FocusOffset.y;
                }
                else
                {
                    _FocusIcon.visible = false;
                }
            }
        }

        public function set FocusIconOffset( p:Point ):void
        {
            if ( p )
            {
                _FocusOffset = p;
            }
            else
            {
                _FocusOffset = new Point();
            }
        }

        public function get ItemRenderer():IFactory
        {
            return _ItemRenderer;
        }

        public function set ItemRenderer( val:IFactory ):void
        {
            _ItemRenderer = val;
        }

        override public function set PositionX( px:Number ):void
        {
            super.PositionX = px;

            if ( this._FocusShape )
            {
                this._FocusShape.x = px;
            }
        }

        override public function set PositionY( py:Number ):void
        {
            super.PositionY = py;

            if ( this._FocusShape )
            {
                this._FocusShape.y = py;
            }
        }

        /**删除数据源*/
        public function RemoveData( data:Object ):void
        {
            if ( DataProvider )
            {
                var index:int = DataProvider.indexOf( data );

                if ( index != -1 )
                {
                    removeChildAt( index );
                }
            }
        }

        public function RemoveItemAt( idx:int ):void
        {
            removeChildAt( idx );
        }

        public function get SelectedData():Object
        {
            return (SelectedIndex>=this.numChildren || SelectedIndex<0) ? null : DataProvider[SelectedIndex];
        }

        public function get SelectedIndex():int
        {
            return _SelectedIndex;
        }

        public function set SelectedIndex( idx:int ):void
        {

            var maxIdx:int = DataProvider.length>0 ? DataProvider.length : this.numChildren;

            if ( idx >= maxIdx )
            {
                idx = maxIdx - 1;
            }

            var item:Object; // = SelectedItem;

//            if ( item )
//            {
//                if ( item.hasOwnProperty( "Selected" ))
//                {
//                    item["Selected"] = false;
//                }
//            }
            for ( var i:int=0; i<this.numChildren; i++ )
            {
                item = getChildAt( i );

                if ( item.hasOwnProperty( "Selected" ))
                {
                    item["Selected"] = false;
                }
            }

            if ( idx!=-1 )
            {
                item = getChildAt( idx );

                if ( item.hasOwnProperty( "Selected" ))
                {
                    item["Selected"] = true;
                }
            }
            var evt:UIEvent = new UIEvent( UIEvent.INDEX_CHANGED );
            evt.Data = { NewIndex: idx, OldIndex: SelectedIndex};
            _SelectedIndex = idx;
            _AutoSelectedIndex = idx;


            DrawSelectedItem();

            this.dispatchEvent( evt );
        }

        public function get SelectedItem():DisplayObject
        {
            return (SelectedIndex>=this.numChildren || SelectedIndex<0) ? null : getChildAt( SelectedIndex );
        }

        override public function addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            super.addChildAt( child, index );
            child.addEventListener( MouseEvent.CLICK, Item_OnClick );

//            if ( this.numChildren==1 )
//            {
//                SelectedIndex = 0;
//            }
//            else if ( SelectedIndex>=index )
//            {
//                SelectedIndex = SelectedIndex+1;
//            }
            return child;
        }

        override public function removeChild( child:DisplayObject ):DisplayObject
        {
            var index:int = this.getChildIndex( child );

            if ( this.DataProvider.length>0 )
            {
                this.DataProvider.splice( index, 1 );
            }
            super.removeChild( child );
            child.removeEventListener( MouseEvent.CLICK, Item_OnClick );

            index = SelectedIndex;
            _SelectedIndex = -1;
            SelectedIndex = index;

//            if ( this.numChildren>0 )
//            {
//                if ( SelectedIndex==index )
//                {
//                    SelectedIndex = 0;
//                }
//                else if ( SelectedIndex>index )
//                {
//                    SelectedIndex = SelectedIndex-1;
//                }
//            }
            return child;
        }

        override public function setChildIndex( child:DisplayObject, index:int ):void
        {
            var oldIdx:int = this.getChildIndex( child );

            if ( this.DataProvider.length>0 )
            {
                var obj:Object = this.DataProvider.splice( oldIdx, 1 )[0];
                DataProvider.splice( index, 0, obj );
            }
            super.setChildIndex( child, index );

            if ( SelectedIndex==oldIdx )
            {
                SelectedIndex = index;
            }
        }

        protected function get DefaultItemWrap():DisplayObject
        {
            return new ULabel();
        }

        /**画选中的形状*/
        protected function DrawSelectedItem():void
        {
            if ( _FocusIcon || _FocusBg )
            {
                if ( _FocusIcon )
                {
                    if ( SelectedItem )
                    {
                        _FocusIcon.visible = true;
                        _FocusIcon.x = SelectedItem.x + _FocusOffset.x;
                        _FocusIcon.y = SelectedItem.y + _FocusOffset.y;
                    }
                    else
                    {
                        _FocusIcon.visible = false;
                    }
                }

                if ( _FocusBg )
                {
                    if ( SelectedItem )
                    {
                        _FocusBg.visible = true;
                        _FocusBg.x = SelectedItem.x + _FocusBgOffset.x;
                        _FocusBg.y = SelectedItem.y + _FocusBgOffset.y;
                    }
                    else
                    {
                        _FocusBg.visible = false;
                    }
                }
                return;
            }
            var g:Graphics = this._FocusShape.graphics;
            g.clear();

            var item:DisplayObject = SelectedItem;

            if ( item && FocusBorderThinkness>0 )
            {
                g.lineStyle( FocusBorderThinkness, FocusBorderColor );
                g.drawRect( item.x, item.y, item.width, item.height );
            }
        }

        protected function InitItem( item:DisplayObject, data:Object ):void
        {

            if ( this.ItemWidth > 0 )
            {
                item.width = this.ItemWidth;
            }

            if ( this.ItemHeight > 0 )
            {
                item.height = this.ItemHeight;
            }

            if ( item is TextField )
            {
                item['text'] = data[LabelField];
                item.height = 20;

                if ( this.ItemWidth<=0 && width>0 )
                {
                    item.width = width;
                }
            }
            else if ( item.hasOwnProperty( 'Data' ))
            {
                item['Data'] = data;
            }


            for ( var j:int = 0; ItemRenderProperties && j < ItemRenderProperties.length; j++ )
            {
                if ( item.hasOwnProperty( ItemRenderProperties[ j ]) && data.hasOwnProperty( ItemRenderProperties[ j ]))
                {
                    item[ItemRenderProperties[j]] = data[ItemRenderProperties[j]];
                }
            }
        }

        protected function IsSelectable( child:Object ):Boolean
        {
            return child && (!child.hasOwnProperty( "Selectable" ) || child["Selectable"]);
        }

        protected function Item_OnClick( e:MouseEvent ):void
        {
            if ( !Enabled )
            {
                return;
            }
            var obj:DisplayObject = e.currentTarget as DisplayObject;

            if ( !IsSelectable( obj ))
            {
                return;
            }

			dispatchEvent(new UIEvent(UIEvent.SELECTE,obj));
			
            if ( this.SelectedItem==obj )
            {
                if ( obj.hasOwnProperty( "Selected" ) && !obj["Selected"])
                {
                    obj["Selected"] = true;
                }
                this.DrawSelectedItem();
                return;
            }

            SelectedIndex = this.getChildIndex( obj );
        }

        override protected function PreInit():void
        {
            super.PreInit();
            _FocusShape = new Sprite();
            _FocusShape.mouseChildren = false;
            _FocusShape.mouseEnabled = false;
            $addChild( this._FocusShape );
        }

        override protected function RepaintMask():void
        {
            super.RepaintMask();

            if ( _FocusShape )
            {
                if ( ClipContent )
                {
                    var w:Number = (width>0?width:1);
                    var h:Number = (height>0?height:1);
                    var m:DisplayObject;

                    if ( _FocusShape.mask==null )
                    {

                        m = CreateMask( w, h );
                        $addChildAt( m, 0 );
                        _FocusShape.mask = m;
                    }
                    else
                    {
                        _FocusShape.mask.width = mask.width;
                        _FocusShape.mask.height = mask.height;
                    }
                    _FocusShape.mask.x = mask.x;
                    _FocusShape.mask.y = mask.y;
                }
                else
                {
                    if ( _FocusShape.mask!=null && _FocusShape.mask.parent!=null )
                    {
                        $removeChild( _FocusShape.mask );
                    }
                    _FocusShape.mask = null;
                }
            }
        }
    }
}
