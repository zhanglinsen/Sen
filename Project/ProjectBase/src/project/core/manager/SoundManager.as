package project.core.manager
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import project.core.utils.LocalConfig;

	/**
	 * 声音管理器
	 */
	internal final class SoundManager
	{
		public function SoundManager( key:String, loops:int = 0 )
		{
			if ( loops == 0 )
			{
				this._Loops = int.MAX_VALUE;
			}
			else
			{
				this._Loops = loops;
			}
			_SndTrans = new SoundTransform();
			_SndCtx = new SoundLoaderContext();
			_VolumeKey = key + "_Volume";
			_TurnOnKey = key + "_TurnOn";
			var vol:String = LocalConfig.Get( _VolumeKey );
			Volume = vol ? int(vol) : 50; 
			var on:String = LocalConfig.Get( _TurnOnKey );
			TurnOn =  on ? on=="1" : true;
		}
		private var _VolumeKey:String;
		private var _TurnOnKey:String;
		/**
		 * 声音加载失败次数
		 */
		private var _FaultCnt:int = 0;
		/**
		 * 循环播放的次数
		 */
		private var _Loops:int;
		/**
		 * 是否正在播放
		 */
		private var _Playing:Boolean = false;
		/**
		 * 控制应用程序中的声音
		 */
		private var _SndChn:SoundChannel;
		private var _SndCtx:SoundLoaderContext;
		/**
		 * 声音流，有关声音的数据
		 */
		private var _SndFactory:Sound;
		/**
		 * 声音文件缓存
		 */
		private var _SndMap:Dictionary = new Dictionary();
		/**
		 * 文件请求
		 */
		private var _SndRequest:URLRequest = new URLRequest();
		/**
		 * 声音转换器
		 */
		private var _SndTrans:SoundTransform;
		/**
		 * 声音文件地址
		 */
		private var _SndUrl:String;
		/**
		 * 播放新的声音前先是否要停止上次的声音
		 */
		private var _StopLastSound:Boolean = true;

		/**
		 * 声音开关,true为打开
		 */
		private var _TurnOn:Boolean = true;
		/**
		 * 音量,0-100
		 */
		private var _Volume:int = 50;

		/**
		 * 加载声音
		 *
		 * @url 声音文件地址
		 * @stopLastSound 播放新的声音前先是否要停止上次的声音
		 */
		public function Load( url:String, stopLastSound:Boolean = true, isRetry:Boolean=false ):void
		{
			
//			if ( GlobalVariables.LogLevel<GlobalConst.LOG_DEBUG ) {
//				return ;
//			}
			if ( url=="" || url==null )
			{
				if( stopLastSound ) {
					Stop();
				}
				return;
			}

			if ( _Playing && _Loops==int.MAX_VALUE && url == _SndUrl )
			{
				return;
			}
			_SndUrl = url;

			if ( !TurnOn )
			{
				return;
			}
			this._StopLastSound = stopLastSound;

			if ( !isRetry && _SndFactory != null )
			{
				//另一个声音正在加载
				ResetFactory();

				try
				{
					_SndFactory.close();
				}
				catch ( e:Error )
				{
				}
				_SndFactory = null;
			}
			else if ( _StopLastSound )
			{
				Stop();
			}

			if ( _SndMap[_SndUrl] != null )
			{
				//声音已加载，直接播放
				Play();
			}
			else
			{
				try {
					_SndFactory = new Sound();
					_SndFactory.addEventListener( IOErrorEvent.IO_ERROR, Sound_OnError );
					_SndFactory.addEventListener( Event.COMPLETE, Sound_OnComplete );
	
					_SndRequest.url = _SndUrl + (_FaultCnt > 0 ? '?t=' + new Date().getTime() : '');
					_SndFactory.load( _SndRequest, _SndCtx );
				}catch(e:Error){}
			}
		}

		public function get TurnOn():Boolean
		{
			return _TurnOn;
		}

		/**
		 * 声音开关
		 */
		public function set TurnOn( val:Boolean ):void
		{
			_TurnOn = val;

			if ( !val )
			{
				Stop();
			}
			else if ( _Loops==int.MAX_VALUE )
			{
				Load( _SndUrl, _StopLastSound );
			}
			LocalConfig.Save( _TurnOnKey, val ? "1" : "0" );
		}

		public function get Volume():int
		{
			return _Volume;
		}
		/**
		 * 音量
		 */
		public function set Volume( val:int ):void
		{
			_Volume = val;
			_SndTrans.volume = val / 100;

			if ( _Playing )
			{
				_SndChn.soundTransform = this._SndTrans;
			}
			LocalConfig.Save( _VolumeKey, val );
		}

		/**
		 * 播放声音
		 */
		internal function Play():void
		{
			if ( _SndUrl && _SndMap[_SndUrl] )
			{
				if( TurnOn ) {
					_Playing = true;
					try{
						_SndChn = _SndMap[_SndUrl].play( 0, _Loops, _SndTrans );
					}catch( e:Error ) {
						_Playing = false;
						_SndChn = null;
						_SndMap[_SndUrl] = null;
					}
				}
			}
		}

		/**
		 * 重置
		 */
		internal function ResetFactory():void
		{
			_FaultCnt = 0;
			if( _SndFactory ) {
				_SndFactory.removeEventListener( IOErrorEvent.IO_ERROR, Sound_OnError );
				_SndFactory.removeEventListener( Event.COMPLETE, Sound_OnComplete );
			}
		}

		/**
		 * 声音加载完成
		 */
		internal function Sound_OnComplete( e:Event ):void
		{
			ResetFactory();
			_SndMap[_SndUrl] = _SndFactory;
			Play();
			_SndFactory = null;
		}

		/**
		 * 停止声音播放
		 */
		internal function Stop():void
		{
			_Playing = false;

			if ( _SndChn != null )
			{
				_SndChn.stop();
				_SndChn = null;
			}
		}

		/**
		 * 声音加载出错
		 */
		private function Sound_OnError( e:ErrorEvent ):void
		{
			_FaultCnt++;

			if ( _FaultCnt <= 3 )
			{
				setTimeout( Load, 20, _SndUrl, _StopLastSound, true );
			}
			else
			{
				_FaultCnt = 0;
			}
		}
	}
}