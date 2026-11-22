namespace VisitaPDV.Application.Common.Interfaces;

/// <summary>Servicio de notificaciones push via Firebase Cloud Messaging.</summary>
public interface IFirebaseNotificationService
{
    /// <summary>Envía una notificación a un dispositivo específico.</summary>
    Task SendAsync(
        string deviceToken,
        string titulo,
        string cuerpo,
        Dictionary<string, string>? datos = null,
        CancellationToken ct = default);

    /// <summary>Envía una notificación a múltiples dispositivos.</summary>
    Task SendMulticastAsync(
        IEnumerable<string> deviceTokens,
        string titulo,
        string cuerpo,
        Dictionary<string, string>? datos = null,
        CancellationToken ct = default);

    /// <summary>Envía a un tema (topic) de FCM.</summary>
    Task SendToTopicAsync(
        string topic,
        string titulo,
        string cuerpo,
        Dictionary<string, string>? datos = null,
        CancellationToken ct = default);
}
