using System.Net;
using System.Text.Json;
using FluentValidation;
using Microsoft.Data.SqlClient;
using VisitaPDV.Application.Common.Models;
using VisitaPDV.Domain.Exceptions;

namespace VisitaPDV.API.Middleware;

public sealed class GlobalExceptionMiddleware(
    RequestDelegate next,
    ILogger<GlobalExceptionMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            LogException(logger, ex);
            await HandleExceptionAsync(context, ex);
        }
    }

    private static void LogException(ILogger logger, Exception exception)
    {
        switch (exception)
        {
            case ValidationException:
                logger.LogWarning(exception, "Error de validación: {Message}", exception.Message);
                break;

            case NotFoundException:
                logger.LogInformation(exception, "Recurso no encontrado: {Message}", exception.Message);
                break;

            case DomainException:
                logger.LogInformation(exception, "Regla de negocio rechazada: {Message}", exception.Message);
                break;

            case UnauthorizedAccessException:
                logger.LogWarning(exception, "Acceso no autorizado: {Message}", exception.Message);
                break;

            case SqlException sqlException when IsMissingObjectException(sqlException):
                logger.LogWarning(sqlException, "Objeto SQL faltante: {Message}", sqlException.Message);
                break;

            default:
                logger.LogError(exception, "Excepción no controlada: {Message}", exception.Message);
                break;
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var (status, response) = exception switch
        {
            ValidationException ve => (
                HttpStatusCode.BadRequest,
                ApiResponse.Fail(string.Join("; ", ve.Errors.Select(e => e.ErrorMessage)))),

            NotFoundException nfe => (
                HttpStatusCode.NotFound,
                ApiResponse.Fail(nfe.Message)),

            DomainException de => (
                HttpStatusCode.UnprocessableEntity,
                ApiResponse.Fail(de.Message)),

            UnauthorizedAccessException => (
                HttpStatusCode.Unauthorized,
                ApiResponse.Fail("No autorizado.")),

            SqlException sqlException when IsMissingObjectException(sqlException) => (
                HttpStatusCode.ServiceUnavailable,
                ApiResponse.Fail(BuildMissingObjectMessage(sqlException))),

            _ => (
                HttpStatusCode.InternalServerError,
                ApiResponse.Fail("Ocurrió un error interno en el servidor."))
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)status;

        var json = JsonSerializer.Serialize(response,
            new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });

        return context.Response.WriteAsync(json);
    }

    private static bool IsMissingObjectException(SqlException exception)
        => exception.Message.Contains("El nombre de objeto", StringComparison.OrdinalIgnoreCase)
            && exception.Message.Contains("no es válido", StringComparison.OrdinalIgnoreCase);

    private static string BuildMissingObjectMessage(SqlException exception)
    {
        var objectName = TryExtractObjectName(exception.Message);
        return objectName is null
            ? "La base de datos no está alineada con el esquema esperado por la aplicación."
            : $"La base de datos no tiene el objeto requerido '{objectName}'. Debe actualizarse el esquema antes de usar esta pantalla.";
    }

    private static string? TryExtractObjectName(string message)
    {
        const string marker = "'";
        var start = message.IndexOf(marker, StringComparison.Ordinal);
        if (start < 0)
            return null;

        var end = message.IndexOf(marker, start + 1, StringComparison.Ordinal);
        if (end <= start)
            return null;

        return message.Substring(start + 1, end - start - 1);
    }
}
