package project.core.reader
{

    /**
     * 解析器工厂
     */
    public class ReaderFactory
    {
        /**
         * 图像数据解析器
         */
        private static var _ImgSetReader:ImageSetDataReader = new ImageSetDataReader();
        /**
         * 模块数据解析器
         */
        private static var _ModReader:ModuleDataReader = new ModuleDataReader();
        /**
         * MovieClip数据解析器
         */
        private static var _MovieClipReader:MovieClipDataReader = new MovieClipDataReader();
        /**
         * 文本数据解析器
         */
        private static var _TxtReader:TextDataReader = new TextDataReader();
        /**
         * XML数据解析器
         */
        private static var _XmlReader:XmlDataReader = new XmlDataReader();

        /**
         * 图像数据解析器实例
         */
        public static function get ImageSetReader():ImageSetDataReader
        {
            return _ImgSetReader;
        }

        /**
         * 模块数据解析器实例
         */
        public static function get ModuleReader():ModuleDataReader
        {
            return _ModReader;
        }

        /**
         * MovieClip数据解析器实例
         */
        public static function get MovieClipReader():MovieClipDataReader
        {
            return _MovieClipReader;
        }

        /**
         * 文本数据解析器实例
         */
        public static function get TextReader():TextDataReader
        {
            return _TxtReader;
        }

        /**
         * XML数据解析器实例
         */
        public static function get XmlReader():XmlDataReader
        {
            return _XmlReader;
        }
    }
}