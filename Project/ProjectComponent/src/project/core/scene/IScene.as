package project.core.scene
{
    public interface IScene
    {
        function ClearSelected():void;
        function CloseScene():void;
        function OpenScene(params:*=null):void;
        function set SelectedObject( obj:ISceneObject ):void;
        function get SelectedObject():ISceneObject;
		function set LockSelected(val:Boolean):void;
		function get LockSelected():Boolean;
		function UpdateBg():void;
		function get SceneType():int;
    }
}