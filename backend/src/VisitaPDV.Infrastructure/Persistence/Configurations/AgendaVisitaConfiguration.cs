using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Infrastructure.Persistence.Configurations;

public sealed class AgendaVisitaConfiguration : IEntityTypeConfiguration<AgendaVisita>
{
    public void Configure(EntityTypeBuilder<AgendaVisita> builder)
    {
        builder.ToTable("AgendaVisitas");
        builder.HasKey(a => a.Id);
        builder.Property(a => a.Id).ValueGeneratedNever();

        builder.Property(a => a.PdvId).IsRequired();
        builder.Property(a => a.VisitadorId).IsRequired();
        builder.Property(a => a.FechaPlaneada).IsRequired();
        builder.Property(a => a.Observaciones).HasMaxLength(500);
        builder.Property(a => a.Completada).HasDefaultValue(false);

        builder.HasOne(a => a.Pdv)
               .WithMany(p => p.AgendaVisitas)
               .HasForeignKey(a => a.PdvId)
               .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.Visitador)
               .WithMany()
               .HasForeignKey(a => a.VisitadorId)
               .OnDelete(DeleteBehavior.Restrict);
    }
}
