using System.Net;
using System.Net.Http.Json;
using System.Linq;
using finrecon360_backend.Data;
using finrecon360_backend.Dtos.Auth;
using finrecon360_backend.Models;
using finrecon360_backend.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace finrecon360_backend.Tests;

public class AuthIntegrationTests : IClassFixture<TestWebApplicationFactory>
{
    private readonly TestWebApplicationFactory _factory;

    public AuthIntegrationTests(TestWebApplicationFactory factory)
    {
        _factory = factory;
    }


    [Fact]
    public async Task Register_sends_email_and_persists_token()
    {
        _factory.EmailSender.Requests.Clear();
        using var client = _factory.CreateClient();
        var payload = new RegisterRequest(
            "newuser@test.local",
            "New",
            "User",
            "US",
            "male",
            "Password123!",
            "Password123!");

        var response = await client.PostAsJsonAsync("/api/auth/register", payload);
        response.EnsureSuccessStatusCode();

        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        Assert.True(await db.AuthActionTokens.AnyAsync(t => t.Email == "newuser@test.local" && t.Purpose == MagicLinkPurpose.EmailVerify));
        Assert.Single(_factory.EmailSender.Requests);
    }

    [Fact]
    public async Task Verify_email_consumes_token_and_sets_confirmed()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var magicService = scope.ServiceProvider.GetRequiredService<IMagicLinkService>();

        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "verify@test.local",
            FirstName = "Verify",
            LastName = "User",
            Country = "US",
            Gender = "male",
            PasswordHash = "hash",
            CreatedAt = DateTime.UtcNow,
            IsActive = true
        };
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var token = await magicService.CreateTokenAsync(user.Email, user.UserId, MagicLinkPurpose.EmailVerify, null);
        Assert.NotNull(token);

        using var client = _factory.CreateClient();
        var response = await client.PostAsJsonAsync("/api/auth/verify-email-link", new VerifyEmailLinkRequest { Token = token!.Token });
        response.EnsureSuccessStatusCode();

        using var verifyScope = _factory.Services.CreateScope();
        var verifyDb = verifyScope.ServiceProvider.GetRequiredService<AppDbContext>();
        var updated = await verifyDb.Users.AsNoTracking().FirstAsync(u => u.UserId == user.UserId);
        Assert.True(updated.EmailConfirmed);
    }

    [Fact]
    public async Task Request_password_reset_does_not_reveal_email_existence()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        db.Users.Add(new User
        {
            UserId = Guid.NewGuid(),
            Email = "known@test.local",
            FirstName = "Known",
            LastName = "User",
            Country = "US",
            Gender = "male",
            PasswordHash = "hash",
            CreatedAt = DateTime.UtcNow,
            IsActive = true
        });
        await db.SaveChangesAsync();

        using var client = _factory.CreateClient();

        var known = await client.PostAsJsonAsync("/api/auth/request-password-reset-link", new RequestPasswordResetLinkRequest { Email = "known@test.local" });
        var unknown = await client.PostAsJsonAsync("/api/auth/request-password-reset-link", new RequestPasswordResetLinkRequest { Email = "missing@test.local" });

        var knownBody = await known.Content.ReadFromJsonAsync<Dictionary<string, string>>();
        var unknownBody = await unknown.Content.ReadFromJsonAsync<Dictionary<string, string>>();

        Assert.Equal(HttpStatusCode.OK, known.StatusCode);
        Assert.Equal(HttpStatusCode.OK, unknown.StatusCode);
        Assert.Equal(knownBody?["message"], unknownBody?["message"]);
    }

    [Fact]
    public async Task Admin_endpoints_require_permissions()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "noperm@test.local",
            FirstName = "No",
            LastName = "Perm",
            Country = "US",
            Gender = "male",
            PasswordHash = "hash",
            CreatedAt = DateTime.UtcNow,
            IsActive = true
        };
        db.Users.Add(user);
        await db.SaveChangesAsync();

        using var client = TestWebApplicationFactory.CreateAuthenticatedClient(_factory, user.UserId, user.Email);
        var response = await client.GetAsync("/api/admin/roles");

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Me_returns_computed_permissions()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "perm@test.local",
            FirstName = "Perm",
            LastName = "User",
            Country = "US",
            Gender = "male",
            PasswordHash = "hash",
            CreatedAt = DateTime.UtcNow,
            IsActive = true
        };
        var role = new Role
        {
            RoleId = Guid.NewGuid(),
            Code = "TEST",
            Name = "Test",
            IsSystem = false,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        var permission = new Permission
        {
            PermissionId = Guid.NewGuid(),
            Code = "ADMIN.USERS.MANAGE",
            Name = "User Management",
            CreatedAt = DateTime.UtcNow
        };

        db.Users.Add(user);
        db.Roles.Add(role);
        db.Permissions.Add(permission);
        db.UserRoles.Add(new UserRole { UserId = user.UserId, RoleId = role.RoleId, AssignedAt = DateTime.UtcNow });
        db.RolePermissions.Add(new RolePermission { RoleId = role.RoleId, PermissionId = permission.PermissionId, GrantedAt = DateTime.UtcNow });
        await db.SaveChangesAsync();

        using var client = TestWebApplicationFactory.CreateAuthenticatedClient(_factory, user.UserId, user.Email);
        var response = await client.GetAsync("/api/me");
        response.EnsureSuccessStatusCode();

        var payload = await response.Content.ReadFromJsonAsync<Dictionary<string, object>>();
        Assert.NotNull(payload);
        var permissions = payload!["permissions"] as System.Text.Json.JsonElement?;
        Assert.True(permissions.HasValue);
        Assert.Contains("ADMIN.USERS.MANAGE", permissions.Value.EnumerateArray().Select(p => p.GetString()));
    }
}
