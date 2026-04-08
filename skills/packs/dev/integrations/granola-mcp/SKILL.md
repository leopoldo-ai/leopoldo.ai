---
name: granola-mcp
version: 0.2.0
description: Granola MCP integration skill. Connects Granola AI meeting transcription to a contact database via MCP (Model Context Protocol). Automates meeting→structured report→contact update pipeline. Covers 10 MCP tools, AI extraction prompts for scorecard/fields, participant matching, and auto-update patterns. Use when implementing meeting integration, building the meeting→contact pipeline, or configuring Granola MCP server.
license: Apache-2.0
metadata:
  author: pedramamini
  source: https://github.com/pedramamini/GranolaMCP
---

# Granola MCP — Meeting Intelligence Integration

Granola AI integration to automate the meeting → structured report → contact update cycle.

## Overview

Granola is a desktop tool that records and transcribes meetings (Google Meet, Zoom, Teams). Via MCP (Model Context Protocol), the application accesses meetings, transcripts and notes to:

1. **Auto-update** contact records with data extracted from meetings
2. **Generate scorecards** automatically based on configurable evaluation areas
3. **Save structured reports** linked to contacts and jobs
4. **Track interaction history** for each contact/organization

## Architettura

```
Partner fa meeting (Meet/Zoom/Teams)
         ↓
Granola Desktop → trascrive + genera note AI
         ↓
Granola cache locale (cache-v3.json)
         ↓
GranolaMCP Server (Python 3.12+, locale)
         ↓  MCP Protocol (JSON-RPC)
App API Route (/api/meetings/process)
         ↓
AI Extraction (structured data from transcript)
         ↓
DB Update (Drizzle/Neon): meeting_reports + contacts
```

### Approcci disponibili

| Approccio | URL/Config | Pro | Contro |
|-----------|-----------|-----|--------|
| **Granola MCP ufficiale** | `https://mcp.granola.ai/mcp` | Plug & play, supportato | Piano a pagamento, dati via cloud |
| **GranolaMCP locale** (pedramamini) | Cache locale `cache-v3.json` | Zero API calls, privacy, 10 tools | Python 3.12+, setup manuale |
| **granola-mcp** (mishkinf) | Cache locale + embeddings | Ricerca semantica, temi | Richiede OpenAI API key |

**Recommendation:** GranolaMCP local (pedramamini) for privacy and full control.

## Setup — GranolaMCP Server Locale

### Installazione

```bash
# Prerequisiti
python3 --version  # >= 3.12

# Clone e install
git clone https://github.com/pedramamini/GranolaMCP.git
cd GranolaMCP
pip install -e .
```

### Configurazione MCP Client

Per Claude Desktop (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "granola-mcp": {
      "command": "python",
      "args": ["-m", "granola_mcp.mcp"],
      "env": {
        "GRANOLA_CACHE_PATH": "~/Library/Application Support/Granola/cache-v3.json"
      }
    }
  }
}
```

For programmatic integration via MCP SDK:

```typescript
// lib/mcp/granola-client.ts
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

