package project.core.cache
{
	public interface ICache
	{
		
		/**
		 * 获取缓存数据，数据通过回调函数调用
		 * @param callback 回调函数
		 * @param params 动态参数，根据不同缓存类设置不同参数
		 */
		function GetCacheCallback(callback:Function,...params):void;
		/**
		 * 获取缓存
		 * @param params 动态参数，根据不同缓存类设置不同参数
		 * @return 返回缓存数据
		 */
		function GetCache(...params):*;
	}
}