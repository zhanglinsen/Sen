package project.core.containers
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.events.Event;
    
    import project.core.controls.UComponent;
    import project.core.global.DirectionConst;

    [Event(name="resize", type="flash.events.Event")]
    public class UBox extends UComponent
    {
        /**
         * Box容器，添加的子对象自动横向或竖向排列
         * @param layout 默认横向，DirectionConst常量可改变排列方式
         * @param gap 排列间隔，默认为3
         * @param w 容器宽度 -1为自动按照内容大小调整
         * @param h 容器高度 -1为自动按照内容大小调整
         */
        public function UBox( layout:String = DirectionConst.HORIZONTAL, gap:int = 3, w:Number = -1, h:Number = -1 )
        {
            _Layout = layout;
            _Gap = gap;
            super( w, h );
        }

        private var _AutoAlign:Boolean = true;
        private var _Gap:int;
        private var _Height:Number=-1;
        private var _ItemHeight:Number=0;
        private var _ItemWidth:Number=0;
        private var _Layout:String;
        private var _MaxItemHeight:Number=0;
        private var _MaxItemWidth:Number=0;
        private var _MultiLine:Boolean = false;
        private var _Width:Number=-1;

        /**
         *
         * @param child
         * @return
         */
        public function $contains( child:DisplayObject ):Boolean
        {
            return super.contains( child );
        }

        /**
         * 自动对齐，横向排列时所有子对象y值为MarginTop，竖向排列时所有子对象x值为MarginLeft
         * @return
         */
        public function get AutoAlign():Boolean
        {
            return _AutoAlign;
        }

        /**
         * 自动对齐，横向排列时所有子对象y值为MarginTop，竖向排列时所有子对象x值为MarginLeft
         * @param val
         */
        public function set AutoAlign( val:Boolean ):void
        {
            if ( AutoAlign==val )
            {
                return;
            }
            _AutoAlign = val;
            this.ValidateSize();
        }

        /**
         * 排列间隔
         * @return
         */
        public function get Gap():Number
        {
            return _Gap;
        }

        /**
         * 排列间隔
         * @param gap
         */
        public function set Gap( gap:Number ):void
        {
            if ( _Gap==gap )
            {
                return;
            }
            _Gap = gap;
            ValidateSize();
        }

        /**
         * 内容高度，如果指定，则加入的子对象都会被设置为此值
         * @return
         */
        public function get ItemHeight():Number
        {
            return _ItemHeight>0?_ItemHeight:_MaxItemHeight;
        }

        /**
         * 内容高度，如果指定，则加入的子对象都会被设置为此值
         * @param h
         */
        public function set ItemHeight( h:Number ):void
        {
            _ItemHeight = h;
        }

        /**
         * 内容宽度，如果指定，则加入的子对象都会被设置为此值
         * @return
         */
        public function get ItemWidth():Number
        {
            return _ItemWidth>0?_ItemWidth:_MaxItemWidth;
        }

        /**
         * 内容宽度，如果指定，则加入的子对象都会被设置为此值
         * @param w
         */
        public function set ItemWidth( w:Number ):void
        {
            _ItemWidth = w;
        }

        /**
         * 排列方式
         * @return
         */
        public function get Layout():String
        {
            return _Layout;
        }

        /**
         * 排列方式
         * @param dir
         */
        public function set Layout( dir:String ):void
        {
            if ( _Layout==dir )
            {
                return;
            }
            _Layout = dir;
            ValidateSize();
        }

        /**
         * 最大内容高度，如果子对象超过，则按此值设置
         * @return
         */
        public function get MaxItemHeight():Number
        {
            return _MaxItemHeight;
        }

        /**
         * 最大内容高度，如果子对象超过，则按此值设置
         * @return
         */
        public function get MaxItemWidth():Number
        {
            return _MaxItemWidth;
        }

        /**
         * 是否多行排列，如果是，则在横向超过宽度或竖向超过高度时从新行或新列添加子对象
         * @return
         */
        public function get MultiLine():Boolean
        {
            return _MultiLine;
        }

        /**
         * 是否多行排列，如果是，则在横向超过宽度或竖向超过高度时从新行或新列添加子对象
         * @param val
         */
        public function set MultiLine( val:Boolean ):void
        {
            if ( MultiLine==val )
            {
                return;
            }
            _MultiLine = val;
            this.ValidateSize();
        }

        override public function addChild( child:DisplayObject ):DisplayObject
        {
            return addChildAt( child, numChildren );
        }

        override public function addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            if ( child )
            {
                child.addEventListener( Event.RESIZE, Child_OnResize );
                $addChildAt( child, index );
                ValidateSize();
            }
//            ValidateSize( index );
            return child;
        }

        override public function get height():Number
        {
            return super.height==-1&&_Height!=-1?_Height+PaddingTop+PaddingBottom:super.height;
        }

        override public function removeChild( child:DisplayObject ):DisplayObject
        {
            if ( child )
            {
                child.removeEventListener( Event.RESIZE, Child_OnResize );
                var child:DisplayObject = $removeChild( child );
                ValidateSize();
            }
            return child;
        }

        override public function removeChildAt( index:int ):DisplayObject
        {
            return removeChild( getChildAt( index ));
        }

