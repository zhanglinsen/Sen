package project.core.manager
{
	/**
	 * 背景音乐管理器
	 */
	public final class BgSoundManager
	{
		private static var _SndMgrInstance:SoundManager = new SoundManager("BgSound");

		/**
		 * 播放音乐
		 * @url 音乐地址
		 */
		public static function Play(url:String=""):void
		{
			_SndMgrInstance.Load(url);
		}

		/**
		 * 音乐开关
		 */
		public static function get TurnOn():Boolean
		{
			return _SndMgrInstance.TurnOn;
		}

		public static function set TurnOn(val:Boolean):void
		{
			_SndMgrInstance.TurnOn = val;
		}

		/**
		 * 音量
		 */
		public static function set Volume(val:int):void
		{
			_SndMgrInstance.Volume = val;
		}
		public static function get Volume():int {
			return _SndMgrInstance.Volume;
		}
	}
}