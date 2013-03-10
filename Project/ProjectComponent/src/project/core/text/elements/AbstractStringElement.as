package project.core.text.elements
{
    import flash.text.TextFormat;

    public class AbstractStringElement implements IHyperElement
    {
        public function AbstractStringElement( str:String = "", isDynamic:Boolean=false )
        {
            _Content = str;
			_IsDynamic = isDynamic;
        }
		private var _IsDynamic:Boolean=false;
		public function get IsDynamic():Boolean {
			return _IsDynamic;
		}

        public function Parse( node:XML ):void
        {
			_NodeName=node.localName().toString();
        }
        private var _Content:String;
		private var _NodeName:String;
		public function get NodeName():String {
			return _NodeName;
		}

        public function get Content():String
        {
            return _Content;
        }

        public function set Content( str:String ):void
        {
            _Content = str;
        }
        private var _Format:TextFormat = null;

        public function get ContentFormat():TextFormat
        {
            return _Format;
        }

        public function set ContentFormat( fmt:TextFormat ):void
        {
            _Format = fmt;
        }
    }
}