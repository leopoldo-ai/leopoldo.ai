---
name: amplemarket-api
version: 0.2.0
description: Use when implementing Amplemarket enrichment, building people search, managing sequences, or debugging Amplemarket API issues. Covers all endpoints (contacts, people search/find, enrichment, companies, email validation, sequences, lead lists, tasks, calls), rate limits, cursor-based pagination, credit model, and enrichment workflow patterns.
type: technique
---

# Amplemarket API — Reference Skill

Complete reference for Amplemarket API integration.

## Base Configuration

| Parametro | Valore |
|-----------|--------|
| **Base URL** | `https://api.amplemarket.com` (endpoints direttamente sotto root, es. `GET /people/search`) |
| **Auth** | Bearer Token (`Authorization: Bearer <API_KEY>`) |
| **Rate Limit Global** | 500 richieste/minuto |
| **Content-Type** | `application/json` |
| **Pagination** | Cursor-based: `page[size]`, `page[before]`, `page[after]` |
| **Error Format** | `{ _errors: [{ status, code, title, detail, source }] }` |

## Autenticazione

```typescript
const headers = {
  'Authorization': `Bearer ${process.env.AMPLEMARKET_API_KEY}`,
  'Content-Type': 'application/json',
};
```

> **IMPORTANTE**: Mai esporre `AMPLEMARKET_API_KEY` nel client-side. Solo server-side.

## Rate Limits per Endpoint

| Endpoint | Limite | Note |
|----------|--------|------|
| **Globale** | 500 req/min | Tutti gli endpoint combinati |
| `POST /people/search` | 300 req/min | Ricerca persone |
| `POST /people/find` | 300 req/min | Trova persona specifica |
| `POST /sequences/{id}/leads` | 30 req/min | Aggiungi lead a sequenza |

### Usage Limits (non rate-based)

| Operazione | Limite |
|------------|--------|
| Enrichment requests | **15.000/ora** |
| Email validations per request | **100.000 max** |
| Page size max | **100** |

### Credit Model

Amplemarket usa un modello a crediti. Ogni operazione consuma crediti:

- **People Search**: 1 credito per risultato trovato
- **People Find**: 1 credito per persona trovata
- **Enrichment**: 1 credito per profilo arricchito
- **Email Validation**: Crediti variabili per volume

> Monitorare il consumo crediti per evitare interruzioni del servizio.

## Pagination — Cursor-based

A differenza di Manatal (offset-based), Amplemarket usa cursor pagination:

