# Service Backend - Project Documentation for AI Agents

## Project Overview

This is a **microservices backend project** written in Go, designed as a modular service-oriented architecture. The project currently consists of a Single Sign-On (SSO) service with a placeholder for a Company Profile (Compro) service.

### Services Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose Stack                     │
├─────────────┬─────────────┬─────────────┬───────────────────┤
│  PostgreSQL │  SSO Service│Compro Svcs  │  (Reserved)       │
│   :5432     │   :8001     │   :8002     │                   │
│  (v16-alpine)│  (Go/Chi)  │  (TBD)      │                   │
└─────────────┴─────────────┴─────────────┴───────────────────┘
       │              │              │
       └──────────────┴──────────────┘
              core-network (bridge)
```

- **postgres**: PostgreSQL 16 Alpine database server
- **sso-service**: Go-based authentication/authorization service (port 8001)
- **compro-service**: Placeholder for company profile service (commented out, port 8002 reserved)

## Technology Stack

### Core Technologies
| Component | Technology | Version |
|-----------|------------|---------|
| Language | Go | 1.25.3 |
| Web Framework | Chi Router | v5.2.5 |
| Database | PostgreSQL | 16-alpine |
| Migration Tool | golang-migrate | v4 |
| Hot Reload | Air | latest |
| Container | Docker + Docker Compose | 3.9 |

### Go Dependencies
```
github.com/go-chi/chi/v5 v5.2.5  # HTTP router and middleware
github.com/golang-migrate/migrate/v4  # Database migrations (via CLI)
```

## Project Structure

```
servicebackend/
├── .env                      # Environment variables (gitignored)
├── docker-compose.yml        # Orchestration configuration
├── AGENTS.md                 # This file
├── init-db/                  # Database initialization scripts
│   └── init.sql             # Creates sso_db and compro_db
├── sso-service/             # Single Sign-On service (ACTIVE)
│   ├── cmd/app/
│   │   └── main.go          # Application entry point
│   ├── internal/            # Private application code
│   │   ├── handler/         # HTTP handlers (empty)
│   │   ├── repository/      # Data access layer (empty)
│   │   └── service/         # Business logic layer (empty)
│   ├── migrations/          # Database migration files
│   │   ├── *.up.sql         # Forward migrations
│   │   └── *.down.sql       # Rollback migrations
│   ├── pkg/                 # Public shared packages (empty)
│   ├── tmp/                 # Air hot-reload build cache
│   ├── .air.toml           # Air configuration for hot reload
│   ├── .gitignore          # Go-specific ignores
│   ├── Dockerfile          # Service container image
│   ├── go.mod              # Go module definition
│   ├── go.sum              # Go dependency checksums
│   └── README.md           # golang-migrate documentation
└── compro-service/          # Company Profile service (EMPTY/PLACEHOLDER)
    └── (no files yet)
```

## Code Organization Conventions

### Go Project Layout (Standard)
The project follows the [Standard Go Project Layout](https://github.com/golang-standards/project-layout):

- **`/cmd/app/`**: Main application entry point. Only `main.go` here.
- **`/internal/`**: Private application code, cannot be imported by other modules
  - **`/handler/`**: HTTP request handlers/controllers
  - **`/service/`**: Business logic implementation
  - **`/repository/`**: Database access and data persistence
- **`/pkg/`**: Public packages that can be imported by other projects
- **`/migrations/`**: SQL migration files (up/down pairs)

### Naming Conventions
- Migration files: `{timestamp}_{description}.{up|down}.sql`
  - Example: `20260217090406_create_users_table.up.sql`
- Go files: lowercase with underscores (snake_case)
- Package names: lowercase, single word when possible

## Build and Development Commands

### Docker Compose Operations

```bash
# Start all services
docker-compose up -d

# Start with build (after code changes)
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: data loss)
docker-compose down -v
```

### SSO Service Development

```bash
cd sso-service/

# Run with hot reload (requires Air: go install github.com/air-verse/air@latest)
air

# Build manually
go build -o app ./cmd/app

# Run manually
./app

# Download dependencies
go mod download

