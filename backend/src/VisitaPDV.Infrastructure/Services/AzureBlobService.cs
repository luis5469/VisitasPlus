using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Sas;
using Microsoft.Extensions.Configuration;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Processing;
using VisitaPDV.Application.Common.Interfaces;

namespace VisitaPDV.Infrastructure.Services;

/// <summary>
/// Implementación de Azure Blob Storage con compresión de imágenes via ImageSharp.
/// Configuración requerida en appsettings.json:
///   "AzureBlob": { "ConnectionString": "...", "AccountName": "...", "AccountKey": "..." }
/// </summary>
public sealed class AzureBlobService : IAzureBlobService
{
    private readonly BlobServiceClient? _client;
    private readonly string _accountName;
    private readonly string _accountKey;
    private const int MaxWidthPx = 1920;
    private const int JpegQuality = 80;

    public AzureBlobService(IConfiguration config)
    {
        var section = config.GetSection("AzureBlob");
        var connectionString = section["ConnectionString"];
        _accountName = section["AccountName"] ?? string.Empty;
        _accountKey = section["AccountKey"] ?? string.Empty;
        
        if (!string.IsNullOrEmpty(connectionString))
        {
            _client = new BlobServiceClient(connectionString);
        }
        else
        {
            _client = null;
        }
    }

    public async Task<string> UploadAsync(
        Stream fileStream,
        string fileName,
        string contentType,
        string containerName = "novedades",
        CancellationToken ct = default)
    {
        if (_client == null)
        {
            // Devuelve una URL Picsum aleatoria con semilla para mock offline
            var mockSeed = Guid.NewGuid().ToString("N").Substring(0, 8);
            return $"https://picsum.photos/seed/{mockSeed}/800/600";
        }

        var container = _client.GetBlobContainerClient(containerName);
        await container.CreateIfNotExistsAsync(PublicAccessType.None, cancellationToken: ct);

        Stream uploadStream = fileStream;

        // Comprimir si es imagen
        if (contentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
            uploadStream = await ComprimirImagenAsync(fileStream, ct);

        var blob = container.GetBlobClient(fileName);
        uploadStream.Position = 0;
        await blob.UploadAsync(uploadStream, new BlobHttpHeaders { ContentType = contentType }, cancellationToken: ct);

        if (uploadStream != fileStream) await uploadStream.DisposeAsync();

        return blob.Uri.ToString();
    }

    public Task<string> GetSasUrlAsync(
        string blobName,
        string containerName = "novedades",
        int validMinutes = 60,
        CancellationToken ct = default)
    {
        if (_client == null)
        {
            // Retorna la misma URL si es mock (comienza por http) o picsum con semilla del nombre
            if (blobName.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                return Task.FromResult(blobName);

            return Task.FromResult($"https://picsum.photos/seed/{blobName.GetHashCode()}/800/600");
        }

        var container = _client.GetBlobContainerClient(containerName);
        var blob = container.GetBlobClient(blobName);

        if (!blob.CanGenerateSasUri)
        {
            // Construir SAS manualmente con StorageSharedKeyCredential
            var sasBuilder = new BlobSasBuilder
            {
                BlobContainerName = containerName,
                BlobName = blobName,
                Resource = "b",
                ExpiresOn = DateTimeOffset.UtcNow.AddMinutes(validMinutes)
            };
            sasBuilder.SetPermissions(BlobSasPermissions.Read);

            var cred = new Azure.Storage.StorageSharedKeyCredential(_accountName, _accountKey);
            var sasUri = new UriBuilder(blob.Uri)
            {
                Query = sasBuilder.ToSasQueryParameters(cred).ToString()
            };
            return Task.FromResult(sasUri.Uri.ToString());
        }

        var sasBuilderDirect = new BlobSasBuilder
        {
            BlobContainerName = containerName,
            BlobName = blobName,
            Resource = "b",
            ExpiresOn = DateTimeOffset.UtcNow.AddMinutes(validMinutes)
        };
        sasBuilderDirect.SetPermissions(BlobSasPermissions.Read);
        return Task.FromResult(blob.GenerateSasUri(sasBuilderDirect).ToString());
    }

    public async Task DeleteAsync(
        string blobName,
        string containerName = "novedades",
        CancellationToken ct = default)
    {
        if (_client == null) return;

        var container = _client.GetBlobContainerClient(containerName);
        var blob = container.GetBlobClient(blobName);
        await blob.DeleteIfExistsAsync(cancellationToken: ct);
    }

    // ─── helpers ─────────────────────────────────────────────────────────────
    private static async Task<Stream> ComprimirImagenAsync(Stream input, CancellationToken ct)
    {
        var output = new MemoryStream();
        using var image = await Image.LoadAsync(input, ct);

        if (image.Width > MaxWidthPx)
            image.Mutate(x => x.Resize(new ResizeOptions
            {
                Mode = ResizeMode.Max,
                Size = new Size(MaxWidthPx, 0)
            }));

        await image.SaveAsJpegAsync(output, new JpegEncoder { Quality = JpegQuality }, ct);
        output.Position = 0;
        return output;
    }
}
