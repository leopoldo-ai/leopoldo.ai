---
name: python-backend
description: Use when building Python backend applications with FastAPI, Django, or Flask. Invoke for project structure, ORM patterns, authentication, async patterns, testing, middleware, configuration management, and deployment.
version: 0.2.0
layer: userland
category: domain
pack: full-stack
triggers:
  - pattern: "python backend|fastapi|django|flask|sqlalchemy|uvicorn|gunicorn|pytest|pydantic"
dependencies:
  hard: []
  soft:
    - api-designer
    - docker-workflow
    - postgres-pro
    - test-master
metadata:
  author: internal
  source: custom
  license: Proprietary
  forge_strategy: build
  created: 2026-03-13
---

# Python Backend

Senior Python backend developer. Framework-agnostic core con adapter per FastAPI, Django e Flask. Focus su type safety, async-first, testing rigoroso e deployment production-grade.

## Perche' esiste

| Domanda | Risposta |
|---------|----------|
| Quando usarla? | Qualsiasi backend Python: API REST, microservizi, monoliti, task worker |
| Cosa copre? | Struttura progetto, ORM, auth, testing, async, config, middleware, deploy |
| Cosa NON copre? | Frontend, ML/AI pipelines, data engineering (vedi skill dedicate) |
| Framework supportati | FastAPI (primario), Django + DRF, Flask + extensions |

## Core Workflow

### Phase 1: Struttura Progetto

Adotta la struttura **src layout** per tutti i framework:

```
project-root/
  src/
    app/
      __init__.py
      config.py          # Settings via pydantic-settings o django-environ
      main.py            # Entrypoint (FastAPI app / ASGI / WSGI)
      models/            # ORM models, one file per domain
      schemas/           # Pydantic schemas (request/response)
      routers/           # Route handlers (FastAPI routers / Django views / Flask blueprints)
      services/          # Business logic — framework-agnostic
      repositories/      # Data access layer — DB queries isolate
      middleware/         # Custom middleware
      dependencies/      # DI providers (FastAPI Depends / manual)
      exceptions/        # Custom exceptions + handlers
      utils/             # Shared helpers
  tests/
    conftest.py          # Fixtures, factories, test DB
    unit/
    integration/
    e2e/
  alembic/               # Migrations (SQLAlchemy) o Django migrations/
  pyproject.toml
  Dockerfile
  docker-compose.yml
```

**Regola chiave:** la directory `services/` contiene TUTTA la business logic. Router/view chiamano service, service chiama repository. Mai query dirette nei router.

### Phase 2: ORM e Data Access

**SQLAlchemy 2.0+ (FastAPI, Flask):**

- Usa `DeclarativeBase` + `Mapped[]` + `mapped_column()` (typed, non legacy)
- Session via `async_sessionmaker` con `AsyncSession` per async stack
- Repository pattern: una classe per aggregate root, metodi `get`, `list`, `create`, `update`, `delete`
- Alembic per migrazioni: `--autogenerate` + review manuale obbligatoria

**Django ORM (Django):**

- Model con `Meta.indexes`, `Meta.constraints`, `__str__` obbligatorio
- Manager custom per query complesse riusabili
- `select_related` / `prefetch_related` obbligatori per FK/M2M (mai N+1)
- Migrazioni: `makemigrations` + `squashmigrations` periodico

### Phase 3: Autenticazione e Autorizzazione

| Metodo | Quando | Implementazione |
|--------|--------|-----------------|
| JWT (Bearer) | API stateless, SPA, mobile | `python-jose` / `PyJWT`, access + refresh token, rotation |
| OAuth2 | Login social, SSO enterprise | `authlib` / `python-social-auth`, PKCE per public client |
| Session-based | Web tradizionale, admin panel | Cookie httpOnly + secure + SameSite=Strict |

**Pattern comune:** middleware/dependency che estrae `current_user` dal token/session. Tutte le route protette ricevono `current_user` iniettato, mai parsing manuale del token nel handler.

