package project.core.manager
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.system.System;
    
    import project.core.global.GlobalVariables;
    import project.core.navigators.UMenu;

    /**
     * 弹出菜单管理器
     * @author meibin
     */
    public final class MenuManager
    {
        /**
         * 菜单容器
         * @default 
         */
        public static var Root:DisplayObjectContainer;

        /**
         * 初始化
         */
        public static function Init():void
        {
            Root = new Sprite();
            GlobalVariables.RootParent.addChild( Root );
        }

        /**
         * 弹出菜单
         * @param menu 菜单对象
         */
        public static function PopupMenu( menu:UMenu ):void
        {
            var p:Point = new Point( GlobalVariables.CurrStage.mouseX, GlobalVariables.CurrStage.mouseY );
            p = Root.parent.globalToLocal( p );

            if ( p.x+menu.width > GlobalVariables.StageWidth )
            {
                p.x -= menu.width;
            }

            if ( p.y + menu.height > GlobalVariables.StageHeight )
            {
                p.y -= menu.height;
            }
            menu.x = p.x;
            menu.y = p.y;
            Root.addChild( menu );
        }
		/**
		 * 忽略所有事件
		 * 当值为true时，不处理由事件触发的菜单隐藏
		 * @default false
		 */
		public static var IgnoreEventTrigger:Boolean=false;
		/**
		 * 隐藏菜单
		 * @param menu 菜单对象
		 * @param isEvtTrigger 是否由事件触发
		 */
		public static function HideMenu( menu:UMenu, isEvtTrigger:Boolean=false ):void {
			if( isEvtTrigger && IgnoreEventTrigger ) {
				return ;
			}
			if( menu.parent!=null ) {
				menu.parent.removeChild( menu );
			}
			System.gc();
		}
		/**
		 * 清除所有显示的菜单
		 */
		public static function Clear():void {
			if(!Root) return ;
			while(Root.numChildren>0) {
				Root.removeChildAt(0);
			}
			System.gc();
		}
    }
}