//		override public function removeChild( child:DisplayObject ):DisplayObject
//		{
//			return removeChildAt( getChildIndex( child ));
//		}
//
//        override public function removeChildAt( index:int ):DisplayObject
//        {
//            var child:DisplayObject = super.removeChildAt( index );
//			ValidateSize();
//            return child;
//        }

        override public function setChildIndex( child:DisplayObject, index:int ):void
        {
            super.setChildIndex( child, index );
            ValidateSize();
        }

        override public function get width():Number
        {
            return super.width==-1&&_Width!=-1?_Width+PaddingLeft+PaddingRight:super.width;
        }


        /**
         *
         * @param child
         * @return
         */
        protected function $addChild( child:DisplayObject ):DisplayObject
        {
            return super.addChild( child );
        }

        /**
         *
         * @param child
         * @param index
         * @return
         */
        protected function $addChildAt( child:DisplayObject, index:int ):DisplayObject
        {
            return super.addChildAt( child, index );
        }

        /**
         *
         * @param index
         * @return
         */
        protected function $getChildAt( index:int ):DisplayObject
        {
            return super.getChildAt( index );
        }

        /**
         *
         * @param name
         * @return
         */
        protected function $getChildByName( name:String ):DisplayObject
        {
            return super.getChildByName( name );
        }

        /**
         *
         * @return
         */
        protected function get $graphics():Graphics
        {
            return super.graphics;
        }

        /**
         *
         * @return
         */
        protected function get $numChildren():int
        {
            return super.numChildren;
        }

        /**
         *
         * @param c
         * @return
         */
        protected function $removeChild( c:DisplayObject ):DisplayObject
        {
            return super.removeChild( c );
        }

        /**
         *
         * @param child
         * @param index
         */
        protected function $setChildIndex( child:DisplayObject, index:int ):void
        {
            super.setChildIndex( child, index );
        }

        /**
         * 调整横向排列的大小
         */
        protected function ValidateHorSize():void
        {
            var px:Number = MarginLeft;
            var py:Number = MarginTop;

            _Height = MaxItemHeight + MarginTop + MarginBottom;

//            if ( startIdx>0 )
//            {
//                var obj:DisplayObject = getChildAt( startIdx-1 );
//                px = obj.x + obj.width + Gap;
//            }

            for ( var i:int=0; i<numChildren; i++ )
            {
                var item:DisplayObject = getChildAt( i );

                if ( item.visible )
                {
                    if ( MultiLine && px+item.width>width )
                    {
                        px = MarginLeft;
                        py += MaxItemHeight + Gap;
                    }
                    item.x = px;

                    if ( AutoAlign )
                    {
                        item.y = py;
                    }
                    px += item.width + Gap;
                }
            }

            var w:Number = Math.round(( px==MarginLeft? px :px - Gap )+MarginRight );

            if ( _Width != w )
            {
                _Width = w;
                this.dispatchEvent( new Event( Event.RESIZE ));
            }
        }

        /**
         * 调整子对象的大小
         */
        protected function ValidateItemSize():void
        {
            var w:Number = 0;
            var h:Number = 0;

            if ( _ItemHeight<=0 || _ItemWidth<=0 )
            {
                for ( var i:int=0; i<numChildren; i++ )
                {
                    var item:DisplayObject = getChildAt( i );

                    if ( item.visible )
                    {
                        if ( item.width>w )
                        {
                            w = item.width;
                        }

                        if ( item.height>h )
                        {
                            h = item.height;
                        }
                    }
                }
            }

            if ( _ItemHeight>0 )
            {
                h = _ItemHeight;
            }

            if ( _ItemWidth>0 )
            {
                w = _ItemWidth;
            }
            _MaxItemWidth = w;
            _MaxItemHeight = h;
        }

        override protected function ValidateSize():void
        {
            if ( Layout!=DirectionConst.ABSOLUTE )
            {
                ValidateItemSize();

                if ( numChildren>0 )
                {
                    switch ( Layout )
                    {
                        case DirectionConst.HORIZONTAL:
                            ValidateHorSize();
                            break;
                        case DirectionConst.VERTICAL:
                            ValidateVerSize();
                            break;
                    }
                }
                else
                {
                    _Width = MarginLeft + MarginRight;
                    _Height = MarginTop + MarginBottom;
                }
            }
            else
            {
                _Width = -1;
                _Height = -1;
            }
            super.ValidateSize();
        }

        /**
         * 调整竖向排列的大小
         */
        protected function ValidateVerSize():void
        {
            var px:Number = MarginLeft;
            var py:Number = MarginTop;
            _Width = MaxItemWidth + MarginLeft + MarginRight;

//            if ( startIdx>0 )
//            {
//                var obj:DisplayObject = getChildAt( startIdx-1 );
//                py = obj.y + obj.height + Gap;
//            }

            for ( var i:int=0; i<numChildren; i++ )
            {
                var item:DisplayObject = getChildAt( i );

                if ( item.visible )
                {
                    if ( MultiLine && py+item.height>height )
                    {
                        py = MarginTop;
                        px += MaxItemWidth + Gap;
                    }
                    item.y = py;

                    if ( AutoAlign )
                    {
                        item.x = px;
                    }
                    py += item.height + Gap;
                }
            }
            var h:Number = Math.round(( py==MarginTop? py :py - Gap )+MarginBottom );

            if ( _Height != h )
            {
                _Height = h;
                this.dispatchEvent( new Event( Event.RESIZE ));
            }
        }

        private function Child_OnResize( e:Event ):void
        {
            this.ValidateSize();
        }
    }
}
