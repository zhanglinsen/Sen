package project.core.tooltip
{

    public class ToolTipUIFactory
    {
        private static var _DefaultUI:IToolTipUI = null;
        private static var _FixedPosUI:IToolTipUI = null;
        private static var _StyleUI:IToolTipUI = null;

        public static function get DefaultUI():IToolTipUI
        {
            if ( _DefaultUI == null )
            {
                _DefaultUI = new DefaultToolTipUI();
            }
            return _DefaultUI;
        }

        public static function get FixedPositionUI():IToolTipUI
        {
            if ( _FixedPosUI==null )
            {
                _FixedPosUI = new FixedPositionToolTipUI();
            }
            return _FixedPosUI;
        }

        public static function get StyleUI():IToolTipUI
        {
            if ( _StyleUI==null )
            {
                _StyleUI = new StyleToolTipUI();
            }
            return _StyleUI;
        }
    }
}