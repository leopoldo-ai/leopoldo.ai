---
name: file-storage
description: "Use when handling file uploads, storage, and serving. Covers MinIO (S3-compatible OSS), uploadthing, presigned URLs, and image optimization. OSS-first: MinIO primary, S3/R2 as alternatives. Triggers on: file upload, storage, S3, MinIO, uploadthing, presigned URL, file serving, blob storage, image upload."
type: technique
metadata:
  author: leopoldo
  source: custom
  created: 2026-03-24
  forge_strategy: build
license: MIT
upstream:
  url: null
  version: null
  last_checked: 2026-03-24
---

# File Storage -- Upload, Store, and Serve Files

## Why This Exists

| Problem | Solution |
|---------|----------|
| File handling is complex (upload, validate, store, serve) | Complete patterns from upload to CDN |
| S3 is the standard but proprietary | MinIO: S3-compatible, self-hostable |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| MinIO (S3-compatible, self-host) | AWS S3 |
| uploadthing (simple uploads) | Cloudflare R2 |
| Sharp (image processing) | Cloudinary |

## Core Workflow

### 1. Presigned Upload (S3/MinIO)

```typescript
// app/api/upload/route.ts
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3"
import { getSignedUrl } from "@aws-sdk/s3-request-presigner"

const s3 = new S3Client({
  endpoint: process.env.S3_ENDPOINT, // MinIO or S3
  region: "auto",
  credentials: { accessKeyId: process.env.S3_KEY!, secretAccessKey: process.env.S3_SECRET! }
})

export async function POST(req: Request) {
  const { filename, contentType } = await req.json()
  const key = `uploads/${Date.now()}-${filename}`

  const url = await getSignedUrl(s3, new PutObjectCommand({
    Bucket: process.env.S3_BUCKET!,
    Key: key,
    ContentType: contentType
  }), { expiresIn: 3600 })

  return Response.json({ uploadUrl: url, key })
}

// Client: upload directly to S3 (no server relay)
const { uploadUrl } = await fetch("/api/upload", {
  method: "POST",
  body: JSON.stringify({ filename: file.name, contentType: file.type })
}).then(r => r.json())

await fetch(uploadUrl, { method: "PUT", body: file, headers: { "Content-Type": file.type } })
```

### 2. Server-Side Validation

```typescript
// Validate before generating presigned URL
const MAX_SIZE = 10 * 1024 * 1024 // 10MB
const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp", "application/pdf"]

if (fileSize > MAX_SIZE) return Response.json({ error: "File too large" }, { status: 400 })
if (!ALLOWED_TYPES.includes(contentType)) return Response.json({ error: "Invalid type" }, { status: 400 })
```

## Rules

1. Presigned URLs for uploads (client uploads directly, no server relay)
2. Validate file type and size on BOTH client and server
3. MinIO for self-hosted S3-compatible storage
4. Generate unique keys with timestamp to prevent collisions
5. Use Sharp for server-side image optimization
6. Never serve uploads from the same domain as your app (use CDN/separate domain)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Upload through your server | Memory/bandwidth bottleneck | Presigned URLs (direct to storage) |
| No file type validation | Security risk (malicious files) | Validate type + size server-side |
| Storing files in database | DB bloat, slow queries | Object storage (S3/MinIO) |
| Same domain for uploads | XSS vector, mixed content | Separate CDN domain |
