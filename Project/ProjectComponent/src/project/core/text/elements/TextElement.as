package project.core.text.elements
{
	/**
	 * 文本 + 文本颜色
	 * @author Administrator
	 * 
	 */	
	public class TextElement
	{
		public var Text:String;
		public var Color:uint;
		
		public function TextElement(text:String, color:uint = 0x00ff00)
		{
			Text = text;
			Color = color;
		}
	}
}