---
name: manatal-api
version: 0.2.0
description: Use when implementing Manatal sync, building a Manatal API client, handling Manatal webhooks, or debugging Manatal Open API v3 issues. Covers all endpoints (candidates, organizations, jobs, activities, webhooks), rate limits, pagination, payload structures, and chunked sync patterns for large contact databases.
type: technique
---

# Manatal Open API v3 — Reference Skill

Complete reference for Manatal API integration.

## Base Configuration

| Parametro | Valore |
|-----------|--------|
| **Base URL** | `https://api.manatal.com/open/v3` |
| **Auth** | Bearer Token (`Authorization: Token <API_KEY>`) |
| **Rate Limit** | 100 richieste/minuto per token |
| **Rate Limit Header** | HTTP 429 Too Many Requests quando superato |
| **Content-Type** | `application/json` |
| **Pagination** | Offset-based: `page` (1-indexed) + `page_size` (max 100) |
| **Response Format** | `{ count, next, previous, results[] }` |

## Autenticazione

```typescript
const headers = {
  'Authorization': `Token ${process.env.MANATAL_API_KEY}`,
  'Content-Type': 'application/json',
};
```

> **IMPORTANTE**: Mai esporre `MANATAL_API_KEY` nel client-side. Usare solo in API routes server-side o cron jobs.

## Rate Limiting & Resilience

### Limiti

- **100 req/min** per API token
- Nessun header `X-RateLimit-Remaining` — bisogna tracciare lato client
- HTTP 429 = rate limit superato, risposta senza body utile

### Pattern Raccomandato: Exponential Backoff + Circuit Breaker

```typescript
// Chunked sync + webhook coexistence pattern
const RATE_LIMIT = {
  maxPerMinute: 100,
  safePerMinute: 80,        // margine 20% per webhook concorrenti
  backoffBase: 1000,         // 1s base
  backoffMax: 30000,         // 30s max
  circuitBreakerThreshold: 5, // 5 errori consecutivi = circuit open
  circuitBreakerReset: 60000, // 60s prima di retry
};
```

### Coordinamento Cron + Webhook

Il cron sync (400 records/invocazione) e i webhook Manatal condividono lo stesso rate limit. Pattern:

1. Cron usa max **80 req/min** (lascia 20 per webhook)
2. Se webhook riceve 429, il cron si mette in pausa alla prossima invocazione
3. `sync_state` traccia `last_rate_limit_hit` per coordinamento

## Endpoints — Candidates

### List Candidates

```
GET /open/v3/candidates/
```

**Query Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `page` | integer | Pagina (1-indexed) |
| `page_size` | integer | Record per pagina (max 100) |
| `created_after` | datetime | Filtro data creazione (ISO 8601) |
| `modified_after` | datetime | Filtro ultima modifica (ISO 8601) |

**Response:**

```json
{
  "count": 198432,
  "next": "https://api.manatal.com/open/v3/candidates/?page=2&page_size=100",
  "previous": null,
  "results": [
    {
      "id": 12345,
      "uid": "abc-123-def",
      "full_name": "Mario Rossi",
      "first_name": "Mario",
      "last_name": "Rossi",
      "email": "mario.rossi@example.com",
      "phone_number": "+39 333 1234567",
      "current_position": "Senior Developer",
      "current_company": "Acme SpA",
      "current_salary": 50000,
      "expected_salary": 60000,
      "currency": "EUR",
      "country": "Italy",
      "city": "Roma",
      "address": "Via Roma 1",
      "postal_code": "00100",
      "date_of_birth": "1990-01-15",
      "gender": "male",
      "nationality": "Italian",
      "linkedin": "https://linkedin.com/in/mariorossi",
      "social_accounts": [],
      "skills": ["TypeScript", "React", "Node.js"],
      "languages": [{"language": "Italian", "level": "native"}],
      "educations": [],
      "experiences": [],
      "tags": ["senior", "frontend"],
      "custom_fields": {},
      "source": "LinkedIn",
      "status": "active",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-06-20T14:22:00Z"
    }
  ]
}
```

### Get Single Candidate

```
GET /open/v3/candidates/{id}/
```

### Create Candidate

```
POST /open/v3/candidates/
```

**Body:** Stessi campi della response (senza `id`, `uid`, `created_at`, `updated_at`).

