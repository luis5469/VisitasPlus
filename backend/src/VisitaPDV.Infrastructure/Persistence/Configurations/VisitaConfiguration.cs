using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;

namespace VisitaPDV.Infrastructure.Persistence.Configurations;

public sealed class VisitaConfiguration : IEntityTypeConfiguration<Visita>
{
    public void Configure(EntityTypeBuilder<Visita> builder)
    {
        builder.ToTable("Visitas");
        builder.HasKey(v => v.Id);
        builder.Property(v => v.Id).ValueGeneratedNever();

        builder.Property(v => v.PdvId).IsRequired();
        builder.Property(v => v.VisitadorId).IsRequired();
        builder.Property(v => v.Estado)
               .HasDefaultValue(VisitStatus.EnCurso);

        builder.Property(v => v.LatitudInicio).HasColumnType("decimal(10,7)");
        builder.Property(v => v.LongitudInicio).HasColumnType("decimal(10,7)");
        builder.Property(v => v.LatitudFin).HasColumnType("decimal(10,7)");
        builder.Property(v => v.LongitudFin).HasColumnType("decimal(10,7)");
        builder.Property(v => v.TimestampInicio).IsRequired();
        builder.Property(v => v.ActaPdfUrl).HasMaxLength(500);
        builder.Property(v => v.Sincronizado).HasDefaultValue(true);

        // Índice para búsqueda de visita activa por visitador
        builder.HasIndex(v => new { v.VisitadorId, v.Estado });

        builder.HasOne(v => v.Pdv)
               .WithMany(p => p.Visitas)
               .HasForeignKey(v => v.PdvId)
               .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(v => v.Visitador)
               .WithMany(u => u.Visitas)
               .HasForeignKey(v => v.VisitadorId)
               .OnDelete(DeleteBehavior.Restrict);
    }
}
