package  project.core.factory
{
	public class ClassFactory implements IFactory
	{
	    public function ClassFactory(generator:Class = null, properties:Object = null)
	    {
			super();
			
	    	this.generator = generator;
			this.properties = properties;
	    }
	
	    public var generator:Class;
		
		public var properties:Object = null;
	
		public function NewInstance():*
		{
			var instance:Object = new generator();
	
	        if (properties != null)
	        {
	        	for (var p:String in properties)
				{
					if(instance.hasOwnProperty(p))
					{
	        			instance[p] = properties[p];
					}
				}
	       	}
	
	       	return instance;
		}
		
		public function get GeneratorClass():Class
		{
			return generator;
		}
	}
}