### Update Candidate

```
PATCH /open/v3/candidates/{id}/
```

**Body:** Solo i campi da aggiornare (partial update).

### Delete Candidate

```
DELETE /open/v3/candidates/{id}/
```

### Nested Endpoints — Candidates

| Endpoint | Method | Descrizione |
|----------|--------|-------------|
| `/candidates/{id}/activities/` | GET | Attivita' del candidato |
| `/candidates/{id}/attachments/` | GET, POST | Allegati (CV, documenti) |
| `/candidates/{id}/educations/` | GET, POST | Percorsi formativi |
| `/candidates/{id}/experiences/` | GET, POST | Esperienze lavorative |
| `/candidates/{id}/matches/` | GET | Match con job openings |
| `/candidates/{id}/notes/` | GET, POST | Note interne |
| `/candidates/{id}/resume/` | GET | Resume/CV parsed |
| `/candidates/{id}/social-media/` | GET | Link social media |

## Endpoints — Organizations (Client Companies)

### List Organizations

```
GET /open/v3/organizations/
```

**Query Parameters:** `page`, `page_size`, `created_after`, `modified_after`

**Response:**

```json
{
  "count": 1250,
  "next": "...",
  "previous": null,
  "results": [
    {
      "id": 567,
      "name": "Acme Corporation SpA",
      "industry": "Technology",
      "website": "https://acme.it",
      "description": "...",
      "phone_number": "+39 02 1234567",
      "email": "hr@acme.it",
      "address": "Via Milano 10",
      "city": "Milano",
      "country": "Italy",
      "postal_code": "20100",
      "linkedin": "https://linkedin.com/company/acme",
      "tags": ["enterprise", "tech"],
      "custom_fields": {},
      "created_at": "2024-01-10T09:00:00Z",
      "updated_at": "2024-07-01T11:30:00Z"
    }
  ]
}
```

### Get / Create / Update / Delete Organization

```
GET    /open/v3/organizations/{id}/
POST   /open/v3/organizations/
PATCH  /open/v3/organizations/{id}/
DELETE /open/v3/organizations/{id}/
```

### Nested Endpoints — Organizations

| Endpoint | Method | Descrizione |
|----------|--------|-------------|
| `/organizations/{id}/activities/` | GET | Attivita' dell'organizzazione |
| `/organizations/{id}/attachments/` | GET, POST | Allegati |
| `/organizations/{id}/notes/` | GET, POST | Note interne |

## Endpoints — Jobs

```
GET    /open/v3/jobs/                    # List
GET    /open/v3/jobs/{id}/               # Detail
POST   /open/v3/jobs/                    # Create
PATCH  /open/v3/jobs/{id}/               # Update
DELETE /open/v3/jobs/{id}/               # Delete
```

### Nested — Jobs

| Endpoint | Method | Descrizione |
|----------|--------|-------------|
| `/jobs/{id}/activities/` | GET | Attivita' del job |
| `/jobs/{id}/attachments/` | GET, POST | Allegati |
| `/jobs/{id}/matches/` | GET | Candidate matches |
| `/jobs/{id}/notes/` | GET, POST | Note |

## Endpoints — Placements & Pipelines

```
GET /open/v3/placements/                  # Placement tracking
GET /open/v3/candidate_job_matches/       # Match candidato-job
GET /open/v3/pipeline_stages/             # Stage della pipeline
```

## Webhooks Manatal

Manatal invia webhook per eventi su candidati e organizzazioni.

### Configurazione

Configurati via dashboard Manatal (Settings > Webhooks). Puntano a:
```
POST /api/webhooks/manatal
```

### Payload Webhook

```json
{
  "event": "candidate.updated",
  "data": {
    "id": 12345,
    "full_name": "Mario Rossi",
    "...": "..."
  },
  "timestamp": "2024-07-01T12:00:00Z"
}
```

### Eventi supportati

| Evento | Trigger |
|--------|---------|
| `candidate.created` | Nuovo candidato |
| `candidate.updated` | Candidato modificato |
| `candidate.deleted` | Candidato eliminato |
| `organization.created` | Nuova organizzazione |
| `organization.updated` | Organizzazione modificata |
| `organization.deleted` | Organizzazione eliminata |

