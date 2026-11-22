namespace VisitaPDV.Application.Common.Interfaces;

/// <summary>Servicio para subir y obtener imágenes en Azure Blob Storage.</summary>
public interface IAzureBlobService
{
    /// <summary>Sube un archivo y devuelve la URL pública (o SAS si está configurado).</summary>
    Task<string> UploadAsync(
        Stream fileStream,
        string fileName,
        string contentType,
        string containerName = "novedades",
        CancellationToken ct = default);

    /// <summary>Genera una URL firmada (SAS) válida por <paramref name="validMinutes"/> minutos.</summary>
    Task<string> GetSasUrlAsync(
        string blobName,
        string containerName = "novedades",
        int validMinutes = 60,
        CancellationToken ct = default);

    /// <summary>Elimina un blob por su nombre.</summary>
    Task DeleteAsync(string blobName, string containerName = "novedades", CancellationToken ct = default);
}
