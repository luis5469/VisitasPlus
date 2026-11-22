using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;

namespace VisitaPDV.Infrastructure.Persistence.Configurations;

public sealed class NovedadConfiguration : IEntityTypeConfiguration<Novedad>
{
    public void Configure(EntityTypeBuilder<Novedad> builder)
    {
        builder.ToTable("Novedades");
        builder.HasKey(n => n.Id);
        builder.Property(n => n.Id).ValueGeneratedNever();

        builder.Property(n => n.VisitaId).IsRequired();
        builder.Property(n => n.PdvId).IsRequired();
        builder.Property(n => n.Titulo).IsRequired().HasMaxLength(200);
        builder.Property(n => n.Descripcion).IsRequired().HasMaxLength(2000);
        builder.Property(n => n.Categoria).HasMaxLength(100);
        builder.Property(n => n.Prioridad).HasMaxLength(50);
        builder.Property(n => n.Estado)
               .HasDefaultValue(NovedadStatus.Abierta);
        builder.Property(n => n.FechaSeguimiento).IsRequired();
        builder.Property(n => n.Sincronizado).HasDefaultValue(true);

        builder.HasOne(n => n.Visita)
               .WithMany(v => v.Novedades)
               .HasForeignKey(n => n.VisitaId)
               .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(n => n.Imagenes)
               .WithOne()
               .HasForeignKey(i => i.NovedadId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(n => n.Historial)
               .WithOne()
               .HasForeignKey(h => h.NovedadId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class NovedadImagenConfiguration : IEntityTypeConfiguration<NovedadImagen>
{
    public void Configure(EntityTypeBuilder<NovedadImagen> builder)
    {
        builder.ToTable("NovedadImagenes");
        builder.HasKey(i => i.Id);
        builder.Property(i => i.Id).ValueGeneratedNever();
        builder.Property(i => i.UrlImagen).IsRequired().HasMaxLength(1000);
        builder.Property(i => i.NombreArchivo).IsRequired().HasMaxLength(255);
        builder.Property(i => i.Latitud).HasColumnType("decimal(10,7)");
        builder.Property(i => i.Longitud).HasColumnType("decimal(10,7)");
        builder.Property(i => i.MarcaAguaAplicada).HasDefaultValue(true);
    }
}

public sealed class NovedadHistorialConfiguration : IEntityTypeConfiguration<NovedadHistorial>
{
    public void Configure(EntityTypeBuilder<NovedadHistorial> builder)
    {
        builder.ToTable("NovedadHistorial");
        builder.HasKey(h => h.Id);
        builder.Property(h => h.Id).ValueGeneratedNever();
        builder.Property(h => h.Comentario).HasMaxLength(1000);
        builder.Property(h => h.UsuarioId).IsRequired();
    }
}
