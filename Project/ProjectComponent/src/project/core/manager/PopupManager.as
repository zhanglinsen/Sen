package project.core.manager
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.system.System;
	import flash.ui.Keyboard;
	
	import project.core.containers.UPopupWindow;
	import project.core.containers.UWindow;
	import project.core.controls.UMessageBox;
	import project.core.global.GlobalVariables;
	import project.core.loader.LoaderUIBase;
	
	/**
	 * 弹出窗口管理器
	 * @author meibin
	 */
	public final class PopupManager
	{
		/**
         * 窗口容器
		 * @default 
		 */
		public static var Root:DisplayObjectContainer;
		/**
		 * 弹出窗口数量
		 * @return 
		 */
		public static function get numChildren():int {
			return Root.numChildren;
		}
		/**
		 * 初始化
		 */
		public static function Init():void {
			GlobalVariables.CurrStage.addEventListener(KeyboardEvent.KEY_UP, Stage_OnKeyUp );
			Root = new Sprite();
			GlobalVariables.RootParent.addChild(Root);
		}
		/**
		 * @return 是否已有模式窗口显示
		 */
		public static function HasModalWin():Boolean {
			if(!Root) return false;
			for(var i:int=numChildren-1; i>=0; i--) {
				var obj:Object = Root.getChildAt(i);
				if( obj.Modal ){
					return true;
				}
			}
			return false;
		}
		/**
		 * 关闭所有弹出窗口
		 * @param onlyModal 当值为true时只清除模式窗口
		 * @return 是否有窗口被关闭
		 */
		public static function Clear(onlyModal:Boolean=false):Boolean {
			if(!Root) return false;
			var ret:Boolean = false;
			for(var i:int=numChildren-1; i>=0; i--) {
				if( i>=numChildren ) continue;
				var obj:Object = Root.getChildAt(i);
				if( onlyModal ){
					if( !(obj is UWindow) || !obj.Modal || obj is LoaderUIBase){
						continue;
					}
				}
				ret = true;
				if( obj is UPopupWindow ) {
					if( !obj.IgnoreClear ) {
						obj.Hide();
					}
				} else {
					Root.removeChild(obj as DisplayObject);
				}
			}
			System.gc();
			return ret;
		}
		/**
		 * 忽略所有事件
		 * 当值为true时，不处理键盘事件esc(关闭窗口)和enter(确定对话框)
		 * @default false
		 */
		public static var IgnoreEventTrigger:Boolean=false;
		private static function Stage_OnKeyUp( e:KeyboardEvent ):void {
			if( Root.numChildren==0 || IgnoreEventTrigger ) return ;
			var obj:Object = Root.getChildAt(Root.numChildren-1);
			switch( e.keyCode ) {
				case Keyboard.ESCAPE:
					if( obj is UPopupWindow && obj.CloseEnabled ) {
						obj.Esc();
						break;
					}
					break;
				case Keyboard.ENTER:
					if( obj is UMessageBox ) {
						obj.DoEnter();
					}
					break;
			}
		}
		/**
		 * 弹出窗口
		 * @param comp 窗口对象
		 */
		public static function Show( comp:DisplayObject ):void {
			
			var i:int;
			var obj:Object;
			if ( comp is UPopupWindow && comp['PopupGroup'] )
			{
				for ( i=Root.numChildren-1; i>=0; i-- )
				{
					obj = Root.getChildAt( i );
					
					if ( obj!=comp && obj is UPopupWindow && obj['PopupGroup']==comp['PopupGroup'] )
					{
						obj.Hide();
					}
					obj = null;
				}
			}
			
//			for ( i=Root.numChildren-1; i>=0; i-- )
//			{
//				obj = Root.getChildAt( i );
//				
//				if ( !(obj is UPopupWindow && obj.Modal ) )
//				{
//					break;
//				}
//				obj = null;
//			}
			ToTop( comp );
		}
		/**
		 * 将窗口放到显示的顶层
		 * @param comp 窗口对象
		 */
		public static function ToTop( comp:DisplayObject ):void {
			Root.addChildAt( comp, Root.numChildren );
		}
	}
}