### Validazione Webhook

```typescript
// Verificare signature se disponibile, altrimenti validare IP source
// + Zod validation del payload
import { z } from 'zod';

const ManatalWebhookSchema = z.object({
  event: z.enum([
    'candidate.created', 'candidate.updated', 'candidate.deleted',
    'organization.created', 'organization.updated', 'organization.deleted',
  ]),
  data: z.record(z.unknown()),
  timestamp: z.string().datetime(),
});
```

## Chunked Sync Pattern

Pattern for synchronizing large contact databases without timeout or rate limit issues.

### Strategia

1. **Cron Vercel** (ogni 5 minuti) esegue 1 invocazione
2. Ogni invocazione processa **4 pagine x 100 record = 400 record**
3. Cursore salvato in `sync_state` (tabella Neon)
4. Full sync completo in ~500 invocazioni (~42 ore)
5. Sync incrementale usa `modified_after` per aggiornamenti delta

### Implementazione

```typescript
// Pseudocode chunked sync
async function syncManatalChunk() {
  const state = await db.select().from(syncState)
    .where(eq(syncState.provider, 'manatal'))
    .limit(1);

  const cursor = state[0]?.cursor_position ?? 1;
  const PAGES_PER_CHUNK = 4;
  const PAGE_SIZE = 100;

  for (let i = 0; i < PAGES_PER_CHUNK; i++) {
    const page = cursor + i;
    const response = await fetch(
      `https://api.manatal.com/open/v3/candidates/?page=${page}&page_size=${PAGE_SIZE}`,
      { headers: { 'Authorization': `Token ${API_KEY}` } }
    );

    if (response.status === 429) {
      // Rate limited — salva cursore e riprova al prossimo cron
      await updateSyncState(cursor + i, 'rate_limited');
      return;
    }

    const data = await response.json();
    await upsertContacts(data.results);

    if (!data.next) {
      // Sync completo
      await updateSyncState(1, 'completed');
      return;
    }
  }

  await updateSyncState(cursor + PAGES_PER_CHUNK, 'in_progress');
}
```

### Validazione Completezza

```typescript
// Dopo full sync, verificare completezza
const manatalTotal = await fetch('/open/v3/candidates/?page_size=1')
  .then(r => r.json())
  .then(d => d.count);

const localTotal = await db.select({ count: count() })
  .from(contacts)
  .where(eq(contacts.source, 'manatal'));

const completeness = (localTotal[0].count / manatalTotal) * 100;
// Se < 99.5%, flaggare per review manuale
```

## Key Field Mapping

| Manatal Field | App Column | Note |
|---------------|-------------------|------|
| `id` | `manatal_id` | PK mapping |
| `full_name` | `full_name` | |
| `email` | `email` | |
| `phone_number` | `phone` | |
| `current_position` | `current_title` | |
| `current_company` | `current_company` | |
| `linkedin` | `linkedin_url` | |
| `skills` | `skills` (JSONB) | Array |
| `tags` | `tags` (JSONB) | Array |
| `custom_fields` | `custom_fields` (JSONB) | Object |
| `source` | `source` | |
| `created_at` | `created_at` | |
| `updated_at` | `updated_at` | Per sync incrementale |

## Error Handling

| HTTP Code | Significato | Azione |
|-----------|-------------|--------|
| 200 | OK | Processare response |
| 201 | Created | Risorsa creata |
| 400 | Bad Request | Validare payload, loggare errore |
| 401 | Unauthorized | API key invalida, controllare env |
| 403 | Forbidden | Permessi insufficienti |
| 404 | Not Found | Risorsa non esiste (potrebbe essere stata eliminata) |
| 429 | Rate Limited | Backoff esponenziale, coordinare con sync |
| 500 | Server Error | Retry con backoff, circuit breaker |

## Anti-Patterns

- **MAI** fare polling aggressivo (>80 req/min) — lasciare margine per webhook
- **MAI** usare `page_size` > 100 — non supportato
- **MAI** ignorare HTTP 429 — implementare sempre backoff
- **MAI** fare full sync senza cursor — rischio di duplicati o record persi
- **MAI** esporre API key nel frontend
- **MAI** assumere che `count` sia stabile durante la paginazione — usare `modified_after` per delta sync
