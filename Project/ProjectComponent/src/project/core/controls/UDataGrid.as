package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;
    import project.core.containers.UCanvas;
    import project.core.events.UIEvent;
    import project.core.global.DirectionConst;
    import project.core.global.ScrollPolicy;
    import project.core.utils.Filters;
	
    /**
     * 表格
     * @author chenwei
     */
    public class UDataGrid extends UCanvas
    {
        /**
         * 
         * @param bgColorEnabled 是否有背景色
         * @param bgColor 背景色
         */
        public function UDataGrid( bgColorEnabled:Boolean = true, bgColor:uint = 0x0c1417 )
        {
            super( bgColorEnabled, bgColor );
            BorderThickness=0;
            BorderColor=0x4b7a70;
//            addEventListener( Event.ADDED_TO_STAGE, OnAddToStage );
        }

		/**
		 * 自动调整高度
		 * @default false 
		 */
		public var AutoHeight:Boolean = false;
		
        private var _AlternateColors:Array;
        private var _BgSprite:Sprite;
        private var _BorderSprite:Sprite;
        private var _ColumnCount:int;
        private var _Columns:Array=[];
        private var _DataProvider:Array=[];
        private var _Gap:int;
        private var _GridHeight:int=20;
        private var _IsNeedBorder:Boolean=true;
        private var _LineThick:int=1;
        private var _SelectedIndex:int;
        private var _SelectedItem:Object;
        private var _TitleHeight:int=22;

        /**
         * 交替背景色
         * @param value
         */
        public function set AlternateColors( value:Array ):void
        {
            _AlternateColors=value;
        }

        /**
         * 表格列
         * @param val
         */
        public function set Columns( val:Array ):void
        {
            if ( _Columns == val )
            {
                return;
            }
            _Columns=val;
			OnAddToStage();
        }

        /**
         * 
         * @return 
         */
        public function get DataProvider():Array
        {
            return _DataProvider;
        }
        /**
         * 数据
         * @param val
         */
        public function set DataProvider( val:Array ):void
        {
            _DataProvider=val;
			if( AutoHeight ) {
				height = ( _GridHeight + _LineThick )*val.length+TitleHeight+2;
			}

            for ( var i:int=0; i < _Columns.length; i++ )
            {
                _Columns[i].Data=_DataProvider;
            }
        }
		
		/**
		 * 表格高度
		 * @return 
		 */
		public function get GridHeight():int {
			return _GridHeight;
		}

        /**
         * 
         * @param val
         */
        public function set GridHeight( val:int ):void
        {
            if ( _GridHeight == val )
            {
                return;
            }
            _GridHeight=val;

//			OnAddToStage();
        }

        /**
         * 是否有边框
         * @param value
         */
        public function set IsNeedBorder( value:Boolean ):void
        {
            _IsNeedBorder=value;
            _Gap=_LineThick;
        }

        /**
         * 边框大小
         * @param val
         */
        public function set LineThick( val:int ):void
        {
            if ( _LineThick == val )
            {
                return;
            }
            _LineThick=val;
            _Gap=_LineThick;
        }

        /**
         * 选中位置
         * @return 
         */
        public function get SelectedIndex():int
        {
            return _SelectedIndex;
        }

        /**
         * 
         * @param value
         */
        public function set SelectedIndex( value:int ):void
        {
            _SelectedIndex=value;
        }

        /**
         * 选中对象
         * @return 
         */
        public function get SelectedItem():Object
        {
            return _DataProvider[_SelectedIndex];
        }
		
		/**
		 * 标题高题
		 * @return 
		 */
		public function get TitleHeight():int {
			return _TitleHeight;
		}

        /**
         * 
         * @param val
         */
        public function set TitleHeight( val:int ):void
        {
            if ( _TitleHeight == val )
            {
                return;
            }
            _TitleHeight=val;
        }

        override public function set height( h:Number ):void
        {
            if ( height!=h )
            {
				super.height = h;
				OnAddToStage();
//				if ( _AlternateColors )
//				{
//					DrawBg( height/_GridHeight );
//				}
//				for ( var i:int=0; i < _Columns.length; i++ )
//				{
//					_Columns[i].height=height;
//				}
//				if ( _IsNeedBorder )
//				{
//					DrawBorder( height/_GridHeight );
//				}
            }
        }

        protected function OnAddToStage( e:Event = null ):void
        {
            if ( _AlternateColors )
            {
                DrawBg( height/_GridHeight );
            }

            for ( var i:int=0; i < _Columns.length; i++ )
            {
                if ( i == 0 )
                {
                    _Columns[i].x=0;
                }
                else
                {
                    _Columns[i].x=_Columns[i - 1].width + _Columns[i - 1].x;
                }
                _Columns[i].y=BorderThickness;
                _Columns[i].height=height;
                _Columns[i].TitleHeight=_TitleHeight;
                _Columns[i].GridHeight=_GridHeight;

                if ( i != _Columns.length - 1 )
                {
                    _Columns[i].HGap=_Gap;
                }

                if ( !_Columns[i].parent )
                {
                    _Columns[i].addEventListener( "GridSelect", OnItemClick );
                    addChild( _Columns[ i ]);
                }
            }

            if ( _IsNeedBorder )
            {
                DrawBorder( height/_GridHeight );
            }

            removeEventListener( Event.ADDED_TO_STAGE, OnAddToStage );
        }

        private function DrawBg( num:int ):void
        {
			if(_BgSprite == null)
			{
				_BgSprite=new Sprite();
				addChild( _BgSprite );
			}
            _BgSprite.x=_LineThick;
            _BgSprite.y=_LineThick - _Gap;
            var g:Graphics=_BgSprite.graphics;
			g.clear();
            for ( var i:int=0; i < num; i++ )
            {
                if ( i < (num - 1))
                {
                    g.beginFill( _AlternateColors[ i % _AlternateColors.length ],BackgroundAlpha);
                    g.drawRect( 0, _TitleHeight+i*( _GridHeight + _LineThick )+_LineThick, width-_LineThick, _GridHeight+_Gap );
                    g.endFill();
                }
            }
        }

        private function DrawBorder( num:int ):void
        {
			if(_BorderSprite == null)
			{
				_BorderSprite=new Sprite();
				addChild( _BorderSprite );
			}
            var g:Graphics=_BorderSprite.graphics;
			g.clear();
            g.lineStyle( _LineThick, 0x4b7a70 );

            g.moveTo( 0, 0 );
            g.lineTo( width, 0 );

            for ( var i:int=0; i < num; i++ )
            {
                g.moveTo( 0, _TitleHeight+i*( _GridHeight + _LineThick )+_LineThick );
                g.lineTo( width, _TitleHeight+i*( _GridHeight + _LineThick )+_LineThick );
            }

            for ( var j:int=0; j < _Columns.length; j++ )
            {
                DrawUnitBox( new Point( _Columns[ j ].x, 0 ), g );
            }

            g.moveTo( width, 0 );
            g.lineTo( width, height );
        }

        private function DrawUnitBox( point:Point, g:Graphics ):void
        {
            g.lineStyle( 1, 0x4b7a70 );
            g.moveTo( point.x, point.y );
            g.lineTo( point.x, height );
        }

        private function OnItemClick( event:UIEvent ):void
        {
            _SelectedIndex=event.Data as int;
        }
    }
}