**RBAC minimo:** `User.role` enum, decorator/dependency `require_role(Role.ADMIN)`. Per ABAC complesso valutare `casbin` o `oso`.

### Phase 4: Testing

**Stack obbligatorio:** `pytest` + `pytest-asyncio` + `pytest-cov` + `factory-boy` + `httpx` (async test client).

```python
# conftest.py — pattern base
@pytest.fixture
async def db_session():
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with async_session() as session:
        yield session
        await session.rollback()

@pytest.fixture
def client(db_session):
    app.dependency_overrides[get_db] = lambda: db_session
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()
```

- **Unit test:** service layer isolato, mock del repository
- **Integration test:** DB reale (testcontainers o SQLite in-memory), HTTP client
- **Async test:** `@pytest.mark.asyncio` con `anyio` backend, fixture async
- **Coverage target:** >= 80% su services/, >= 60% overall. `pytest --cov=src --cov-report=term-missing`

### Phase 5: Async e Performance

- **ASGI-first:** Uvicorn + `async def` handler come default
- **Database:** `asyncpg` + SQLAlchemy async, connection pool `pool_size=5, max_overflow=10`
- **Background task:** `asyncio.create_task` per fire-and-forget, `arq`/`celery` per job persistenti
- **Concurrency:** `asyncio.gather` per I/O parallelo, `asyncio.Semaphore` per rate limiting
- **WSGI fallback:** Django con `gunicorn` + `--workers $(nproc)`, oppure `uvicorn` con ASGI adapter (`django.core.asgi`)

### Phase 6: Error Handling e Logging

```python
# Structured logging — standard per tutti i framework
import structlog
logger = structlog.get_logger()

# Exception handler pattern
class AppError(Exception):
    def __init__(self, code: str, message: str, status: int = 400):
        self.code = code
        self.message = message
        self.status = status

# Risposta errore uniforme
{"error": {"code": "ITEM_NOT_FOUND", "message": "...", "request_id": "..."}}
```

- `structlog` con JSON output in produzione, console colorata in dev
- `request_id` iniettato via middleware in ogni log entry
- Mai `except Exception: pass` — log + re-raise o return errore tipizzato

### Phase 7: Configuration Management

```python
# pydantic-settings (FastAPI, Flask)
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    redis_url: str = "redis://localhost:6379"
    debug: bool = False
    secret_key: str

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

# Django — django-environ
import environ
env = environ.Env()
environ.Env.read_env(".env")
DATABASES = {"default": env.db("DATABASE_URL")}
```

- `.env` per development (mai committato), variabili d'ambiente in produzione
- Validazione al boot: app crasha subito se manca una config obbligatoria
- Settings immutabili dopo init: mai modificare config a runtime

### Phase 8: Middleware e Dependency Injection

**Middleware chain standard (ordine):**
1. Request ID injection
2. CORS
3. Authentication
4. Rate limiting
5. Logging (request/response)
6. Error handler (catch-all)

**DI:** FastAPI ha `Depends()` nativo. Per Django/Flask: iniettare service via factory function o `dependency-injector` library. Mai istanziare service nei handler.

### Phase 9: Deploy

- **Docker:** multi-stage build, `python:3.12-slim`, non-root user (vedi `docker-workflow`)
- **ASGI:** `uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4`
- **WSGI:** `gunicorn app.wsgi:application --bind 0.0.0.0:8000 --workers 4 --timeout 120`
- **Health check:** endpoint `/health` che verifica DB + Redis + dipendenze critiche
- **Graceful shutdown:** signal handler per SIGTERM, drain connections

---

## Framework Adapter: FastAPI

