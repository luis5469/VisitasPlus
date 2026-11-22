namespace VisitaPDV.Domain.Exceptions;

public class NotFoundException : Exception
{
    public NotFoundException(string name, object key)
        : base($"'{name}' ({key}) no fue encontrado.") { }

    public NotFoundException(string message)
        : base(message) { }
}
