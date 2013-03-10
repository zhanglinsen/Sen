package project.core.text.elements
{
	import project.core.global.GlobalVariables;
	import project.core.utils.Utility;
	
	public class DynamicStringElement extends AbstractStringElement
	{
		public function DynamicStringElement()
		{
			super("", true);
		}
		
		override public function Parse(node:XML):void
		{
			super.Parse(node);
			this.ContentFormat = Utility.ParseTextFormat( node );
		}
	}
}