package project.editors.loader
{
	import flash.system.LoaderContext;
	
	import project.core.loader.ImageLoader;
	
	
	public class AirImageLoader extends ImageLoader
	{
		public function AirImageLoader()
		{
			var ctx:LoaderContext = new LoaderContext();
			ctx.allowLoadBytesCodeExecution = true;
			super(ctx);
		}
	}
}