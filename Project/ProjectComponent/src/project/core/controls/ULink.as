package project.core.controls
{
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    
    /**
     * 超链接
     * @author meibin
     */
    public class ULink extends UButton
    {
        /**
         * 
         * @param label
         */
        public function ULink( label:String = "" )
        {
            super( label, false );
			Padding = [0,0,0,0];
            this.Border = false;
            this.Background = false;
        }

        /**
         * 
         * @default 
         */
        public var Target:String="_blank";
        /**
         * 
         * @default 
         */
        public var Url:String;
        private var _DisabledUnderline:Boolean = false;
        private var _DownUnderline:Boolean = false;
        private var _OverUnderline:Boolean = true;
        private var _UpUnderline:Boolean = false;

        /**
         * 
         * @return 
         */
        public function get DisabledUnderline():Boolean
        {
            return _DisabledUnderline;
        }

        /**
         * 
         * @param val
         */
        public function set DisabledUnderline( val:Boolean ):void
        {
            if ( DisabledUnderline==val )
            {
                return;
            }
            _DisabledUnderline = val;

            if ( !Enabled )
            {
                ValidateText();
            }
        }

        /**
         * 
         * @return 
         */
        public function get DownUnderline():Boolean
        {
            return _DownUnderline;
        }

        /**
         * 
         * @param val
         */
        public function set DownUnderline( val:Boolean ):void
        {
            if ( DownUnderline==val )
            {
                return;
            }
            _DownUnderline = val;

            if ( Enabled && _pState==BUTTON_DOWN )
            {
                ValidateText();
            }
        }

        /**
         * 
         * @return 
         */
        public function get OverUnderline():Boolean
        {
            return _OverUnderline;
        }

        /**
         * 
         * @param val
         */
        public function set OverUnderline( val:Boolean ):void
        {
            if ( OverUnderline==val )
            {
                return;
            }
            _OverUnderline = val;

            if ( Enabled && _pState==BUTTON_OVER )
            {
                ValidateText();
            }
        }

        /**
         * 
         * @return 
         */
        public function get UpUnderline():Boolean
        {
            return _UpUnderline;
        }

        /**
         * 
         * @param val
         */
        public function set UpUnderline( val:Boolean ):void
        {
            if ( UpUnderline==val )
            {
                return;
            }
            _UpUnderline = val;

            if ( Enabled && _pState==BUTTON_UP )
            {
                ValidateText();
            }
        }

        override protected function OnMouseClick( e:MouseEvent ):void
        {
            if ( Enabled && Url )
            {
                navigateToURL( new URLRequest( Url ), Target );
            }
            super.OnMouseClick( e );
        }

        override protected function ValidateText():void
        {
            if ( this.Enabled )
            {
                switch ( _pState )
                {
                    case BUTTON_DOWN:
                        Underline = DownUnderline;
                        break;
                    case BUTTON_OVER:
                        Underline = OverUnderline;
                        break;
                    case BUTTON_UP:
                        Underline = UpUnderline;
                        break;
                }
            }
            else
            {
                Underline = DisabledUnderline;
            }
            super.ValidateText();
        }
    }
}