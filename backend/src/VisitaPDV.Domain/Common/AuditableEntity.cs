namespace VisitaPDV.Domain.Common;

public abstract class AuditableEntity : BaseEntity
{
    public string CreatedBy { get; set; } = string.Empty;
    public string? UpdatedBy { get; set; }
}