export async function createGranolaClient() {
  const transport = new StdioClientTransport({
    command: 'python',
    args: ['-m', 'granola_mcp.mcp'],
    env: {
      GRANOLA_CACHE_PATH: process.env.GRANOLA_CACHE_PATH!,
    },
  });

  const client = new Client({
    name: 'my-app',
    version: '1.0.0',
  });

  await client.connect(transport);
  return client;
}
```

## MCP Tools — Reference Completo

### 1. `get_recent_meetings`

Recupera gli ultimi X meeting.

```typescript
const result = await client.callTool({
  name: 'get_recent_meetings',
  arguments: { limit: 10 },
});
// Returns: [{id, title, date, duration, participants[], summary}]
```

**Usage:** Cron job ogni 15 min — controlla nuovi meeting da processare.

### 2. `list_meetings`

Lista meeting con filtri data.

```typescript
const result = await client.callTool({
  name: 'list_meetings',
  arguments: {
    start_date: '2026-02-01',
    end_date: '2026-02-28',
  },
});
```

**Usage:** Dashboard "meeting del mese", filtri per periodo.

### 3. `search_meetings`

Ricerca avanzata: testo, partecipanti, date.

```typescript
const result = await client.callTool({
  name: 'search_meetings',
  arguments: {
    query: 'Mario Rossi',
    participant: 'mario.rossi@acme.it',
  },
});
```

**Usage:** "Trova tutti i meeting con questo candidato" nella scheda contatto.

### 4. `get_meeting`

Dettaglio completo di un meeting.

```typescript
const result = await client.callTool({
  name: 'get_meeting',
  arguments: { meeting_id: 'abc-123' },
});
// Returns: {id, title, date, duration, participants[], notes, summary, metadata}
```

**Usage:** Pagina dettaglio meeting report.

### 5. `get_transcript`

Trascrizione completa con identificazione speaker.

```typescript
const result = await client.callTool({
  name: 'get_transcript',
  arguments: { meeting_id: 'abc-123' },
});
// Returns: {meeting_id, transcript: [{speaker, timestamp, text}]}
```

**Usage:** Input per AI extraction — il tool piu' importante per l'automazione.

### 6. `get_meeting_notes`

Note strutturate (AI-generated + umane).

```typescript
const result = await client.callTool({
  name: 'get_meeting_notes',
  arguments: { meeting_id: 'abc-123' },
});
// Returns: {meeting_id, ai_summary, human_notes, action_items[]}
```

**Usage:** Pre-compilazione report, action items per follow-up.

### 7. `list_participants`

Analisi partecipanti con storico meeting.

```typescript
const result = await client.callTool({
  name: 'list_participants',
  arguments: {},
});
// Returns: [{name, email, meeting_count, last_meeting_date}]
```

**Usage:** Matching partecipante → contatto DB (per email).

### 8. `get_statistics`

Analytics: durata media, frequenza, pattern.

```typescript
const result = await client.callTool({
  name: 'get_statistics',
  arguments: {},
});
```

**Usage:** KPI dashboard — meeting per partner, durata media interviste.

### 9. `export_meeting`

Export in formato markdown.

```typescript
const result = await client.callTool({
  name: 'export_meeting',
  arguments: { meeting_id: 'abc-123' },
});
```

**Usage:** Archiviazione, allegato a scheda contatto.

### 10. `analyze_patterns`

Trend e pattern nei meeting.

```typescript
const result = await client.callTool({
  name: 'analyze_patterns',
  arguments: {},
});
```

**Usage:** Insight operativi per management.

## Data Model — Tabelle Meeting

### meeting_reports

```sql
CREATE TABLE meeting_reports (
  id SERIAL PRIMARY KEY,
  contact_id INTEGER REFERENCES contacts(id),
  job_id INTEGER REFERENCES jobs(id),
  granola_meeting_id TEXT UNIQUE NOT NULL,
  meeting_date TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER,
  participants JSONB,
  transcript_summary TEXT,
  structured_data JSONB NOT NULL,
  raw_notes TEXT,
  scorecard JSONB,
  processed_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_meeting_reports_contact ON meeting_reports(contact_id);
CREATE INDEX idx_meeting_reports_job ON meeting_reports(job_id);
CREATE INDEX idx_meeting_reports_date ON meeting_reports(meeting_date DESC);
```

### contact_auto_updates

```sql
CREATE TABLE contact_auto_updates (
  id SERIAL PRIMARY KEY,
  contact_id INTEGER REFERENCES contacts(id),
  source TEXT NOT NULL,  -- 'granola_meeting' | 'amplemarket_enrichment' | 'manatal_sync'
  fields_updated JSONB NOT NULL,
  meeting_report_id INTEGER REFERENCES meeting_reports(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_auto_updates_contact ON contact_auto_updates(contact_id);
```

### structured_data JSONB Schema

```typescript
import { z } from 'zod';

const MeetingStructuredDataSchema = z.object({
  current_title: z.string().optional(),
  current_company: z.string().optional(),
  skills_mentioned: z.array(z.string()).default([]),
  availability: z.enum(['active', 'passive', 'not_looking', 'unknown']).default('unknown'),
  salary_expectation: z.object({
    min: z.number().optional(),
    max: z.number().optional(),
    currency: z.string().default('EUR'),
  }).optional(),
  motivation_level: z.enum(['high', 'medium', 'low', 'unknown']).default('unknown'),
  cultural_fit: z.enum(['strong', 'moderate', 'weak', 'unknown']).default('unknown'),
  red_flags: z.array(z.string()).default([]),
  strengths: z.array(z.string()).default([]),
  next_steps: z.array(z.string()).default([]),
  follow_up_date: z.string().datetime().optional(),
  interview_stage: z.string().optional(),
});
```

### scorecard JSONB Schema — Configurable Evaluation Areas

```typescript
const ScorecardSchema = z.object({
  technical_skills: z.object({
    score: z.number().min(1).max(5),
    evidence: z.string(),
    notes: z.string().optional(),
  }),
  leadership_management: z.object({
    score: z.number().min(1).max(5),
    evidence: z.string(),
    notes: z.string().optional(),
  }),
  soft_skills_cultural_fit: z.object({
    score: z.number().min(1).max(5),
    evidence: z.string(),
    notes: z.string().optional(),
  }),
  motivation_availability: z.object({
    score: z.number().min(1).max(5),
    evidence: z.string(),
    notes: z.string().optional(),
  }),
  track_record_results: z.object({
    score: z.number().min(1).max(5),
    evidence: z.string(),
    notes: z.string().optional(),
  }),
  overall_score: z.number().min(1).max(5),
  recommendation: z.enum(['strong_yes', 'yes', 'maybe', 'no', 'strong_no']),
  summary: z.string(),
});
```

## AI Extraction — Prompt per Analisi Trascrizione

### Prompt: Estrazione Campi Strutturati

```typescript
const EXTRACTION_PROMPT = `You are an expert analyst.
Analyze this meeting transcript with a candidate.

TRASCRIZIONE:
{transcript}

NOTE GRANOLA:
{notes}

Estrai un JSON strutturato con questi campi:

{
  "current_title": "titolo attuale menzionato dal candidato",
  "current_company": "azienda attuale",
  "skills_mentioned": ["skill1", "skill2"],
  "availability": "active|passive|not_looking|unknown",
  "salary_expectation": {"min": N, "max": N, "currency": "EUR"},
  "motivation_level": "high|medium|low|unknown",
  "cultural_fit": "strong|moderate|weak|unknown",
  "red_flags": ["flag1 con evidenza"],
  "strengths": ["punto di forza con evidenza"],
  "next_steps": ["azione1", "azione2"],
  "follow_up_date": "YYYY-MM-DD o null",
  "interview_stage": "screening|first|second|final|offer"
}

Regole:
- Estrai SOLO informazioni esplicitamente menzionate nella trascrizione
- Per campi non menzionati, usa "unknown" o null
- Le evidenze devono citare frasi specifiche dalla trascrizione
- salary_expectation solo se il candidato ha dato numeri concreti
- red_flags: segnali negativi oggettivi (gap inspiegati, incoerenze, etc.)
- NON inventare informazioni non presenti nella trascrizione`;
```

### Prompt: Scorecard 5 Aree

```typescript
const SCORECARD_PROMPT = `You are a senior evaluator.
Compila una scorecard per questo candidato basata sulla trascrizione del meeting.

TRASCRIZIONE:
{transcript}

JOB CONTEXT (if available):
{job_context}

Valuta su 5 aree (score 1-5, dove 5 = eccellente):

1. **Competenze tecniche/settoriali**: esperienza specifica nel settore/ruolo target, hard skills rilevanti, certificazioni, track record tecnico
2. **Leadership & Management**: gestione team, decision making, capacita' di delega, visione strategica, P&L ownership
3. **Soft skills & Cultural fit**: comunicazione, empatia, adattabilita', allineamento con cultura aziendale target
4. **Motivazione & Disponibilita'**: interesse reale per l'opportunita', tempistiche, notice period, relocation willingness
5. **Track record & Risultati**: achievement concreti con numeri, KPI raggiunti, promozioni, crescita di business

Per ogni area fornisci:
- score (1-5)
- evidence: citazione diretta dalla trascrizione che giustifica il punteggio
- notes: osservazioni aggiuntive (opzionale)

Output:
- overall_score: media ponderata (leadership e track record pesano doppio per ruoli C-level)
- recommendation: strong_yes | yes | maybe | no | strong_no
- summary: 2-3 frasi di sintesi`;
```

## Pipeline Completa — Meeting Processing

### API Route: /api/meetings/process

```typescript
// Pseudocode — meeting processing pipeline
async function processMeetings() {
  const granola = await createGranolaClient();

  // 1. Recupera meeting recenti non ancora processati
  const recentMeetings = await granola.callTool({
    name: 'get_recent_meetings',
    arguments: { limit: 20 },
  });

  const processedIds = await db.select({ id: meetingReports.granolaMeetingId })
    .from(meetingReports);
  const processedSet = new Set(processedIds.map(r => r.id));

  const newMeetings = recentMeetings.filter(m => !processedSet.has(m.id));

  for (const meeting of newMeetings) {
    // 2. Recupera trascrizione e note
    const [transcript, notes] = await Promise.all([
      granola.callTool({ name: 'get_transcript', arguments: { meeting_id: meeting.id } }),
      granola.callTool({ name: 'get_meeting_notes', arguments: { meeting_id: meeting.id } }),
    ]);

    // 3. Match partecipanti → contatti DB
    const contact = await matchParticipantToContact(meeting.participants);
    if (!contact) continue;

    // 4. Match job (if referenced in meeting)
    const job = await matchMeetingToJob(meeting.title, contact.id);

    // 5. AI Extraction — campi strutturati
    const structuredData = await extractStructuredData(transcript, notes);

    // 6. AI Scorecard — configurable evaluation areas
    const scorecard = await generateScorecard(transcript, job);

    // 7. Salva meeting report
    const [report] = await db.insert(meetingReports).values({
      contactId: contact.id,
      jobId: job?.id ?? null,
      granolaMeetingId: meeting.id,
      meetingDate: meeting.date,
      durationMinutes: meeting.duration,
      participants: meeting.participants,
      transcriptSummary: notes.ai_summary,
      structuredData,
      rawNotes: notes.human_notes,
      scorecard,
    }).returning();

    // 8. Auto-update contatto (solo campi con nuove info)
    const updates = buildContactUpdates(contact, structuredData);
    if (Object.keys(updates.fields).length > 0) {
      await db.update(contacts)
        .set(updates.fields)
        .where(eq(contacts.id, contact.id));

      await db.insert(contactAutoUpdates).values({
        contactId: contact.id,
        source: 'granola_meeting',
        fieldsUpdated: updates.changelog,
        meetingReportId: report.id,
      });
    }
  }

  await granola.close();
}
```

### Participant Matching

```typescript
async function matchParticipantToContact(
  participants: { name: string; email: string }[]
): Promise<Contact | null> {
  // Configure with your organization's email domains to filter out internal participants
  const INTERNAL_DOMAINS = (process.env.INTERNAL_EMAIL_DOMAINS ?? '').split(',').filter(Boolean);
  const externals = participants.filter(
    p => !INTERNAL_DOMAINS.some(d => p.email?.endsWith(d))
  );

  if (externals.length === 0) return null;

  // Match per email (priorita')
  for (const ext of externals) {
    if (ext.email) {
      const match = await db.select().from(contacts)
        .where(eq(contacts.email, ext.email))
        .limit(1);
      if (match[0]) return match[0];
    }
  }

  // Match per nome (fallback fuzzy)
  for (const ext of externals) {
    const match = await db.select().from(contacts)
      .where(ilike(contacts.fullName, `%${ext.name}%`))
      .limit(1);
    if (match[0]) return match[0];
  }

  return null;
}
```

## Cron Schedule

```json
// vercel.json
{
  "crons": [
    { "path": "/api/cron/sync-manatal", "schedule": "*/5 * * * *" },
    { "path": "/api/cron/process-meetings", "schedule": "*/15 * * * *" },
    { "path": "/api/cron/enrich-contacts", "schedule": "0 */2 * * *" }
  ]
}
```

## Privacy & GDPR

- **Granola locale**: trascrizioni restano sul Mac del partner, mai inviate a cloud terzi
- **AI extraction**: processed server-side, data stored in PostgreSQL
- **Consent**: il candidato deve essere informato della registrazione meeting
- **Right to erasure**: cancellazione meeting_reports + contact_auto_updates nel flusso GDPR
- **Retention**: meeting_reports seguono la stessa data retention policy dei contatti

## Anti-Patterns

- **MAI** processare meeting senza match contatto — rischio report orfani
- **MAI** sovrascrivere dati contatto senza changelog in contact_auto_updates
- **MAI** processare meeting interni (solo meeting con esterni)
- **MAI** fidarsi ciecamente dell'AI extraction — il partner deve poter review/edit la scorecard
- **MAI** registrare meeting senza consenso del candidato
- **MAI** usare il server MCP cloud in produzione senza valutazione GDPR completa
