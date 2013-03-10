package project.core.manager
{
    import flash.display.DisplayObjectContainer;
    import flash.display.InteractiveObject;
    import flash.display.Sprite;
    import flash.utils.Dictionary;
    
    import project.core.controls.UComponent;
    import project.core.global.GlobalVariables;
    import project.core.tooltip.IToolTipUI;
    import project.core.tooltip.ToolTip;
    import project.core.tooltip.ToolTipUIFactory;

    /**
     * tooltip管理器
     * @author meibin
     */
    public final class ToolTipManager
    {
        private static var _Instance:ToolTip;
        private static var _TipDataMap:Dictionary = new Dictionary();
        private static var _TipUIMap:Dictionary = new Dictionary();
        /**
         * tooltip容器
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

            _Instance = new ToolTip();
            _Instance.GetToolTipData = GetTip;
            _Instance.GetToolTipUI = GetUI;
        }

        /**
         * 获取对象的tooltip内容
         * @param comp 
         * @return tooltip内容
         */
        public static function GetTip( comp:InteractiveObject ):Object
        {
            if ( comp is UComponent )
            {
                return (comp as UComponent).ToolTip;
            }
            else
            {
                return _TipDataMap[comp];
            }
        }

        /**
         * 获取对象的tooltip显示ui
         * @param comp
         * @return tooltip显示ui
         */
        public static function GetUI( comp:InteractiveObject ):Object
        {
            return _TipUIMap[comp];
        }

        /**
         * 添加对象到tooltip管理器
         * @param comp 受管理的对象
         * @param tipData tooltip内容
         * @param tipUI 显示tooltip的ui,如果为null,则使用默认ui显示
         */
        public static function Register( comp:InteractiveObject, tipData:Object = null, tipUI:IToolTipUI = null ):void
        {
            _Instance.UnRegister( comp );

            if ( !( comp is UComponent ))
            {
                _TipDataMap[comp] = tipData;
            }
            else
            {
                delete _TipDataMap[comp];
            }

            if ( tipUI!=null )
            {
                _TipUIMap[comp] = tipUI;
            }
            else
            {
                delete _TipUIMap[comp];
            }
            _Instance.Register( comp );
        }

        /**
         * 取消管理
         * @param comp
         */
        public static function UnRegister( comp:InteractiveObject ):void
        {
            delete _TipDataMap[comp];
            _Instance.UnRegister( comp );
        }

        /**
         * 显示tooltip
         * @param comp
         */
        public static function Show( comp:InteractiveObject ):void
        {
			_Instance.Show(comp);
        }
    }
}