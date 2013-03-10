package project.core.network
{
    import com.hurlant.crypto.hash.MD5;
    import com.hurlant.crypto.symmetric.AESKey;
    import com.hurlant.crypto.symmetric.CBCMode;
    import com.hurlant.util.Hex;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.Socket;
    import flash.system.System;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    import flash.utils.clearInterval;
    import flash.utils.clearTimeout;
    import flash.utils.describeType;
    import flash.utils.getTimer;
    import flash.utils.setInterval;
    import flash.utils.setTimeout;
    
    import project.core.global.LogType;
	
	/**
	 * 通讯接口<br/>
	 * Socket连接事件: SOCKET_CONNECT,SOCKET_DISCONNECT,SOCKET_ERROR,SOCKET_RETRY
	 * <br/>
	 * 监听服务端数据包:<br />
	 * TransceiverInstance.addEventListener( packetID.toString(), callbackFunction );<br/>
	 * packetID由服务端提供，为 int 类型.
	 */
    public final class Transceiver extends EventDispatcher
    {
		/**
		 * 服务器人满
		 */
		public static const GATE_FULL:int = 2;
		/**
		 * 服务器断开
		 */
		public static const GATE_OFFLINE:int = 1;
		/**
		 * 服务器正常，可连接
		 */
		public static const GATE_OK:int = 0;
		/**
		 * 
		 * @default 
		 */
		public static var Instance:Transceiver;// = new Transceiver(GlobalVariables.ServerHost, GlobalVariables.ServerPortList, GlobalVariables.LogLevel!=-1 && !GlobalVariables.UrlParams.reportId);
		
		/**
		 * 是否发送心跳包
		 * @default 
		 */
		public static const KEEP_ALIVE:uint = 0;
		/**
		 * 心跳包ID
		 * @default 
		 */
		public static const KEEP_ALIVE_ACK:uint = 4;
		/**
		 * 加密包头大小
		 */
		public static const PACKET_HEADER_SIZE: uint = 4;
		/**
		 * 非加密包头大小
		 * @default 
		 */
		public static const PACKET_HEADER_SIZE_NOSAVE:int = 8;
		/**
		 * 请求超时
		 */
		public static const REQUEST_TIMEOUT:int = 10000;
		
		/**
		 * Socket已连接
		 */
		public static const SOCKET_CONNECT:uint=SOCKET_BASE + 0;
		/**
		 * Socket断开连接
		 */
		public static const SOCKET_DISCONNECT:uint=SOCKET_BASE + 1;
		/**
		 * Socket出错
		 */
		public static const SOCKET_ERROR:uint=SOCKET_BASE + 2;
		/**
		 * Socket连接重试中
		 */
		public static const SOCKET_RETRY:uint=SOCKET_BASE + 3;
		/**
		 * 已连接
		 * @default 
		 */
		public static const STATE_CONNECTED: int = 2;
		/**
		 * 连接中
		 * @default 
		 */
		public static const STATE_CONNECTING: int = 1;
		/**
		 * 未连接
		 * @default 
		 */
		public static const STATE_DISCONNECTED: int = 0;
		/**
		 * 连接失败
		 * @default 
		 */
		public static const STATE_FAILED: int = 3;
		
		private static const SOCKET_BASE:uint=0xFF000000;

		/**
		 * 初始化SOCKET
		 * @param host 服务器地址
		 * @param ports 端口列表
		 * @param encrypt 发包是否加密
		 * @param sendKey 发包加密key
		 * @param recvKey 收包加密key,如果为null，则跟发包相同
		 * @param proxyKey 代理加密key，如果为空，则表示不使用代理
		 */
		public static function Init( host:String, ports:Array, encrypt:Boolean, sendKey:String, recvKey:String=null, proxyKey:String = null ):void {
			Instance = new Transceiver( host, ports, encrypt, sendKey, recvKey, proxyKey );
		}
		/**
		 * 通讯类.
		 * @param host 服务端地址
		 * @param ports 服务端端口列表(第二个端口开始为备用端口，如果第一个连接不了会重试下一个)
		 * @param encrypt 是否加密
		 * @param sendKey 发包加密key
		 * @param recvKey 收包加密key,如果为null，则跟发包相同
		 * @param proxyKey 代理加密key，如果为空，则表示不使用代理
		 */
        public function Transceiver( host:String, ports:Array, encrypt:Boolean, sendKey:String, recvKey:String=null, proxyKey:String = null )
        {
            super();
			if(recvKey) { 
				var buff:ByteArray = new ByteArray();
				buff.endian = Endian.LITTLE_ENDIAN;
				buff.writeUTFBytes( recvKey );
				_RecvCbc = new CBCMode( new AESKey( buff ));
			}
			
			Encrypt = encrypt;
			_SendKey = sendKey;
			_RecvKey = recvKey;
			_ProxyKey = proxyKey;
			if ( ports.length==1 )
			{
				ports.push( ports[ 0 ]);
			}
			_Host = host;
			_Ports = ports;
			
            _Socket=new Socket();
            _Socket.endian=Endian.LITTLE_ENDIAN;

            _KeepAlivePacket=new DataBlock( KEEP_ALIVE );
            this.addEventListener( KEEP_ALIVE_ACK.toString(), Socket_OnKeepAliveAck );
            State=STATE_DISCONNECTED;

			//GlobalVariables.LogLevel!=-1 && !GlobalVariables.UrlParams.reportId
//            if ( autoConnect )
            {
                this.Connect();
            }
        }

		/**
		 * 断线自动重连
		 * @default 
		 */
		public var AutoRetry:Boolean = false;
		/**
		 * 
		 * @default 
		 */
		public var Code:int = 0;

//		public function get Focus():Boolean {
//			return GlobalVariables.SameClick<4;
//		}
        /**
         * 是否保持长连接，保持长连接将隔一段时间发送心跳包
         */
        public var KeepAlive:Boolean=true;
        /**
         * 服务端连接状态
         */
        public var State:int;

        /**
         * 间隔多久发送心跳包
         */
        private const PING_INTERVAL:int=15000;

        private var _BuffList:Array = [];
		private var _ConnectTimeoutID:uint;

		private var _FocusOutTimes:int = 0;
        private var _GateState:int = -2;
		private var _Host:String;
        private var _IsProcess:Boolean = false;
        /**
         * 心跳包回应
         */
//		private var _KeepAliveAckPacket:DataBlock;
        /**
         * 长连接心跳包
         */
        private var _KeepAlivePacket:DataBlock;
        private var _LastPing:int;

        private var _LastReceive:int;
        /**
         * 包ID/命令ID
         */
        private var _PacketID:int;
		private var _PacketInfoMap:Dictionary = new Dictionary();
        private var _PingID:int;
        private var _PingTick:int=-1;
		private var _PortIdx:int = 0;
		private var _Ports:Array = [];
        private var _ProcessTimeID:int;
        private var _RecvCbc:CBCMode;
		private var _RecvKey:String;

		private var _RetryCount:int=0;
        private var _SendCbc:CBCMode;
		private var _SendKey:String;
		private var _ProxyKey:String;
        /**
         * socket
         */
        private var _Socket:Socket;
        private var _Time:int=1;

        //---- Public Methods --------------------------------------------------
        /**
         * 连接到服务器
         */
        private var _TryPort:int = 0;
		
        /**
         * 连接服务器
         */
        public function Connect():void
        {
            switch ( State )
            {
                case STATE_DISCONNECTED:
                case STATE_FAILED:
                    _Socket.addEventListener( Event.CONNECT, Socket_OnConnect );
                    _Socket.addEventListener( Event.CLOSE, Socket_OnClose );
                    _Socket.addEventListener( IOErrorEvent.IO_ERROR, Socket_OnIOError );
                    _Socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, Socket_OnSecurityError );
                    _Socket.addEventListener( ProgressEvent.SOCKET_DATA, Socket_OnReceivedData );

                    _TryPort = ServerPort;
                    Logger( "Connect to:"+_TryPort, LogType.INFO );
//					Security.loadPolicyFile("xmlsocket://"+ServerHost+":"+ServerPort);
                    _Socket.connect( ServerHost, _TryPort );

                    State=STATE_CONNECTING;
                    break;
            }
        }

        /**
         * 断开服务器连接
         */
        public function Disconnect():void
        {
            if ( State==STATE_DISCONNECTED )
            {
                return;
            }

            try
            {
                flash.utils.clearInterval( _PingID );
                _Socket.close();
				Socket_OnClose(null);
            }
            catch ( E:Error )
            {

            }

            State=STATE_DISCONNECTED;
        }

        /**
         * 网关状态
         * @return 
         */
        public function get GateState():int
        {
            return _GateState;
        }
		/**
		 * 获取下一个服务器端口
		 */
		public function NextServerPort():void {
			_PortIdx ++;
		}
		/**
		 * 设置包ID常量的类。设置后在调试模式中可以看到发包，收包的信息。
		 * 例如：
		 * <code>
		 * Transceiver.Instance.PacketTypes = PacketIDConst;
		 * 
		 * Transceiver.Instance.Send( packet );//调试窗口显示[Send]Packet ID:xxx, Packet Name:...
		 * PacketID是PacketIDConst中的常量值，PacketName是常量名
		 * </code>
		 * @param packetType
		 */
		public function set PacketTypes( packetType:* ):void {
			var str:String = "unknow";
			var typeInfo:XML = describeType( packetType );
			var properties:XMLList = typeInfo.constant;
			
			for each ( var propertyInfo:XML in properties )
			{
				var prop:String = propertyInfo.@name;
				_PacketInfoMap[ packetType[prop] ] = prop;
			}
			properties = null;
			typeInfo = null;
			System.gc();
		}
        /**
         * 发送心跳包
         */
        public function Ping():void
        {
            if ( State != STATE_CONNECTED )
            {
                return;
            }
            Send( _KeepAlivePacket, true );

            _LastPing=getTimer();
        }

        /**
         * @return 网络延迟时间
         */
        public function get PingTick():int
        {
            return _PingTick;
        }

        /**
         * @return 网关是否可使用
         */
        public function get Ready():Boolean
        {
            return _SendCbc!=null;
        }
        /**
         * 发送数据
		 * @param packet 数据包
         */
        public function Send( packet:DataBlock, ignore:Boolean=false ):void
        {
			
            if ( State != STATE_CONNECTED || int( packet.Ident )<0 )
            {
                return;
            }
			
//			if( !ignore && !Focus ) {
//				if( _FocusOutTimes<10 ) {
//					_FocusOutTimes++;
//					Logger("Game not in focus." + _FocusOutTimes, LogType.ERROR);
//				} else {
//					return ;
//				}
//			} else if(Focus){
//				_FocusOutTimes = 0;
//			}
			
            Logger( "[Send]"+GetPacketInfo( packet.Ident )+",Header:"+packet.Ident+","+packet.Data.length, LogType.PACKET_SEND );

            if ( Encrypt )
            {
				SendSave( packet, _SendCbc );
            }
            else
            {
                _Socket.writeUnsignedInt( packet.Data.length+PACKET_HEADER_SIZE_NOSAVE );
                _Socket.writeUnsignedInt( packet.Ident );

                if ( packet.Data.length != 0 )
                {
                    _Socket.writeBytes( packet.Data );
                }
            }

            _Socket.flush();
        }
		/**是否加密数据包*/
		public var Encrypt:Boolean=true;
		/**
		 * @return 当前连接的服务器地址
		 */
		public function get ServerHost():String {
			return _Host;
		}
		/**
		 * @return 当前连接的服务器端口
		 */
		public function get ServerPort():int {
			var port:int = 80;
			if( _PortIdx>=_Ports.length ) {
				_PortIdx = 0;
			}
			if( _Ports.length>0 ) {
				port = int(_Ports[_PortIdx]);
			}
			return port;
		}
        /**
         * 设置加密tick
         * @param tick
         */
        public function set ServerTick( tick:String ):void
        {
            if ( tick.length>32 )
            {
                tick = tick.substr( 0, 32 );
            }
            else if ( tick.length<32 )
            {
                tick = StringUtils.FillString( tick, 32, "a", true );
            }
            var buff:ByteArray = new ByteArray();
            buff.endian = Endian.LITTLE_ENDIAN;
            buff.writeUTFBytes( tick );
            _SendCbc = new CBCMode( new AESKey( buff ));

//            if ( GlobalVariables.ServerConfig.@samecbc.toString()!="1" )
//            {
//                tick = GlobalVariables.ModAndResConfig.@sid;
//            }
//			if( _RecvKey ) {
//				tick = _RecvKey;
//			}
			if(!_RecvKey) {
	            buff = new ByteArray();
	            buff.endian = Endian.LITTLE_ENDIAN;
	            buff.writeUTFBytes( tick );
	            _RecvCbc = new CBCMode( new AESKey( buff ));
			}
            clearInterval( _PingID );

            _PingID = setInterval( Ping, PING_INTERVAL );
        }

        private function CheckBuff( buff:ByteArray, len:int, rollbackPos:int = 0 ):Boolean
        {
            while ( buff.bytesAvailable < len )
            {
                if ( _BuffList.length==0 )
                {
                    if ( buff.bytesAvailable>0 )
                    {
                        this.UnshiftBuff( buff, rollbackPos );
                    }
                    _IsProcess = false;
                    return false;
                }
                _BuffList.splice( 0, 1 )[0].readBytes( buff, buff.length );
            }
            return true;
        }
		private function ConnectTimeout():void {
			AutoRetry = true;
			this.Disconnect();
		}
		private function GetGateState( e:DataBlock=null ):void {
			if( e!=null ) {
				var ret:int = e.Data.readShort();
				if( ret!=0 ) {
//					UMessageBox.Show( e.Data.readUTF() );
					return ;
				}
			}
			_GateState = -1;
			State=STATE_CONNECTED;
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.LITTLE_ENDIAN;
			ba.writeInt( 0x1 );
			_Socket.writeBytes( ba );
			_Socket.flush();
			
			_ConnectTimeoutID = setTimeout( ConnectTimeout, 20000 );
			this.dispatchEvent( new DataBlock( SOCKET_CONNECT ));
		}

        private function GetPacketInfo( packetId:int ):String
        {
//            if ( GlobalVariables.LogLevel<GlobalConst.LOG_DEBUG )
//            {
//                return "";
//            }
            return "Packet ID: "+packetId + ", Packet Name:" + _PacketInfoMap[packetId];
        }
		private function ProcessBuffDelay():void {
			clearTimeout( _ProcessTimeID );
			_ProcessTimeID = 0;
			ProcessBuff();
		}
        private function ProcessBuff():void
        {
            if ( _IsProcess )
            {
                return;
            }
            _IsProcess = true;

            if ( _BuffList.length>0 )
            {
                var buff:ByteArray = _BuffList.splice( 0, 1 )[0];

                while ( true )
                {
                    var rollbackPos:int = 0;//buff.position;
					var len:int = 0;
                    if ( GateState==-2 && _ProxyKey /*GateState<0 */)
                    {
						switch( GateState ) {
							case -2://未通过验证
								if ( !CheckBuff( buff, 12 ))
								{
									return;
								}
								break;
							case -1://已通过验证
							default:
								if ( !CheckBuff( buff, 8 ))
								{
									return;
								}
								break;
						}
                        len=buff.readInt() - 8;
                        _PacketID=buff.readUnsignedInt();
						rollbackPos = 8;
                    }
                    else
                    {
                        if ( !CheckBuff( buff, PACKET_HEADER_SIZE ))
                        {
                            return;
                        }
                        len=buff.readInt() - PACKET_HEADER_SIZE;
                        rollbackPos = PACKET_HEADER_SIZE;
                    }

                    if ( !CheckBuff( buff, len, rollbackPos ))
                    {
                        return;
                    }
                    var data:DataBlock = Socket_ReceivePacketData( buff, len );

                    if ( data!=null )
                    {
						switch( GateState ) {
							case -1://已通过验证
								Socket_OnGateState( data );
								break;
							case -2://未通过验证
								GetGateState( data );
								break;
							default:
								this.dispatchEvent( data );
								break;
						}
                    }
                }
            }
            _IsProcess = false;

            if ( _BuffList.length>0 )
            {
				clearTimeout(_ProcessTimeID);
				_ProcessTimeID = setTimeout( ProcessBuffDelay, 100 );
            }
        }
        private function Retry():Boolean
        {
			var cnt:int = _Ports.length*2;
			Logger("connect retry [" + _RetryCount + "/" + cnt + "]", LogType.ERROR );
            if ( _RetryCount < cnt )
            {
				_RetryCount++
                NextServerPort();
                Logger( "connect retry...", LogType.ERROR );
                this.dispatchEvent( new DataBlock( SOCKET_RETRY ));
                setTimeout( Connect, 100 );
                return true;
            }
            return false;
        }
		private function SendSave( packet:DataBlock, aes:CBCMode, hash:Boolean=true ):void {
			var buff:ByteArray = new ByteArray();
			buff.endian = Endian.LITTLE_ENDIAN;
			buff.writeUnsignedInt( packet.Ident );
			
			if ( packet.Data.length != 0 )
			{
				buff.writeBytes( packet.Data );
			}
			var crypto:ByteArray = new ByteArray();
			crypto.endian = Endian.LITTLE_ENDIAN;
			if( hash ) {
				var md5:ByteArray = new MD5().hash( buff );
				md5.endian = Endian.LITTLE_ENDIAN;
				md5.position = 0;
				crypto.writeInt( _Time++ );
				crypto.writeBytes( md5 );
			}
			crypto.writeBytes( buff );
			
			var iv:uint = uint( crypto.length/16 )+1;
			var hex:String = iv.toString( 16 );
			var ivStr:String = "";
			
			for ( var k:int=0; k<hex.length; k++ )
			{
				ivStr += "0" + hex;
			}
			ivStr = StringUtils.FillString( ivStr, 128, "0" );
			aes.IV = Hex.toArray( ivStr );
			aes.encrypt( crypto );
			_Socket.writeUnsignedInt( crypto.length+4 );
			_Socket.writeBytes( crypto );
		}

        //---- Event Handling Methods ------------------------------------------
        /**
         * Socket连接关闭事件
         */
        private function Socket_OnClose( e:Event ):void
        {
			clearInterval( _PingID );
			clearTimeout( _ProcessTimeID );
			clearTimeout( _ConnectTimeoutID );
            Logger( "Socket Disconnected.", LogType.INFO );

            State=STATE_DISCONNECTED;

            _Socket.removeEventListener( Event.CONNECT, Socket_OnConnect );
            _Socket.removeEventListener( Event.CLOSE, Socket_OnClose );
            _Socket.removeEventListener( IOErrorEvent.IO_ERROR, Socket_OnIOError );
            _Socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, Socket_OnSecurityError );
            _Socket.removeEventListener( ProgressEvent.SOCKET_DATA, Socket_OnReceivedData );

			Code = 0;
			_PingTick = -1;
            _IsProcess = false;
            _SendCbc = null;
            _RecvCbc = null;
            _GateState = -2;
            _BuffList = [];

			if( AutoRetry ) {
				AutoRetry = false;
				Retry();
			} else {
            	this.dispatchEvent( new DataBlock( SOCKET_DISCONNECT ));
			}
        }
        /**
         * Socket连接事件
         */
        private function Socket_OnConnect( CurrentEvent:Event ):void
        {
            Logger( "Socket Connected.", LogType.INFO);
			
			State=STATE_CONNECTED;
			Code = 1;
//			if( GlobalVariables.PreAsk ) {
			if( _ProxyKey ) {
				Code = 1001;
				var tick:String = _ProxyKey;//GlobalVariables.ModAndResConfig.@sid;
				var buff:ByteArray = new ByteArray();
				buff.endian = Endian.LITTLE_ENDIAN;
				buff.writeUTFBytes( tick );
				var aes:CBCMode = new CBCMode( new AESKey( buff ));
				
				var packet:DataBlock = new DataBlock( 6 );
				packet.Data.writeUTF( ServerHost + ":" + ServerPort);
				_Socket.writeShort( 1 );
				SendSave( packet, aes, false );
				_Socket.flush();
			} else {
				GetGateState();
			}
        }
        private function Socket_OnGateState( e:DataBlock ):void
        {
			clearTimeout( _ConnectTimeoutID );
			Code = 2;
			try {
	            e.Data.position = 0;
	            _GateState = e.Data.readByte();
	
	            var digits:Array = e.Data.readInt64ToBit();
	
	            var uuid:String = _SendKey;//GlobalVariables.ModAndResConfig.@uuid;
	            var tick:String = "";
	
	            for ( var i:int=0; i<digits.length; i++ )
	            {
	                if ( digits[i]==1 )
	                {
	                    tick += uuid.charAt( i );
	                }
	            }
	            ServerTick = tick;
				
				Logger( "Gate State:"+_GateState, LogType.INFO );
				if( _GateState!=0 ) {
					Logger( "Gate not ready.", LogType.INFO );
					if( Retry() ) {
						return ;
					}
				}
				Logger( "Gate is ready.", LogType.INFO );
				
				Ping();
			}catch(e:Error) {
				Logger(e.message, LogType.ERROR);
				Code = 3;
			}
        }

        /**
         * Socket连接出错事件
         */
        private function Socket_OnIOError( e:IOErrorEvent ):void
        {
            Logger( "Socket IO Error: "+e.text, LogType.ERROR );

            State=STATE_FAILED;

            if ( Retry())
            {
                return;
            }
            var dat:MyByteArray = new MyByteArray();
            dat.writeUTF( "Socket IO Error: "+e.toString());
            this.dispatchEvent( new DataBlock( SOCKET_ERROR, dat ));
        }

        /**
         * 接收到心跳包响应
         */
        private function Socket_OnKeepAliveAck( packet:DataBlock ):void
        {
			if( _PingTick==-1 ) {
				Code = 0;
				this.dispatchEvent( new Event( "OnGateState" ));
			}
            _PingTick = _LastReceive - _LastPing;
            Logger( "[Ping:"+_PingTick+"]Send:"+_LastPing+",LaseReceive:"+_LastReceive+",Curr:"+getTimer(), LogType.INFO);
        }

        /**
         * Socket接收数据事件
         */
        private function Socket_OnReceivedData( e:ProgressEvent ):void
        {
            _LastReceive = getTimer();

            var bytes:ByteArray = new ByteArray();
            bytes.endian = Endian.LITTLE_ENDIAN;
            _Socket.readBytes( bytes );
            Logger( "[Recevie]Buff Len:"+bytes.length, LogType.PACKET_RECV );

            bytes.position = 0;
//			while( bytes.bytesAvailable>0 ) {
//				var b:ByteArray = new ByteArray();
//				b.endian = Endian.LITTLE_ENDIAN;
//				b.writeByte( bytes.readByte() );
//				b.position = 0;
//				_BuffList.push( b );
//			}
            _BuffList.push( bytes );

            if ( !_IsProcess && _ProcessTimeID==0 )
            {
                _ProcessTimeID = setTimeout( ProcessBuffDelay, 50 );
            }
        }

        /**
         * Socket连接安全出错事件
         */
        private function Socket_OnSecurityError( e:SecurityErrorEvent ):void
        {
            Logger( "Socket Security Error."+e.text, LogType.ERROR );

            if ( State != STATE_DISCONNECTED )
            {
                State=STATE_FAILED;

                if ( Retry())
                {
                    return;
                }

                var dat:MyByteArray = new MyByteArray();
                this.dispatchEvent( new DataBlock( SOCKET_ERROR, dat ));
            }
        }

        /**
         * 读取包数据内容
         */
        private function Socket_ReceivePacketData( buff:ByteArray, len:int ):DataBlock
        {
            if ( State!=STATE_CONNECTED )
            {
                return null;
            }


            if ( buff.bytesAvailable >= len )
            {

                var data:MyByteArray;

                if ( len != 0 )
                {
                    data=new MyByteArray();
                    data.endian=Endian.LITTLE_ENDIAN;
					
					if( GateState==-2 && _ProxyKey ) {
						buff.readBytes( data, 0, len );
					} else if ( _RecvCbc )
                    {
                        var crypto:MyByteArray=new MyByteArray();
                        crypto.endian=Endian.LITTLE_ENDIAN;

                        buff.readBytes( crypto, 0, len );

                        var iv:uint = uint(( len-PACKET_HEADER_SIZE )/16 )+1;
                        var hex:String = iv.toString( 16 );
                        var ivStr:String = "";

                        for ( var k:int=0; k<hex.length; k++ )
                        {
                            ivStr += "0" + hex;
                        }
                        ivStr = StringUtils.FillString( ivStr, 128, "0" );
                        _RecvCbc.IV = Hex.toArray( ivStr );

                        _RecvCbc.decrypt( crypto );
                        crypto.position = 0;

                        _PacketID=crypto.readUnsignedInt();


                        crypto.readBytes( data );

                        crypto = null;
                    }
                    else
                    {
                        buff.readBytes( data, 0, len );
                    }
                }

                Logger( "[Process]"+GetPacketInfo( _PacketID )+", PacketLen: "+( len ), LogType.PACKET_BUFF );

                System.gc();
                return new DataBlock( _PacketID, data );

            }
            Logger( "Data Length Not Enough: ID["+_PacketID+"],Length:["+len+"],Available["+buff.bytesAvailable+"]", LogType.ERROR );
            return null;
        }
		/**
		 * 记录调试信息的方法，将传递两个参数，function(msg:String, type:int=0)
		 * @default 
		 */
		public static var Logger:Function = function(msg:String, type:int=0):void{trace(msg);};
		
        private function UnshiftBuff( buff:ByteArray, rollbackPos:int ):void
        {
            if ( buff!=null )
            {
                var leftBuff:ByteArray = new ByteArray();
                leftBuff.endian = Endian.LITTLE_ENDIAN;
//				if( rollbackPos>=0 ) {
//					buff.position = rollbackPos;
//				}
                buff.position -= rollbackPos;
                buff.readBytes( leftBuff );
                _BuffList.unshift( leftBuff );
            }
            _IsProcess = false;
        }
    }
}
