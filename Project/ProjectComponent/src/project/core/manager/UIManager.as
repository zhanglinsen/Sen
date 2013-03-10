package project.core.manager
{
    import flash.display.DisplayObject;
    import flash.utils.Dictionary;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    import project.core.containers.UPopupWindow;
    import project.core.containers.UWindow;
    import project.core.controls.UMessageBox;
    import project.core.global.GlobalVariables;
    import project.core.loader.ClassLoader;
    import project.core.reader.IStreamReader;
    import project.core.reader.ReaderFactory;
    import project.core.scene.IScene;
	
    /**
     * UI管理器，管理各模块和模块所需资源的加载
     * @author meibin
     */
    public final class UIManager
    {
        private static var _CurrScene:IScene;
        private static var _Instance:UIManager = new UIManager();
		private static var _LastScene:IScene;
		private static var _LastSceneSound:String;

        /**
         * 清楚显示的UI，包含弹出窗口，菜单，和场景
         */
        public static function Clear():void
        {
			PopupManager.Clear();
			MenuManager.Clear();
            if ( CurrScene!=null )
            {
				if ( CurrScene!=null )
				{
					CurrScene.CloseScene();
				}
				_CurrScene = null;
            }
        }

		/**
		 * 与Clear的区别是不关闭场景，但会把LoadeUI隐藏
		 */
		public static function CloseAll():void {
			PopupManager.Clear();
			MenuManager.Clear();
			LoaderManager.Hide();
		}
		/**
		 * @return 当前场景
		 */
		public static function get CurrScene():IScene {
			return _CurrScene;
		}
		/**
		 * 获取ui实例
		 * @param uiClass ui类全路径
		 * @return ui实例
		 */
		public static function GetUI( uiClass:String ):* {
			return _Instance.GetUI(uiClass);
		}
		/**
		 * 隐藏ui
		 * @param uiClass ui类全路径
		 */
		public static function HideUI( uiClass:String ):void {
			var inst:Object = _Instance.GetUI(uiClass);
			if( inst ) {
				if( inst is UPopupWindow || inst.hasOwnProperty("Hide") ) {
					inst.Hide();
				}
			}
		}
		/**
		 * @return 上一个显示的场景
		 */
		public static function get LastScene():IScene {
			return _LastScene;
		}
        /**
         * 加载UI
         * @moduleName 模块名
         * @uiClass 加载显示的类名(含包路径)
         * @callback 加载完成后的回调，不设置则使用默认回调
         */
        public static function LoadUI( moduleName:String, uiClass:String, callback:Function = null, param:* = null, silent:Boolean=false, errorCallback:Function=null ):void
        {
            _Instance.LoadUI( moduleName, uiClass, callback, param, silent, errorCallback );
        }
		/**
		 * 播放场景背景音乐
		 */
		public static function PlaySceneSound():void {
			BgSoundManager.Play( _LastSceneSound );
		}
		/**
		 * 重置请求队列
		 */
		public static function ResetQueue():void {
			_Instance.ResetQueue();
		}

        /**
         * 显示ui
         * @param instance ui实例
         * @param p 参数
         */
        public static function ShowUI( instance:DisplayObject, p:*=null ):void
        {
            _Instance.ShowUI( instance, p );
        }
		/**
		 * 停止加载
		 */
		public static function Stop():void {
			_Instance.Stop();
		}

//        public static function LoadMap( data:Object, callback:Function ):void
//        {
//            _Instance.LoadMap( data, callback );
//        }

        private const STEP_COMPLETE:int = 6;
		private const STEP_LOAD_STATIC_DATA:int = 0;
        private const STEP_LOAD_IMAGESET:int = 1;
		private const STEP_LOAD_STRING_TABLE:int = 2;
		private const STEP_LOAD_IMAGE:int = 3;
        private const STEP_LOAD_MAP:int = 4;
        private const STEP_LOAD_MODULE:int = 5;
        private var _CompleteCallback:Function;
        private var _CurrStep:int;
		private var _ErrorCallback:Function;
        private var _InstanceClassList:Array = [];
        private var _InstanceList:Array = [];
		private var _LoadQueue:Array = [];
		private var _LoadQueueTimeId:int;
        private var _LoadedCache:Array = [[],[],[],[],[],[],[]];
//        private var _ModNode:Object = null;
        private var _ModResNode:Object = null;
//		private var _LastSound:String;
        private var _ModuleName:String;
		private var _ModuleSound:String;
        private var _ModuleUIClass:String;
        private var _Params:*;
		private var _RequestCache:Dictionary;
		private var _Retry:Boolean = false;
		private var _RetryModule:String;
		private var _Silent:Boolean = false;
		
//		internal function HideUI( uiClass:String ):void {
//			var idx:int = _InstanceClassList.indexOf( uiClass );
//			if( idx!=-1 ) {
//				var inst:Object = _InstanceList[idx];
//				if( inst is UPopupWindow || inst.hasOwnProperty("Hide") ) {
//					inst.Hide();
//				}
//			}
//		}
		
		internal function GetUI( uiClass:String ):* {
			var idx:int = _InstanceClassList.indexOf( uiClass );
			if( idx!=-1 ) {
				return _InstanceList[idx];
			}
			return null;
		}
        internal function LoadUI( moduleName:String, uiClass:String, callback:Function = null, param:* = null, silent:Boolean=false, errorCallback:Function=null ):void
        {
			if( moduleName ) {
				if( _ModuleName == moduleName ) {
					_Params = param;
					if( callback==null ) {
						callback = ShowUI;
					}
					_ErrorCallback = errorCallback;
					_CompleteCallback = callback;
					if( _Silent && !silent ) {
						_Silent = silent;
						LoaderManager.Show();
					}
					return ;
				}
				var modLoaded:Boolean = _LoadedCache[STEP_COMPLETE].indexOf( moduleName )!=-1;
				if( _ModuleName ) {
					if( _Silent && !silent ) {
						Stop();
					} else {
						if( !modLoaded ) {
							if( !silent ) {
								RemoveQueue( moduleName );
								for( var i:int=0; i<_LoadQueue.length; i++ ) {
									if( _LoadQueue[i][4]==true ) {
										var tmp:Array = _LoadQueue.splice(i);
										_LoadQueue.push([moduleName,uiClass,callback,param,silent]);
										_LoadQueue = _LoadQueue.concat( tmp );
										break;
									}
								}
							} else {
								RemoveQueue( moduleName );
								_LoadQueue.push([moduleName,uiClass,callback,param,silent]);
							}
						}
						return ;
					}
				}
			}
			clearTimeout( _LoadQueueTimeId );
			_LoadQueueTimeId = 0;
			_Retry = _RetryModule == moduleName;
			if( moduleName==null ) {
				_Silent = false;
				_Params = null;
				LoadQueue();
				return ;
			}
			_Params = param;
			_Silent = silent;
//			if( moduleName.indexOf("Scene")!=-1 ) {
//				if( PopupManager.HasModalWin() ) {
//					FadeInfoManager.Show(XmlUtils.GetText("preload.msg.modalinui"), true, null, false);
//					return ;
//				}
//			}
            if ( callback==null )
            {
                callback = this.ShowUI;
            }
			
            var idx:int = _InstanceClassList.indexOf( uiClass );
			
            if ( modLoaded )
            {
				if( uiClass==null ) {
					_Silent = false;
					if( !silent ) {
						LoaderManager.Hide();
					}
					callback( null, param, silent);
					LoadQueue();
					return ;
				}
                if ( idx==-1 )
                {
                    var cls:Class = ClassLoader.Instance.GetClass( uiClass );

                    if ( cls==null )
                    {
						if( !_Silent ) {
							LoaderManager.Show();
						}
						LoaderManager.UI.Status = moduleName + " not found. Retry...";
						_Retry = true;
						
						idx = _LoadedCache[STEP_COMPLETE].indexOf( moduleName );
						_LoadedCache[STEP_COMPLETE].splice( idx, 1 );
						
						idx = -1;
                    } else {
	                    idx=_InstanceList.length;
						if( _InstanceClassList.indexOf(uiClass)==-1) {
	                    	_InstanceClassList.push( uiClass );
						}
						var instance:*;
						try {
							instance = new cls();
						}catch(e:Error) {
							UMessageBox.Show("["+_ModuleName+"] initialize failed.");
							Debugger.Error(e.message);
							return ;
						}
						if( instance ) {
	                    	_InstanceList.push( instance );
						} 
					}
                }
            }
			if( !_Silent ) {
				switch( moduleName ) {
					case "TowerScene":
						_ModuleSound = GlobalVariables.GetSoundPath( "shilianta.mp3");
						break;
					case "WarScene":
					case "WorldScene":
					case "AreaScene":
					case "CampaignScene":
						_ModuleSound = GlobalVariables.GetSoundPath( "fuben.mp3");
						break;
					case "BattleScene":
						_ModuleSound = GlobalVariables.GetSoundPath( "zhandou.mp3");
						break;
					case "CastleScene":
						_ModuleSound = GlobalVariables.GetSoundPath( "zhucheng.mp3");
						break;
					case "ChallengeCupScene":
						_ModuleSound = GlobalVariables.GetSoundPath( "38-Arena.mp3");
						break;
					default:
						if( moduleName.indexOf("Scene")!=-1 ) {
							_ModuleSound = GlobalVariables.GetSoundPath( "zhucheng.mp3");
						} else {
							_ModuleSound = "";
						}
				}
			}
//			var sounds:XMLList = GlobalVariables.ModuleConfig.Module.(@name == moduleName).Sound;
//			if( sounds.length()>0 ) {
//				_ModuleSound = GlobalVariables.GetSoundPath( sounds[0].@name );
//			} else {
//				_ModuleSound ="";
//			}
            if ( idx!=-1 )
            {
				_Silent = false;
				//教程需要LoaderManager的Hide事件
//				LoaderManager.Show();
				if( !silent ) {
					LoaderManager.Hide();
					if( moduleName.indexOf("Scene")!=-1 ) {
						BgSoundManager.Play( _ModuleSound );
						
						if( _InstanceList[idx].hasOwnProperty("SceneType") && _InstanceList[idx].SceneType>0 ) {
							_LastSceneSound = _ModuleSound;
						}
						_ModuleSound = "";
					}
				}
                callback( _InstanceList[idx], param, silent);
				LoadQueue();
            }
            else
            {
				_ErrorCallback = errorCallback;
                _CompleteCallback = callback;
                _ModuleName = moduleName;
                _ModuleUIClass = uiClass;
                _CurrStep = -1;
                LoaderManager.OnAllCompleteCallback = Process;
				LoaderManager.OnCompleteCallback = OnLoadComplete;
				LoaderManager.OnErrorCallback = ProcessError;
				if( !_Silent ) {
                	LoaderManager.Show();
				}

                _ModResNode = GlobalVariables.ModAndResConfig.Module.(@name == _ModuleName);
				if ( _ModResNode==null )
				{
					_Silent = false;
					LoaderManager.UI.Status = "Module config load failed.";
					LoaderManager.Error();
					return;
				}
//				_ModResNode = GlobalVariables.ResourceConfig.Module.(@name == _ModuleName);
//                if ( _ModResNode==null )
//                {
//					_Silent = false;
//					LoaderManager.UI.Status = "Resource config load failed.";
//                    LoaderManager.Error();
//                    return;
//                }
//				
//				_ModNode = GlobalVariables.ModuleConfig.Module.(@name == moduleName);
//                if ( _ModNode==null )
//                {
//					_Silent = false;
//					LoaderManager.UI.Status = "Module config load failed.";
//                    LoaderManager.Error();
//                    return;
//                }
				
				Debugger.Debug("Load Module:" + _ModuleName);
				InitRequest();
				
                Process();
            }
        }
		internal function RemoveQueue( moduleName:String ):void {
			for( var i:int=0; i<_LoadQueue.length; i++ ) {
				if( _LoadQueue[i][0]==moduleName && _LoadQueue[i][4]==true ) {
					_LoadQueue.splice(i,1);
					break;
				}
			}
		}
		internal function ResetQueue():void {
			_LoadQueue = [];
		}

        internal function ShowUI( instance:DisplayObject, p:*=null, silent:Boolean=false ):void
        {
			if( silent ) return ;
            if ( instance is IScene )
            {
                if ( instance != CurrScene )
                {
					if( CurrScene && (_LastScene==null || CurrScene.SceneType!=_LastScene.SceneType ) ) {
						if( CurrScene.SceneType>0 ) {
							_LastScene = CurrScene;
						}
					}
                    Clear();
					_CurrScene = instance as IScene;
                    CurrScene.OpenScene( p );
                } else if( p && p.BattleUID ) {
					CurrScene.OpenScene( p );
				}
            }
            else if ( instance is UPopupWindow )
            {
				instance['Data'] = p;
                (instance as UPopupWindow).Show();
            }
            else if ( instance is UWindow )
            {
                GlobalVariables.Root.addChild( instance );
            }
        }
		internal function Stop():void {
			_LoadQueue.unshift([_ModuleName,_ModuleUIClass,_CompleteCallback,_Params,_Silent,_ErrorCallback]);
			LoaderManager.Loader.Reset();
			LoaderManager.Reset();
			Reset();
			clearTimeout( _LoadQueueTimeId );
			_LoadQueueTimeId = 0;
			_Retry = false;
		}
		private function DelayLoadQueue():void {
			if( _LoadQueue.length>0 && _ModuleName==null) {
				this.LoadUI.apply( this, _LoadQueue.shift() );
			}
		}
		private function InitRequest():void {
			var total:int = 0;
			_RequestCache = new Dictionary();
			total += _InitRequest( _ModResNode.ImageSet, STEP_LOAD_IMAGESET);
			total += _InitRequest( _ModResNode.Text, STEP_LOAD_STRING_TABLE);
			total += _InitRequest( _ModResNode.Map, STEP_LOAD_MAP);
			total += _InitRequest( _ModResNode.StaticData, STEP_LOAD_STATIC_DATA);
			total += _InitRequest( _ModResNode.Dll, STEP_LOAD_MODULE, _Retry );
			
			var list:XMLList = _ModResNode.Image;
			var req:Array = [];
			for ( var i:int = 0; i < list.length(); i++ )
			{
				var item:XML = list[i];
				var folder:String = item.@name+"/";
				folder = folder.replace("{lang}", GlobalVariables.Lang);
				
				var fileList:XMLList = item.File;
				var type:String = item.@type;
				if(!type) {
					type = "class";
				}
				for( var k:int=0; k<fileList.length(); k++ ) { 
					var name:String = fileList[k].@name;
					if ( _LoadedCache[STEP_LOAD_IMAGE].indexOf( name )==-1 && req.indexOf( name )==-1 )
					{
						req.push( {Folder:folder, Name:name, Label:item.@label.toString(), Version:"", Type:type} );
					}
				}
			}
			_RequestCache[STEP_LOAD_IMAGE] = req;
			total += req.length;
			
			LoaderManager.UI.TotalRequest = total;
		}
		private function LoadQueue():void {
			if( _LoadQueue.length==0 ) return ;
			var t:int = 300;
			if(_LoadQueue[0][4]==true ) {
				t = 2000;
			}
			clearTimeout( _LoadQueueTimeId ); 
			_LoadQueueTimeId = setTimeout( DelayLoadQueue, t );
//			Debugger.Error("QueueID:"+_LoadQueueTimeId);
		}
		private function OnLoadComplete( name:String ):void {
			_LoadedCache[_CurrStep].push( name );
		}
		/**
		 * 0:StaticData
		 * 1:ImageSet
		 * 2:Text
		 * 3:Image
		 * 4:Map
		 * 5:Module
		 */
		public static var ResFolders:Array = [];
        private function Process():void
        {
            _CurrStep++;

            switch ( _CurrStep )
            {
				case STEP_LOAD_STATIC_DATA:
					ProcessLoad( ReaderFactory.XmlReader, /*_ModResNode.StaticData,*/  ResFolders[_CurrStep]);
					break;
                case STEP_LOAD_IMAGESET:
                    ProcessLoad( ReaderFactory.ImageSetReader, /*_ModResNode.ImageSet, */ ResFolders[_CurrStep]);
                    break;
                case STEP_LOAD_STRING_TABLE:
                    ProcessLoad( ReaderFactory.TextReader, /*_ModResNode.Text,*/ ResFolders[_CurrStep]);
                    break;
				case STEP_LOAD_IMAGE:
					ProcessLoad( ReaderFactory.ImageSetReader, ResFolders[_CurrStep] );
					//					LoaderManager.Loader.Reader = ReaderFactory.MovieClipReader;
					//					var list:XMLList = _ModResNode.Image;
					//					var path:String = GlobalConst.RESOURCE_PATH+GlobalConst.RESOURCE_IMAGE ;
					//					for ( var i:int = 0; i < list.length(); i++ )
					//					{
					//						var item:XML = list[i];
					//						var name:String = item.@name+"/";
					//						
					//						var fileList:XMLList = item.File;
					//						for( var k:int=0; k<fileList.length(); k++ ) { 
					//							var file:String = fileList[k].@name;
					//							if ( _LoadedCache[_CurrStep].indexOf( file )==-1 )
					//							{
					//								LoaderManager.Loader.AddRequest( path+name, file, item.@label );
					//							}
					//						}
					//					}
					//					LoaderManager.Loader.Process();
					break;
                case STEP_LOAD_MAP:
                    ProcessLoad( ReaderFactory.XmlReader, /*_ModResNode.Map,*/  ResFolders[_CurrStep]);
                    break;
                case STEP_LOAD_MODULE:
                    ProcessLoad( ReaderFactory.ModuleReader, /*_ModNode.Dll,*/ ResFolders[_CurrStep]);
                    break;
                case STEP_COMPLETE:
                    ProcessComplete();
                    break;
            }
        }
        private function ProcessComplete():void
        {
            LoaderManager.OnAllCompleteCallback = null;
			LoaderManager.OnCompleteCallback = null;
			
			var callback:Function = _CompleteCallback;
			var p:* = _Params;
			_CompleteCallback = null;
			_ErrorCallback = null;
			_Params = null;
			var silent:Boolean = _Silent;
			
			if( _ModuleUIClass==null ) {
//				LoaderManager.Hide();
				_LoadedCache[STEP_COMPLETE].push( _ModuleName );
				
				Reset();
				if(!silent) {
					LoaderManager.Hide();
				}
				if(callback!=null) {
					callback( null );
				}
				LoadQueue();
				return ;
			}
			
			var cls:Class = ClassLoader.Instance.GetClass( _ModuleUIClass );
            if ( cls!=null )
            {
				if( !_Silent ) {
					LoaderManager.Hide();
				}
				
				var instance:DisplayObject;
				try {
					instance = new cls();
				} catch ( e:Error ) {
//					UMessageBox.Show("["+_ModuleName+"]" + XmlUtils.GetText("preload.label.initerror"));
					Debugger.Error(e.message);
				}
				if( instance ) {
					//加载成功
					_LoadedCache[STEP_COMPLETE].push( _ModuleName );
					_InstanceClassList.push( _ModuleUIClass );
					
					if( !_Silent && _ModuleName.indexOf("Scene")!=-1 ) {
						BgSoundManager.Play( _ModuleSound );
						
						if( instance.hasOwnProperty("SceneType") && instance['SceneType']>0 ) {
							_LastSceneSound = _ModuleSound;
						}
						_ModuleSound = "";
					}
					Reset();
					
					_InstanceList.push( instance );
					
					callback( instance, p, silent );
					
					LoadQueue();
					return ;
				}
            } else {
				Debugger.Error( "Class not found:" + _ModuleUIClass  );
			}
			//加载出错处理
			var modName:String = _ModuleName;
			var modCls:String = _ModuleUIClass;
			var retryMod:String = _RetryModule;
			_ErrorCallback = null;
			
			Reset();
			
			var nodeList:XMLList = GlobalVariables.ModAndResConfig.Module.(@name==modName).Dll;
			for( var i:int=0; i<nodeList.length(); i++ ) {
				var dll:String = nodeList[i].@name;
				var idx:int = _LoadedCache[STEP_LOAD_MODULE].indexOf( dll );
				if( idx!=-1 ) {
					_LoadedCache[STEP_LOAD_MODULE].splice(idx,1);
				}
			}
			if( retryMod != modName ) {
				Debugger.Error( modName + " Retry Loading.");
				_RetryModule = modName;
				this.LoadUI( modName, modCls, callback, p, silent );
			} else {
				Debugger.Error( modCls + " not found.");
				LoaderManager.UI.Status = "[" + modCls.substr(modCls.lastIndexOf(".")+1) + "] load failed.";
				LoaderManager.UI.ShowClose();
			}
        }
		private function ProcessError():void {
			Reset();
			var err:Function = _ErrorCallback;
			_ErrorCallback = null;
			_CompleteCallback = null;
			var name:String = LoaderManager.Loader.CurrRequest.FileName;
			var idx:int = _LoadedCache[_CurrStep].indexOf( name );
			if( idx!=-1 ) {
				_LoadedCache[_CurrStep].splice( idx, 1);
			}
			if( err!=null ) {
				err();
			}
		}
//        internal function LoadMap( data:Object, callback:Function ):void
//        {
//			LoaderManager.OnCompleteCallback = callback;
//			LoaderManager.Show();
//				
//            var path:String = GlobalConst.RESOURCE_PATH + GlobalConst.RESOURCE_MAP;
//            LoaderManager.Loader.Reader = ReaderFactory.XmlReader;
//
//			if( data is XMLList ) {
//	            for ( var i:int = 0; i < data.length(); i++ )
//	            {
//					AddMapRequest( data[i], path );
//	            }
//			} else if( data is XML ) {
//				AddMapRequest( data as XML, path );
//			}
//            LoaderManager.Loader.Process();
//        }
//		private function AddMapRequest(item:XML, path:String):void {
//			var name:String = item.@name;
//			
//			if ( _LoadedCache[STEP_LOAD_MAP].indexOf( name )==-1 )
//			{
//				_LoadedCache[STEP_LOAD_MAP].push( name );
//				LoaderManager.Loader.AddRequest( path, item.@name, item.@label, item.@version );
//			}
//		}

        private function ProcessLoad( reader:IStreamReader,/* list:XMLList,*/ path:String ):void
        {
            LoaderManager.Loader.Reader = reader;

			var list:Array = _RequestCache[_CurrStep];
            for ( var i:int = 0; i < list.length; i++ )
            {
				LoaderManager.Loader.AddRequest( path+list[i].Folder, list[i].Name, list[i].Label, list[i].Version, list[i].Retry, null, list[i].Type );
//                var item:Object = list[i];
//                var name:String = item.@name;
//				name = name.replace("{lang}", GlobalVariables.ServerConfig.@lang );
//                if ( _LoadedCache[_CurrStep].indexOf( name )==-1 )
//                {
//                    LoaderManager.Loader.AddRequest( path, name, item.@label, item.@version );
//                }
            }
			LoaderManager.UI.TotalRequest = list.length;
            LoaderManager.Loader.Process();
        }
		private function Reset():void {
			_Silent = false;
//			_ModNode = null;
			_ModResNode = null;
			_ModuleName = null;
			_ModuleUIClass = null;
			_RetryModule = null;
		}
		private function _InitRequest( list:XMLList, type:int, retry:Boolean=false ):int {
			var req:Array = [];
			for ( var i:int = 0; i < list.length(); i++ )
			{
				var item:Object = list[i];
				var name:String = item.@name;
				name = name.replace("{lang}", GlobalVariables.Lang);
				if ( _LoadedCache[type].indexOf( name )==-1 && req.indexOf( name )==-1 )
				{
					req.push( {Retry:retry, Folder:"", Name:name, Label:item.@label.toString(), Version:item.@version.toString(), Type:""} );
				}
			}
			_RequestCache[type] = req;
			return req.length;
		}
    }
}