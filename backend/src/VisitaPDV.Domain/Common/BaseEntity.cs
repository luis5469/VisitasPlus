namespace VisitaPDV.Domain.Common;

public abstract class BaseEntity
{
    public string Id { get; protected set; } = Guid.NewGuid().ToString("N").Substring(0, 10);
    public DateTime CreatedAt { get; protected set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; protected set; } = DateTime.UtcNow;

    private readonly List<IDomainEvent> _domainEvents = [];
    public IReadOnlyCollection<IDomainEvent> DomainEvents => _domainEvents.AsReadOnly();

    protected void AddDomainEvent(IDomainEvent domainEvent) => _domainEvents.Add(domainEvent);
    public void ClearDomainEvents() => _domainEvents.Clear();

    public void SetCreatedAt(DateTime dateTime) => CreatedAt = dateTime;
    public void SetUpdatedAt(DateTime dateTime) => UpdatedAt = dateTime;
}
