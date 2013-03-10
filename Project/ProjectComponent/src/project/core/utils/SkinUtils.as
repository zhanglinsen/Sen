package project.core.utils
{
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import project.core.reader.ReaderFactory;

    public class SkinUtils
    {
        private static var _Instance:SkinUtils = new SkinUtils();

        public static function GetSkin( skinId:String, state:String, skinFolder:String = "Button" ):DisplayObject
        {
            return _Instance.GetSkin( skinId, state, skinFolder );
        }

        public function SkinUtils()
        {
            _ScaleMap = new Dictionary();
            _ScaleMap["0"] = new Rectangle( 8, 8, 16, 6 );
            _ScaleMap["1"] = new Rectangle( 11, 11, 56, 8 );
            _ScaleMap["5"] = new Rectangle( 12, 10, 54, 10 );
            _ScaleMap["9"] = new Rectangle( 9, 7, 85, 8 );
            _ScaleMap["10"] = new Rectangle( 11, 11, 56, 8 );
            _ScaleMap["14"] = new Rectangle( 7, 6, 54, 12 );
            _ScaleMap["24"] = new Rectangle( 7, 6, 54, 12 );
            _ScaleMap["f4_03"] = new Rectangle( 5, 5, 47, 18 );
            _ScaleMap["25"] = new Rectangle( 8, 8, 143, 8 );
            _ScaleMap["c70"] = new Rectangle( 35, 3, 20, 21 );
            _ScaleMap["c71"] = new Rectangle( 9, 2, 35, 22 );
        }

        private var _ScaleMap:Dictionary;

        internal function GetSkin( skinId:String, state:String, skinFolder:String ):DisplayObject
        {
            var ext:String = skinId=="27" ? ".swf" : ( skinId=="25"||skinId=="16"||skinId=="13" ? ".jpg" : ".png" );
            var img:DisplayObject = ReaderFactory.ImageSetReader.GetContent( skinFolder+"/"+skinId+"_"+state+ext );

            if ( img )
            {
                img.scale9Grid = _ScaleMap[skinId];
            }
            return img;
        }
    }
}