- **Router:** `APIRouter(prefix="/api/v1/items", tags=["items"])`, include in `app` con `include_router`
- **Depends:** DI nativo. `db: AsyncSession = Depends(get_db)`, `user: User = Depends(get_current_user)`
- **Pydantic v2:** `BaseModel` per request/response, `model_validator(mode="before")` per custom validation, `ConfigDict(from_attributes=True)` per ORM mode
- **Response model:** sempre esplicito `response_model=ItemResponse`, mai return dict raw
- **Background tasks:** `BackgroundTasks` per operazioni leggere, `arq` per job pesanti
- **Lifespan:** `@asynccontextmanager async def lifespan(app)` per startup/shutdown (connection pool, cache warm-up)

## Framework Adapter: Django + DRF

- **Views:** class-based con `APIView` o `ModelViewSet` (DRF). Function-based solo per endpoint semplici
- **Serializers:** `ModelSerializer` con `fields` espliciti (mai `fields = "__all__"`), validazione custom in `validate_<field>`
- **Admin:** registrare TUTTI i model con `list_display`, `search_fields`, `list_filter` minimi
- **URL routing:** `path()` con namespace, `DefaultRouter` per ViewSet DRF
- **Signals:** usare con parsimonia. Preferire service layer esplicito a signal impliciti
- **Async Django:** `async def view(request)` supportato da Django 4.1+. ASGI via `uvicorn myproject.asgi:application`

## Framework Adapter: Flask

- **Blueprint:** un blueprint per dominio, registrato in `create_app()` factory
- **Extensions:** `Flask-SQLAlchemy`, `Flask-Migrate`, `Flask-JWT-Extended`, `Flask-CORS`
- **App factory:** `create_app(config_name)` pattern obbligatorio, mai `app = Flask(__name__)` globale
- **Error handler:** `@app.errorhandler(AppError)` registrato nella factory
- **Context:** `g` per request-scoped state (db session, current user). `current_app` per config access
- **Async:** Flask 2.0+ supporta `async def` route. Per async pieno preferire FastAPI

---

## Regole (MUST)

1. **MUST usare src layout** — mai codice applicativo nella root del progetto
2. **MUST separare service da router** — business logic nei service, mai nei handler/view
3. **MUST tipizzare** — type hint su tutti i parametri e return, `mypy --strict` come target
4. **MUST validare input** — Pydantic schema per ogni endpoint, mai trust di dati raw
5. **MUST usare migration tool** — Alembic (SQLAlchemy) o Django migrations. Mai `CREATE TABLE` manuale
6. **MUST avere health endpoint** — `/health` che verifica tutte le dipendenze
7. **MUST loggare strutturato** — JSON in produzione con `request_id`, `user_id`, `duration_ms`
8. **MUST testare service layer** — coverage >= 80% su `services/`
9. **MUST non esporre stacktrace** — error handler catch-all in produzione, dettagli solo in log

---

## Anti-Pattern

| Anti-Pattern | Problema | Approccio Corretto |
|---|---|---|
| Business logic nei router/view | Non testabile, non riusabile | Estrarre in `services/`, handler chiama service |
| Query ORM nei handler | Coupling con DB, N+1 nascosti | Repository pattern, eager loading esplicito |
| `from settings import *` | Namespace pollution, config implicita | Import esplicito: `from app.config import settings` |
| `except Exception: pass` | Bug silenziati, debug impossibile | Log + re-raise o errore tipizzato |
| Secret hardcoded | Leak in version control | `pydantic-settings` / `environ`, `.env` in `.gitignore` |
| Test che dipendono da ordine | Flaky test, CI non deterministica | Fixture isolate, DB rollback per test |
| `fields = "__all__"` (DRF) | Espone campi interni (password, token) | `fields` lista esplicita sempre |
| Global app instance (Flask) | Import circolari, test impossibili | App factory `create_app()` |
| Sync ORM in async handler | Event loop bloccato, latenza | `AsyncSession` o `sync_to_async` wrapper |
| No migration review | Schema drift, data loss | Autogenerate + review manuale obbligatoria |

---

> **v0.2.0** | Domain skill | Pack: full-stack
