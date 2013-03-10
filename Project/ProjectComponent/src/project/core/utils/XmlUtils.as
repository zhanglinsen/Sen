package project.core.utils
{
	import flash.display.DisplayObject;
	
	import project.core.global.GlobalVariables;
	import project.core.loader.ClassLoader;
	import project.core.reader.ReaderFactory;
	import project.core.text.IText;

    public final class XmlUtils
    {

        public static function GetNode( fileName:String, tagName:String, ident:*, attr:String = "ident" ):XML
        {
            var xml:XML = ReaderFactory.XmlReader.GetXml( fileName );

            if ( xml )
            {
                var list:XMLList = xml[tagName].(@[attr]==ident);

                if ( list.length()>0 )
                {
                    return list[0];
                }
            }
            return null;
        }

        public static function GetNodeList( fileName:String, tagName:String, subTagName:String = "", ident:* = -1, attr:String = "ident" ):XMLList
        {
            var xml:XML = ReaderFactory.XmlReader.GetXml( fileName );

            if ( xml )
            {
                var list:XMLList;

                if ( subTagName )
                {
                    list = xml[tagName][subTagName];
                }
                else
                {
                    list = xml[tagName];
                }

                if ( ident==-1 )
                {
                    return list;
                }
                return list.(@[attr]==ident);
            }
            return new XMLList();
        }


        public static function GetText( ident:String, params:Object = null ):String
        {
			if( !ident ) return "";
            var txt:IText = ReaderFactory.TextReader.GetText( ident );

            if ( txt )
            {
                return txt.toString( params );
            }
            return ident;
        }

        /**
         * 如果有URL则返回相应URL，否则通过id取对象<br/>
         * 示例：<br/>
         * GetXmlImage( node, "icon" );<br/>
         * 如果 node=&lt;Object icon="0.gif" /&gt;;<br/>
         * 则返回 "resource/Image/0.gif";<br/>
         * 如果 node=&lt;Object iconId="1001" /&gt;;<br/>
         * 则返回 ReaderFactory.ImageSetReader.GetContentByIdent( iconId );
         */
        public static function GetXmlImage( node:XML, attr:String = "icon", className:String = null ):Object
        {
            if ( node==null )
            {
                return null;
            }
            var val:String = node.@[attr];

            if ( val )
            {
				var obj:DisplayObject = ReaderFactory.ImageSetReader.GetContent( val );
				if( obj ) {
					return obj;
				}
                return GlobalVariables.GetResourcePath( val );
            }

            if ( !className )
            {
                className = node.@[attr+"Class"];
            }

            var ident:int = node.@[attr+"Id"];

            if ( ident>0 )
            {
                var flip:Boolean = node.@flip=="1";
                return ReaderFactory.ImageSetReader.GetContentByIdent( ident, className, flip );
            }

            if ( className )
            {
                return ClassLoader.GetInstance( className );
            }
            return null;
        }

        //===================================END=================================

        public static function GetXmlList( fileName:String, nodeName:String, subNodeName:String = null ):XMLList
        {
            var typeXml:XML = ReaderFactory.XmlReader.GetXml( fileName );

            if ( typeXml )
            {
                if ( subNodeName )
                {
                    return typeXml[nodeName][subNodeName];
                }
                else
                {
                    return typeXml[nodeName];
                }
            }

            return null
        }

        /**
         * 如果有字符则返回相应内容，否则通过id取对象<br/>
         * 示例：<br/>
         * GetXmlText( node, "name" );<br/>
         * 如果 node=&lt;Object name="天水" /&gt;;<br/>
         * 则返回 "天水";<br/>
         * 如果 node=&lt;Object nameId="1001" /&gt;;<br/>
         * 则返回 ReaderFactory.TextReader.GetText( nameId );
         */
        public static function GetXmlText( node:XML, attr:String = "name" ):Object
        {
            var val:String = node.@[attr];

            if ( val )
            {
                return val;
            }

            var ident:String = node.@[attr+"Id"];

            if ( ident )
            {
                return ReaderFactory.TextReader.GetText( ident );
            }
            return "";
        }
    }
}