---
name: pptx
description: "Use when working with presentations (.pptx files): creating new presentations, modifying or editing content, working with layouts, adding comments or speaker notes, or any other presentation task."
type: technique
---

# PPTX Creation, Editing, and Analysis

## Reading and Analyzing Content

**Text extraction:** `python -m markitdown path-to-file.pptx`

**Raw XML access** (for comments, speaker notes, layouts, animations, formatting):
- Unpack: `python ooxml/scripts/unpack.py <office_file> <output_dir>`
- Key paths: `ppt/slides/slide{N}.xml`, `ppt/notesSlides/notesSlide{N}.xml`, `ppt/comments/`, `ppt/slideLayouts/`, `ppt/slideMasters/`, `ppt/theme/`, `ppt/media/`
- Typography/color extraction: Read `ppt/theme/theme1.xml` for `<a:clrScheme>` and `<a:fontScheme>`, examine slide XML for `<a:rPr>`, grep for `<a:solidFill>` and `<a:srgbClr>`

## Creating New Presentations (without template)

Uses **html2pptx** workflow.

### Design Principles

Before creating any presentation:
1. Analyze subject matter, tone, industry, audience
2. Check for branding/company identity
3. Match color palette to content
4. State design approach BEFORE writing code

**Requirements:**
- Web-safe fonts only: Arial, Helvetica, Times New Roman, Georgia, Courier New, Verdana, Tahoma, Trebuchet MS, Impact
- Clear visual hierarchy through size, weight, color
- Strong contrast, appropriately sized text, clean alignment
- Consistent patterns across slides

**Color palette:** Pick 3-5 colors (dominant + supporting + accent). Ensure text readable on backgrounds. Be creative with combinations.

**Layout rules for charts/tables:**
- Two-column layout (PREFERRED): header spans full width, text + chart side by side
- Full-slide: chart takes entire slide for maximum impact
- NEVER vertically stack text above charts/tables

### Workflow

| Step | Action |
|------|--------|
| 1 | **MANDATORY**: Read [`html2pptx.md`](html2pptx.md) completely (no range limits) |
| 2 | Create HTML file per slide (720pt x 405pt for 16:9). Use `<p>`, `<h1>`-`<h6>`, lists. Use `class="placeholder"` for chart/table areas. Rasterize gradients/icons as PNG via Sharp first. |
| 3 | Create JS file using [`html2pptx.js`](scripts/html2pptx.js) to convert HTML to PPTX. Add charts/tables via PptxGenJS API. Save with `pptx.writeFile()`. |
| 4 | Validate: `python scripts/thumbnail.py output.pptx workspace/thumbnails --cols 4`. Check for text cutoff, overlap, positioning, contrast. Fix and regenerate until correct. |

## Editing Existing Presentations

Uses raw OOXML workflow.

| Step | Action |
|------|--------|
| 1 | **MANDATORY**: Read [`ooxml.md`](ooxml.md) completely (no range limits) |
| 2 | Unpack: `python ooxml/scripts/unpack.py <file> <output_dir>` |
| 3 | Edit XML files (primarily `ppt/slides/slide{N}.xml`) |
| 4 | Validate after EACH edit: `python ooxml/scripts/validate.py <dir> --original <file>` |
| 5 | Pack: `python ooxml/scripts/pack.py <input_dir> <office_file>` |

## Creating from Template

| Step | Action |
|------|--------|
| 1 | Extract text (`python -m markitdown template.pptx`) + create thumbnails (`python scripts/thumbnail.py template.pptx`). Read both completely. |
| 2 | Analyze template, save `template-inventory.md` listing every slide (0-indexed) with layout and purpose. |
| 3 | Create `outline.md` with content + template mapping. Match layout structure to actual content (count content pieces BEFORE selecting layout). Never use layouts with more placeholders than content. |
| 4 | Rearrange: `python scripts/rearrange.py template.pptx working.pptx 0,34,34,50,52` |
| 5 | Extract inventory: `python scripts/inventory.py working.pptx text-inventory.json`. Read entirely. |
| 6 | Create `replacement-text.json` with `"paragraphs"` for shapes needing content. Shapes without paragraphs are auto-cleared. Include formatting properties (bold, bullet, alignment, color). When `bullet: true`, do NOT include bullet symbols in text. |
| 7 | Apply: `python scripts/replace.py working.pptx replacement-text.json output.pptx` |

## Thumbnail Grids

```bash
python scripts/thumbnail.py template.pptx [output_prefix] [--cols 4]
```
Default: 5 columns, max 30 slides/grid. Slides are 0-indexed.

## Code Style

Write concise code. Avoid verbose variable names, redundant operations, and unnecessary print statements.

## Dependencies

markitdown, pptxgenjs, playwright, react-icons, sharp, LibreOffice (PDF conversion), Poppler (pdftoppm), defusedxml
