---
name: data-tables
description: "Use when building data tables with sorting, filtering, pagination, and selection. Covers TanStack Table (OSS) with React and shadcn/ui DataTable. Triggers on: data table, TanStack Table, sorting, filtering, pagination, column visibility, row selection, DataTable, spreadsheet."
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

# Data Tables -- TanStack Table for React

## Why This Exists

| Problem | Solution |
|---------|----------|
| Data tables are in every dashboard/admin, no dedicated skill | Complete TanStack Table patterns |
| Premium table libraries are expensive (AG Grid) | OSS-first with TanStack Table |
| Table features (sort, filter, paginate) are complex to implement | Ready-to-use patterns with shadcn/ui |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| TanStack Table | AG Grid |
| shadcn/ui DataTable | Kendo UI Grid |

## Core Workflow

### 1. Setup

```bash
npm install @tanstack/react-table
```

### 2. Basic Table with shadcn/ui

```typescript
"use client"
import { ColumnDef, flexRender, getCoreRowModel, useReactTable,
  getSortedRowModel, getFilteredRowModel, getPaginationRowModel } from "@tanstack/react-table"

// Define columns (type-safe)
const columns: ColumnDef<User>[] = [
  { accessorKey: "name", header: "Name",
    cell: ({ row }) => <span className="font-medium">{row.getValue("name")}</span> },
  { accessorKey: "email", header: "Email" },
  { accessorKey: "role", header: "Role",
    filterFn: "equals" },
  { accessorKey: "createdAt", header: "Created",
    cell: ({ row }) => new Date(row.getValue("createdAt")).toLocaleDateString() }
]

// Table component
export function UsersTable({ data }: { data: User[] }) {
  const [sorting, setSorting] = useState<SortingState>([])
  const [filtering, setFiltering] = useState("")

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    onSortingChange: setSorting,
    state: { sorting, globalFilter: filtering }
  })

  return (
    <div>
      <Input placeholder="Search..." value={filtering}
        onChange={(e) => setFiltering(e.target.value)} className="mb-4" />

      <Table>
        <TableHeader>
          {table.getHeaderGroups().map((hg) => (
            <TableRow key={hg.id}>
              {hg.headers.map((h) => (
                <TableHead key={h.id} onClick={h.column.getToggleSortingHandler()}
                  className="cursor-pointer select-none">
                  {flexRender(h.column.columnDef.header, h.getContext())}
                  {{ asc: " ↑", desc: " ↓" }[h.column.getIsSorted() as string] ?? ""}
                </TableHead>
              ))}
            </TableRow>
          ))}
        </TableHeader>
        <TableBody>
          {table.getRowModel().rows.map((row) => (
            <TableRow key={row.id}>
              {row.getVisibleCells().map((cell) => (
                <TableCell key={cell.id}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </TableCell>
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>

      {/* Pagination */}
      <div className="flex items-center gap-2 mt-4">
        <Button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
          Previous
        </Button>
        <span>Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}</span>
        <Button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
          Next
        </Button>
      </div>
    </div>
  )
}
```

### 3. Row Selection

```typescript
const columns: ColumnDef<User>[] = [
  { id: "select",
    header: ({ table }) => <Checkbox checked={table.getIsAllPageRowsSelected()}
      onCheckedChange={(v) => table.toggleAllPageRowsSelected(!!v)} />,
    cell: ({ row }) => <Checkbox checked={row.getIsSelected()}
      onCheckedChange={(v) => row.toggleSelected(!!v)} /> },
  // ... other columns
]

const table = useReactTable({
  enableRowSelection: true,
  onRowSelectionChange: setRowSelection,
  state: { rowSelection }
})

// Get selected rows
const selected = table.getFilteredSelectedRowModel().rows
```

### 4. Server-Side Pagination

```typescript
// For large datasets: paginate on server
const { data, isLoading } = useQuery({
  queryKey: ["users", pagination, sorting, filters],
  queryFn: () => fetchUsers({ page: pagination.pageIndex, pageSize: pagination.pageSize,
    sort: sorting, filters })
})

const table = useReactTable({
  data: data?.rows ?? [],
  pageCount: data?.pageCount ?? -1,
  manualPagination: true,
  manualSorting: true,
  manualFiltering: true,
  onPaginationChange: setPagination,
  state: { pagination, sorting }
})
```

## Rules

1. TanStack Table for ALL data table needs (headless, flexible, type-safe)
2. Use shadcn/ui Table components for consistent styling
3. Server-side pagination for datasets > 1000 rows
4. Always provide global search + column-specific filters
5. Sortable columns by default (opt-out, not opt-in)
6. Row selection with bulk actions for admin interfaces

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Client-side pagination for large datasets | Loads all data, slow | Server-side pagination via API |
| Building table from scratch | Reinventing complex logic | TanStack Table (handles all edge cases) |
| AG Grid for simple tables | Expensive, heavy bundle | TanStack Table (free, headless, lighter) |
| No loading states | Table jumps on data fetch | Skeleton rows while loading |
| Fixed column widths | Breaks on different screens | Responsive: hide columns on mobile |