# Tidy dependencies
go mod tidy
```

### Database Migrations

Migrations are managed using [golang-migrate](https://github.com/golang-migrate/migrate) CLI.

```bash
# Install migrate CLI
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Create new migration
migrate create -ext sql -dir migrations -seq create_users_table

# Run migrations (up)
migrate -path migrations -database "postgres://postgres:postgres123@localhost:5432/sso_db?sslmode=disable" up

# Rollback migrations (down)
migrate -path migrations -database "postgres://postgres:postgres123@localhost:5432/sso_db?sslmode=disable" down

# Check version
migrate -path migrations -database "postgres://postgres:postgres123@localhost:5432/sso_db?sslmode=disable" version
```

## Configuration

### Environment Variables

Create a `.env` file in the project root:

```bash
POSTGRES_USER=postgres
POSTGRES_PASSWORD=supersecretpassword123
```

### Database Connections

| Service | Database URL | Database Name |
|---------|--------------|---------------|
| sso-service | `postgres://postgres:postgres123@postgres:5432/sso_db?sslmode=disable` | sso_db |
| compro-service | `postgres://postgres:postgres123@postgres:5432/compro_db?sslmode=disable` | compro_db |

### Service Ports

| Service | Internal Port | External Port | Status |
|---------|---------------|---------------|--------|
| postgres | 5432 | 5432 | Active |
| sso-service | 8000 | 8001 | Active |
| compro-service | 8000 | 8002 | Reserved/Inactive |

## Testing Strategy

### Current State
- **No test files present** in the codebase
- Test infrastructure to be added as services are developed

### Recommended Testing Approach
```bash
# Run Go tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run tests with race detection
go test -race ./...
```

## Security Considerations

### Current Security Posture
1. **Database**: PostgreSQL with basic authentication
2. **Network**: Services communicate via internal Docker network (`core-network`)
3. **SSL**: Disabled for database connections (`sslmode=disable`) - NOT for production
4. **Secrets**: Stored in `.env` file (gitignored)

### Security TODOs for Production
- [ ] Enable SSL/TLS for database connections
- [ ] Use secrets management (Docker secrets, HashiCorp Vault, etc.)
- [ ] Implement authentication middleware for SSO service
- [ ] Add request rate limiting
- [ ] Configure CORS properly
- [ ] Add input validation
- [ ] Implement audit logging

## Development Workflow

### Adding a New Feature to SSO Service

1. **Create migration** (if database change needed):
   ```bash
   cd sso-service
   migrate create -ext sql -dir migrations -seq feature_description
   # Edit the generated .up.sql and .down.sql files
   ```

2. **Implement layers** (bottom-up):
   - `internal/repository/` - Data access
   - `internal/service/` - Business logic
   - `internal/handler/` - HTTP handlers

3. **Register routes** in `cmd/app/main.go`

4. **Test locally** with `air` for hot reload

5. **Build and deploy**:
   ```bash
   docker-compose up -d --build
   ```

### Adding a New Service

1. Create new directory: `mkdir new-service`
2. Copy structure from `sso-service/`
3. Update `docker-compose.yml`:
   - Add service definition
   - Configure database connection
   - Map appropriate port
4. Create database in `init-db/init.sql` if needed

## Deployment Notes

- **Docker Compose**: Used for local development
- **Container Registry**: Not configured (builds locally)
- **Production**: Consider Kubernetes or similar orchestration
- **Database**: Use managed PostgreSQL in production (RDS, Cloud SQL, etc.)

## Common Issues

### Hot Reload Not Working
- Check `.air.toml` configuration
- Ensure `tmp/` directory exists and is writable
- Verify Air is installed: `air -v`

### Database Connection Failed
- Verify PostgreSQL container is running: `docker-compose ps`
- Check credentials in `.env` match docker-compose configuration
- Ensure databases exist: `docker-compose exec postgres psql -U postgres -l`

### Port Already in Use
- Kill existing process: `lsof -ti:8001 | xargs kill -9`
- Or change port mapping in `docker-compose.yml`

## References

- [Chi Router Documentation](https://github.com/go-chi/chi)
- [golang-migrate Documentation](https://github.com/golang-migrate/migrate)
- [Air Hot Reload](https://github.com/air-verse/air)
- [Standard Go Project Layout](https://github.com/golang-standards/project-layout)
