package project.core.manager
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.system.ApplicationDomain;
    import flash.utils.Dictionary;
    import flash.utils.describeType;
    
    import project.core.cache.ICache;

    /**
     * 缓存管理器
	 * 定义缓存类需实现ICache接口，然后通过CacheManager.RegisterCache方法注册缓存。
	 * 注册后的缓存可通过CacheManager统一管理。缓存类中的事件通过在类定义前添加
	 * [Cache(event="eventTypeName")]，如果无此定义，则缓存管理器不处理缓存类中的事件。
     * @author meibin
     */
    public final class CacheManager
    {
        private static var _CacheMap:Dictionary = new Dictionary();
        private static var _Dispatcher:EventDispatcher = new EventDispatcher();

        /**
         * 监听缓存
         * @param type 缓存事件类型
         * @param listener 监听器
         */
        public static function AddCacheListener( type:String, listener:Function ):void
        {
            _Dispatcher.addEventListener( type, listener );
        }

        /**
         * 获取缓存数据，数据通过回调函数调用
         * @param className 缓存类名
         * @param callback 回调函数
         * @param params 动态参数，根据不同缓存类设置不同参数
         */
        public static function GetCacheCallback( className:String, callback:Function, ... params ):void
        {
            var cache:ICache = GetInstance( className );

			if(!cache) {
				cache = RegisterCache(className);
			}
			
            params.splice( 0, 0, callback );
            cache.GetCacheCallback.apply( cache, params );
        }
		/**
		 * 获取缓存
		 * @param className 缓存类名
		 * @param params 动态参数，根据不同缓存类设置不同参数
		 * @return 返回缓存数据
		 */
		public static function GetCache( className:String, ... params ):*
		{
			var cache:ICache = GetInstance( className );
			
			if ( cache )
			{
				return cache.GetCache.apply( cache, params );
			}
			return null;
		}

        /**
         * 获取缓存实例。缓存实例在注册缓存时就存在唯一的单例。
         * @param className 缓存类名
         * @return 缓存实例
         */
        public static function GetInstance( className:String ):*
        {
            return _CacheMap[className];
        }

        /**
         * 注册缓存
         * @param className 缓存类名(包含包名的全路径)
         * @return 返回缓存实例
         */
        public static function RegisterCache( className:String ):*
        {
            if ( !className )
            {
                return null;
            }

            if ( !_CacheMap[className])
            {
                try
                {
                    var clazz:Object = ApplicationDomain.currentDomain.getDefinition( className );

                    if ( clazz )
                    {
                        var instance:* = new (clazz as Class)();
						
						var xml:XML = describeType( instance );
						var nodeList:XMLList = xml.metadata.(@name="Cache").arg.(@key=="event");

						for ( var i:int=0; i<nodeList.length(); i++ )
						{
							var evtType:String = nodeList[i].@value;
							var evt:String;
							if( evtType.toUpperCase()==evtType ) {
								var arr:Array = evtType.toLowerCase().split("_");
								evt = arr[0];
								for( var j:int=1; j<arr.length; j++ ) {
									var s:String = arr[j];
									evt+=s.charAt(0).toUpperCase() + s.substr(1);
								}
							} else {
								evt = evtType;
							}
							instance.addEventListener( evt, Cache_AutoForward );
						}
                        _CacheMap[className] = instance;
						return instance;
                    }
                }
                catch ( e:* )
                {

                }
            }
			return _CacheMap[className];
        }

        /**
         * 移除缓存监听器
         * @param type 缓存事件名
         * @param listener 监听器
         */
        public static function RemoveCacheListener( type:String, listener:Function ):void
        {
            _Dispatcher.removeEventListener( type, listener );
        }

        private static function Cache_AutoForward( evt:Event ):void
        {
			_Dispatcher.dispatchEvent( evt.clone() );
        }
    }
}