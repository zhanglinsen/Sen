package project.core.controls
{
    import project.core.manager.ToolTipManager;
    import project.core.tooltip.IToolTipUI;

    public class UComponent extends USprite implements IRender
    {

		/**
		 * UComponent容器，基础容器类 		支持ToolTip提示。<br/>  ToolTip： 支持 String 和 UI：DisplayObject
		 * @param w 容器宽度 
		 * @param h 容器高度
		 */
        public function UComponent( w:Number = 0, h:Number = 0 )
        {
            super( w, h );
        }

        private var _CustomerToolTipUI:IToolTipUI=null;
        private var _Data:Object = null;
        private var _Enabled:Boolean=true;
        private var _ToolTip:Object;

        public function get CustomerToolTipUI():IToolTipUI
        {
            return _CustomerToolTipUI;
        }

        public function set CustomerToolTipUI( ui:IToolTipUI ):void
        {
            _CustomerToolTipUI = ui;

            if ( _ToolTip != null && _ToolTip!="" )
            {
                ToolTipManager.Register( this, null, ui );
            }
        }

        public function get Data():Object
        {
            return _Data;
        }

        public function set Data( val:Object ):void
        {
            if ( val==Data )
            {
                return;
            }
            _Data = val;
        }

        public function get Enabled():Boolean
        {
            return _Enabled;
        }

        public function set Enabled( val:Boolean ):void
        {
            if ( Enabled == val )
            {
                return;
            }
            _Enabled = val;
        }

        public function get ToolTip():Object
        {
            return _ToolTip;
        }

        public function set ToolTip( obj:Object ):void
        {
            if ( _ToolTip==obj )
            {
                return;
            }
            _ToolTip = obj;

            if ( obj == null || obj=="" )
            {
                ToolTipManager.UnRegister( this );
            }
            else
            {
                ToolTipManager.Register( this, null, CustomerToolTipUI );
            }
        }
    }
}