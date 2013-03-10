package project.core.text.elements
{
	import project.core.utils.Utility;

	public class StringElement extends AbstractStringElement
	{
		public function StringElement(str:String="")
		{
			super(str);
		}
		
		override public function Parse(node:XML):void
		{
			super.Parse(node);
			Content = node.text().toString();
			this.ContentFormat = Utility.ParseTextFormat( node );
		}
	}
}