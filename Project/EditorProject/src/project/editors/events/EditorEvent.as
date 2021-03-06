package project.editors.events
{
    import flash.events.Event;

    public class EditorEvent extends Event
    {
		public static const UPDATE:String = "update";
		public static const CHANGE:String = "change";
        public static const CONFIRM:String = "confirm";
        public static const COPY:String = "copy";
        public static const CREATE:String = "create";
        public static const DELETE:String = "delete";
        public static const EDIT:String = "edit";
        public static const SELECTED:String = "selected";
        public static const UNSELECT:String = "unselect";
		public static const RELOAD:String = "reload";

        public function EditorEvent( type:String, data:Object = null )
        {
            super( type );
            Data = data;
        }

        public var Data:Object;
    }
}