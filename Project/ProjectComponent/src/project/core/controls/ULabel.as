package project.core.controls
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import project.core.global.GlobalVariables;
	import project.core.manager.ToolTipManager;
	
	/**
	 * 在TextField基础上增加的Tooltip,如果不需要tooltip的使用TextField
	 * @author meiibin
	 */
	public class ULabel extends TextField
	{
		private static var DefaultFormat:TextFormat = new TextFormat( GlobalVariables.Font, GlobalVariables.FontSize, 0x6B9945 );
		/**
		 * 
		 * @param fmt
		 */
		public function ULabel(fmt:TextFormat=null)
		{
			super();
			_TextFormat = fmt;
			selectable = false;
		}
		private var _TextFormat:TextFormat;
		override public function set text(value:String):void {
			super.text = value;
			if( _TextFormat!=null ) {
				setTextFormat(_TextFormat);
				width = textWidth+4;
				height = textHeight+4;
			}
		}
		private var _ToolTip:Object;
		
		/**
		 * 
		 * @return 
		 */
		public function get ToolTip():Object
		{
			return _ToolTip;
		}
		
		/**
		 * 
		 * @param obj
		 */
		public function set ToolTip( obj:Object ):void
		{
			if( _ToolTip==obj ) return ;
			_ToolTip = obj;
			
			if ( obj == null || obj=="" )
			{
				ToolTipManager.UnRegister( this );
			}
			else
			{
				ToolTipManager.Register( this, obj );
			}
		}
	}
}