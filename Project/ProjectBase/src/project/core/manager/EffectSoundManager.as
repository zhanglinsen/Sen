package project.core.manager
{
	/**
	 * 效果音管理器
	 */
	public final class EffectSoundManager
	{
		private static var _SndMgrInstance:SoundManager = new SoundManager("EffectSound", 1);

		/**
		 * 播放效果音
		 * @url 效果音地址
		 * @stopLostSound 播放新的声音前先是否要停止上次的声音
		 */
		public static function Play(url:String="", stopLastSound:Boolean=false):void
		{
//			Debugger.Info("特效音乐:" + url );
			_SndMgrInstance.Load(url, stopLastSound);
		}

		/**
		 * 效果音开关
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