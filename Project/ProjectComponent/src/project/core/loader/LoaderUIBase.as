package project.core.loader
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	
	import project.core.containers.UPopupWindow;
	import project.core.controls.UButton;
	import project.core.events.LoaderEvent;
	import project.core.events.UIEvent;
	import project.core.global.GlobalVariables;
	import project.core.manager.Debugger;
	
	[Event(name="allCompleted", type="project.core.events.LoaderEvent")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	public class LoaderUIBase extends UPopupWindow
	{
		public function LoaderUIBase( w:Number, h:Number, loader:StreamLoader = null )
		{
			this.Loader = loader;
			super(w, h, true);
			this.addEventListener(MouseEvent.MOUSE_UP, StopEvent);
		}
		private function StopEvent(e:MouseEvent):void {
			e.preventDefault();
			e.stopPropagation();
		}
		protected var _pStreamLoader:StreamLoader;
		
		/**
		 * 显示窗口
		 */
		override public function Show(autoHide:Boolean=true):void
		{
			if ( parent==null )
			{
				if( Debugger.ChildIndex>=0 ) {
					GlobalVariables.RootParent.addChildAt( this, Debugger.ChildIndex );
				} else {
					GlobalVariables.RootParent.addChild(this);
				}
//				PopupManager.Show( this );
				this.dispatchEvent( new UIEvent( UIEvent.SHOWN ));
			} else if(autoHide){
				this.Hide();
			}
		}
		override public function Hide():void
		{
			if ( !parent )
			{
				this.dispatchEvent( new UIEvent( UIEvent.HIDDEN ));
			} else {
				super.Hide();
			}
		}
		override public function Destroy():void
		{
			Loader = null;
		}

		public function get Loader():StreamLoader
		{
			return _pStreamLoader;
		}

		public function set Loader( loader:StreamLoader ):void
		{
			if ( _pStreamLoader==loader )
			{
				return;
			}

			if ( _pStreamLoader!=null )
			{
				this._pStreamLoader.removeEventListener( LoaderEvent.RETRY, this.StreamLoader_OnRetry );
				this._pStreamLoader.removeEventListener( Event.OPEN, this.StreamLoader_OnOpen );
				this._pStreamLoader.removeEventListener( ProgressEvent.PROGRESS, this.StreamLoader_OnProgress );
				this._pStreamLoader.removeEventListener( Event.COMPLETE, this.StreamLoader_OnComplete );
				this._pStreamLoader.removeEventListener( LoaderEvent.ALL_COMPLETED, this.StreamLoader_OnAllComplete );
				this._pStreamLoader.removeEventListener( IOErrorEvent.IO_ERROR, this.StreamLoader_OnIOError );
				this._pStreamLoader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.StreamLoader_OnSecurityError );
				this._pStreamLoader.removeEventListener( LoaderEvent.DATA_ERROR, this.StreamLoader_OnDataError );
				_pStreamLoader = null;
			}
			_pStreamLoader = loader;

			if ( _pStreamLoader!=null )
			{
				this._pStreamLoader.addEventListener( LoaderEvent.RETRY, this.StreamLoader_OnRetry );
				this._pStreamLoader.addEventListener( Event.OPEN, this.StreamLoader_OnOpen );
				this._pStreamLoader.addEventListener( ProgressEvent.PROGRESS, this.StreamLoader_OnProgress );
				this._pStreamLoader.addEventListener( Event.COMPLETE, this.StreamLoader_OnComplete );
				this._pStreamLoader.addEventListener( LoaderEvent.ALL_COMPLETED, this.StreamLoader_OnAllComplete );
				this._pStreamLoader.addEventListener( IOErrorEvent.IO_ERROR, this.StreamLoader_OnIOError );
				this._pStreamLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.StreamLoader_OnSecurityError );
				this._pStreamLoader.addEventListener( LoaderEvent.DATA_ERROR, this.StreamLoader_OnDataError );
			}
		}

		public function Reset():void
		{
		}

		private function StreamLoader_OnAllComplete( e:Event ):void
		{
			this.dispatchEvent( new LoaderEvent(LoaderEvent.ALL_COMPLETED) );
//			this.Reset();
		}

		private function StreamLoader_OnComplete( e:Event ):void
		{
//			Status = _pStreamLoader.DisplayName + XmlUtils.GetText("preload.label.loadfinish");// + "(" + _pStreamLoader.RequestLoadedCount+"/"+_pStreamLoader.RequestCount + ")";
			_LoadedRequest++;
			SetProgress(_LoadedRequest,_TotalRequest);
			this.dispatchEvent( new Event(Event.COMPLETE) );
		}
		protected function StreamLoader_OnDataError( e:LoaderEvent ):void {
			this.dispatchEvent( new ErrorEvent(ErrorEvent.ERROR) );
		}
		protected function StreamLoader_OnIOError( e:IOErrorEvent ):void
		{
			this.dispatchEvent( new ErrorEvent(ErrorEvent.ERROR) );
		}
		private var _TotalRequest:int;
		private var _LoadedRequest:int;
		public function set TotalRequest(total:int):void {
			_TotalRequest = total;
			_LoadedRequest = 0;
		}

		protected function StreamLoader_OnOpen( e:Event ):void
		{
			SetProgress(_LoadedRequest,_TotalRequest);
		}
		protected function StreamLoader_OnRetry( e:Event ):void {
		}
		public function set Status(val:String):void {
			if( FixedStatus ) return ;
		}
		/**固定状态显示，当值为true时，状态显示不会被改变*/
		public var FixedStatus:Boolean = false;
		/**固定进度显示，当值为true时，进度显示不会被改变*/
		public var FixedProgress:Boolean = false;
		public function SetProgress(count:Number,total:Number, info:String=null):void {
			if( FixedProgress ) {
				return ;
			}
		}
		protected function StreamLoader_OnProgress( e:ProgressEvent ):void
		{
			SetProgress( _LoadedRequest + (e.bytesLoaded/e.bytesTotal)/_TotalRequest, _TotalRequest );
		}

		protected function StreamLoader_OnSecurityError( e:SecurityErrorEvent ):void
		{
			this.dispatchEvent( new ErrorEvent(ErrorEvent.ERROR) );
		}
		public function ShowClose():void {
		}
	}
}