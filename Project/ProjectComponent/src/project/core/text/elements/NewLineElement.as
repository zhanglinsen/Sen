package project.core.text.elements
{
	public class NewLineElement extends AbstractStringElement
	{
		public function NewLineElement()
		{
			super();
		}
		
		override public function get Content():String
		{
			return "\n";
		}
	}
}