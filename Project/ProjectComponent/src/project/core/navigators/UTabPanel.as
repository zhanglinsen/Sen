package project.core.navigators
{
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    
    import project.core.containers.UCanvas;
    import project.core.events.UIEvent;
    import project.core.global.AlignConst;
    import project.core.global.DirectionConst;
    import project.core.global.GlobalVariables;
	
	[Event(name="indexChanged", type="project.core.events.UIEvent")]
    public class UTabPanel extends UCanvas
    {
        public function UTabPanel( direction:String=DirectionConst.HORIZONTAL )
        {
            _TabBar.Layout = direction;
            _TabBar.addEventListener( UIEvent.INDEX_CHANGED, TabBar_OnIndexChanged );
            super();
        }

        private var _Align:String = AlignConst.LEFT;
        private var _TabBar:UTabBar=new UTabBar();
        private var _TabContList:Array = [];
        private var _TabList:Array = [];

        /**
         * 添加一个标签页
         * @tab 标签信息，字符串或者对象{Label:'',ToolTip:''}
         * @comp 内容
         * @idx 位置,-1为添加到最后
         */
        public function AddTab( tab:Object, comp:DisplayObject, idx:int = -1 ):void
        {
            if ( idx==-1 )
            {
                idx = _TabList.length;
            }
            _TabList.splice( idx, 0, tab );
            _TabContList.splice( idx, 0, comp );

            if ( tab==null )
            {
                tab = {Label:''};
            }
            else if ( tab is String )
            {
                tab = {Label:tab};
            }
            var item:UTabItem = CreateTabItem( tab );
            _TabBar.addChildAt( item, idx );
            ValidateDir();
        }
		
		public override function set Enabled(val:Boolean):void
		{
			super.Enabled = val;
			for(var i:int = 0 ; i < _TabBar.numChildren; i++)
			{
				_TabBar.getChildAt(i)["Enabled"] = val;
			}
		}

        public function get Align():String
        {
            return _Align;
        }

        public function set Align( val:String ):void
        {
            if ( _Align==val )
            {
                return;
            }
            _Align = val;
            ValidateAlign();
        }

        public function get Direction():String
        {
            return _TabBar.Layout;
        }

        public function set Direction( dir:String ):void
        {
            if ( _TabBar.Layout == dir )
            {
                return;
            }
            _TabBar.Layout = dir;
            ValidateDir();
        }

        public function get ItemGap():Number
        {
            return _TabBar.Gap;
        }

        public function set ItemGap( gap:Number ):void
        {
            _TabBar.Gap = gap;
        }

        public function RemoveTab( idx:int ):void
        {
            if ( idx>=0 && idx<_TabList.length )
            {
				var cont:DisplayObject = _TabContList[idx];
				if ( cont!=null && cont.parent )
				{
					cont.parent.removeChild( cont );
				}
				_TabContList.splice( idx, 1 );
				
				_TabList.splice( idx, 1 );
                _TabBar.removeChildAt( idx );
            }
        }

        public function get SelectedIndex():int
        {
            return _TabBar.SelectedIndex;
        }

        public function set SelectedIndex( idx:int ):void
        {
            _TabBar.SelectedIndex = idx;
        }

        override public function set height( h:Number ):void
        {
            super.height = h;
            ValidateAlign();
        }

        override public function hitTestPoint( x:Number, y:Number, shapeFlag:Boolean = false ):Boolean
        {
            if ( x<0 || y<0 )
            {
                return _TabBar.hitTestPoint( x-_TabBar.x, y-_TabBar.y, shapeFlag );
            }
            return super.hitTestPoint( x, y, shapeFlag );
        }

        override public function set width( w:Number ):void
        {
            super.width = w;
            ValidateAlign();
        }

        override protected function CreateMask( w:Number, h:Number ):DisplayObject
        {
            var s:Shape = new Shape();
            PaintTabMask( s, w, h );
            return s;
        }

        protected function CreateTabItem( data:Object ):UTabItem
        {
            var item:UTabItem = new UTabItem();
			item.Data = data;
			return item;
        }

        /**
         * 初始化
         */
        override protected function Init( e:Event = null ):void
        {
            super.Init();
            $addChild( _TabBar );
            ValidateDir();
        }

        override public function set PositionX( px:Number ):void
        {
            if ( Direction==DirectionConst.VERTICAL )
            {
                px+=_TabBar.width+Gap;
            }
			super.PositionX = px;
        }

        override public function set PositionY( py:Number ):void
        {
            if ( Direction==DirectionConst.HORIZONTAL )
            {
                py+=_TabBar.height+Gap;
            }
			super.PositionY = py;
        }

        override protected function RepaintMask():void
        {
            super.RepaintMask();

            if ( ClipContent )
            {
                if ( this.mask!=null )
                {
                    this.mask.x = _TabBar.x;
                    this.mask.y = _TabBar.y;

                    if ( Direction==DirectionConst.HORIZONTAL )
                    {
                        this.mask.height = this.mask.height + _TabBar.height;
                    }
                    else
                    {
                        this.mask.width = this.mask.width + _TabBar.width;
                    }
                }
            }
        }

        protected function TabBar_OnIndexChanged( e:UIEvent ):void
        {
            var newIdx:int = e.Data.NewIndex;
            var oldIdx:int = e.Data.OldIndex;
            var cont:DisplayObject = _TabContList[ oldIdx ];
            this.VScrollPosition = 0;
            this.HScrollPosition = 0;

            if ( cont!=null && cont.parent )
            {
                cont.parent.removeChild( cont );
            }
            cont = _TabContList[ newIdx ];

            if ( cont!=null )
            {
                addChild( cont );
            }
			dispatchEvent( new UIEvent(UIEvent.INDEX_CHANGED, e.Data) );
        }

        protected function ValidateAlign():void
        {
            if ( Direction==DirectionConst.HORIZONTAL )
            {
                var px:Number = 0;

                if ( width>0 )
                {
                    switch ( Align )
                    {
                        case AlignConst.LEFT:
                            break;
                        case AlignConst.RIGHT:
                            px = width - _TabBar.width;
                            break;
                        case AlignConst.CENTER:
                            px = (width - _TabBar.width)*0.5;
                            break;
                    }
                }
                _TabBar.x = px;
                _TabBar.y = 0;
            }
            else
            {
                var py:Number = 0;

                if ( height>0 )
                {
                    switch ( Align )
                    {
                        case AlignConst.TOP:
                            break;
                        case AlignConst.BOTTOM:
                            py = height - _TabBar.height;
                            break;
                        case AlignConst.MIDDLE:
                            py = (height - _TabBar.height)*0.5;
                            break;
                    }
                }
                _TabBar.x = 0;
                _TabBar.y = py;
            }
        }
//		override public function get PaddingTop():int {
//			return (Direction==DirectionConst.HORIZONTAL ? _TabBar.height : 0)+super.PaddingTop;
//		} 
//		override public function get PaddingLeft():int {
//			return (Direction==DirectionConst.VERTICAL?_TabBar.width:0)+super.PaddingLeft;
//		} 

        protected function ValidateDir():void
        {
            if ( Direction==DirectionConst.HORIZONTAL )
            {
				this.PositionX = 0;
				this.PositionY = PaddingTop;
                this.BgContainer.x = this.PositionX; 
                this.BgContainer.y = this.PositionY;
				
				this.BgContainer.width = this.width;
				this.BgContainer.height = this.height - this.BgContainer.y;
            }
            else
            {
				this.PositionX = PaddingLeft;
				this.PositionY = 0;
                this.BgContainer.x = this.PositionX;
                this.BgContainer.y = this.PositionY;
				
				this.BgContainer.width = this.width - this.BgContainer.x;
				this.BgContainer.height = this.height;
            }
            ValidateAlign();
            ValidateScrollPos();

            if ( this.mask )
            {
                this.PaintTabMask( mask as Shape, ( width>0?width:0 )+BorderThickness*2, ( height>0?height:0 )+BorderThickness*2 );
            }
        }

        private function PaintTabMask( s:Shape, w:Number, h:Number ):void
        {
            s.graphics.clear();
            s.graphics.beginFill( 0xFF0000 );

            for ( var i:int=0; i<_TabBar.numChildren; i++ )
            {
                var obj:DisplayObject = _TabBar.getChildAt( i );
                s.graphics.drawRect( obj.x, obj.y, obj.width, obj.height );
            }

            if ( Direction==DirectionConst.HORIZONTAL )
            {
                s.graphics.drawRect( 0, _TabBar.height, w, h );
            }
            else
            {
                s.graphics.drawRect( _TabBar.width, 0, w, h );
            }
            s.graphics.endFill();
        }
    }
}