using ClosedXML.Excel;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Dashboard.Dtos;

namespace VisitaPDV.Infrastructure.Services;

public sealed class ExportService : IExportService
{
    public Task<ExportResultDto> ExportDashboardToPdfAsync(DashboardResumenDto data, CancellationToken ct = default)
    {
        QuestPDF.Settings.License = LicenseType.Community;

        var bytes = Document.Create(container =>        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.DefaultTextStyle(x => x.FontSize(10));

                page.Header().Column(col =>
                {
                    col.Item().Text("Dashboard Ejecutivo — VisitaPDV")
                        .Bold().FontSize(18).FontColor(Colors.Blue.Darken2);
                    col.Item().Text($"Período: {data.Desde:dd/MM/yyyy} – {data.Hasta:dd/MM/yyyy}")
                        .FontSize(10).FontColor(Colors.Grey.Darken1);
                    col.Item().LineHorizontal(1).LineColor(Colors.Blue.Lighten2);
                });

                page.Content().PaddingTop(10).Column(col =>
                {
                    // KPIs
                    col.Item().Text("KPIs Principales").Bold().FontSize(13);
                    col.Item().PaddingTop(5).Table(table =>
                    {
                        table.ColumnsDefinition(c =>
                        {
                            c.RelativeColumn(3);
                            c.RelativeColumn(2);
                        });

                        void AddRow(string label, string value)
                        {
                            table.Cell().Padding(4).Text(label);
                            table.Cell().Padding(4).Text(value).Bold();
                        }

                        AddRow("Novedades Abiertas",                data.Kpis.NovedadesAbiertas.ToString());
                        AddRow("Novedades Vencidas",                data.Kpis.NovedadesVencidas.ToString());
                        AddRow("Tiempo Promedio Resolución (h)",    $"{data.Kpis.TiempoResolucionPromedioHoras:N1}");
                        AddRow("Visitas Ejecutadas",                data.Kpis.VisitasEjecutadas.ToString());
                        AddRow("Cumplimiento Agenda",               $"{data.Kpis.PorcentajeCumplimientoAgenda:N1}%");
                        AddRow("Total Agendado",                    data.Kpis.TotalAgendado.ToString());
                        AddRow("Total Novedades en Período",        data.Kpis.TotalNovedades.ToString());
                    });

                    col.Item().PaddingTop(15).Text("Incidencias por Categoría").Bold().FontSize(13);
                    col.Item().PaddingTop(5).Table(table =>
                    {
                        table.ColumnsDefinition(c =>
                        {
                            c.RelativeColumn(4);
                            c.RelativeColumn(1);
                            c.RelativeColumn(1);
                            c.RelativeColumn(1);
                            c.RelativeColumn(1);
                        });

                        // Header
                        foreach (var h in new[] { "Categoría", "Total", "Abiertas", "Resueltas", "Vencidas" })
                            table.Cell().Background(Colors.Blue.Lighten4).Padding(4).Text(h).Bold();

                        foreach (var cat in data.IncidenciasPorCategoria)
                        {
                            table.Cell().Padding(4).Text(cat.Categoria);
                            table.Cell().Padding(4).Text(cat.Total.ToString());
                            table.Cell().Padding(4).Text(cat.Abiertas.ToString());
                            table.Cell().Padding(4).Text(cat.Resueltas.ToString());
                            table.Cell().Padding(4).Text(cat.Vencidas.ToString());
                        }
                    });

                    col.Item().PaddingTop(15).Text("Eficiencia por Visitador").Bold().FontSize(13);
                    col.Item().PaddingTop(5).Table(table =>
                    {
                        table.ColumnsDefinition(c =>
                        {
                            c.RelativeColumn(4);
                            c.RelativeColumn(2);
                            c.RelativeColumn(2);
                            c.RelativeColumn(2);
                        });

                        foreach (var h in new[] { "Visitador", "Visitas", "Cumplimiento", "T.Prom(min)" })
                            table.Cell().Background(Colors.Blue.Lighten4).Padding(4).Text(h).Bold();

                        foreach (var v in data.EficienciaPorVisitador)
                        {
                            table.Cell().Padding(4).Text(v.NombreCompleto);
                            table.Cell().Padding(4).Text(v.VisitasCompletadas.ToString());
                            table.Cell().Padding(4).Text($"{v.PorcentajeCumplimiento:N1}%");
                            table.Cell().Padding(4).Text($"{v.TiempoPromedioVisitaMinutos:N1}");
                        }
                    });

                    if (data.AlertasActivas.Any())
                    {
                        col.Item().PaddingTop(15).Text("Alertas Activas (Novedades Vencidas)").Bold().FontSize(13)
                            .FontColor(Colors.Red.Darken2);
                        col.Item().PaddingTop(5).Table(table =>
                        {
                            table.ColumnsDefinition(c =>
                            {
                                c.RelativeColumn(4);
                                c.RelativeColumn(2);
                                c.RelativeColumn(2);
                                c.RelativeColumn(2);
                            });

                            foreach (var h in new[] { "Novedad", "Categoría", "PDV", "Días Vencida" })
                                table.Cell().Background(Colors.Red.Lighten4).Padding(4).Text(h).Bold();

                            foreach (var a in data.AlertasActivas)
                            {
                                table.Cell().Padding(4).Text(a.Titulo);
                                table.Cell().Padding(4).Text(a.Categoria);
                                table.Cell().Padding(4).Text(a.NombrePdv);
                                table.Cell().Padding(4).Text(a.DiasVencida.ToString()).FontColor(Colors.Red.Medium);
                            }
                        });
                    }
                });

                page.Footer().AlignCenter()
                    .Text(t =>
                    {
                        t.Span("Generado: ").FontSize(8).FontColor(Colors.Grey.Medium);
                        t.Span(DateTime.Now.ToString("dd/MM/yyyy HH:mm")).FontSize(8);
                        t.Span("   Página ").FontSize(8);
                        t.CurrentPageNumber().FontSize(8);
                        t.Span(" de ").FontSize(8);
                        t.TotalPages().FontSize(8);
                    });
            });
        }).GeneratePdf();

        return Task.FromResult(new ExportResultDto(
            Contenido:      bytes,
            ContentType:    "application/pdf",
            NombreArchivo:  $"dashboard_{data.Desde:yyyyMMdd}_{data.Hasta:yyyyMMdd}.pdf"
        ));
    }

    public Task<ExportResultDto> ExportDashboardToExcelAsync(DashboardResumenDto data, CancellationToken ct = default)
    {
        using var workbook = new XLWorkbook();

        // ── Hoja 1: KPIs ─────────────────────────────────────────
        var wsKpi = workbook.Worksheets.Add("KPIs");
        wsKpi.Cell(1, 1).Value = "Dashboard Ejecutivo – VisitaPDV";
        wsKpi.Cell(1, 1).Style.Font.Bold = true;
        wsKpi.Cell(1, 1).Style.Font.FontSize = 16;
        wsKpi.Range(1, 1, 1, 2).Merge();

        wsKpi.Cell(2, 1).Value = $"Período: {data.Desde:dd/MM/yyyy} – {data.Hasta:dd/MM/yyyy}";
        wsKpi.Range(2, 1, 2, 2).Merge();

        var kpiRows = new (string Label, object Value)[]
        {
            ("Novedades Abiertas",               data.Kpis.NovedadesAbiertas),
            ("Novedades Vencidas",               data.Kpis.NovedadesVencidas),
            ("Tiempo Prom. Resolución (h)",      data.Kpis.TiempoResolucionPromedioHoras),
            ("Visitas Ejecutadas",               data.Kpis.VisitasEjecutadas),
            ("Cumplimiento Agenda (%)",          data.Kpis.PorcentajeCumplimientoAgenda),
            ("Total Agendado",                   data.Kpis.TotalAgendado),
            ("Total Novedades en Período",       data.Kpis.TotalNovedades),
        };

        for (int i = 0; i < kpiRows.Length; i++)
        {
            wsKpi.Cell(i + 4, 1).Value = kpiRows[i].Label;
            wsKpi.Cell(i + 4, 2).Value = XLCellValue.FromObject(kpiRows[i].Value);
            wsKpi.Cell(i + 4, 1).Style.Fill.BackgroundColor = XLColor.LightSkyBlue;
        }

        wsKpi.Columns().AdjustToContents();

        // ── Hoja 2: Incidencias por Categoría ────────────────────
        var wsCat = workbook.Worksheets.Add("Por Categoría");
        var catHeaders = new[] { "Categoría", "Total", "Abiertas", "Resueltas", "Vencidas" };
        for (int c = 0; c < catHeaders.Length; c++)
        {
            wsCat.Cell(1, c + 1).Value = catHeaders[c];
            wsCat.Cell(1, c + 1).Style.Font.Bold = true;
            wsCat.Cell(1, c + 1).Style.Fill.BackgroundColor = XLColor.SteelBlue;
            wsCat.Cell(1, c + 1).Style.Font.FontColor = XLColor.White;
        }

        int row = 2;
        foreach (var cat in data.IncidenciasPorCategoria)
        {
            wsCat.Cell(row, 1).Value = cat.Categoria;
            wsCat.Cell(row, 2).Value = cat.Total;
            wsCat.Cell(row, 3).Value = cat.Abiertas;
            wsCat.Cell(row, 4).Value = cat.Resueltas;
            wsCat.Cell(row, 5).Value = cat.Vencidas;
            row++;
        }

        wsCat.Columns().AdjustToContents();

        // ── Hoja 3: Eficiencia por Visitador ─────────────────────
        var wsEf = workbook.Worksheets.Add("Eficiencia Visitador");
        var efHeaders = new[] { "Visitador", "Visitas Completadas", "Visitas Agendadas",
            "Cumplimiento (%)", "Novedades", "Nov. Resueltas", "T.Prom Visita (min)" };

        for (int c = 0; c < efHeaders.Length; c++)
        {
            wsEf.Cell(1, c + 1).Value = efHeaders[c];
            wsEf.Cell(1, c + 1).Style.Font.Bold = true;
            wsEf.Cell(1, c + 1).Style.Fill.BackgroundColor = XLColor.SteelBlue;
            wsEf.Cell(1, c + 1).Style.Font.FontColor = XLColor.White;
        }

        row = 2;
        foreach (var v in data.EficienciaPorVisitador)
        {
            wsEf.Cell(row, 1).Value = v.NombreCompleto;
            wsEf.Cell(row, 2).Value = v.VisitasCompletadas;
            wsEf.Cell(row, 3).Value = v.VisitasAgendadas;
            wsEf.Cell(row, 4).Value = v.PorcentajeCumplimiento;
            wsEf.Cell(row, 5).Value = v.NovedadesRegistradas;
            wsEf.Cell(row, 6).Value = v.NovedadesResueltas;
            wsEf.Cell(row, 7).Value = v.TiempoPromedioVisitaMinutos;
            row++;
        }

        wsEf.Columns().AdjustToContents();

        // ── Hoja 4: Alertas Activas ────────────────────────────
        var wsAl = workbook.Worksheets.Add("Alertas");
        var alHeaders = new[] { "Novedad", "Categoría", "Prioridad", "PDV",
            "Fecha Seguimiento", "Días Vencida", "Responsable" };

        for (int c = 0; c < alHeaders.Length; c++)
        {
            wsAl.Cell(1, c + 1).Value = alHeaders[c];
            wsAl.Cell(1, c + 1).Style.Font.Bold = true;
            wsAl.Cell(1, c + 1).Style.Fill.BackgroundColor = XLColor.Red;
            wsAl.Cell(1, c + 1).Style.Font.FontColor = XLColor.White;
        }

        row = 2;
        foreach (var a in data.AlertasActivas)
        {
            wsAl.Cell(row, 1).Value = a.Titulo;
            wsAl.Cell(row, 2).Value = a.Categoria;
            wsAl.Cell(row, 3).Value = a.Prioridad;
            wsAl.Cell(row, 4).Value = a.NombrePdv;
            wsAl.Cell(row, 5).Value = a.FechaSeguimiento.ToString("dd/MM/yyyy");
            wsAl.Cell(row, 6).Value = a.DiasVencida;
            wsAl.Cell(row, 7).Value = a.ResponsableNombre;
            row++;
        }

        wsAl.Columns().AdjustToContents();

        // ── Hoja 5: Timeline ─────────────────────────────────────
        var wsTime = workbook.Worksheets.Add("Timeline");
        var timeHeaders = new[] { "Fecha", "Abiertas", "En Progreso", "Resueltas", "Cerradas" };
        for (int c = 0; c < timeHeaders.Length; c++)
        {
            wsTime.Cell(1, c + 1).Value = timeHeaders[c];
            wsTime.Cell(1, c + 1).Style.Font.Bold = true;
            wsTime.Cell(1, c + 1).Style.Fill.BackgroundColor = XLColor.SteelBlue;
            wsTime.Cell(1, c + 1).Style.Font.FontColor = XLColor.White;
        }

        row = 2;
        foreach (var t in data.Timeline)
        {
            wsTime.Cell(row, 1).Value = t.Fecha.ToString("dd/MM/yyyy");
            wsTime.Cell(row, 2).Value = t.Abiertas;
            wsTime.Cell(row, 3).Value = t.EnProgreso;
            wsTime.Cell(row, 4).Value = t.Resueltas;
            wsTime.Cell(row, 5).Value = t.Cerradas;
            row++;
        }

        wsTime.Columns().AdjustToContents();

        using var ms = new MemoryStream();
        workbook.SaveAs(ms);
        return Task.FromResult(new ExportResultDto(
            Contenido:      ms.ToArray(),
            ContentType:    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            NombreArchivo:  $"dashboard_{data.Desde:yyyyMMdd}_{data.Hasta:yyyyMMdd}.xlsx"
        ));
    }
}
