# Backend API Contract Mapping

This backend implements the RBAC endpoints expected by the Angular admin screens. The frontend can run against in-memory mocks or the real API.

Frontend method -> Backend endpoint -> DTO

- AuthService login refresh -> GET `api/me` -> `MeResponse`
- AuthService register -> POST `api/auth/register` -> `RegisterRequest`
- AuthService verifyEmailLink -> POST `api/auth/verify-email-link` -> `VerifyEmailLinkRequest`
- AuthService requestPasswordResetLink -> POST `api/auth/request-password-reset-link` -> `RequestPasswordResetLinkRequest`
- AuthService confirmPasswordResetLink -> POST `api/auth/confirm-password-reset-link` -> `ConfirmPasswordResetLinkRequest`
- AuthService requestChangePasswordLink -> POST `api/auth/request-change-password-link` -> none
- AuthService confirmChangePasswordLink -> POST `api/auth/confirm-change-password-link` -> `ConfirmChangePasswordLinkRequest`
- AdminRoleService.getRoles -> GET `api/admin/roles?page=&pageSize=&search=` -> `PagedResult<RoleSummaryDto>`
- AdminRoleService.createRole -> POST `api/admin/roles` -> `RoleCreateRequest`
- AdminRoleService.updateRole -> PUT `api/admin/roles/{roleId}` -> `RoleUpdateRequest`
- AdminRoleService.deactivateRole -> POST `api/admin/roles/{roleId}/deactivate` -> none
- AdminRoleService.reactivateRole -> POST `api/admin/roles/{roleId}/activate` -> none
- AdminComponentService.getComponents -> GET `api/admin/components?page=&pageSize=&search=` -> `PagedResult<ComponentSummaryDto>`
- AdminComponentService.createComponent -> POST `api/admin/components` -> `ComponentCreateRequest`
- AdminComponentService.updateComponent -> PUT `api/admin/components/{componentId}` -> `ComponentUpdateRequest`
- AdminComponentService.deactivateComponent -> POST `api/admin/components/{componentId}/deactivate` -> none
- AdminComponentService.reactivateComponent -> POST `api/admin/components/{componentId}/activate` -> none
- AdminPermissionService.getActions -> GET `api/admin/actions?page=&pageSize=&search=` -> `PagedResult<ActionSummaryDto>`
- AdminPermissionService.createAction -> POST `api/admin/actions` -> `ActionCreateRequest`
- AdminPermissionService.updateAction -> PUT `api/admin/actions/{actionId}` -> `ActionUpdateRequest`
- AdminPermissionService.deactivateAction -> POST `api/admin/actions/{actionId}/deactivate` -> none
- AdminPermissionService.activateAction -> POST `api/admin/actions/{actionId}/activate` -> none
- AdminPermissionService.getMatrix -> GET `api/admin/roles` + GET `api/admin/permissions` + GET `api/admin/roles/{roleId}` -> `RoleDetailDto`
- AdminPermissionService.saveMatrix -> PUT `api/admin/roles/{roleId}/permissions` -> `RolePermissionSetRequest`
- AdminUserService.getUsers -> GET `api/admin/users?page=&pageSize=&search=` -> `PagedResult<AdminUserSummaryDto>`
- AdminUserService.createUser -> POST `api/admin/users` -> `AdminUserCreateRequest`
- AdminUserService.updateUser -> PUT `api/admin/users/{userId}` -> `AdminUserUpdateRequest`
- AdminUserService.setUserRoles -> PUT `api/admin/users/{userId}/roles` -> `AdminUserRoleSetRequest`
- AdminUserService.deactivateUser -> POST `api/admin/users/{userId}/deactivate` -> none
- AdminUserService.reactivateUser -> POST `api/admin/users/{userId}/activate` -> none
- ProfileService.getProfile -> GET `api/users/profile` -> `UserProfileDto`
- ProfileService.updateProfile -> PUT `api/users/profile` -> `UpdateProfileRequest`
- ProfileService.uploadProfileImage -> POST `api/users/profile/photo` -> multipart form
- ProfileService.deleteProfileImage -> DELETE `api/users/profile/photo` -> none
- ProfileService.deleteAccount -> POST `api/users/profile/delete` -> none

Notes
- Permission policies use `PERM:<CODE>` and are enforced server-side.

## Run Locally

Backend

1) Configure environment variables in `.env`.
2) Run the API:

```
cd finrecon360-backend-master/finrecon360-backend
dotnet run
```

Frontend

```
cd finrecon360-frontend
npm install
ng serve
```

## Tests

Backend:

```
cd finrecon360-backend-master
dotnet test
```

Frontend:

```
cd finrecon360-frontend
ng test --watch=false
```

## Required Environment Variables (names only)

- BREVO_API_KEY
- BREVO_SENDER_EMAIL
- BREVO_SENDER_NAME
- BREVO_TEMPLATE_ID_MAGICLINK_VERIFY
- BREVO_TEMPLATE_ID_MAGICLINK_RESET
- BREVO_TEMPLATE_ID_MAGICLINK_CHANGE
- FRONTEND_BASE_URL
- ADMIN_EMAILS

## Brevo Template Requirements

Magic-link templates must include:
- `{{ params.magicLink }}`
- `{{ params.expiresInMinutes }}`

If your template does not include these, update it in the Brevo dashboard (manual change required).

## Deployment

Angular:
- `ng build` and deploy the generated static files.

Backend:
- `dotnet publish -c Release`
- Run behind a reverse proxy (Nginx/Apache/IIS).
- Use HTTPS and set environment variables in the host environment.
