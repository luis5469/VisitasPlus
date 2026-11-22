using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Infrastructure.Persistence.Configurations;

public sealed class PermisoConfiguration : IEntityTypeConfiguration<Permiso>
{
    public void Configure(EntityTypeBuilder<Permiso> builder)
    {
        builder.ToTable("Permisos");
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Id).ValueGeneratedNever();
        builder.Property(p => p.Nombre).IsRequired().HasMaxLength(150);
        builder.Property(p => p.Modulo).IsRequired().HasMaxLength(100);
        builder.Property(p => p.Accion).IsRequired().HasMaxLength(100);
        builder.Property(p => p.Descripcion).HasMaxLength(500);
        builder.HasIndex(p => p.Nombre).IsUnique();
    }
}

public sealed class RolPermisoConfiguration : IEntityTypeConfiguration<RolPermiso>
{
    public void Configure(EntityTypeBuilder<RolPermiso> builder)
    {
        builder.ToTable("RolPermisos");
        builder.HasKey(rp => new { rp.RolId, rp.PermisoId });

        builder.HasOne(rp => rp.Rol)
               .WithMany(r => r.RolPermisos)
               .HasForeignKey(rp => rp.RolId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(rp => rp.Permiso)
               .WithMany(p => p.RolPermisos)
               .HasForeignKey(rp => rp.PermisoId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class UsuarioRolConfiguration : IEntityTypeConfiguration<UsuarioRol>
{
    public void Configure(EntityTypeBuilder<UsuarioRol> builder)
    {
        builder.ToTable("UsuarioRoles");
        builder.HasKey(ur => new { ur.UsuarioId, ur.RolId });

        builder.HasOne(ur => ur.Usuario)
               .WithMany(u => u.UsuarioRoles)
               .HasForeignKey(ur => ur.UsuarioId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(ur => ur.Rol)
               .WithMany(r => r.UsuarioRoles)
               .HasForeignKey(ur => ur.RolId)
               .OnDelete(DeleteBehavior.Restrict);
    }
}
