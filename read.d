Database Schema (SQL Server)

Tables

1) __EFMigrationsHistory
- Purpose: Tracks applied EF Core migrations.
- Columns:
  - MigrationId NVARCHAR(150) PK
  - ProductVersion NVARCHAR(32) NOT NULL

2) Users
- Purpose: Core user identity records with auth profile and status fields.
- Columns:
  - UserId UNIQUEIDENTIFIER PK
  - Email NVARCHAR(512) NOT NULL
  - DisplayName NVARCHAR(512) NULL
  - PhoneNumber NVARCHAR(64) NULL
  - EmailConfirmed BIT NOT NULL DEFAULT 0
  - IsActive BIT NOT NULL DEFAULT 1
  - CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  - UpdatedAt DATETIME2 NULL
  - FirstName NVARCHAR(512) NOT NULL
  - LastName NVARCHAR(512) NOT NULL
  - Country NVARCHAR(512) NOT NULL
  - Gender NVARCHAR(128) NOT NULL
  - PasswordHash NVARCHAR(1024) NOT NULL
  - VerificationCode NVARCHAR(128) NULL
  - VerificationCodeExpiresAt DATETIME2 NULL
  - ProfileImage VARBINARY(MAX) NULL
  - ProfileImageContentType NVARCHAR(200) NULL
- Indexes/Constraints:
  - PK_Users (UserId)
  - IX_Users_Email UNIQUE

3) Roles
- Purpose: Role definitions for RBAC.
- Columns:
  - RoleId UNIQUEIDENTIFIER PK
  - Code NVARCHAR(200) NOT NULL
  - Name NVARCHAR(200) NOT NULL
  - Description NVARCHAR(512) NULL
  - IsSystem BIT NOT NULL DEFAULT 0
  - IsActive BIT NOT NULL DEFAULT 1
  - CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
- Indexes/Constraints:
  - PK_Roles (RoleId)
  - IX_Roles_Code UNIQUE
  - IX_Roles_Name UNIQUE

4) Permissions
- Purpose: Permission definitions assignable to roles.
- Columns:
  - PermissionId UNIQUEIDENTIFIER PK
  - Code NVARCHAR(300) NOT NULL
  - Name NVARCHAR(400) NOT NULL
  - Description NVARCHAR(1000) NULL
  - Module NVARCHAR(200) NULL
  - CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
- Indexes/Constraints:
  - PK_Permissions (PermissionId)
  - IX_Permissions_Code UNIQUE

5) UserRoles
- Purpose: M:N user-role assignments.
- Columns:
  - UserId UNIQUEIDENTIFIER NOT NULL
  - RoleId UNIQUEIDENTIFIER NOT NULL
  - AssignedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  - AssignedByUserId UNIQUEIDENTIFIER NULL
- Indexes/Constraints:
  - PK_UserRoles (UserId, RoleId)
  - IX_UserRoles_RoleId
  - FK_UserRoles_Users_UserId ON DELETE CASCADE
  - FK_UserRoles_Roles_RoleId ON DELETE CASCADE

6) RolePermissions
- Purpose: M:N role-permission grants.
- Columns:
  - RoleId UNIQUEIDENTIFIER NOT NULL
  - PermissionId UNIQUEIDENTIFIER NOT NULL
  - GrantedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  - GrantedByUserId UNIQUEIDENTIFIER NULL
- Indexes/Constraints:
  - PK_RolePermissions (RoleId, PermissionId)
  - IX_RolePermissions_PermissionId
  - FK_RolePermissions_Roles_RoleId ON DELETE CASCADE
  - FK_RolePermissions_Permissions_PermissionId ON DELETE CASCADE

7) AuthActionTokens
- Purpose: Persisted auth action tokens for verification/reset flows.
- Columns:
  - AuthActionTokenId UNIQUEIDENTIFIER PK
  - UserId UNIQUEIDENTIFIER NULL
  - Email NVARCHAR(512) NOT NULL
  - Purpose NVARCHAR(100) NOT NULL
  - TokenHash VARBINARY(32) NOT NULL
  - TokenSalt VARBINARY(16) NOT NULL
  - ExpiresAt DATETIME2 NOT NULL
  - ConsumedAt DATETIME2 NULL
  - AttemptCount INT NOT NULL DEFAULT 0
  - CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  - CreatedIp NVARCHAR(128) NULL
  - LastAttemptAt DATETIME2 NULL
- Indexes/Constraints:
  - PK_AuthActionTokens (AuthActionTokenId)
  - IX_AuthActionTokens_Email_Purpose_ExpiresAt
  - IX_AuthActionTokens_UserId
  - IX_AuthActionTokens_UserId_Purpose
  - FK_AuthActionTokens_Users_UserId ON DELETE SET NULL

8) AuditLogs
- Purpose: Audit trail for security-relevant actions.
- Columns:
  - AuditLogId UNIQUEIDENTIFIER PK
  - UserId UNIQUEIDENTIFIER NULL
  - Action NVARCHAR(400) NOT NULL
  - Entity NVARCHAR(400) NULL
  - EntityId NVARCHAR(200) NULL
  - Metadata NVARCHAR(MAX) NULL
  - CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
- Indexes/Constraints:
  - PK_AuditLogs (AuditLogId)
  - IX_AuditLogs_CreatedAt
  - IX_AuditLogs_UserId
  - FK_AuditLogs_Users_UserId ON DELETE SET NULL

9) AppComponents
- Purpose: Admin UI component registry for permission mapping.
- Columns:
  - AppComponentId UNIQUEIDENTIFIER PK
  - Code NVARCHAR(200) NOT NULL
  - Name NVARCHAR(400) NOT NULL
  - RoutePath NVARCHAR(400) NOT NULL
  - Category NVARCHAR(200) NULL
  - Description NVARCHAR(1000) NULL
  - IsActive BIT NOT NULL DEFAULT 1
  - CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
- Indexes/Constraints:
  - PK_AppComponents (AppComponentId)
  - IX_AppComponents_Code UNIQUE

10) PermissionActions
- Purpose: Admin action catalog for permission mapping.
- Columns:
  - PermissionActionId UNIQUEIDENTIFIER PK
  - Code NVARCHAR(100) NOT NULL
  - Name NVARCHAR(400) NOT NULL
  - Description NVARCHAR(1000) NULL
  - IsActive BIT NOT NULL DEFAULT 1
  - CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
- Indexes/Constraints:
  - PK_PermissionActions (PermissionActionId)
  - IX_PermissionActions_Code UNIQUE

Relationships Summary
- Users 1..* UserRoles (UserRoles.UserId -> Users.UserId, cascade)
- Roles 1..* UserRoles (UserRoles.RoleId -> Roles.RoleId, cascade)
- Roles 1..* RolePermissions (RolePermissions.RoleId -> Roles.RoleId, cascade)
- Permissions 1..* RolePermissions (RolePermissions.PermissionId -> Permissions.PermissionId, cascade)
- Users 1..* AuthActionTokens (AuthActionTokens.UserId -> Users.UserId, set null)
- Users 1..* AuditLogs (AuditLogs.UserId -> Users.UserId, set null)
