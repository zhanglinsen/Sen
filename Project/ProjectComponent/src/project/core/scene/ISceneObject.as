package project.core.scene
{

    public interface ISceneObject
    {
        function Blur():void;
        function Focus():void;
        function get Ident():int;
        function Select():void;
        function get Selected():Boolean;
        function UnSelect():void;
    }
}