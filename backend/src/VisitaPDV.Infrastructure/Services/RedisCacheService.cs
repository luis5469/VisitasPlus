using System.Text.Json;
using Microsoft.Extensions.Caching.Distributed;
using VisitaPDV.Application.Common.Interfaces;

namespace VisitaPDV.Infrastructure.Services;

public sealed class RedisCacheService(IDistributedCache cache) : ICacheService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy        = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true
    };

    public async Task<T?> GetAsync<T>(string key, CancellationToken ct = default) where T : class
    {
        var bytes = await cache.GetAsync(key, ct);
        if (bytes is null || bytes.Length == 0)
            return null;

        return JsonSerializer.Deserialize<T>(bytes, JsonOptions);
    }

    public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null, CancellationToken ct = default) where T : class
    {
        var opts = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = expiry ?? TimeSpan.FromMinutes(5)
        };

        var bytes = JsonSerializer.SerializeToUtf8Bytes(value, JsonOptions);
        await cache.SetAsync(key, bytes, opts, ct);
    }

    public async Task RemoveAsync(string key, CancellationToken ct = default)
        => await cache.RemoveAsync(key, ct);

    public async Task RemoveByPrefixAsync(string prefix, CancellationToken ct = default)
    {
        // IDistributedCache no soporta búsqueda por prefijo de forma nativa.
        // Implementación vacía compatible; si se necesita scan use StackExchange.Redis directamente.
        await Task.CompletedTask;
    }
}
