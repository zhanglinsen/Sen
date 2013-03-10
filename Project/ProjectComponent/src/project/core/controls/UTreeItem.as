package project.core.controls
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import project.core.containers.UBox;
	import project.core.entity.TreeItemData;
	import project.core.events.UIEvent;
	import project.core.global.AlignConst;
	import project.core.global.DirectionConst;
	import project.core.image.MinusBtnDownImage;
	import project.core.image.MinusBtnOverImage;
	import project.core.image.MinusBtnUpImage;
	import project.core.image.PlusBtnDownImage;
	import project.core.image.PlusBtnOverImage;
	import project.core.image.PlusBtnUpImage;
	
	public class UTreeItem extends UBox
	{
		public function UTreeItem(parent:UTreeItem=null, gap:int=6)
		{
			super(DirectionConst.VERTICAL, gap);
			_Parent = parent;
			InitIcon();
			InitLabel();
			WrapItem();
		}
		private var _Parent:UTreeItem;
		public function get Parent():UTreeItem {
			return _Parent;
		}
		public function get Root():UTreeItem {
			var p:UTreeItem = this;
			while( p.Parent!=null ) {
				p = p.Parent;
			}
			return p;
		}
		protected var _pNode:UToggleButton;
		protected var _pNodeIco:UToggleButton;
		override public function set Data(val:Object):void {
			super.Data = val;
			var data:TreeItemData = val as TreeItemData;
			_pNode.Label = data.Label;
			_pNodeIco.visible = data.Children.length!=0;
			for( var i:int=0; i<data.Children.length; i++ ) {
				var child:UTreeItem = NewChildItem();
				child.MarginLeft = 12;
				child.Data = data.Children[i];
				child.visible = false;
				child.addEventListener(UIEvent.STATE_CHANGED, Child_OnStateChange );
				this.addChild( child );
			}
			this.Ident = data.Ident;
		}
		protected function NewChildItem():UTreeItem {
			return new UTreeItem(this, Gap);
		}
		protected function WrapItem():void {
			_pNode.x = 12;
			_pNode.addEventListener(UIEvent.STATE_CHANGED, Label_OnStateChange );
			_pNode.LockSelected = true;
			
			_pNodeIco.addEventListener(UIEvent.STATE_CHANGED, Node_OnStateChange );
			_pNodeIco.visible = false;
			_pNodeIco.MarginTop = 0.5*(_pNode.height - _pNodeIco.height );
			
			var wrap:USprite = new USprite();
			wrap.addChild( _pNodeIco );
			wrap.addChild( _pNode );
			wrap.width = _pNode.x + _pNode.width;
			wrap.height = _pNode.y + _pNode.height;
			addChild( wrap );
		}
		protected function Node_OnStateChange( e:UIEvent ):void {
			for( var i:int=1; i<this.numChildren; i++ ) {
				this.getChildAt(i).visible = _pNodeIco.Selected;
			}
			this.Refresh();
			this.dispatchEvent(new Event(Event.RESIZE));
		}
		protected function Child_OnStateChange(e:UIEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.STATE_CHANGED, e.Data));			
		}
		protected function Label_OnStateChange(e:UIEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.STATE_CHANGED, this));
		}
		protected function InitLabel():void {
			_pNode = new UToggleButton("", false);
			_pNode.Align = AlignConst.LEFT;
			_pNode.Border = false;
			_pNode.Background = false;
//			_pNode.SelectedUpSkin = new TreeNodeBgImage();
//			_pNode.OverSkin = _pNode.SelectedUpSkin;
			_pNode.height = 18;
			_pNode.TextColor = 0xCECBB5;
			_pNode.OverTextColor = 0xCECBB5;
			_pNode.DownTextColor = 0xCECBB5;
			_pNode.SelectedTextColor = 0xFFFF99;
			_pNode.SelectedOverTextColor = 0xFFFF99;
			_pNode.SelectedDownTextColor = 0xFFFF99;
			_pNode.LabelFilters = [];
		}
		protected function InitIcon():void {
			_pNodeIco = new UToggleButton("", false);
			_pNodeIco.Border = false;
			_pNodeIco.Background = false;
			_pNodeIco.SelectedOverSkin = new MinusBtnOverImage();
			_pNodeIco.SelectedDownSkin = new MinusBtnDownImage();
			_pNodeIco.SelectedUpSkin = new MinusBtnUpImage();
			_pNodeIco.OverSkin = new PlusBtnOverImage();
			_pNodeIco.DownSkin = new PlusBtnDownImage();
			_pNodeIco.UpSkin = new PlusBtnUpImage();
		}
		public function Collapse():void {
			_pNodeIco.Selected = false;
		}
		public function Expand():void {
			var node:UTreeItem = this;
			while( node!=null ) {
				if( !node._pNodeIco.Selected ) {
					node._pNodeIco.Selected = true;
					node.Node_OnStateChange(null);
				}
				node = node.Parent;
			}
		}
		public function set Selected(val:Boolean):void {
			_pNode.Selected = val;
		}
		public function get Selected():Boolean {
			return _pNode.Selected;
		}
		public function GetNodeByID(nodeId:int):UTreeItem {
			if( this.Ident==nodeId ) {
				return this;
			}
			for( var i:int=1; i<this.numChildren; i++ ) {
				var node:UTreeItem = (this.getChildAt(i) as UTreeItem).GetNodeByID(nodeId);
				if( node ) {
					return node;
				}
			}
			return null;
		}
		override public function set width(value:Number):void {
			super.width = value;
			_pNode.width = value - _pNode.x;
			for( var i:int=1; i<this.numChildren; i++ ) {
				getChildAt(i).width = _pNode.width;
			}
		} 
	}
}