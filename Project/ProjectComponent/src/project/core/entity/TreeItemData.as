package project.core.entity
{
	public class TreeItemData
	{
		public var Label:String;
		public var Children:Array = [];
		public var Ident:int;
		public var ParentID:int;
		public var Data:Object;
		public function AddChild( data:TreeItemData ):void {
			Children.push( data );
		}
	}
}