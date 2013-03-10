package project.core.navigators
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    import project.core.controls.UList;
    import project.core.events.UIEvent;
    import project.core.factory.ClassFactory;
    import project.core.factory.IFactory;
    import project.core.global.DirectionConst;

    public class UTabBar extends UList 
    {
        public function UTabBar(direction:String=DirectionConst.HORIZONTAL, gap:int = 3, renderer:Class=null)
        {
            super(direction, gap);		
			ItemRenderer = new ClassFactory(renderer==null?UTabItem:renderer);
        }
		
		public function AddTab(label:String = "", ident:int = -1, toolTip:String = null):DisplayObject
		{
			return AddData( {Ident:ident, Label:label, ToolTip:toolTip} );
		}
    }
}