using System;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using VisitaPDV.Application.Common.Interfaces;

namespace VisitaPDV.Infrastructure.Services;

/// <summary>
/// Servicio Firebase Cloud Messaging usando el Admin SDK.
/// Configuración requerida:
///   "Firebase": { "CredentialsPath": "ruta/a/serviceAccount.json" }
/// </summary>
public sealed class FirebaseNotificationService : IFirebaseNotificationService
{
    private readonly FirebaseMessaging? _messaging;
    private readonly ILogger<FirebaseNotificationService> _logger;
    private readonly bool _isEnabled;

    public FirebaseNotificationService(
        IConfiguration config,
        ILogger<FirebaseNotificationService> logger)
    {
        _logger = logger;

        try
        {
            if (FirebaseApp.DefaultInstance is null)
            {
                var credPath = config["Firebase:CredentialsPath"];
                GoogleCredential credential;

                if (!string.IsNullOrWhiteSpace(credPath) && File.Exists(credPath))
                {
                    credential = GoogleCredential.FromFile(credPath);
                    FirebaseApp.Create(new AppOptions { Credential = credential });
                    _isEnabled = true;
                }
                else
                {
                    _logger.LogWarning("Firebase CredentialsPath not configured or file not found. Firebase notifications will be disabled.");
                    _isEnabled = false;
                }
            }
            else
            {
                _isEnabled = true;
            }

            if (_isEnabled)
            {
                _messaging = FirebaseMessaging.DefaultInstance;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to initialize FirebaseAdmin. Firebase notifications will be disabled.");
            _isEnabled = false;
        }
    }

    public async Task SendAsync(
        string deviceToken,
        string titulo,
        string cuerpo,
        Dictionary<string, string>? datos = null,
        CancellationToken ct = default)
    {
        if (!_isEnabled || _messaging is null)
        {
            _logger.LogWarning("Firebase notification skipped (service disabled): {Titulo}", titulo);
            return;
        }

        try
        {
            var message = new Message
            {
                Token = deviceToken,
                Notification = new Notification { Title = titulo, Body = cuerpo },
                Data = datos ?? new Dictionary<string, string>(),
                Android = new AndroidConfig { Priority = Priority.High }
            };
            await _messaging.SendAsync(message, ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error enviando push a token {Token}", deviceToken[..Math.Min(8, deviceToken.Length)] + "...");
        }
    }

    public async Task SendMulticastAsync(
        IEnumerable<string> deviceTokens,
        string titulo,
        string cuerpo,
        Dictionary<string, string>? datos = null,
        CancellationToken ct = default)
    {
        if (!_isEnabled || _messaging is null)
        {
            _logger.LogWarning("Firebase notification multicast skipped (service disabled): {Titulo}", titulo);
            return;
        }

        var tokens = deviceTokens.ToList();
        if (tokens.Count == 0) return;

        try
        {
            var message = new MulticastMessage
            {
                Tokens = tokens,
                Notification = new Notification { Title = titulo, Body = cuerpo },
                Data = datos ?? new Dictionary<string, string>(),
                Android = new AndroidConfig { Priority = Priority.High }
            };
            var result = await _messaging.SendEachForMulticastAsync(message, ct);
            _logger.LogInformation("FCM multicast: {Success}/{Total} enviados",
                result.SuccessCount, tokens.Count);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error enviando push multicast");
        }
    }

    public async Task SendToTopicAsync(
        string topic,
        string titulo,
        string cuerpo,
        Dictionary<string, string>? datos = null,
        CancellationToken ct = default)
    {
        if (!_isEnabled || _messaging is null)
        {
            _logger.LogWarning("Firebase notification to topic skipped (service disabled): {Topic}", topic);
            return;
        }

        try
        {
            var message = new Message
            {
                Topic = topic,
                Notification = new Notification { Title = titulo, Body = cuerpo },
                Data = datos ?? new Dictionary<string, string>()
            };
            await _messaging.SendAsync(message, ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error enviando push a topic {Topic}", topic);
        }
    }
}
