package project.core.controls
{
    import flash.display.DisplayObject;
    
    import project.core.utils.SkinUtils;

    public class USkinButton extends UButton
    {
        public function USkinButton( label:String = "", skinID:String = "0", fixedSize:Boolean = true, folder:String = "Button" )
        {
            _SkinID = skinID;
            _FixedSize = fixedSize;
            _SkinFolder = folder;
            super( label, false );
            TextColor = 0xFFFFB0;
            this.Background = false;
            this.Border = false;
        }

        private var _FixedSize:Boolean;
        private var _SkinFolder:String;
        private var _SkinID:String;

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
            var skin:String;
            var img:DisplayObject;

            for ( var i:int=0; i<skins.length; i++ )
            {
                skin = skins[i];
                img = SkinUtils.GetSkin( _SkinID, skin, _SkinFolder );

                if ( img )
                {
                    if ( _FixedSize && skin=="Up" )
                    {
                        width = img.width;
                        height = img.height;
                    }
                    this[skin+"Skin"] = img;
                }
            }
        }
    }
}