using System;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using VisitaPDV.Application.Common.Interfaces;

namespace VisitaPDV.Infrastructure.Services;

public class AnonymizationService : IAnonymizationService
{
    private readonly IGeminiService _geminiService;
    private readonly ILogger<AnonymizationService> _logger;

    private static readonly Regex EmailRegex = new(
        @"[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*",
        RegexOptions.Compiled | RegexOptions.IgnoreCase);

    // Captura celulares (+5939xxxxxxxx, 09xxxxxxxx, 5939xxxxxxxx) y fijos ecuatorianos (02xxxxxxx, 03xxxxxxx, etc.)
    private static readonly Regex PhoneRegex = new(
        @"\b(?:\+?593|0)(9\d{8}|[2-7]\d{7})\b",
        RegexOptions.Compiled);

    // Secuencias de 9 a 10 dígitos que representan posibles cédulas (con o sin guion)
    private static readonly Regex CedulaCandidateRegex = new(
        @"\b\d{9}-?\d\b",
        RegexOptions.Compiled);

    public AnonymizationService(IGeminiService geminiService, ILogger<AnonymizationService> logger)
    {
        _geminiService = geminiService;
        _logger = logger;
    }

    public async Task<string> AnonymizeTextAsync(string? text, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;

        // Capa 1: Filtro de Reglas Locales (Regex + Algoritmos deterministas)
        var filteredText = text;

        // 1. Anonimizar correos
        filteredText = EmailRegex.Replace(filteredText, "[EMAIL_ANONIMIZADO]");

        // 2. Anonimizar teléfonos
        filteredText = PhoneRegex.Replace(filteredText, "[TELEFONO_ANONIMIZADO]");

        // 3. Anonimizar Cédulas Ecuatorianas validadas por algoritmo
        filteredText = CedulaCandidateRegex.Replace(filteredText, match =>
        {
            var candidate = match.Value;
            if (ValidarCedulaEcuatoriana(candidate))
            {
                return "[CEDULA_ANONIMIZADA]";
            }
            return candidate;
        });

        // Capa 2: Filtro de IA (Gemini) para nombres, apellidos, direcciones, etc.
        try
        {
            _logger.LogInformation("Enviando texto pre-anonimizado a la Capa 2 (Gemini)...");
            var aiResult = await _geminiService.AnonimizarTextoAsync(filteredText, ct);
            if (!string.IsNullOrWhiteSpace(aiResult))
            {
                return aiResult;
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Fallo en la Capa 2 de anonimización (Gemini). Se utilizará la Capa 1 como fallback.");
        }

        return filteredText;
    }

    /// <summary>
    /// Algoritmo de validación de Cédula de Identidad Ecuatoriana (dígito verificador módulo 10).
    /// </summary>
    public static bool ValidarCedulaEcuatoriana(string cedula)
    {
        if (string.IsNullOrWhiteSpace(cedula)) return false;
        
        // Quitar guiones y espacios
        cedula = cedula.Replace("-", "").Replace(" ", "");
        if (cedula.Length != 10 || !cedula.All(char.IsDigit)) return false;

        // Validar código de provincia (primeros dos dígitos del 01 al 24, o 30 para extranjeros)
        var provincia = int.Parse(cedula.Substring(0, 2));
        if ((provincia < 1 || provincia > 24) && provincia != 30) return false;

        // Validar tercer dígito (debe ser menor a 6 para personas naturales)
        var tercerDigito = int.Parse(cedula.Substring(2, 1));
        if (tercerDigito >= 6) return false;

        int[] coeficientes = { 2, 1, 2, 1, 2, 1, 2, 1, 2 };
        int suma = 0;

        for (int i = 0; i < 9; i++)
        {
            int valor = int.Parse(cedula.Substring(i, 1)) * coeficientes[i];
            if (valor >= 10) valor -= 9;
            suma += valor;
        }

        int verificadorCalculado = (suma % 10 == 0) ? 0 : 10 - (suma % 10);
        int verificadorReal = int.Parse(cedula.Substring(9, 1));

        return verificadorCalculado == verificadorReal;
    }
}
