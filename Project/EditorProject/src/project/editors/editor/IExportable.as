package project.editors.editor
{

    public interface IExportable
    {
        function Export():XML;
		function Parse( xml:XML ):void;
    }
}