```typescript
// Prima pagina
const response = await fetch('https://api.amplemarket.com/contacts?page[size]=100', {
  headers
});
const data = await response.json();

// Pagina successiva (usare cursor dal link `next`)
// data._links.next contiene il cursor
const nextPage = await fetch(
  `https://api.amplemarket.com/contacts?page[size]=100&page[after]=${data._links.next}`,
  { headers }
);
```

**Response pagination structure:**

```json
{
  "data": [...],
  "_links": {
    "self": "...",
    "next": "cursor_token_abc123",
    "prev": null
  },
  "_meta": {
    "total": 5000,
    "page_size": 100
  }
}
```

## Error Handling

### Error Response Structure

```json
{
  "_errors": [
    {
      "status": "422",
      "code": "invalid_parameter",
      "title": "Invalid Parameter",
      "detail": "The email field is not a valid email address",
      "source": {
        "parameter": "email"
      }
    }
  ]
}
```

### HTTP Status Codes

| Code | Significato | Azione |
|------|-------------|--------|
| 200 | OK | Processare response |
| 201 | Created | Risorsa creata |
| 202 | Accepted | Operazione asincrona avviata (enrichment) |
| 400 | Bad Request | Validare payload |
| 401 | Unauthorized | API key invalida |
| 403 | Forbidden | Permessi insufficienti o crediti esauriti |
| 404 | Not Found | Risorsa non trovata |
| 422 | Unprocessable Entity | Errore di validazione (dettagli in `_errors`) |
| 429 | Rate Limited | Backoff esponenziale |
| 500 | Server Error | Retry con backoff |

## Endpoints — Contacts

### List Contacts

```
GET /contacts?page[size]=100
```

**Response:**

```json
{
  "data": [
    {
      "id": "contact_abc123",
      "type": "contact",
      "attributes": {
        "email": "mario.rossi@acme.it",
        "first_name": "Mario",
        "last_name": "Rossi",
        "title": "CTO",
        "company_name": "Acme SpA",
        "phone": "+39 333 1234567",
        "linkedin_url": "https://linkedin.com/in/mariorossi",
        "location": "Milan, Italy",
        "industry": "Technology",
        "created_at": "2024-06-15T10:00:00Z",
        "updated_at": "2024-07-01T14:30:00Z"
      }
    }
  ],
  "_links": { "next": "...", "prev": null }
}
```

### Get / Create / Update / Delete Contact

```
GET    /contacts/{id}
POST   /contacts
PATCH  /contacts/{id}
DELETE /contacts/{id}
```

## Endpoints — People Search (Enrichment Proxy LinkedIn)

**This is the key endpoint for data enrichment.** Amplemarket acts as a proxy for LinkedIn data.

### Search People

```
POST /people/search
```

**Rate limit:** 300 req/min

**Body:**

```json
{
  "filters": {
    "name": "Mario Rossi",
    "company": "Acme SpA",
    "title": "CTO",
    "location": "Italy",
    "industry": "Technology",
    "seniority": ["c_suite", "vp", "director"],
    "company_size": ["51-200", "201-500"]
  },
  "page": {
    "size": 25
  }
}
```

**Response:**

```json
{
  "data": [
    {
      "id": "person_xyz",
      "type": "person",
      "attributes": {
        "first_name": "Mario",
        "last_name": "Rossi",
        "full_name": "Mario Rossi",
        "email": "mario.rossi@acme.it",
        "email_status": "verified",
        "phone": "+39 333 1234567",
        "title": "Chief Technology Officer",
        "seniority": "c_suite",
        "department": "Engineering",
        "company_name": "Acme SpA",
        "company_domain": "acme.it",
        "company_industry": "Technology",
        "company_size": "201-500",
        "company_linkedin_url": "https://linkedin.com/company/acme",
        "linkedin_url": "https://linkedin.com/in/mariorossi",
        "location": "Milan, Lombardy, Italy",
        "country": "Italy",
        "skills": ["Cloud Architecture", "Team Leadership", "DevOps"]
      }
    }
  ]
}
```

### Find Specific Person

```
POST /people/find
```

**Rate limit:** 300 req/min

**Body:**

```json
{
  "email": "mario.rossi@acme.it"
}
```

oppure:

```json
{
  "linkedin_url": "https://linkedin.com/in/mariorossi"
}
```

oppure:

```json
{
  "first_name": "Mario",
  "last_name": "Rossi",
  "company": "Acme SpA"
}
```

## Endpoints — Enrichment Requests

**Endpoint asincrono** — sottometti richieste, ricevi risultati via webhook o polling.

### Create Enrichment Request

```
POST /enrichment-requests
```

**Limite:** 15.000 richieste/ora

**Body:**

```json
{
  "data": {
    "type": "enrichment_request",
    "attributes": {
      "linkedin_url": "https://linkedin.com/in/mariorossi"
    }
  }
}
```

oppure con email:

```json
{
  "data": {
    "type": "enrichment_request",
    "attributes": {
      "email": "mario.rossi@acme.it"
    }
  }
}
```

**Response (202 Accepted):**

```json
{
  "data": {
    "id": "enr_abc123",
    "type": "enrichment_request",
    "attributes": {
      "status": "pending",
      "created_at": "2024-07-01T12:00:00Z"
    }
  }
}
```

### Get Enrichment Request Status

```
GET /enrichment-requests/{id}
```

**Response (completed):**

```json
{
  "data": {
    "id": "enr_abc123",
    "type": "enrichment_request",
    "attributes": {
      "status": "completed",
      "result": {
        "first_name": "Mario",
        "last_name": "Rossi",
        "email": "mario.rossi@acme.it",
        "email_status": "verified",
        "title": "CTO",
        "company_name": "Acme SpA",
        "seniority": "c_suite",
        "skills": ["Cloud", "DevOps"],
        "linkedin_url": "https://linkedin.com/in/mariorossi"
      },
      "completed_at": "2024-07-01T12:00:05Z"
    }
  }
}
```

### List Enrichment Requests

```
GET /enrichment-requests?page[size]=100
```

Filtri: `filter[status]=completed|pending|failed`

## Endpoints — Companies

### Search Companies

```
GET /companies?filter[domain]=acme.it
GET /companies?filter[name]=Acme
```

**Response:**

```json
{
  "data": [
    {
      "id": "company_abc",
      "type": "company",
      "attributes": {
        "name": "Acme SpA",
        "domain": "acme.it",
        "industry": "Technology",
        "size": "201-500",
        "location": "Milan, Italy",
        "linkedin_url": "https://linkedin.com/company/acme",
        "description": "...",
        "founded_year": 2010,
        "revenue_range": "10M-50M"
      }
    }
  ]
}
```

## Endpoints — Email Validation

### Validate Emails (Batch)

```
POST /email-validations
```

**Limite:** 100.000 email per richiesta

**Body:**

```json
{
  "data": {
    "type": "email_validation",
    "attributes": {
      "emails": [
        "mario.rossi@acme.it",
        "info@invalid-domain.xyz"
      ]
    }
  }
}
```

**Response:**

```json
{
  "data": {
    "type": "email_validation",
    "attributes": {
      "results": [
        {
          "email": "mario.rossi@acme.it",
          "status": "valid",
          "is_deliverable": true,
          "is_catch_all": false
        },
        {
          "email": "info@invalid-domain.xyz",
          "status": "invalid",
          "is_deliverable": false,
          "is_catch_all": false
        }
      ]
    }
  }
}
```

## Endpoints — Sequences

### List Sequences

```
GET /sequences?page[size]=50
```

### Get Sequence Details

```
GET /sequences/{id}
```

### Add Leads to Sequence

```
POST /sequences/{id}/leads
```

**Rate limit:** 30 req/min (il piu' restrittivo)

**Body:**

```json
{
  "data": [
    {
      "type": "lead",
      "attributes": {
        "email": "mario.rossi@acme.it",
        "first_name": "Mario",
        "last_name": "Rossi",
        "company_name": "Acme SpA",
        "title": "CTO",
        "custom_fields": {
          "source": "app",
          "manatal_id": "12345"
        }
      }
    }
  ]
}
```

### List Sequence Leads

```
GET /sequences/{id}/leads?page[size]=100
```

## Endpoints — Lead Lists

```
GET    /lead-lists                 # List
GET    /lead-lists/{id}            # Detail
POST   /lead-lists                 # Create
PATCH  /lead-lists/{id}            # Update
DELETE /lead-lists/{id}            # Delete
POST   /lead-lists/{id}/leads      # Add leads
```

## Endpoints — Tasks & Calls

```
GET /tasks?page[size]=50           # List tasks
GET /tasks/{id}                     # Task detail
GET /calls?page[size]=50            # List calls
GET /calls/{id}                     # Call detail
```

## Endpoints — Mailboxes

```
GET /mailboxes                      # List connected mailboxes
```

## Endpoints — Exclusion Lists

```
GET    /exclusion-lists             # List
POST   /exclusion-lists             # Create
DELETE /exclusion-lists/{id}        # Delete
POST   /exclusion-lists/{id}/entries # Add entries (domains/emails)
```

## Enrichment Workflow

Recommended pattern for enriching contacts via Amplemarket.

### Flusso

```
Manatal Contact (linkedin_url)
  → Amplemarket Enrichment Request
  → Webhook/Polling per risultato
  → Update App DB (enriched fields)
  → Track in enrichment_log
