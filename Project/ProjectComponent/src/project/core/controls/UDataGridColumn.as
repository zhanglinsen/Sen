package project.core.controls
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import project.core.containers.UCanvas;
	import project.core.events.UIEvent;
	import project.core.factory.ClassFactory;
	import project.core.factory.IFactory;
	import project.core.global.DirectionConst;
	import project.core.global.GlobalVariables;
	import project.core.utils.Filters;
	
	public class UDataGridColumn extends UCanvas
	{
		public function UDataGridColumn()
		{
			super(false, 0, 1, DirectionConst.VERTICAL);
			Gap = 1;
			this.Padding = [1,0,1,1];
		}
		
		
		private var _GridWidth:int = 80;
		private var _GridHeight:int = 20;
		private var _HeaderTextField:TextField;
		private var _SelectedItem:DisplayObject = null;
		
		private var _HeaderText:String;
//		private var _Data:Array = [];
		private var _Properties:Array = [];
		private var _Filter:Array = [];
		private var _DataField:String;
		
		private var _HeaderBgColor:uint = 0x0c1417;
		private var _GridTextColor:uint;
		private var _HeaderTextColor:uint;
		
		private var _TitleHeight:int = 22;
		private var _ItemRender:IFactory;
		private var _TitleBg:Sprite;
		private var _TitleBgAlpha:Number = 1.0;
		private var _HGap:Number = 0.0;
		
		override protected function PreInit():void
		{
			super.PreInit();
			
			_TitleBg = new Sprite();
			_TitleBg.x = 0;
			_TitleBg.y = 0;
			_TitleBg.graphics.beginFill(0,0);
			_TitleBg.graphics.drawRect(0,0,_GridWidth-1,_TitleHeight);
			_TitleBg.graphics.endFill();
			addChild(_TitleBg);
			
			_HeaderTextField = new TextField();
			_HeaderTextField.height = 1;
			_HeaderTextField.width = _GridWidth-1;
			_HeaderTextField.selectable = false;
			_HeaderTextField.filters = [Filters.TextGlow];
			_TitleBg.addChild(_HeaderTextField);
		}
		
		private function Repaint():void
		{			
			for(var i:int = 1; i<numChildren;i++)
			{
				getChildAt(i).width = _GridWidth-1;
				getChildAt(i).height = _GridHeight;				
			}
		}
			
		public function set HeaderText(val:String):void
		{
			if(_HeaderText == val) return;
			_HeaderText = val;
			_HeaderTextField.defaultTextFormat = new TextFormat(GlobalVariables.Font,GlobalVariables.FontSize,0x9be188,null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 3);
			_HeaderTextField.text = _HeaderText;
			_HeaderTextField.height = _HeaderTextField.textHeight;
			_HeaderTextField.y = (_TitleHeight - _HeaderTextField.textHeight)/2;	
		}
		
		private var _ItemFmt:TextFormat = new TextFormat(GlobalVariables.Font,GlobalVariables.FontSize, 0xE9E7CF,null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 3);
		override public function set Data(val:Object):void
		{			
			super.Data = val;
			Clear();
			
			if(_ItemRender == null)
			{
				_ItemRender = new ClassFactory(UInput);
			}
			for(var i:int = 0;i<Data.length;i++)
			{	
				var obj:Object = _ItemRender.NewInstance();					
				obj.height = this._GridHeight;
				obj.width = this._GridWidth-1;
				if(obj is UInput)
				{									
					obj.defaultTextFormat = _ItemFmt;
					obj.Selectable = false;
					if(_GridTextColor != 0)
						obj.TextColor = _GridTextColor;
					obj["Text"] = DataField == null?Data[i]:Data[i][DataField];
					obj["Editable"] = false;
					if(_Filter.length > 0)
						obj.filters = _Filter;
					obj.PaddingTop = (_GridHeight - obj.ContentHeight)/2;
					addChild(obj as UInput);
				}

				if(obj.hasOwnProperty("Data"))
				{
					obj.Data = Data[i];
					addChild(obj as DisplayObject);
					obj.addEventListener(MouseEvent.CLICK,Item_OnClick);
				}				
				
				if(_Properties.length > 0)
				{
					for(var j:int = 0 ;j<_Properties.length;j++)
					{
						if(Data[i][_Properties[j]] != null || Data[i][_Properties[j]] != 0)
							obj[_Properties[j]] = Data[i][_Properties[j]];
					}
					
				}
			}
		}
		
		private function Clear():void
		{
			while( numChildren > 1)
			{
				if(getChildAt(1).hasOwnProperty("numChildren"))
					getChildAt(1).removeEventListener(MouseEvent.CLICK,Item_OnClick);
				removeChildAt(1);
			}
		}
		
		private function Item_OnClick(e:MouseEvent):void
		{
			if( Item_Selectable(e.currentTarget) ) {
				if(e && _SelectedItem != e.currentTarget )
				{
					if(_SelectedItem && _SelectedItem.hasOwnProperty("Selected"))
					{
						_SelectedItem["Selected"] = false;
					}
					
					this._SelectedItem = e.currentTarget as DisplayObject;			
					if(_SelectedItem && _SelectedItem.hasOwnProperty("Selected"))
					{
						_SelectedItem["Selected"] = true;
					}
				}
				dispatchEvent(new UIEvent("GridSelect",getChildIndex(_SelectedItem)-1));
			}
		}
		
		protected function Item_Selectable(child:Object):Boolean
		{
			return !child.hasOwnProperty("Selectable") || child["Selectable"];
		}
		
		public function set DataField(val:String):void
		{
			if(DataField == val) return;
			_DataField = val;			
		}
		
		public function get DataField():String
		{
			return _DataField;
		}
		
		public function get SelectedItem():DisplayObject
		{
			return _SelectedItem;
		}
		
		public function set HeaderBgColor(val:uint):void
		{
			if(_HeaderBgColor == val) return;
			_HeaderBgColor = val;
			_TitleBg.graphics.clear();
			_TitleBg.graphics.beginFill(_HeaderBgColor);
			_TitleBg.graphics.drawRect(0,0,_GridWidth-1+_HGap,_TitleHeight);
			_TitleBg.graphics.endFill();
		}
		
		public function set HeaderTextColor(val:uint):void
		{
			_HeaderTextColor = val;
			_HeaderTextField.textColor = _HeaderTextColor;
		}
		
		public function set GridWidth(val:int):void
		{
			if(_GridWidth == val) return;
			_GridWidth = val;
			width = _GridWidth;
			Repaint();
			_HeaderTextField.width = _GridWidth;
		}
		
		public function set GridHeight(val:int):void
		{
			if(_GridHeight == val) return;
			_GridHeight = val;
			Repaint();
		}
		
		public function set TitleHeight(val:int):void
		{
			if(_TitleHeight == val) return;
			_TitleHeight = val;
			_TitleBg.graphics.clear();
			_TitleBg.graphics.beginFill(_HeaderBgColor,_TitleBgAlpha);
			_TitleBg.graphics.drawRect(0,0,_GridWidth-1,_TitleHeight);
			_TitleBg.graphics.endFill();
		}
		
		public function set TitleBgAlpha(val:Number):void
		{
			_TitleBgAlpha = val;
			_TitleBg.graphics.clear();
			_TitleBg.graphics.beginFill(_HeaderBgColor,_TitleBgAlpha);
			_TitleBg.graphics.drawRect(0,0,_GridWidth-1,_TitleHeight+_HGap);
			_TitleBg.graphics.endFill();
		}
		
		public function set GridTextColor(val:uint):void
		{
			if(_GridTextColor == val) return;
			_GridTextColor = val;
		}
		
		public function set ItemRender(val:IFactory):void
		{
			if(_ItemRender == val) return;
			_ItemRender = val;
		}
		
		public function set Disabled(val:int):void
		{
			if(getChildAt(val) is TextField)
			{
				TextField(getChildAt(val)).textColor = 0xD3D3D3;
			}else
			{
				IRender(getChildAt(val)).Enabled = false;
			}
		}
		
		public function set Properties(val:Array):void
		{
			_Properties = val;
		}
		
		public function set Filter(array:Array):void
		{
			_Filter = array;			
		}
		
		public function set HGap(value:Number):void
		{
			_HGap = value;
			_TitleBg.graphics.clear();
			_TitleBg.graphics.beginFill(_HeaderBgColor,_TitleBgAlpha);
			_TitleBg.graphics.drawRect(0,0,_GridWidth-1+_HGap,_TitleHeight);
			_TitleBg.graphics.endFill();
		}
	}
}