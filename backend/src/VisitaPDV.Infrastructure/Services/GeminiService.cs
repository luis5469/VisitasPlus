using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using VisitaPDV.Application.Common.Interfaces;

namespace VisitaPDV.Infrastructure.Services;

public class GeminiService : IGeminiService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<GeminiService> _logger;
    private readonly string _apiKey;
    private readonly string _model;

    public GeminiService(HttpClient httpClient, IConfiguration configuration, ILogger<GeminiService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
        _apiKey = configuration["GeminiSettings:ApiKey"] ?? string.Empty;
        _model = configuration["GeminiSettings:Model"] ?? "gemini-1.5-flash";
    }

    public async Task<NovedadAnalisisResult> AnalizarNovedadAsync(string descripcion, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(_apiKey))
        {
            _logger.LogError("La API Key de Gemini no está configurada en GeminiSettings:ApiKey.");
            throw new System.InvalidOperationException("Configuración de IA no disponible.");
        }

        var systemPrompt = "Analiza la siguiente novedad de visita registrada en un punto de venta (farmacia) de Farmaenlace.\n" +
                            "Determina la categoría más apropiada. Puedes usar categorías existentes (Inventario, Limpieza, Exhibición, Precio, Equipamiento) o crear una nueva categoría corta personalizada (de 1 o 2 palabras, ej: Sistemas, Infraestructura, Talento Humano) según corresponda.\n" +
                            "Determina la prioridad de criticidad (Baja, Media, Alta o Crítica) según el impacto en la operación y riesgo para las personas.\n" +
                            "Genera un título corto y conciso que resuma la novedad y justifica tu decisión en una frase breve en español.\n" +
                            $"Novedad: \"{descripcion}\"";

        var payload = new
        {
            contents = new[]
            {
                new
                {
                    parts = new[]
                    {
                        new { text = systemPrompt }
                    }
                }
            },
            generationConfig = new
            {
                responseMimeType = "application/json",
                responseSchema = new
                {
                    type = "OBJECT",
                    properties = new
                    {
                        categoria = new { type = "STRING" },
                        prioridad = new { type = "STRING", @enum = new[] { "Baja", "Media", "Alta", "Crítica" } },
                        tituloSugerido = new { type = "STRING" },
                        justificacion = new { type = "STRING" }
                    },
                    required = new[] { "categoria", "prioridad", "tituloSugerido", "justificacion" }
                }
            }
        };

        var json = JsonSerializer.Serialize(payload);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        var url = $"https://generativelanguage.googleapis.com/v1beta/models/{_model}:generateContent?key={_apiKey}";
        
        _logger.LogInformation("Enviando petición a Gemini API ({Model})...", _model);

        var response = await _httpClient.PostAsync(url, content, ct);
        if (!response.IsSuccessStatusCode)
        {
            var errorContent = await response.Content.ReadAsStringAsync(ct);
            _logger.LogError("Error al llamar a la API de Gemini: {StatusCode} - {Error}", response.StatusCode, errorContent);
            throw new System.Exception($"Error en servicio de IA: {response.StatusCode}");
        }

        var responseJson = await response.Content.ReadAsStringAsync(ct);
        
        using var doc = JsonDocument.Parse(responseJson);
        var textResult = doc.RootElement
            .GetProperty("candidates")[0]
            .GetProperty("content")
            .GetProperty("parts")[0]
            .GetProperty("text")
            .GetString();

        if (string.IsNullOrWhiteSpace(textResult))
        {
            throw new System.Exception("Respuesta vacía de la API de Gemini.");
        }

        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var analysis = JsonSerializer.Deserialize<GeminiAnalysisJsonResult>(textResult, options);

        if (analysis == null)
        {
            throw new System.Exception("No se pudo deserializar la respuesta del análisis de Gemini.");
        }

        return new NovedadAnalisisResult(
            analysis.Categoria,
            analysis.Prioridad,
            analysis.TituloSugerido,
            analysis.Justificacion
        );
    }

    public async Task<string> AnonimizarTextoAsync(string texto, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(_apiKey))
        {
            _logger.LogError("La API Key de Gemini no está configurada en GeminiSettings:ApiKey.");
            throw new System.InvalidOperationException("Configuración de IA no disponible.");
        }

        if (string.IsNullOrWhiteSpace(texto)) return string.Empty;

        var systemPrompt = "Eres un agente experto en cumplimiento de la LOPDP (Ley Orgánica de Protección de Datos Personales de Ecuador). " +
                            "Tu tarea es recibir el siguiente texto de una novedad de visita registrada en una farmacia y anonimizar cualquier dato personal que identifique a una persona natural " +
                            "(nombres, apellidos, direcciones físicas completas, números de cuenta, cédulas o cualquier dato sensible). " +
                            "Reemplaza únicamente estos datos personales con etiquetas en mayúsculas entre corchetes, por ejemplo: [NOMBRE_ANONIMIZADO], [DIRECCION_ANONIMIZADA]. " +
                            "Conserva el resto del texto descriptivo intacto sin cambiar el significado técnico ni los nombres de los productos o farmacias. " +
                            "Debes retornar la respuesta en el formato JSON estructurado solicitado.\n" +
                            $"Texto a anonimizar: \"{texto}\"";

        var payload = new
        {
            contents = new[]
            {
                new
                {
                    parts = new[]
                    {
                        new { text = systemPrompt }
                    }
                }
            },
            generationConfig = new
            {
                responseMimeType = "application/json",
                responseSchema = new
                {
                    type = "OBJECT",
                    properties = new
                    {
                        textoAnonimizado = new { type = "STRING" }
                    },
                    required = new[] { "textoAnonimizado" }
                }
            }
        };

        var json = JsonSerializer.Serialize(payload);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        var url = $"https://generativelanguage.googleapis.com/v1beta/models/{_model}:generateContent?key={_apiKey}";
        
        _logger.LogInformation("Enviando petición de anonimización a Gemini API ({Model})...", _model);

        var response = await _httpClient.PostAsync(url, content, ct);
        if (!response.IsSuccessStatusCode)
        {
            var errorContent = await response.Content.ReadAsStringAsync(ct);
            _logger.LogError("Error al llamar a la API de Gemini para anonimización: {StatusCode} - {Error}", response.StatusCode, errorContent);
            throw new System.Exception($"Error en servicio de IA para anonimización: {response.StatusCode}");
        }

        var responseJson = await response.Content.ReadAsStringAsync(ct);
        
        using var doc = JsonDocument.Parse(responseJson);
        var textResult = doc.RootElement
            .GetProperty("candidates")[0]
            .GetProperty("content")
            .GetProperty("parts")[0]
            .GetProperty("text")
            .GetString();

        if (string.IsNullOrWhiteSpace(textResult))
        {
            throw new System.Exception("Respuesta vacía de la API de Gemini.");
        }

        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var resultJson = JsonSerializer.Deserialize<GeminiAnonymizeJsonResult>(textResult, options);

        if (resultJson == null)
        {
            throw new System.Exception("No se pudo deserializar la respuesta de la anonimización de Gemini.");
        }

        return resultJson.TextoAnonimizado;
    }

    private class GeminiAnalysisJsonResult
    {
        public string Categoria { get; set; } = string.Empty;
        public string Prioridad { get; set; } = string.Empty;
        public string TituloSugerido { get; set; } = string.Empty;
        public string Justificacion { get; set; } = string.Empty;
    }

    private class GeminiAnonymizeJsonResult
    {
        public string TextoAnonimizado { get; set; } = string.Empty;
    }
}