```

### Implementazione Cron Enrichment

```typescript
// Pseudocode — cron enrichment batch job
async function enrichContacts() {
  // 1. Seleziona contatti da arricchire (mai enriched o stale > 90 giorni)
  const toEnrich = await db.select()
    .from(contacts)
    .where(
      or(
        isNull(contacts.enriched_at),
        lt(contacts.enriched_at, subDays(new Date(), 90))
      )
    )
    .where(isNotNull(contacts.linkedin_url))
    .orderBy(contacts.enriched_at)  // null first = mai enriched
    .limit(100);  // batch size (15K/hour limit = ~250/min safe)

  // 2. Invia enrichment requests
  for (const contact of toEnrich) {
    const response = await fetch(
      'https://api.amplemarket.com/enrichment-requests',
      {
        method: 'POST',
        headers,
        body: JSON.stringify({
          data: {
            type: 'enrichment_request',
            attributes: {
              linkedin_url: contact.linkedin_url
            }
          }
        })
      }
    );

    if (response.status === 429) {
      // Rate limited — stop batch
      break;
    }

    if (response.status === 202) {
      const data = await response.json();
      // 3. Salva enrichment request ID per polling successivo
      await db.insert(enrichmentLog).values({
        contact_id: contact.id,
        provider: 'amplemarket',
        request_id: data.data.id,
        status: 'pending',
        requested_at: new Date(),
      });
    }
  }

  // 4. Controlla enrichment completati (batch precedenti)
  const pending = await db.select()
    .from(enrichmentLog)
    .where(eq(enrichmentLog.status, 'pending'))
    .limit(200);

  for (const log of pending) {
    const result = await fetch(
      `https://api.amplemarket.com/enrichment-requests/${log.request_id}`,
      { headers }
    );
    const data = await result.json();

    if (data.data.attributes.status === 'completed') {
      const enriched = data.data.attributes.result;
      await db.update(contacts)
        .set({
          current_title: enriched.title,
          current_company: enriched.company_name,
          seniority: enriched.seniority,
          skills: enriched.skills,
          email_verified: enriched.email_status === 'verified',
          enriched_at: new Date(),
          enrichment_source: 'amplemarket',
          enrichment_data: enriched,  // JSONB full payload
        })
        .where(eq(contacts.id, log.contact_id));

      await db.update(enrichmentLog)
        .set({ status: 'completed', completed_at: new Date() })
        .where(eq(enrichmentLog.id, log.id));
    }
  }
}
```

### Seniority Mapping

Amplemarket restituisce seniority standardizzata:

| Valore | Descrizione |
|--------|-------------|
| `c_suite` | CEO, CTO, CFO, COO, etc. |
| `vp` | Vice President |
| `director` | Director |
| `manager` | Manager |
| `senior` | Senior individual contributor |
| `entry` | Entry level |
| `intern` | Intern |

## Key Field Mapping

| Amplemarket Field | App Column | Note |
|-------------------|-------------------|------|
| `email` | `email` | Verificata da Amplemarket |
| `email_status` | `email_verified` | boolean mapping |
| `first_name` + `last_name` | `full_name` | Concatenare |
| `title` | `current_title` | Enrichment |
| `company_name` | `current_company` | Enrichment |
| `seniority` | `seniority` | Enrichment |
| `skills` | `skills` (JSONB) | Enrichment |
| `linkedin_url` | `linkedin_url` | Validato |
| `phone` | `phone` | Enrichment |
| `location` | `city` / `country` | Parse necessario |
| (full result) | `enrichment_data` (JSONB) | Payload completo |

## Webhooks Amplemarket

Amplemarket supporta webhook per notifiche async (enrichment completato, sequence events).

Configurazione via dashboard Amplemarket.

```
POST /api/webhooks/amplemarket
```

### Validazione Webhook

```typescript
import { z } from 'zod';

const AmplemarketWebhookSchema = z.object({
  event: z.string(),
  data: z.object({
    id: z.string(),
    type: z.string(),
    attributes: z.record(z.unknown()),
  }),
  timestamp: z.string().datetime(),
});
```

## Anti-Patterns

- **MAI** superare 15K enrichment/ora — il servizio blocca l'account
- **MAI** fare enrichment senza `linkedin_url` o `email` — spreco di crediti
- **MAI** ignorare il campo `email_status` — usare solo email `verified` per outreach
- **MAI** fare people/search senza filtri specifici — risultati troppo ampi, spreco crediti
- **MAI** aggiungere lead a sequenze senza validazione email
- **MAI** esporre API key nel frontend
- **MAI** fare polling aggressivo su enrichment requests — usare batch con intervalli ragionevoli (ogni 5 min)
- **MAI** arricchire lo stesso contatto piu' volte in 90 giorni — configurare `enriched_at` check
