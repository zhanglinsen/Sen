package project.core.tooltip
{
    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.geom.Point;
    
    import project.core.global.GlobalVariables;
    import project.core.manager.ToolTipManager;

    public class FixedPositionToolTipUI extends StyleToolTipUI
    {
        public function FixedPositionToolTipUI(fixedFunc:Function=null)
        {
            super();
			FixedPositionFunc = fixedFunc==null?CommonFixedFunc:fixedFunc;
        }
		public static function CommonFixedFunc( ui:FixedPositionToolTipUI, target:DisplayObject ):void {
			var fixedX:Number = target.width + 5;
			var fixedY:Number = target.height - ui.height;
			var p:Point = new Point( target.x, target.y );
			p = target.parent.localToGlobal( p );
			var px:Number = p.x + fixedX;
			if( (px+ui.width)>GlobalVariables.StageWidth ) {
				px = p.x - ui.width - 5;
			}
			ui.x = px;
			ui.y = p.y + fixedY;
		}
        public var FixedPositionFunc:Function;

        override public function Show( target:InteractiveObject ):void
        {
			if ( FixedPositionFunc==null )
			{
				super.Show( target );
			} else {
				if ( !Data )
				{
					return;
				}
				UpdateUI();
				if ( target is IToolTipFixed )
				{
					( target as IToolTipFixed ).FixedToolTipPosition( this );
				} else
				{
					FixedPositionFunc( this, target );
				}
				ToolTipManager.Root.addChild( this );
			}
        }
    }
}