using MediatR;
using System.Threading;
using System.Threading.Tasks;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Novedades.Commands;

namespace VisitaPDV.Application.Features.Novedades.Handlers;

public sealed class AnalizarNovedadCommandHandler(IGeminiService geminiService)
    : IRequestHandler<AnalizarNovedadCommand, NovedadAnalisisResult>
{
    public async Task<NovedadAnalisisResult> Handle(AnalizarNovedadCommand request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Descripcion))
        {
            throw new System.ArgumentException("La descripción no puede estar vacía.", nameof(request.Descripcion));
        }

        return await geminiService.AnalizarNovedadAsync(request.Descripcion, cancellationToken);
    }
}
