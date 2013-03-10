package project.core.tooltip
{
	import project.core.text.HyperText;
	
	public class StyleToolTipUI extends DefaultToolTipUI
	{
		public function StyleToolTipUI()
		{
			super();
		}
		private var _IsHyper:Boolean = false;
		override protected function set TextData( obj:Object ):void {
			if( obj is HyperText ) {
				_IsHyper = true;
				(obj as HyperText).ToTextField( _pText, [], _pLabelFormat );
			} else {
				_IsHyper = false;
				super.TextData = obj;
			}
		}
		override protected function ValidateText():void {
			if( _IsHyper ) {
				width = _pText.width+PaddingLeft+PaddingRight;
				height = _pText.height+PaddingTop+PaddingBottom+(_pText.numLines>1?2:0);
				_pText.y = PaddingTop;
				_pText.x = PaddingLeft;
			} else {
				super.ValidateText();
			}
		}
	}
}