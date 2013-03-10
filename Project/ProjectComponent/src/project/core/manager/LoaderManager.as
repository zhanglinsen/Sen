package project.core.manager
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.system.System;
	
	import project.core.events.LoaderEvent;
	import project.core.loader.LoaderUIBase;
	import project.core.loader.StreamLoader;
	
	/**
	 * 加载管理器
	 */
	public final class LoaderManager
	{
		/**
		 * 加载完成回调
		 */
		public static var OnAllCompleteCallback:Function;
		/**
		 * 加载完成回调
		 */
		public static var OnCompleteCallback:Function;
		/**
		 * 加载出错回调
		 */
		public static var OnErrorCallback:Function;
		/**
		 * 加载UI
		 */
		private static var _UI:LoaderUIBase;
		
		public static function get UI():LoaderUIBase {
			return _UI;
		} 
		
		/**
		 * 初始化
		 */
		public static function set UI(ui:LoaderUIBase):void
		{
			_UI = ui;
			_UI.addEventListener( Event.CLOSE, UI_OnClose );
			_UI.addEventListener( ErrorEvent.ERROR, UI_OnError );
			_UI.addEventListener( Event.COMPLETE, UI_OnComplete );
			_UI.addEventListener( LoaderEvent.ALL_COMPLETED, UI_OnAllComplete );
		}

		/**
		 * 销毁
		 */
		public static function Destroy():void
		{
			OnAllCompleteCallback = null;
			OnCompleteCallback = null;
			OnErrorCallback = null;

			if ( _UI!=null )
			{
				if ( _UI.parent!=null )
				{
					_UI.parent.removeChild( _UI );
				}
				_UI.removeEventListener( Event.CLOSE, UI_OnClose );
				_UI.removeEventListener( ErrorEvent.ERROR, UI_OnError );
				_UI.removeEventListener( Event.COMPLETE, UI_OnComplete );
				_UI.removeEventListener( LoaderEvent.ALL_COMPLETED, UI_OnAllComplete );
				_UI.Destroy();
				_UI = null;
			}
			System.gc();
		}

		/**
		 * 回调错误函数
		 */
		public static function Error():void
		{
			//Hide();
			_IsLoadFail = true;
			if ( OnErrorCallback!=null )
			{
				OnErrorCallback();
			}
		}
		private static var _IsLoadFail:Boolean = false;
		public static function get IsLoadFail():Boolean {
			return _IsLoadFail;
		}

		/**
		 * 关闭加载UI
		 */
		public static function Hide():void
		{
//			_UI.Loader = null;
			Reset();

			_UI.Hide();
		}

		/**
		 * 加载器
		 */
		public static function get Loader():StreamLoader
		{
			return _UI.Loader;
		}

		public static function set Loader( loader:StreamLoader ):void
		{
			_UI.Loader = loader;
		}

		/**
		 * 重置加载UI
		 */
		public static function Reset():void
		{
			_UI.Reset();
		}
		
		public static function get IsLoading():Boolean {
			return _UI.parent!=null;
		}

		/**
		 * 显示加载UI
		 */
		public static function Show():void
		{
			_IsLoadFail = false;
			_UI.Show(false);
		}

		/**
		 * 加载全部完成
		 */
		private static function UI_OnAllComplete( e:LoaderEvent ):void
		{
			if ( OnAllCompleteCallback!=null )
			{
				OnAllCompleteCallback();
			}
		}
		private static function UI_OnComplete( e:Event ):void {
			if( OnCompleteCallback!=null ) {
				OnCompleteCallback( _UI.Loader.CurrRequest.FileName );
			}
		}
		/**
		 * 加载出错
		 */
		private static function UI_OnError( e:ErrorEvent ):void
		{
			Error();
		}
		
		private static function UI_OnClose( e:Event ):void {
			Hide();
		}
	}
}