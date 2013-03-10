package project.core.manager
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import project.core.containers.UCanvas;
	import project.core.controls.UButton;
	import project.core.global.GlobalVariables;
	import project.core.global.LogType;
	import project.core.utils.Filters;
	import project.core.utils.Utility;
	
	public final class Debugger 
	{
		private static const TxtFormat:TextFormat =new TextFormat(GlobalVariables.Font, GlobalVariables.FontSize, 0xffffff, false, false, false, null, null, null, null, null, null, 3);
		private static function Write( str:String, color:uint=0xffffff ):void {
			var t:int = getTimer();
			var stamp:String = '[' + Utility.FormatTime( t/1000 ) + '.' + (t%1000) + "]: ";
			str = stamp + str;
			
			if( _Root && LogEnabled) {
				var toBottom:Boolean = false;
				var scollEnabled:Boolean = _Root.VScrollEnabled;
				if( _Root.VScrollPosition == _Root.VScrollBarMaxPosition ) {
					toBottom = true;
				}
				var txt:TextField = new TextField();
				txt.width = 350;
				txt.textColor = color;
				txt.filters = [Filters.TextGlow];
				txt.multiline = true;
				txt.wordWrap = true;
				txt.text = str;
				txt.setTextFormat( TxtFormat, 0, stamp.length );
				txt.height = txt.textHeight + 4;
				if( _Root.numChildren>200 ) {
					_Root.removeChildAt(0);
				}
				_Root.addChild( txt );
				_Root.x = GlobalVariables.StageWidth - _Root.width;
				if(toBottom||scollEnabled!=_Root.VScrollEnabled) {
					_Root.VScrollPosition = _Root.VScrollBarMaxPosition;
				}
			}
			
			Trace( str );
		}
		private static function Trace( str:String ):void {
			trace( str );
		}
		
		public static function Log( msg:String, type:int=0 ):void {
			var color:uint = 0x83E733;
			switch( type ) {
				case LogType.PACKET_BUFF:
					color = 0xffff00;
					break;
				case LogType.ERROR:
					color = 0xff0000;
					break;
				case LogType.PACKET_RECV:
					color = 0xff9900;
					break;
				case LogType.PACKET_SEND:
					color = 0x33BFE7;
					break;
				case LogType.INFO:
					color = 0x83E733;
					break;
				default:
					color = 0xbbbbbb;
					break;
			}
			Write(msg,color);
		}
		public static function Error( infos:String, color:uint=0xFF0000 ):void {
			if( GlobalVariables.LogLevel>=LogType.ERROR ) {
				Write( infos, color );
			} else {
				Trace( infos );
			}
		}
		public static function Debug( infos:String, color:uint=0x83E733 ):void {
			if( GlobalVariables.LogLevel>=LogType.DEBUG ) {
				Write( infos, color );
			}else {
				Trace( infos );
			}
		}
		public static function Info( infos:String, color:uint=0xffcc00 ):void {
			if( GlobalVariables.LogLevel>=LogType.INFO ) {
				Write( infos, color );
			}else {
				Trace( infos );
			}
		}
		public static function Warn( infos:String, color:uint=0x33BFE7 ):void {
			if( GlobalVariables.LogLevel>=LogType.INFO ) {
				Write( infos, color );
			}else {
				Trace( infos );
			}
		}
		public static function Hide():void {
			_Root.visible = false;
			_HideBtn.Label = "Show";
		} 
		public static function Clear(e:Event=null):void {
			_Root.RemoveAllChildren();
		}
		private static function ToggleDebugger(e:MouseEvent):void {
			_Root.visible = !_Root.visible;
			_HideBtn.Label = _Root.visible ? "Hide" : "Show";
		} 
		private static var _HideBtn:UButton;
		private static var _ClearBtn:UButton;
		public static function Init():void {
			_ChildIdx = GlobalVariables.RootParent.numChildren;
			_HideBtn = new UButton("Show");
			_HideBtn.height = 20;
			_HideBtn.x = GlobalVariables.StageWidth - _HideBtn.width - 200;
			_HideBtn.y = 100;
			_HideBtn.addEventListener(MouseEvent.CLICK, ToggleDebugger );
			GlobalVariables.RootParent.addChild(_HideBtn);
			
			_ClearBtn = new UButton("Clean");
			_ClearBtn.height = 20;
			_ClearBtn.x = _HideBtn.x- _ClearBtn.width - 2;
			_ClearBtn.y = _HideBtn.y;
			_ClearBtn.addEventListener(MouseEvent.CLICK, Clear );
			GlobalVariables.RootParent.addChild(_ClearBtn);
			
			_Root = new UCanvas(true, 0x0, 0.3, "vertical");
			_Root.visible = false;
			_Root.y = _HideBtn.y+23;
			_Root.height = 330;
			_Root.ClipContent = true;
			_Root.VScrollStep = 20;
			GlobalVariables.RootParent.addChild( _Root );
		} 
		private static var _LogEnabled:Boolean = true;
		public static function set LogEnabled(val:Boolean):void {
			_LogEnabled = val;
			if( _Root ) {
				_HideBtn.visible = val;
				_ClearBtn.visible = val;
				if( !val ) {
					Hide();
				}
			} 
		}
		public static function get LogEnabled():Boolean{
			return _LogEnabled;
		}
		private static var _ChildIdx:int = -1;
		public static function get ChildIndex():int {
			return _ChildIdx;
		}
		private static var _Root:UCanvas;
	}
}