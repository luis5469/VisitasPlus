using MediatR;
using Microsoft.Extensions.Logging;

namespace VisitaPDV.Application.Common.Behaviours;

public sealed class LoggingBehaviour<TRequest, TResponse>(
    ILogger<LoggingBehaviour<TRequest, TResponse>> logger)
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        var name = typeof(TRequest).Name;
        logger.LogInformation("VisitaPDV Request: {Name} {@Request}", name, request);

        var result = await next();

        logger.LogInformation("VisitaPDV Response: {Name} {@Response}", name, result);
        return result;
    }
}
