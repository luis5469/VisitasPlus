namespace VisitaPDV.Application.Common.Models;

public sealed class PagedResult<T>
{
    public IEnumerable<T> Items { get; init; } = [];
    public int TotalCount { get; init; }
    public int Page { get; init; }
    public int PageSize { get; init; }
    public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
    public bool HasNextPage => Page < TotalPages;
    public bool HasPreviousPage => Page > 1;

    public static PagedResult<T> Create(IEnumerable<T> items, int total, int page, int size) =>
        new() { Items = items, TotalCount = total, Page = page, PageSize = size };
}
