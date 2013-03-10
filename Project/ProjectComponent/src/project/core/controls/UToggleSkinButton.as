package project.core.controls
{
    import flash.display.DisplayObject;
    
    import project.core.utils.SkinUtils;

    public class UToggleSkinButton extends UToggleButton
    {
        public function UToggleSkinButton( label:String = "", skinID:String = "0", fixedSize:Boolean = true, folder:String = "Button" )
        {
            _SkinID = skinID;
            _FixedSize = fixedSize;
            _SkinFolder = folder;
            super( label, false );
            this.Background = false;
            this.Border = false;
        }

        private var _FixedSize:Boolean;
        private var _SkinFolder:String;
        private var _SkinHeight:Number=0;
        private var _SkinID:String;
        private var _SkinWidth:Number=0;

        public function get FixedSize():Boolean
        {
            return _FixedSize;
        }

        public function set FixedSize( val:Boolean ):void
        {
            if ( FixedSize==val )
            {
                return;
            }
            _FixedSize = val;
            width = _SkinWidth;
            height = _SkinHeight;
        }

        public function get SkinID():String
        {
            return _SkinID;
        }

        public function set SkinID( val:String ):void
        {
            if ( SkinID==val )
            {
                return;
            }
            _SkinID = val;
            InitSkin();
        }

        override protected function InitComponent():void
        {
            InitSkin();
            super.InitComponent();
        }

        protected function InitSkin():void
        {
            var skins:Array = ["Up", "Over", "Down", "Disabled"];
            var selSkins:Array = ["Down", "Over", "Up", "Disabled"];
            var skin:String;
            var img:DisplayObject;

            for ( var i:int=0; i<skins.length; i++ )
            {
                skin = skins[i];
                img = SkinUtils.GetSkin( _SkinID, skin, _SkinFolder );

                if ( skin=="Up" )
                {
                    _SkinWidth = img.width;
                    _SkinHeight = img.height;

                    if ( _FixedSize )
                    {
                        width = _SkinWidth;
                        height = _SkinHeight;
                    }
                }

                if ( img )
                {
                    this[skin+"Skin"] = img;
                    this["Selected"+selSkins[i]+"Skin"] = img;
                }
            }
        }
    }
}