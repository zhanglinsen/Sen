package project.core.factory
{

    public interface IFactory
    {
        function NewInstance():*;
		function get GeneratorClass():Class;
    }
}
