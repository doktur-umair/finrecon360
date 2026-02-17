# Developer Setup (FinRecon360)

This file focuses on local setup, testing, and day-to-day development. Existing README files in subfolders cover general usage; this adds missing setup and seeding details.

## Prerequisites
- Node.js 18+ and npm
- Angular CLI (same major as `package.json` / project README)
- .NET SDK 8.x
- SQL Server (local instance or Docker)

## Repo Layout
- `finrecon360-frontend/` Angular app
- `finrecon360-backend-master/finrecon360-backend/` .NET API
- `finrecon360/` SQL project

## Backend Setup
1. Create a local `.env` from the example:
   - Copy `finrecon360-backend-master/finrecon360-backend/.env.example` to `.env`
   - Fill in Brevo settings and `ADMIN_EMAILS`
2. Update DB connection string in `finrecon360-backend-master/finrecon360-backend/appsettings.json`:
   - `ConnectionStrings:DefaultConnection`
3. Run the API:

```bash
cd finrecon360-backend-master/finrecon360-backend
dotnet restore
dotnet run
```

On startup the API applies EF Core migrations and runs database seeding.

## Frontend Setup
```bash
cd finrecon360-frontend
npm install
ng serve
```
Open `http://localhost:4200`.

## Seeding and Admin Access
The backend seeds roles, permissions, components, and actions on startup. Admin role assignment uses the `ADMIN_EMAILS` environment variable.

Steps to get an admin user locally:
1. Set `ADMIN_EMAILS` in `.env` to include the email you will use (semicolon or comma separated).
2. Register a user via the frontend or `POST api/auth/register`.
3. Restart the API (or re-run) so `DbSeeder` can assign the admin role to that email.

If a user already exists before `ADMIN_EMAILS` is set, just restart the API after updating the env file.

## Tests
Backend:
```bash
cd finrecon360-backend-master
dotnet test
```

Frontend:
```bash
cd finrecon360-frontend
ng test --watch=false
```

## Development Notes
- `.env` is local-only and ignored by git. Use `.env.example` as the template.
- Update `Jwt:Key` in `appsettings.json` for anything beyond local development.
- If SQL Server is not local, adjust the connection string accordingly.
