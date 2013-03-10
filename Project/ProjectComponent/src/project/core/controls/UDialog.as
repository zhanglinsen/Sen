package project.core.controls
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import project.core.containers.UBox;
	import project.core.containers.UCanvas;
	import project.core.containers.UWindow;
	import project.core.events.UIEvent;
	import project.core.global.DirectionConst;
	import project.core.global.GlobalVariables;
	import project.core.image.DialogBgImage;
	import project.core.manager.PopupManager;
	import project.core.text.IText;
	import project.core.utils.Filters;
	
	[Event(name="hidden", type="project.core.events.UIEvent")]
	[Event(name="shown", type="project.core.events.UIEvent")]
	/**
	 * 对话框
	 * @author meibin
	 */
	public class UDialog extends UWindow
	{
		public static var ContinueText:String = "continue";
		public static const END_PRINT:String = "endPrint";
		public static const HIDDEN:int = 1;
		public static const PRINTING:int = 3;
		public static const PRINT_END:int = 2;

		/**
		 * 
		 * @param w 宽度
		 * @param h 高度
		 * @param modal 是否模式对话框
		 */
		public function UDialog(w:Number=305, h:Number=94, modal:Boolean=false)
		{
			super(w, h, modal);
			this.Layout = DirectionConst.HORIZONTAL;
			this.Gap = 8;
		}

//		/**
//		 * 自动完成
//		 * @default 
//		 */
//		public var AutoFinish:Boolean=true;
		/**
		 * 对话结束自动隐藏
		 * @default true
		 */
		public var AutoHide:Boolean = true;
		/**
		 * 显示下一步
		 * @default 
		 */
		public var ShowContinue:Boolean = true;
		private var _Continue:UBox;
		private var _Icon:UCanvas;
		private var _Label:TextField;
		private var _PrintIdx:int;
		private var _PrintIntervalID:int;
		private var _PrintText:String;
		private var _Showing:Boolean = false;
		private var _Text:TextField;

		/**
		 * 文本颜色
		 * @param val
		 */
		public function set Color(val:uint):void {
			_Label.textColor = val;
		}
		/**
		 * 点击，打印全部文字
		 * @return 
		 */
		public function DoClick():int {
			if(!parent) return HIDDEN;
			if( _Text.text!=_PrintText.replace(/\n/g,'\r') ) {
//				if( AutoFinish && _PrintIntervalID!=0 ) {
//					_Text.text = _PrintText;
//					EndPrint();
//					return PRINT_END;
//				}
				if( _PrintIntervalID!=0 ) {
					for( var i:int=_PrintIdx; i<_PrintText.length; i++ ) {
						if( PrintText() ) {
							return PRINT_END;
						}
					}
				}
				return PRINTING;
			}
			if( alpha!=1 ) {
				if(	_Showing ) {
					TweenLite.killTweensOf( this );
					alpha=1;
					BeginPrint();
				}
			} else {
				if( AutoHide ){
					Hide();
				}
				return HIDDEN;
			}
			return PRINTING;
		}
		/**
		 * 关闭窗口
		 */
		public function Hide(eff:Boolean=true):void
		{
			if ( parent!=null )
			{
				if( eff ) {
					TweenLite.to( this, 0.5, {alpha:0,ease:Linear.easeNone,onComplete:_Hide} );
				} else {
					_Hide();
				}
			}
		}
		/**
		 * 对话框图标
		 * @return 
		 */
		public function get Icon():* {
			return _Icon.Background;
		}
		/**
		 * 
		 * @param val
		 */
		public function set Icon( val:* ):void {
			_Icon.Background = val;
		}
		/**
		 * 
		 * @return 
		 */
		public function get Label():String {
			return _Label ? _Label.text : "";
		}
		/**
		 * 
		 * @param val
		 */
		public function set Label(val:String):void {
			_Label.text = val;
		}
		/**
		 * 显示超文本
		 * @param txt
		 * @param params
		 */
		public function SetHyperText( txt:IText, params:Object=null ):void {
			if( txt ) {
				txt.ToTextField( _Text, null, null, params );
				this.visible = true;
			} else {
				this.visible = false;
			}
//			ValidateText();
		}
		/**
		 * 对话内容
		 * @param val
		 */
		public function SetText( val:String ):void {
			_PrintText = val.replace(/\r/g,'');
			_Text.text = "";
//			_Text.text = val;
//			ValidateText();
		}
		/**
		 * 显示窗口
		 */
		public function Show(root:DisplayObjectContainer=null):void
		{
			if ( parent==null )
			{
				_Showing = true;
				this.alpha = 0;
				if( root ) {
					root.addChild(this);
				} else {
					PopupManager.Show( this );
				}
				TweenLite.to( this, 0.5, {alpha:1,ease:Linear.easeNone, onComplete:BeginPrint} );
			} else {
				BeginPrint();
			}
		}
		override protected function PreInit():void {
			this.addEventListener(MouseEvent.CLICK, Mouse_OnClick);
			Margin = [11,11,11,11];
			
			this.Background = DialogBgImage.GetImage();			
			
			_Icon = new UCanvas();
			_Icon.width = height - MarginTop - MarginBottom;
			_Icon.height = _Icon.width;
			
			_Label = new TextField();
			_Label.width = _Icon.width;
			_Label.height = 18;
			_Label.y = _Icon.height - _Label.height - 3;
			_Label.defaultTextFormat = new TextFormat(GlobalVariables.Font, GlobalVariables.FontSize, 0xDDDCCC, null, null, null, null, null, TextFormatAlign.RIGHT, null, null, null, 3);
			_Label.filters = [Filters.TextGlow];
			_Icon.addChild( _Label );
			
			addChild( _Icon );
			
			_Text = new TextField();
			_Text.selectable = false;
			_Text.multiline = true;
			_Text.wordWrap = true;
			_Text.mouseEnabled = false;
			_Text.mouseWheelEnabled = false;
			_Text.width = width - Gap - _Icon.width - MarginLeft - MarginRight;
			_Text.defaultTextFormat = new TextFormat(GlobalVariables.Font, GlobalVariables.FontSize, 0xffffcc, false, false, false, null, null, null, null, null, null, 3);
//			_Text.filters = [Filters.TextGlow];
			_Text.height = height - MarginTop - MarginBottom;
			addChild( _Text );
			
			super.PreInit();
		}
		private function BeginPrint():void {
			clearInterval(_PrintIntervalID);
			_PrintIntervalID = 0;
			if( _Continue ) {
				_Continue.visible = false;
			}
			_Showing = false;
			this.dispatchEvent(new UIEvent(UIEvent.SHOWN));
			_PrintIdx = 0;
			if( _Text.text!=_PrintText ) {
				_PrintIntervalID = setInterval(PrintText, 100);
			}
		}
		private function EndPrint():void {
			if( _PrintIntervalID==0 ) return ;
			if( ShowContinue ) {
				if( _Continue==null ) {
					_Continue = new UBox();
//					var ico:Bitmap = new ArrowImage();
					var ico:UImage = new UImage("resource/Image/UI/a30.png");
					_Continue.addChild(ico);
					
					var lbl:TextField = new TextField();
					lbl.defaultTextFormat = new TextFormat(GlobalVariables.Font,GlobalVariables.FontSize, 0xffcc00,null, null, null, null, null, null, null, null, null, 3);;
					lbl.autoSize = TextFieldAutoSize.LEFT;
					lbl.text = ContinueText;
					_Continue.addChild(lbl);
					
//					var txt:IText = ReaderFactory.TextReader.GetText("preload.label.continue");
//					if(txt) {
//						var lbl:TextField = new TextField();
//						txt.ToTextField(lbl,[]);
//						_Continue.addChild(lbl);
//					}
					ico.y = 3;
					$addChild(_Continue);
				}
				_Continue.visible = true;
				_Continue.x = width - MarginRight - _Continue.width + this.PositionX;
				_Continue.y = height - MarginBottom -_Continue.height + this.PositionY + 5;
			}
			clearInterval(_PrintIntervalID);
			_PrintIntervalID = 0;
			this.dispatchEvent(new Event(END_PRINT));
		}
		private function Mouse_OnClick(e:MouseEvent):void {
			DoClick();			
		}
		private function PrintText():Boolean {
			_Text.appendText( _PrintText.charAt(_PrintIdx) );
			_PrintIdx++;
			if(_PrintIdx>=_PrintText.length) {
				EndPrint();
				return true;
			}
			return false;
		}

		private function _Hide():void {
			if ( parent ) {
				clearInterval(_PrintIntervalID);
				_PrintIntervalID = 0;
				if( _Continue ) {
					_Continue.visible = false;
				}
				_Label.textColor = 0xDDDCCC;
				_Text.text = "";
				parent.removeChild( this );
				this.dispatchEvent(new UIEvent(UIEvent.HIDDEN));
			}
		}
	}
}