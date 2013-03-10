package project.editors.editor
{
    import flash.filesystem.File;
    public interface IEditor
    {
		function Init():void;
		
        function Export():XML;

        function Import( file:File ):void;

        function Reload():void;

        function Save():void;
		
        function SaveAs( file:File ):void;
		
		function get FileName():String;
    }
}