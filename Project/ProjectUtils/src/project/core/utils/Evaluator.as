package project.core.utils
{

	public class Evaluator
	{
		private static var IsRunning:Boolean=false;

		/**
		 * 计算表达式
		 * @param og 公式
		 * @return 
		 */
		public static function Eval(og:String):Number
		{
			IsRunning=true;
			var sourceStr:ExprString=new ExprString("(" + Trim(og) + ")");
			var s1:Array=SetArrayLv2(sourceStr);
			var s2:Number=CaculateArrayLv2(s1);
			if (IsRunning)
			{
				return s2;
			}
			return 0;
		}

		private static function Trim(og:String):String
		{
			var i:Number, j:Number;
			for (i=0; og.charCodeAt(i) == 32 || og.charCodeAt(i) == 13; i++)
			{
			}
			for (j=og.length - 1; og.charCodeAt(j) == 32 || og.charCodeAt(j) == 13; j--)
			{
			}
			if (j >= i)
			{
				return og.substring(i, j + 1);
			}
			else
			{
				OnError();
				return "";
			}
		}

		private static function OnError():void
		{
			IsRunning=false;
		}

		private static function GetNumber(ogStr:ExprString):Number
		{
			if (IsRunning)
			{
				var tmp:Number;
				var sign:Number=1;
				if (ogStr.nowChar == "-")
				{
					sign=-1;
					ogStr.next();
				}
				if ((ogStr.nowCharCode >= 48 && ogStr.nowCharCode <= 57) || ogStr.nowChar == ".")
				{
					tmp = 0;
					var dotRem:Number=-1;
					while ((ogStr.nowCharCode >= 48 && ogStr.nowCharCode <= 57) || ogStr.nowChar == ".")
					{
						if (ogStr.nowChar == ".")
						{
							if (dotRem != -1)
							{
								OnError();
								return 0;
							}
							else
							{
								dotRem=0;
								ogStr.next();
							}
						}
						else
						{
							if (dotRem != -1)
							{
								dotRem++;
							}
							tmp=tmp * 10 + Number(ogStr.nowChar);
							ogStr.next();
						}
					}
					if (dotRem == -1)
					{
						return sign * tmp;
					}
					else
					{
						return sign * tmp / (Math.pow(10, dotRem));
					}
				}
				else
				{
					if (tmp==MatchMathFunc(ogStr))
					{
						return tmp;
					}
					OnError();
					return 0;
				}
			}
			else
			{
				return 0;
			}
		}

		private static function GetCharTillNextEnd(ogStr:ExprString):String
		{
			var rt:String="";
			var limit:Number=1;
			while ((ogStr.nowChar != ")" && ogStr.nowChar != ",") || --limit > 0)
			{
				if (ogStr.nowChar == "(")
				{
					limit++;
				}
				rt+=ogStr.nowChar;
				ogStr.next();
			}
			return rt;
		}

		private static function MatchMathFunc(ogStr:ExprString):Number
		{
			var functionKey:String="";
			var rt:Number;
			for (var i:int=0; i <= 10 && ogStr.nowChar != "("; i++)
			{
				functionKey+=ogStr.nowChar;
				ogStr.next();
			}
			if (i == 10)
			{
				OnError();
				return 0;
			}
			ogStr.next();
			var tmp1:Number;
			var tmp2:Number;
			switch (functionKey)
			{
				case "sin":
					rt=Math.sin(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "cos":
					rt=Math.cos(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "tan":
					rt=Math.tan(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "abs":
					rt=Math.abs(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "atan":
					rt=Math.atan(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "acos":
					rt=Math.acos(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "asin":
					rt=Math.asin(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "atan2":
					tmp1=Eval(GetCharTillNextEnd(ogStr));
					ogStr.next();
					tmp2=Eval(GetCharTillNextEnd(ogStr));
					rt=Math.atan2(tmp1, tmp2);
					break;
				case "ceil":
					rt=Math.ceil(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "exp":
					rt=Math.exp(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "floor":
					rt=Math.floor(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "round":
					rt=Math.round(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "log":
					rt=Math.log(Eval(GetCharTillNextEnd(ogStr)));
					break;
				case "max":
					tmp1=Eval(GetCharTillNextEnd(ogStr));
					ogStr.next();
					tmp2=Eval(GetCharTillNextEnd(ogStr));
					rt=Math.max(tmp1, tmp2);
					break;
				case "min":
					tmp1=Eval(GetCharTillNextEnd(ogStr));
					ogStr.next();
					tmp2=Eval(GetCharTillNextEnd(ogStr));
					rt=Math.min(tmp1, tmp2);
					break;
				case "pow":
					tmp1=Eval(GetCharTillNextEnd(ogStr));
					ogStr.next();
					tmp2=Eval(GetCharTillNextEnd(ogStr));
					rt=Math.pow(tmp1, tmp2);
					break;
				case "sqrt":
					rt=Math.sqrt(Eval(GetCharTillNextEnd(ogStr)));
					break;
				default:
					OnError();
					return 0;
			}
			ogStr.next();
			return rt;
		}

		private static function GetChar(ogStr:ExprString):String
		{
			if (IsRunning)
			{
				var tmp:String=ogStr.nowChar;
				ogStr.next();
				return tmp;
			}
			else
			{
				return "";
			}
		}

		private static function GetChar2(ogStr:ExprString):String
		{
			//读字符并要求是运算符号
			if (IsRunning)
			{
				var tmp:String=ogStr.nowChar;
				ogStr.next();
				if (GetSignLevel(tmp))
				{
					return tmp;
				}
				else
				{
					OnError();
					return "";
				}
			}
			else
			{
				return "";
			}
		}

		private static function SetArrayBase(og:ExprString):Array
		{
			if (IsRunning)
			{
				og.next();
				var sArray:Array=new Array();
				while (IsRunning)
				{
					if (og.nowChar == "(")
					{
						sArray.push(SetArrayBase(og));
					}
					else
					{
						sArray.push(GetNumber(og));
					}
					if (og.nowChar == ")")
					{
						og.next();
						return sArray;
					}
					else
					{
						sArray.push(GetChar2(og));
					}
					if (og.Index > og.Length)
					{
						OnError();
					}
				}
				return [];
			}
			else
			{
				return [];
			}
		}

		private static function GetSignLevel(og:String):Number
		{
			if (og == "+" || og == "-")
			{
				return 1;
			}
			else if (og == "*" || og == "/" || og == "%")
			{
				return 2;
			}
			else if (og == "^")
			{
				return 3;
			}
			else
			{
				return 0;
			}
		}

		private static function SetArrayAdvance(ogArr:*):*
		{
			if (IsRunning)
			{
				var newArr:Array=new Array();
				var newArr2:Array=new Array();
				var tmpArr:Array=new Array();
				if (ogArr is Number)
				{
					return ogArr;
				}
				else
				{
					var len:Number=ogArr.length;
					var tmp:Number=GetSignLevel(ogArr[1]);
					var tmp1:Boolean=true;
					for (var c:int=3; c < len; c+=2)
					{
						if (GetSignLevel(ogArr[c]) != tmp)
						{
							tmp1=false;
							break;
						}
					}
					if (tmp1 == true)
					{
						for (var j:int=0; j < len; j+=2)
						{
							newArr.push(SetArrayAdvance(ogArr[j]));
							if (ogArr[j + 1] != undefined)
							{
								newArr.push(ogArr[j + 1]);
							}
						}
						return newArr;
					}
					for (var i:int=0; i < len; i+=2)
					{
						if (GetSignLevel(ogArr[i + 1]) == 3)
						{
							tmpArr.push(SetArrayAdvance(ogArr[i]));
							if (ogArr[i + 1] != undefined)
							{
								tmpArr.push(ogArr[i + 1]);
							}
						}
						else
						{
							if (tmpArr.length == 0)
							{
								newArr.push(SetArrayAdvance(ogArr[i]));
								if (ogArr[i + 1] != undefined)
								{
									newArr.push(ogArr[i + 1]);
								}
							}
							else
							{
								tmpArr.push(SetArrayAdvance(ogArr[i]));
								newArr.push(tmpArr);
								tmpArr=new Array();
								if (ogArr[i + 1] != undefined)
								{
									newArr.push(ogArr[i + 1]);
								}
							}
						}
					}
					len=newArr.length;
					for (var k:int=0; k < len; k+=2)
					{
						if (GetSignLevel(newArr[k + 1]) == 2)
						{
							tmpArr.push(SetArrayAdvance(newArr[k]));
							if (newArr[k + 1] != undefined)
							{
								tmpArr.push(newArr[k + 1]);
							}
						}
						else
						{
							if (tmpArr.length == 0)
							{
								newArr2.push(SetArrayAdvance(newArr[k]));
								if (newArr[k + 1] != undefined)
								{
									newArr2.push(newArr[k + 1]);
								}
							}
							else
							{
								tmpArr.push(SetArrayAdvance(newArr[k]));
								newArr2.push(tmpArr);
								tmpArr=new Array();
								if (newArr[k + 1] != undefined)
								{
									newArr2.push(newArr[k + 1]);
								}
							}
						}
					}
					return newArr2;
				}
			}
			else
			{
				return 0;
			}
		}

		private static function SetArrayLv2(og:ExprString):Array
		{
			if (IsRunning)
			{
				var tmp:Array=SetArrayBase(og);
				og.rewind();
				var tmp2:Array=SetArrayAdvance(tmp);
				return tmp2;
			}
			else
			{
				return [];
			}
		}

		private static function CaculateArrayLv2(og:*):Number
		{
			if (IsRunning)
			{
				if (og is Number)
				{
					return og;
				}
				else
				{
					var len:Number=og.length;
					var basic:Number=CaculateArrayLv2(og[0]);
					for (var i:int=1; i < len; i+=2)
					{
						switch (og[i])
						{
							case "+":
								basic+=CaculateArrayLv2(og[i + 1]);
								break;
							case "-":
								basic-=CaculateArrayLv2(og[i + 1]);
								break;
							case "*":
								basic*=CaculateArrayLv2(og[i + 1]);
								break;
							case "/":
								basic/=CaculateArrayLv2(og[i + 1]);
								break;
							case "%":
								basic%=CaculateArrayLv2(og[i + 1]);
								break;
							case "^":
								basic=Math.pow(basic, og[i + 1]);
								break;
							default:
								OnError();
								return 0;
						}
					}
					return basic;
				}
			}
			else
			{
				return 0;
			}
		}
	}
}

class ExprString  {
	/**
	 * 
	 * @default 
	 */
	public var Index:Number;
	/**
	 * 
	 * @default 
	 */
	public var Length:Number;
	private var _Str:String;
	/**
	 * 
	 * @param str
	 */
	public function ExprString( str:String ) {
		_Str = str;
		Length = str.length;
		Index = 0;
	}
	/**
	 * 
	 */
	public function rewind():void {
		Index = 0;
	}
	/**
	 * 
	 */
	public function next():void {
		++Index;
		while(nowCharCode == 13||nowCharCode == 32){
			++Index
		}
	}
	/**
	 * 
	 */
	public function prev():void {
		--Index;
		while(nowCharCode == 13||nowCharCode == 32){
			--Index;
		}
	}
	/**
	 * 
	 * @return 
	 */
	public function get nowChar():String {
		if (Index>=Length) {
			return "";
		}
		return _Str.charAt(Index);
	}
	/**
	 * 
	 * @return 
	 */
	public function get nowCharCode():Number {
		if (Index>=Length) {
			return 0;
		}
		return _Str.charCodeAt(Index);
	}
}