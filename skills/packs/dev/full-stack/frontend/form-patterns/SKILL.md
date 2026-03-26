---
name: form-patterns
description: "Use when building forms in React/Next.js. Covers React Hook Form, Zod validation, server actions, multi-step forms, and file uploads. OSS-first: React Hook Form + Zod primary. Triggers on: form, validation, React Hook Form, Zod, useForm, server action form, file upload, multi-step form."
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

# Form Patterns -- Forms with React Hook Form and Zod

## Why This Exists

| Problem | Solution |
|---------|----------|
| Forms are 60% of web app interactions, no dedicated skill | Complete form patterns with validation |
| Developers reinvent form logic every project | Reusable patterns with React Hook Form + Zod |
| Server-side validation often forgotten | Server Actions with Zod for full-stack validation |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Alternative) |
|-------------------|----------------------|
| React Hook Form | Formik (heavier) |
| Zod (validation) | Yup, Valibot |
| conform (server actions) | -- |

## Core Workflow

### 1. Basic Form (React Hook Form + Zod)

```typescript
"use client"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"

const schema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Invalid email address"),
  role: z.enum(["user", "admin", "editor"]),
  bio: z.string().max(500).optional()
})

type FormData = z.infer<typeof schema>

export function ProfileForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { role: "user" }
  })

  const onSubmit = async (data: FormData) => {
    await updateProfile(data)
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register("name")} />
      {errors.name && <span className="text-red-500">{errors.name.message}</span>}

      <input {...register("email")} type="email" />
      {errors.email && <span className="text-red-500">{errors.email.message}</span>}

      <select {...register("role")}>
        <option value="user">User</option>
        <option value="admin">Admin</option>
      </select>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "Saving..." : "Save"}
      </button>
    </form>
  )
}
```

### 2. Server Action Validation

```typescript
// lib/schemas.ts - Shared schema (client + server)
export const contactSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  message: z.string().min(10).max(1000)
})

// app/actions.ts
"use server"
import { contactSchema } from "@/lib/schemas"

export async function submitContact(formData: FormData) {
  const parsed = contactSchema.safeParse({
    name: formData.get("name"),
    email: formData.get("email"),
    message: formData.get("message")
  })

  if (!parsed.success) {
    return { error: parsed.error.flatten().fieldErrors }
  }

  await db.insert(contacts).values(parsed.data)
  return { success: true }
}
```

### 3. With shadcn/ui Form Components

```typescript
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form"
import { Input } from "@/components/ui/input"

export function ProfileForm() {
  const form = useForm<FormData>({ resolver: zodResolver(schema) })

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField control={form.control} name="name" render={({ field }) => (
          <FormItem>
            <FormLabel>Name</FormLabel>
            <FormControl><Input {...field} /></FormControl>
            <FormMessage />
          </FormItem>
        )} />
      </form>
    </Form>
  )
}
```

### 4. Multi-Step Form

```typescript
const steps = [PersonalInfo, AddressInfo, Review] as const
const [step, setStep] = useState(0)

// Validate per-step with partial schemas
const stepSchemas = [
  schema.pick({ name: true, email: true }),
  schema.pick({ address: true, city: true }),
  schema // Full schema on final step
]

const handleNext = async () => {
  const isValid = await form.trigger(Object.keys(stepSchemas[step].shape))
  if (isValid) setStep((s) => s + 1)
}
```

### 5. File Upload

```typescript
const fileSchema = z.object({
  file: z.instanceof(File)
    .refine((f) => f.size < 5_000_000, "Max 5MB")
    .refine((f) => ["image/jpeg", "image/png"].includes(f.type), "Only JPG/PNG")
})

// With React Hook Form
const { register } = useForm({ resolver: zodResolver(fileSchema) })
<input type="file" {...register("file")} accept="image/*" />
```

## Rules

1. React Hook Form + Zod for ALL forms (type-safe, performant)
2. Share Zod schemas between client and server (single source of truth)
3. ALWAYS validate on server side too (never trust client validation alone)
4. Use shadcn/ui Form components for consistent styling
5. Show inline errors immediately after field blur, not only on submit
6. Disable submit button while submitting (prevent double submit)
7. Use controlled components only when needed (RHF is uncontrolled by default)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Client-only validation | Easily bypassed | Validate on both client AND server |
| Manual state for each field | Verbose, re-renders entire form | React Hook Form (uncontrolled, performant) |
| Different schemas client/server | Validation drift, inconsistencies | Share Zod schema between both |
| Error messages only on submit | Bad UX, user doesn't know what's wrong | Show on blur + on submit |
| No loading state on submit | User clicks multiple times | Disable button, show spinner |
