using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Infrastructure.Persistence.Configurations;

public sealed class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> builder)
    {
        builder.ToTable("RefreshTokens");
        builder.HasKey(r => r.Id);
        builder.Property(r => r.Id).ValueGeneratedNever();
        builder.Property(r => r.Token).IsRequired().HasMaxLength(512);
        builder.Property(r => r.JwtId).IsRequired().HasMaxLength(100);
        builder.Property(r => r.IpAddress).HasMaxLength(45);
        builder.Property(r => r.UserAgent).HasMaxLength(500);
        builder.Property(r => r.RevokedReason).HasMaxLength(300);

        builder.HasIndex(r => r.Token).IsUnique();
        builder.HasIndex(r => r.UsuarioId);

        builder.HasOne(r => r.Usuario)
               .WithMany(u => u.RefreshTokens)
               .HasForeignKey(r => r.UsuarioId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(r => r.Dispositivo)
               .WithMany(d => d.RefreshTokens)
               .HasForeignKey(r => r.DispositivoId)
               .OnDelete(DeleteBehavior.SetNull);
    }
}
