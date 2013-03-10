package project.core.loader
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.Security;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import project.core.entity.StreamRequestInfo;
	import project.core.events.LoaderEvent;
	import project.core.global.GlobalVariables;
	import project.core.global.LogType;
	import project.core.reader.IStreamReader;

	[Event(name="allCompleted", type="project.core.events.LoaderEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="open", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	/**
	 * 数据流加载器
	 */
	public class StreamLoader extends EventDispatcher
	{
		public static var Instance:StreamLoader = new StreamLoader();
		public function StreamLoader()
		{
			super();

			this._pStreamRequest = new URLRequest();

			this._pStream = new URLStream();
			this._pStream.addEventListener( Event.OPEN, this.Stream_OnOpen );
			this._pStream.addEventListener( ProgressEvent.PROGRESS, this.Stream_OnProgress );
			this._pStream.addEventListener( Event.COMPLETE, this.Stream_OnComplete );
			this._pStream.addEventListener( IOErrorEvent.IO_ERROR, this.Stream_OnError );
			this._pStream.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.Stream_OnError );
			this._pStream.addEventListener( HTTPStatusEvent.HTTP_STATUS, this.Stream_OnHttpStatus );
		}

		public var Reader:IStreamReader;

		/**
		 * 当前请求的信息
		 */
		protected var _pCurrRequest:StreamRequestInfo;

		/**
		 * 加载的流
		 */
		protected var _pStream:URLStream;
		/**
		 * 加载的url对象
		 */
		protected var _pStreamRequest:URLRequest;
		/**
		 * 请求列表
		 */
		protected var _pStreamRequestList:Array = [];
		/**
		 * 加载的url
		 */
		protected var _pStreamUrl:String;

		/**
		 * 当前请求下载速度(bytes/s)
		 */
		private var _CurrSpeed:Number;
		/**
		 * 当前请求加载出错重试次数
		 */
		private var _FaultCnt:int = 0;
		/**
		 * 请求总数量
		 */
		private var _RequestCount:uint = 0;
		/**
		 * 已完成的请求数量
		 */
		private var _RequestLoadedCount:uint = 0;
		/**
		 * 当前请求的开始时间
		 */
		private var _RequestStartTime:Number;

		public function get CurrRequest():StreamRequestInfo {
			return this._pCurrRequest;
		}
		public function get Processing():Boolean {
			return _Processing;
		}
		/**
		 * 添加一个请求
		 * @fileFolder 请求的url目录
		 * @fileName 请求的文件名
		 * @label 请求显示的名称
		 * @version 版本号
		 */
		public function AddRequest( fileFolder:String, fileName:String, label:String, version:String = "", noCache:Boolean=false, resHost:String=null, type:String=null ):StreamRequestInfo
		{
			if( Processing ) return null;
//			label = XmlUtils.GetText(label);
			var req:StreamRequestInfo = new StreamRequestInfo();
			req.Folder = fileFolder;
			req.NoCache = noCache;
			req.FileName = fileName;
			req.Type = type;
			var ver:String = "";

			if ( version )
			{
				ver = "_v" + version;
			}
			var suffix:String = "";
			//把文件扩展名放到版本号之后
			var idx:int = fileName.lastIndexOf( "." );

			if ( idx!=-1 )
			{
				suffix = fileName.substr( idx );
				fileName = fileName.substr( 0, idx );
			}
			else
			{
				suffix = DefaultSuffix;
			}
			req.Suffix = fileName + ver + suffix;
			req.Version = version;
//			req.Url = resHost + fileFolder + fileName + ver + suffix;
			
			req.Custom = resHost!=null;
			if( resHost==null ) {
				resHost = GlobalVariables.ResHost;
			} 
			
			req.Label = label;
			req.LabelVersion = label + ver;
			req.ResHost = resHost;
			
			if( CheckRequest( req.Url ) ){
				return req;
			}
			
			this._pStreamRequestList.push( req );
			this._RequestCount++;
			
			return req;
		}
		protected function CheckRequest( url:String ):Boolean {
			for( var i:int=0; i<_pStreamRequestList.length; i++ ) {
				if( _pStreamRequestList[i].Url == url ) {
					return true;
				}
			}
			return false;
		}
		/**
		 * 当前下载的速度(bytes/s)
		 */
		public function get CurrSpeed():Number
		{
			return this._CurrSpeed;
		}

		/**
		 * 销毁对象
		 */
		public function Destroy():void
		{
			if( this._pStream!=null ) {
				this._pStream.removeEventListener( Event.OPEN, this.Stream_OnOpen );
				this._pStream.removeEventListener( ProgressEvent.PROGRESS, this.Stream_OnProgress );
				this._pStream.removeEventListener( Event.COMPLETE, this.Stream_OnComplete );
				this._pStream.removeEventListener( IOErrorEvent.IO_ERROR, this.Stream_OnError );
				this._pStream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.Stream_OnError );
				this._pStream.removeEventListener( HTTPStatusEvent.HTTP_STATUS, this.Stream_OnHttpStatus );
				this._pStream = null;
			}
			this._pStreamRequest = null;
		}

		/**
		 * 当前请求的显示名称
		 */
		public function get DisplayName():String
		{
			return _pCurrRequest==null?"":_pCurrRequest.Label;
		}

		private var _Processing:Boolean = false;
		private var _IgnoreError:Boolean = false;
		/**
		 * 开始处理
		 */
		public function Process( ignoreError:Boolean=false ):void
		{
			_IgnoreError = ignoreError;
			_Processing = true;
			CloseStream();
			
			this._pCurrRequest = this._pStreamRequestList.shift();
			
			_FaultCnt = 0;
			
			if ( this._pCurrRequest != null )
			{
				if(!_pCurrRequest.Custom) {
					_pCurrRequest.ResHost = GlobalVariables.ResHost;
				}
				this.LoadStream(_pCurrRequest.NoCache);
			}
			else
			{
				AllComplete();
			}
		}

		/**
		 * 请求数量
		 */
		public function get RequestCount():uint
		{
			return _RequestCount;
		}

		/**
		 * 已完成的请求数量
		 */
		public function get RequestLoadedCount():uint
		{
			return _RequestLoadedCount;
		}

		/**
		 * 重新下载当前请求
		 */
		public function Retry(noCache:Boolean=true):void
		{
			this.dispatchEvent( new LoaderEvent( LoaderEvent.RETRY ));
			LoadStream( noCache );
		}

		/**
		 * 所有请求完成
		 */
		protected function AllComplete():void
		{
			clearTimeout( _ProcessTimeoutId );
			clearTimeout( _LoadTimeoutId );
			_Processing = false;
			_RequestCount = 0;
			_RequestLoadedCount = 0;
			this.dispatchEvent( new LoaderEvent( LoaderEvent.ALL_COMPLETED ));
		}

		/**
		 * 默认后缀
		 */
		protected function get DefaultSuffix():String
		{
			return ".dat";
		}

		/**
		 * 下载数据
		 * @noCache 不读取缓存中的数据
		 */
		protected function LoadStream( noCache:Boolean = false ):void
		{
			if(!_pStreamRequest) {
				return ;
			}
			
			if( _CloseFile[_pCurrRequest.FileName] ) {
				noCache = true;
				delete _CloseFile[_pCurrRequest.FileName];
			}
			clearTimeout( _ProcessTimeoutId );
			clearTimeout( _LoadTimeoutId );
			_pStreamRequest.url = _pCurrRequest.Url+( noCache ? "?t=" + new Date().getTime() : "" );
			_pStream.load( _pStreamRequest );
		}
		
		/**
		 * 记录调试信息的方法，将传递两个参数，function(msg:String, type:int=0)
		 * @default 
		 */
		public static var Logger:Function = function(msg:String, type:int=0):void{trace(msg);};
		/**
		 * 处理下载的数据
		 */
		protected function ProcessStreamData():void
		{
			try { 
				var err:String = Reader.ReadStream( this._pStream, this._pCurrRequest );
			}catch(e:Error) {
				Logger("[Read Stream]" + _pCurrRequest.Url + ":" + e.message, -1);
				return ;
			}

			if( err ) {
				Reset();
				this.dispatchEvent( new LoaderEvent(LoaderEvent.DATA_ERROR, err) );
				_pCurrRequest = null;
				return ;
			}
			ProcessNext();
		}
		protected function ProcessNext(skip:Boolean=false):void {
			_RequestLoadedCount ++;
			this.dispatchEvent( new Event( Event.COMPLETE ));
			_pCurrRequest = null;
			clearTimeout(_ProcessTimeoutId);
			_ProcessTimeoutId = setTimeout( Process, 50, _IgnoreError );
		}

		/**
		 * 数据下载完成
		 */
		protected function Stream_OnComplete( e:Event ):void
		{
			clearTimeout( _LoadTimeoutId );
			if(_pCurrRequest){
				Logger(this._pCurrRequest.LabelVersion + ":下载完成.平均速度:"+Speed, -1);
			}
			ProcessStreamData();
		}
		
		private var _CloseFile:Dictionary = new Dictionary();
		private function CloseStream():void {
			if( _pCurrRequest ) {
				_CloseFile[_pCurrRequest.FileName] = true;
			}
			try{ 
				this._pStream.close();
			}catch( e:Error ){};
		}

		public function Reset():void {
			CloseStream();
			clearTimeout( _ProcessTimeoutId );
			clearTimeout( _LoadTimeoutId );
			this._FaultCnt=0;
			_Processing = false;
			_RequestCount = 0;
			_RequestLoadedCount = 0;
			_pStreamRequestList = [];
		}
		/**
		 * 数据下载出错
		 */
		protected function Stream_OnError( e:ErrorEvent ):void
		{
			this._FaultCnt++;
			clearTimeout( _LoadTimeoutId );
			Logger(this._pCurrRequest.LabelVersion + ":下载出错！"+e.toString(), LogType.ERROR);
			
			
			if ( this._FaultCnt >= GlobalVariables.ResHostList.length*2 )
			{
				if( _IgnoreError ) {
					ProcessNext(true);
				} else {
					Reset();
					this.dispatchEvent( e );
				}
			}
			else
			{
				if( !_pCurrRequest.Custom ) {
					GlobalVariables.NextResHost();
					_pCurrRequest.ResHost = GlobalVariables.ResHost;
				}
				
				if( e.type==SecurityErrorEvent.SECURITY_ERROR ) {
					Security.loadPolicyFile(_pCurrRequest.ResHost+"/crossdomain.xml"); 
				}
				
				clearTimeout(_ProcessTimeoutId);
				_ProcessTimeoutId = setTimeout( Retry, 1000, this._FaultCnt>=GlobalVariables.ResHostList.length );
			}
		}

		/**
		 * 下载状态改变
		 */
		protected function Stream_OnHttpStatus( e:HTTPStatusEvent ):void
		{
//			trace(this._pCurrRequest.Label + ":" + e.status.toString());
			this.dispatchEvent( e );
		}

		/**
		 * 下载开始
		 */
		protected function Stream_OnOpen( e:Event ):void
		{
			clearTimeout( _LoadTimeoutId );
			_LoadTimeoutId = setTimeout( LoadTimeout, 10000 );
			if( _pCurrRequest ) {
				Logger(this._pCurrRequest.LabelVersion + "," + this._pStreamRequest.url + ":开始下载！", -1);
			}
			this._RequestStartTime = getTimer();
			this.dispatchEvent( e );
		}
		private var _LoadTimeoutId:int;
		private var _ProcessTimeoutId:int;
		/**
		 * 下载中
		 */
		protected function Stream_OnProgress( e:ProgressEvent ):void
		{
			clearTimeout( _LoadTimeoutId );
			var elapsedTime:Number = (getTimer() - this._RequestStartTime)/1000;
			this._CurrSpeed = elapsedTime == 0 ? e.bytesLoaded : e.bytesLoaded / elapsedTime;
			
			_LoadTimeoutId = setTimeout( LoadTimeout, 5000 );
			this.dispatchEvent( e );
		}
		private function LoadTimeout():void {
			clearTimeout( _LoadTimeoutId );
			this._FaultCnt=0;
			CloseStream();
			clearTimeout(_ProcessTimeoutId);
			_ProcessTimeoutId = setTimeout( Retry, 1000 );
		}
		public function get Speed():String {
			var speed:String = "";
			var kb:Number = CurrSpeed/1024;
			if( kb>1000 ) {
				speed = Math.round(kb/1024)+ " (MB/s)";
			} else {
				speed = Math.round(kb) + " (KB/s)";
			}
			return speed;
		}
	}
}