package
{
	import flash.utils.ByteArray;

    public final class Base64Decoder
    {
		private static const ESCAPE_CHAR_CODE:Number = 61; // The '=' char
		
		private static const inverse:Array =
			[
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63,
				52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
				64, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
				15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64,
				64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
				41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64
			];
        public static function decode( encoded:String ):ByteArray
        {
			var data:ByteArray = new ByteArray();
			if( !encoded ) return data;
			var count:int = 0;
			var filled:int = 0;
			var work:Array = [0, 0, 0, 0];
            for ( var i:uint = 0; i < encoded.length; ++i )
            {
                var c:Number = encoded.charCodeAt( i );

                if ( c == ESCAPE_CHAR_CODE )
                {
                    work[count++] = -1;
                }
                else if ( inverse[c] != 64 )
                {
                    work[count++] = inverse[c];
                }
                else
                {
                    continue;
                }

                if ( count == 4 )
                {
                    count = 0;
                    data.writeByte(( work[0] << 2 )|((work[1] & 0xFF) >> 4 ));
                    filled++;

                    if ( work[2] == -1 )
                    {
                        break;
                    }

                    data.writeByte(( work[1] << 4 )|((work[2] & 0xFF) >> 2 ));
                    filled++;

                    if ( work[3] == -1 )
                    {
                        break;
                    }

                    data.writeByte(( work[2] << 6 )|work[ 3 ]);
                    filled++;
                }
            }
			data.position = 0;
			return data;
        }
    }
}