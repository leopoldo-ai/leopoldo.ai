# ARIA Patterns — Detailed Implementation Guide

Reference companion for the `accessibility` skill. Contains production-ready code examples for 10 common interactive patterns, following WAI-ARIA Authoring Practices 1.2.

---

## 1. Dialog / Modal

A dialog is a window overlaid on the primary content. It traps focus and blocks interaction with the rest of the page.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `role="dialog"` | Dialog container | Identifies the element as a dialog |
| `aria-modal="true"` | Dialog container | Indicates the dialog is modal (background is inert) |
| `aria-labelledby` | Dialog container | Points to the dialog's heading |
| `aria-describedby` | Dialog container | Points to the dialog's description (optional) |

### Keyboard Interaction

| Key | Action |
|-----|--------|
| Tab | Moves focus to next focusable element inside the dialog; wraps from last to first |
| Shift+Tab | Moves focus to previous focusable element; wraps from first to last |
| Escape | Closes the dialog and returns focus to the trigger |

### Implementation

```html
<!-- Trigger button -->
<button id="open-dialog" aria-haspopup="dialog">Delete account</button>

<!-- Dialog -->
<div
  id="confirm-dialog"
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-desc"
  hidden
>
  <h2 id="dialog-title">Delete your account?</h2>
  <p id="dialog-desc">
    This action is permanent. All your data will be deleted and cannot be recovered.
  </p>
  <div class="dialog-actions">
    <button id="dialog-cancel">Cancel</button>
    <button id="dialog-confirm" class="destructive">Delete permanently</button>
  </div>
</div>
```

```typescript
class AccessibleDialog {
  private dialog: HTMLElement;
  private trigger: HTMLElement;
  private focusableElements: HTMLElement[];
  private previouslyFocused: HTMLElement | null = null;

  constructor(dialogId: string, triggerId: string) {
    this.dialog = document.getElementById(dialogId)!;
    this.trigger = document.getElementById(triggerId)!;
    this.focusableElements = [];

    this.trigger.addEventListener('click', () => this.open());
    this.dialog.addEventListener('keydown', (e) => this.handleKeydown(e));
  }

  open(): void {
    this.previouslyFocused = document.activeElement as HTMLElement;
    this.dialog.hidden = false;

    // Make background inert
    document.querySelectorAll('body > *:not([role="dialog"])').forEach((el) => {
      (el as HTMLElement).inert = true;
    });

    // Collect focusable elements
    this.focusableElements = Array.from(
      this.dialog.querySelectorAll<HTMLElement>(
        'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
      )
    );

    // Focus first focusable element (or the close/cancel button)
    if (this.focusableElements.length > 0) {
      this.focusableElements[0].focus();
    }
  }

  close(): void {
    this.dialog.hidden = true;

    // Restore background
    document.querySelectorAll('body > *').forEach((el) => {
      (el as HTMLElement).inert = false;
    });

    // Return focus to trigger
    this.previouslyFocused?.focus();
  }

  private handleKeydown(event: KeyboardEvent): void {
    if (event.key === 'Escape') {
      this.close();
      return;
    }

    if (event.key === 'Tab') {
      const first = this.focusableElements[0];
      const last = this.focusableElements[this.focusableElements.length - 1];

      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }
  }
}
```

### React Implementation

```tsx
import { useRef, useEffect, useCallback } from 'react';
import { createPortal } from 'react-dom';

interface DialogProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  description?: string;
  children: React.ReactNode;
}

export function Dialog({ isOpen, onClose, title, description, children }: DialogProps) {
  const dialogRef = useRef<HTMLDivElement>(null);
  const previousFocusRef = useRef<HTMLElement | null>(null);
  const titleId = `dialog-title-${title.replace(/\s+/g, '-').toLowerCase()}`;
  const descId = description ? `dialog-desc-${title.replace(/\s+/g, '-').toLowerCase()}` : undefined;

  const handleKeydown = useCallback((e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      onClose();
      return;
    }

    if (e.key === 'Tab' && dialogRef.current) {
      const focusable = dialogRef.current.querySelectorAll<HTMLElement>(
        'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
      );
      const first = focusable[0];
      const last = focusable[focusable.length - 1];

      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }
  }, [onClose]);

  useEffect(() => {
    if (isOpen) {
      previousFocusRef.current = document.activeElement as HTMLElement;
      document.addEventListener('keydown', handleKeydown);

      // Focus first focusable element
      requestAnimationFrame(() => {
        const firstFocusable = dialogRef.current?.querySelector<HTMLElement>(
          'a[href], button:not([disabled]), input:not([disabled])'
        );
        firstFocusable?.focus();
      });

      return () => {
        document.removeEventListener('keydown', handleKeydown);
        previousFocusRef.current?.focus();
      };
    }
  }, [isOpen, handleKeydown]);

  if (!isOpen) return null;

  return createPortal(
    <>
      <div className="dialog-backdrop" onClick={onClose} aria-hidden="true" />
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        aria-describedby={descId}
        className="dialog"
      >
        <h2 id={titleId}>{title}</h2>
        {description && <p id={descId}>{description}</p>}
        {children}
      </div>
    </>,
    document.body
  );
}
```

---

## 2. Tabs

A set of layered sections of content, where only one panel is displayed at a time.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `role="tablist"` | Container of tabs | Groups the tab elements |
| `role="tab"` | Each tab button | Identifies the tab control |
| `role="tabpanel"` | Each content panel | Identifies the tab content |
| `aria-selected="true/false"` | Each tab | Indicates the active tab |
| `aria-controls` | Each tab | Points to the associated tabpanel |
| `aria-labelledby` | Each tabpanel | Points to the controlling tab |
| `tabindex="-1"` | Inactive tabs | Removes from tab order |
| `tabindex="0"` | Active tab | Keeps in tab order |

### Keyboard Interaction

| Key | Action |
|-----|--------|
| Arrow Right | Activates next tab (wraps from last to first) |
| Arrow Left | Activates previous tab (wraps from first to last) |
| Home | Activates first tab |
| End | Activates last tab |
| Tab | Moves focus from active tab into the associated tabpanel |

### Implementation

```tsx
import { useState, useRef, useCallback, useId } from 'react';

interface Tab {
  label: string;
  content: React.ReactNode;
}

interface TabsProps {
  tabs: Tab[];
  label: string; // Accessible label for the tablist
}

export function Tabs({ tabs, label }: TabsProps) {
  const [activeIndex, setActiveIndex] = useState(0);
  const tabRefs = useRef<(HTMLButtonElement | null)[]>([]);
  const baseId = useId();

  const handleKeydown = useCallback(
    (e: React.KeyboardEvent, index: number) => {
      let newIndex: number | null = null;

      switch (e.key) {
        case 'ArrowRight':
          newIndex = (index + 1) % tabs.length;
          break;
        case 'ArrowLeft':
          newIndex = (index - 1 + tabs.length) % tabs.length;
          break;
        case 'Home':
          newIndex = 0;
          break;
        case 'End':
          newIndex = tabs.length - 1;
          break;
        default:
          return;
      }

      e.preventDefault();
      setActiveIndex(newIndex);
      tabRefs.current[newIndex]?.focus();
    },
    [tabs.length]
  );

  return (
    <div>
      <div role="tablist" aria-label={label}>
        {tabs.map((tab, index) => (
          <button
            key={`${baseId}-tab-${index}`}
            ref={(el) => { tabRefs.current[index] = el; }}
            role="tab"
            id={`${baseId}-tab-${index}`}
            aria-selected={activeIndex === index}
            aria-controls={`${baseId}-panel-${index}`}
            tabIndex={activeIndex === index ? 0 : -1}
            onClick={() => setActiveIndex(index)}
            onKeyDown={(e) => handleKeydown(e, index)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {tabs.map((tab, index) => (
        <div
          key={`${baseId}-panel-${index}`}
          role="tabpanel"
          id={`${baseId}-panel-${index}`}
          aria-labelledby={`${baseId}-tab-${index}`}
          tabIndex={0}
          hidden={activeIndex !== index}
        >
          {tab.content}
        </div>
      ))}
    </div>
  );
}
```

---

## 3. Accordion

A vertically stacked set of expandable/collapsible sections.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `aria-expanded="true/false"` | Header button | Indicates section state |
| `aria-controls` | Header button | Points to the content panel |
| `id` | Content panel | Referenced by `aria-controls` |
| `role="region"` (optional) | Content panel | When few accordions on page |
| `aria-labelledby` | Content panel | Points back to the header button |

### Keyboard Interaction

| Key | Action |
|-----|--------|
| Enter / Space | Toggle the focused section |
| Arrow Down | Move focus to next header |
| Arrow Up | Move focus to previous header |
| Home | Move focus to first header |
| End | Move focus to last header |

### Implementation

```tsx
import { useState, useRef, useCallback, useId } from 'react';

interface AccordionItem {
  title: string;
  content: React.ReactNode;
}

interface AccordionProps {
  items: AccordionItem[];
  allowMultiple?: boolean;
}

export function Accordion({ items, allowMultiple = false }: AccordionProps) {
  const [openIndices, setOpenIndices] = useState<Set<number>>(new Set());
  const headerRefs = useRef<(HTMLButtonElement | null)[]>([]);
  const baseId = useId();

  const toggle = useCallback(
    (index: number) => {
      setOpenIndices((prev) => {
        const next = new Set(allowMultiple ? prev : []);
        if (prev.has(index)) {
          next.delete(index);
        } else {
          next.add(index);
        }
        return next;
      });
    },
    [allowMultiple]
  );

  const handleKeydown = useCallback(
    (e: React.KeyboardEvent, index: number) => {
      let targetIndex: number | null = null;

      switch (e.key) {
        case 'ArrowDown':
          targetIndex = (index + 1) % items.length;
          break;
        case 'ArrowUp':
          targetIndex = (index - 1 + items.length) % items.length;
          break;
        case 'Home':
          targetIndex = 0;
          break;
        case 'End':
          targetIndex = items.length - 1;
          break;
        default:
          return;
      }

      e.preventDefault();
      headerRefs.current[targetIndex]?.focus();
    },
    [items.length]
  );

  return (
    <div>
      {items.map((item, index) => {
        const isOpen = openIndices.has(index);
        const headerId = `${baseId}-header-${index}`;
        const panelId = `${baseId}-panel-${index}`;

        return (
          <div key={headerId}>
            <h3>
              <button
                ref={(el) => { headerRefs.current[index] = el; }}
                id={headerId}
                aria-expanded={isOpen}
                aria-controls={panelId}
                onClick={() => toggle(index)}
                onKeyDown={(e) => handleKeydown(e, index)}
              >
                {item.title}
                <span aria-hidden="true">{isOpen ? '−' : '+'}</span>
              </button>
            </h3>
            <div
              id={panelId}
              role="region"
              aria-labelledby={headerId}
              hidden={!isOpen}
            >
              {item.content}
            </div>
          </div>
        );
      })}
    </div>
  );
}
```

---

## 4. Combobox / Autocomplete

A text input with a popup list of suggested values.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `role="combobox"` | Input wrapper or input itself | Identifies the pattern |
| `aria-expanded="true/false"` | Input | Indicates popup visibility |
| `aria-controls` | Input | Points to the listbox |
| `aria-activedescendant` | Input | Points to the currently highlighted option |
| `role="listbox"` | Popup list | Contains the options |
| `role="option"` | Each option | Individual selectable option |
| `aria-selected="true"` | Active option | Currently highlighted option |
| `aria-autocomplete="list/both"` | Input | Type of autocomplete behavior |

### Keyboard Interaction

| Key | Action |
|-----|--------|
| Arrow Down | Open listbox (if closed); move highlight to next option |
| Arrow Up | Move highlight to previous option |
| Enter | Select highlighted option, close listbox |
| Escape | Close listbox without selecting; clear input on second press |
| Home / End | Move to first / last option |

### Implementation

```tsx
import { useState, useRef, useCallback, useEffect, useId } from 'react';

interface ComboboxOption {
  id: string;
  label: string;
}

interface ComboboxProps {
  label: string;
  options: ComboboxOption[];
  onSelect: (option: ComboboxOption) => void;
  placeholder?: string;
}

export function Combobox({ label, options, onSelect, placeholder }: ComboboxProps) {
  const [inputValue, setInputValue] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(-1);
  const inputRef = useRef<HTMLInputElement>(null);
  const listRef = useRef<HTMLUListElement>(null);
  const baseId = useId();

  const filteredOptions = options.filter((opt) =>
    opt.label.toLowerCase().includes(inputValue.toLowerCase())
  );

  const announceResults = useCallback(() => {
    const count = filteredOptions.length;
    const liveRegion = document.getElementById(`${baseId}-live`);
    if (liveRegion) {
      liveRegion.textContent =
        count === 0
          ? 'No results found'
          : `${count} result${count !== 1 ? 's' : ''} available`;
    }
  }, [filteredOptions.length, baseId]);

  useEffect(() => {
    if (isOpen) announceResults();
  }, [isOpen, announceResults]);

  const selectOption = useCallback(
    (option: ComboboxOption) => {
      setInputValue(option.label);
      setIsOpen(false);
      setActiveIndex(-1);
      onSelect(option);
      inputRef.current?.focus();
    },
    [onSelect]
  );

  const handleInputKeydown = useCallback(
    (e: React.KeyboardEvent) => {
      switch (e.key) {
        case 'ArrowDown':
          e.preventDefault();
          if (!isOpen) {
            setIsOpen(true);
            setActiveIndex(0);
          } else {
            setActiveIndex((prev) =>
              prev < filteredOptions.length - 1 ? prev + 1 : 0
            );
          }
          break;

        case 'ArrowUp':
          e.preventDefault();
          setActiveIndex((prev) =>
            prev > 0 ? prev - 1 : filteredOptions.length - 1
          );
          break;

        case 'Enter':
          e.preventDefault();
          if (activeIndex >= 0 && filteredOptions[activeIndex]) {
            selectOption(filteredOptions[activeIndex]);
          }
          break;

        case 'Escape':
          e.preventDefault();
          if (isOpen) {
            setIsOpen(false);
            setActiveIndex(-1);
          } else {
            setInputValue('');
          }
          break;

        case 'Home':
          if (isOpen) {
            e.preventDefault();
            setActiveIndex(0);
          }
          break;

        case 'End':
          if (isOpen) {
            e.preventDefault();
            setActiveIndex(filteredOptions.length - 1);
          }
          break;
      }
    },
    [isOpen, activeIndex, filteredOptions, selectOption]
  );

  const activeDescendant =
    activeIndex >= 0 ? `${baseId}-option-${activeIndex}` : undefined;

  return (
    <div className="combobox-wrapper">
      <label id={`${baseId}-label`} htmlFor={`${baseId}-input`}>
        {label}
      </label>
      <div role="combobox" aria-expanded={isOpen} aria-haspopup="listbox" aria-owns={`${baseId}-listbox`}>
        <input
          ref={inputRef}
          id={`${baseId}-input`}
          type="text"
          aria-autocomplete="list"
          aria-controls={`${baseId}-listbox`}
          aria-activedescendant={activeDescendant}
          aria-labelledby={`${baseId}-label`}
          value={inputValue}
          placeholder={placeholder}
          onChange={(e) => {
            setInputValue(e.target.value);
            setIsOpen(true);
            setActiveIndex(-1);
          }}
          onKeyDown={handleInputKeydown}
          onFocus={() => inputValue && setIsOpen(true)}
          onBlur={() => setTimeout(() => setIsOpen(false), 200)}
        />
      </div>

      <ul
        ref={listRef}
        id={`${baseId}-listbox`}
        role="listbox"
        aria-labelledby={`${baseId}-label`}
        hidden={!isOpen || filteredOptions.length === 0}
      >
        {filteredOptions.map((option, index) => (
          <li
            key={option.id}
            id={`${baseId}-option-${index}`}
            role="option"
            aria-selected={index === activeIndex}
            onClick={() => selectOption(option)}
            onMouseEnter={() => setActiveIndex(index)}
          >
            {option.label}
          </li>
        ))}
      </ul>

      <div id={`${baseId}-live`} role="status" aria-live="polite" className="sr-only" />
    </div>
  );
}
```

---

## 5. Menu (Navigation / Action)

A menu presents a list of actions or functions. Distinct from navigation menus — this is the WAI-ARIA menu pattern for application-like action menus.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `role="menu"` | Menu container | Identifies as a menu |
| `role="menuitem"` | Each menu item | Identifies as a menu item |
| `role="menuitemcheckbox"` | Checkable item | Toggleable menu item |
| `role="menuitemradio"` | Radio item | Mutually exclusive option |
| `aria-haspopup="menu"` | Trigger button | Indicates it opens a menu |
| `aria-expanded="true/false"` | Trigger button | Indicates menu visibility |

### Keyboard Interaction

| Key | Action |
|-----|--------|
| Enter / Space | Activate the focused menu item |
| Arrow Down | Move to next item (wraps) |
| Arrow Up | Move to previous item (wraps) |
| Home | Move to first item |
| End | Move to last item |
| Escape | Close menu, return focus to trigger |
| Character key | Move to next item starting with that character |

### Implementation

```tsx
import { useState, useRef, useCallback, useEffect, useId } from 'react';

interface MenuItem {
  label: string;
  action: () => void;
  disabled?: boolean;
}

interface MenuProps {
  label: string;
  items: MenuItem[];
}

export function Menu({ label, items }: MenuProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(-1);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const menuRef = useRef<HTMLUListElement>(null);
  const itemRefs = useRef<(HTMLLIElement | null)[]>([]);
  const baseId = useId();

  const enabledIndices = items
    .map((item, i) => (item.disabled ? -1 : i))
    .filter((i) => i >= 0);

  const open = useCallback(() => {
    setIsOpen(true);
    setActiveIndex(enabledIndices[0] ?? -1);
  }, [enabledIndices]);

  const close = useCallback(() => {
    setIsOpen(false);
    setActiveIndex(-1);
    triggerRef.current?.focus();
  }, []);

  useEffect(() => {
    if (isOpen && activeIndex >= 0) {
      itemRefs.current[activeIndex]?.focus();
    }
  }, [isOpen, activeIndex]);

  const handleTriggerKeydown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        open();
      }
    },
    [open]
  );

  const getNextEnabled = useCallback(
    (current: number, direction: 1 | -1): number => {
      const idx = enabledIndices.indexOf(current);
      if (idx === -1) return enabledIndices[0] ?? -1;
      const nextIdx = (idx + direction + enabledIndices.length) % enabledIndices.length;
      return enabledIndices[nextIdx];
    },
    [enabledIndices]
  );

  const handleMenuKeydown = useCallback(
    (e: React.KeyboardEvent) => {
      switch (e.key) {
        case 'ArrowDown':
          e.preventDefault();
          setActiveIndex((prev) => getNextEnabled(prev, 1));
          break;
        case 'ArrowUp':
          e.preventDefault();
          setActiveIndex((prev) => getNextEnabled(prev, -1));
          break;
        case 'Home':
          e.preventDefault();
          setActiveIndex(enabledIndices[0] ?? -1);
          break;
        case 'End':
          e.preventDefault();
          setActiveIndex(enabledIndices[enabledIndices.length - 1] ?? -1);
          break;
        case 'Escape':
          e.preventDefault();
          close();
          break;
        case 'Enter':
        case ' ':
          e.preventDefault();
          if (activeIndex >= 0 && !items[activeIndex].disabled) {
            items[activeIndex].action();
            close();
          }
          break;
        default:
          // Character key: jump to item starting with that character
          if (e.key.length === 1) {
            const char = e.key.toLowerCase();
            const match = enabledIndices.find(
              (i) => items[i].label.toLowerCase().startsWith(char) && i > activeIndex
            ) ?? enabledIndices.find(
              (i) => items[i].label.toLowerCase().startsWith(char)
            );
            if (match !== undefined) setActiveIndex(match);
          }
      }
    },
    [activeIndex, close, enabledIndices, getNextEnabled, items]
  );

  return (
    <div className="menu-wrapper">
      <button
        ref={triggerRef}
        aria-haspopup="menu"
        aria-expanded={isOpen}
        aria-controls={`${baseId}-menu`}
        onClick={() => (isOpen ? close() : open())}
        onKeyDown={handleTriggerKeydown}
      >
        {label}
      </button>

      {isOpen && (
        <ul
          ref={menuRef}
          id={`${baseId}-menu`}
          role="menu"
          aria-label={label}
          onKeyDown={handleMenuKeydown}
        >
          {items.map((item, index) => (
            <li
              key={`${baseId}-item-${index}`}
              ref={(el) => { itemRefs.current[index] = el; }}
              role="menuitem"
              tabIndex={index === activeIndex ? 0 : -1}
              aria-disabled={item.disabled || undefined}
              onClick={() => {
                if (!item.disabled) {
                  item.action();
                  close();
                }
              }}
            >
              {item.label}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

---

## 6. Toast / Alert Notifications

Notifications that inform the user of a status change without interrupting their current task.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `role="alert"` | Error/warning toast | Assertive announcement (interrupts screen reader) |
| `role="status"` | Info/success toast | Polite announcement (waits for pause) |
| `aria-live="assertive"` | Error container | Immediate announcement |
| `aria-live="polite"` | Info/status container | Deferred announcement |
| `aria-atomic="true"` | Live region | Announce the entire region content |

### Rules

- Error notifications: use `role="alert"` (implicitly `aria-live="assertive"`).
- Success/info notifications: use `role="status"` (implicitly `aria-live="polite"`).
- The live region container MUST exist in the DOM before content is injected.
- Auto-dismissed toasts MUST remain visible long enough to read (minimum 5 seconds + 1 second per 120 words).
- Include a close/dismiss button for all toasts.
- Focus MUST NOT move to the toast (it should not interrupt keyboard workflow).

### Implementation

```tsx
import { useState, useCallback, useEffect, useRef, useId } from 'react';

type ToastType = 'success' | 'error' | 'warning' | 'info';

interface Toast {
  id: string;
  type: ToastType;
  message: string;
  duration?: number; // ms, undefined = persistent
}

export function ToastContainer() {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const baseId = useId();

  const dismiss = useCallback((id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  const addToast = useCallback((toast: Omit<Toast, 'id'>) => {
    const id = `${baseId}-toast-${Date.now()}`;
    const newToast = { ...toast, id };
    setToasts((prev) => [...prev, newToast]);

    if (toast.duration) {
      setTimeout(() => dismiss(id), toast.duration);
    }
  }, [baseId, dismiss]);

  // Expose addToast globally or via context
  useEffect(() => {
    (window as any).__addToast = addToast;
    return () => { delete (window as any).__addToast; };
  }, [addToast]);

  return (
    <div className="toast-container" aria-label="Notifications">
      {/* Assertive region for errors */}
      <div aria-live="assertive" aria-atomic="true" className="sr-only">
        {toasts
          .filter((t) => t.type === 'error' || t.type === 'warning')
          .map((t) => (
            <div key={t.id}>{t.message}</div>
          ))}
      </div>

      {/* Polite region for success/info */}
      <div aria-live="polite" aria-atomic="true" className="sr-only">
        {toasts
          .filter((t) => t.type === 'success' || t.type === 'info')
          .map((t) => (
            <div key={t.id}>{t.message}</div>
          ))}
      </div>

      {/* Visual toasts */}
      {toasts.map((toast) => (
        <div
          key={toast.id}
          className={`toast toast-${toast.type}`}
          role={toast.type === 'error' ? 'alert' : 'status'}
        >
          <span className="toast-icon" aria-hidden="true">
            {toast.type === 'success' && '✓'}
            {toast.type === 'error' && '✕'}
            {toast.type === 'warning' && '⚠'}
            {toast.type === 'info' && 'ℹ'}
          </span>
          <span className="toast-message">{toast.message}</span>
          <button
            onClick={() => dismiss(toast.id)}
            aria-label={`Dismiss: ${toast.message}`}
            className="toast-close"
          >
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
      ))}
    </div>
  );
}
```

---

## 7. Carousel / Slideshow

A rotating set of content items, typically images or cards.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `role="region"` | Carousel container | Identifies as a landmark |
| `aria-roledescription="carousel"` | Carousel container | Customizes the role announcement |
| `aria-label` | Carousel container | Names the carousel |
| `role="group"` | Each slide | Groups slide content |
| `aria-roledescription="slide"` | Each slide | Customizes the slide announcement |
| `aria-label` | Each slide | "Slide X of Y" |
| `aria-live="off/polite"` | Slide container | Off during auto-rotation, polite when paused |

### Keyboard Interaction

| Key | Action |
|-----|--------|
| Arrow Right / Next button | Show next slide |
| Arrow Left / Previous button | Show previous slide |
| Space / Enter on pause button | Toggle auto-rotation |
| Tab | Move between controls (prev, next, pause, slide indicators) |

### Implementation

```tsx
import { useState, useCallback, useEffect, useRef, useId } from 'react';

interface Slide {
  content: React.ReactNode;
  label: string; // Accessible label for the slide
}

interface CarouselProps {
  slides: Slide[];
  label: string;
  autoRotateInterval?: number; // ms, 0 = no auto-rotate
}

export function Carousel({ slides, label, autoRotateInterval = 0 }: CarouselProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(autoRotateInterval > 0);
  const [isHovered, setIsHovered] = useState(false);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const baseId = useId();

  const goTo = useCallback((index: number) => {
    setCurrentIndex((index + slides.length) % slides.length);
  }, [slides.length]);

  const next = useCallback(() => goTo(currentIndex + 1), [currentIndex, goTo]);
  const prev = useCallback(() => goTo(currentIndex - 1), [currentIndex, goTo]);

  // Auto-rotation
  useEffect(() => {
    if (isPlaying && !isHovered && autoRotateInterval > 0) {
      intervalRef.current = setInterval(next, autoRotateInterval);
      return () => {
        if (intervalRef.current) clearInterval(intervalRef.current);
      };
    }
  }, [isPlaying, isHovered, autoRotateInterval, next]);

  // Respect reduced motion
  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    if (mq.matches) setIsPlaying(false);
    const handler = (e: MediaQueryListEvent) => {
      if (e.matches) setIsPlaying(false);
    };
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  const handleKeydown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'ArrowRight') {
        e.preventDefault();
        next();
      } else if (e.key === 'ArrowLeft') {
        e.preventDefault();
        prev();
      }
    },
    [next, prev]
  );

  const liveRegionPolicy = isPlaying ? 'off' as const : 'polite' as const;

  return (
    <section
      role="region"
      aria-roledescription="carousel"
      aria-label={label}
      onKeyDown={handleKeydown}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <div className="carousel-controls">
        <button onClick={prev} aria-label="Previous slide">
          <span aria-hidden="true">&lsaquo;</span>
        </button>

        {autoRotateInterval > 0 && (
          <button
            onClick={() => setIsPlaying((p) => !p)}
            aria-label={isPlaying ? 'Pause auto-rotation' : 'Start auto-rotation'}
          >
            {isPlaying ? '⏸' : '▶'}
          </button>
        )}

        <button onClick={next} aria-label="Next slide">
          <span aria-hidden="true">&rsaquo;</span>
        </button>
      </div>

      <div aria-live={liveRegionPolicy} aria-atomic="true">
        {slides.map((slide, index) => (
          <div
            key={`${baseId}-slide-${index}`}
            role="group"
            aria-roledescription="slide"
            aria-label={`${slide.label} — Slide ${index + 1} of ${slides.length}`}
            hidden={index !== currentIndex}
          >
            {slide.content}
          </div>
        ))}
      </div>

      {/* Slide indicators */}
      <div role="tablist" aria-label="Slide controls">
        {slides.map((_, index) => (
          <button
            key={`${baseId}-dot-${index}`}
            role="tab"
            aria-selected={index === currentIndex}
            aria-label={`Go to slide ${index + 1}`}
            onClick={() => goTo(index)}
            tabIndex={index === currentIndex ? 0 : -1}
          />
        ))}
      </div>
    </section>
  );
}
```

---

## 8. Tree View

A hierarchical list of items that can be expanded and collapsed.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `role="tree"` | Root container | Identifies the tree widget |
| `role="treeitem"` | Each node | Identifies a tree node |
| `role="group"` | Children container | Groups child nodes under a parent |
| `aria-expanded="true/false"` | Expandable treeitem | Indicates expand state |
| `aria-level` | Each treeitem | Nesting depth (1-based) |
| `aria-setsize` | Each treeitem | Number of siblings |
| `aria-posinset` | Each treeitem | Position among siblings (1-based) |
| `aria-selected="true/false"` | Each treeitem | Selection state |

### Keyboard Interaction

| Key | Action |
|-----|--------|
| Arrow Down | Move to next visible node |
| Arrow Up | Move to previous visible node |
| Arrow Right | Expand collapsed node; if expanded, move to first child |
| Arrow Left | Collapse expanded node; if collapsed, move to parent |
| Home | Move to first node |
| End | Move to last visible node |
| Enter | Activate/select the focused node |
| * (asterisk) | Expand all siblings at the current level |

### Implementation

```tsx
import { useState, useCallback, useRef, useId } from 'react';

interface TreeNode {
  id: string;
  label: string;
  children?: TreeNode[];
}

interface TreeViewProps {
  nodes: TreeNode[];
  label: string;
  onSelect?: (nodeId: string) => void;
}

export function TreeView({ nodes, label, onSelect }: TreeViewProps) {
  const [expanded, setExpanded] = useState<Set<string>>(new Set());
  const [selected, setSelected] = useState<string | null>(null);
  const treeRef = useRef<HTMLUListElement>(null);
  const nodeRefs = useRef<Map<string, HTMLLIElement>>(new Map());

  const toggleExpand = useCallback((id: string) => {
    setExpanded((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }, []);

  const selectNode = useCallback(
    (id: string) => {
      setSelected(id);
      onSelect?.(id);
    },
    [onSelect]
  );

  // Get all visible nodes in DOM order
  const getVisibleNodes = useCallback((): string[] => {
    const result: string[] = [];
    const walk = (nodes: TreeNode[]) => {
      for (const node of nodes) {
        result.push(node.id);
        if (node.children && expanded.has(node.id)) {
          walk(node.children);
        }
      }
    };
    walk(nodes);
    return result;
  }, [nodes, expanded]);

  const focusNode = useCallback((id: string) => {
    nodeRefs.current.get(id)?.focus();
  }, []);

  const findParent = useCallback(
    (targetId: string, searchNodes: TreeNode[], parentId: string | null = null): string | null => {
      for (const node of searchNodes) {
        if (node.id === targetId) return parentId;
        if (node.children) {
          const result = findParent(targetId, node.children, node.id);
          if (result !== null) return result;
        }
      }
      return null;
    },
    [nodes]
  );

  const handleKeydown = useCallback(
    (e: React.KeyboardEvent, node: TreeNode, level: number) => {
      const visibleNodes = getVisibleNodes();
      const currentIdx = visibleNodes.indexOf(node.id);

      switch (e.key) {
        case 'ArrowDown':
          e.preventDefault();
          if (currentIdx < visibleNodes.length - 1) {
            focusNode(visibleNodes[currentIdx + 1]);
          }
          break;

        case 'ArrowUp':
          e.preventDefault();
          if (currentIdx > 0) {
            focusNode(visibleNodes[currentIdx - 1]);
          }
          break;

        case 'ArrowRight':
          e.preventDefault();
          if (node.children?.length) {
            if (!expanded.has(node.id)) {
              toggleExpand(node.id);
            } else {
              focusNode(node.children[0].id);
            }
          }
          break;

        case 'ArrowLeft':
          e.preventDefault();
          if (node.children?.length && expanded.has(node.id)) {
            toggleExpand(node.id);
          } else {
            const parentId = findParent(node.id, nodes);
            if (parentId) focusNode(parentId);
          }
          break;

        case 'Home':
          e.preventDefault();
          focusNode(visibleNodes[0]);
          break;

        case 'End':
          e.preventDefault();
          focusNode(visibleNodes[visibleNodes.length - 1]);
          break;

        case 'Enter':
        case ' ':
          e.preventDefault();
          selectNode(node.id);
          break;
      }
    },
    [expanded, focusNode, getVisibleNodes, nodes, selectNode, toggleExpand, findParent]
  );

  const renderNode = (node: TreeNode, level: number, setSize: number, posInSet: number) => {
    const hasChildren = node.children && node.children.length > 0;
    const isExpanded = expanded.has(node.id);

    return (
      <li
        key={node.id}
        ref={(el) => { if (el) nodeRefs.current.set(node.id, el); }}
        role="treeitem"
        aria-expanded={hasChildren ? isExpanded : undefined}
        aria-selected={selected === node.id}
        aria-level={level}
        aria-setsize={setSize}
        aria-posinset={posInSet}
        tabIndex={selected === node.id ? 0 : -1}
        onKeyDown={(e) => handleKeydown(e, node, level)}
        onClick={(e) => {
          e.stopPropagation();
          if (hasChildren) toggleExpand(node.id);
          selectNode(node.id);
        }}
      >
        <span className="tree-label">
          {hasChildren && (
            <span aria-hidden="true">{isExpanded ? '▼' : '▶'}</span>
          )}
          {node.label}
        </span>

        {hasChildren && isExpanded && (
          <ul role="group">
            {node.children!.map((child, idx) =>
              renderNode(child, level + 1, node.children!.length, idx + 1)
            )}
          </ul>
        )}
      </li>
    );
  };

  return (
    <ul ref={treeRef} role="tree" aria-label={label}>
      {nodes.map((node, idx) => renderNode(node, 1, nodes.length, idx + 1))}
    </ul>
  );
}
```

---

## 9. Toggle / Switch

A control that represents an on/off state.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `role="switch"` | The toggle element | Identifies as a switch control |
| `aria-checked="true/false"` | The toggle element | Current on/off state |
| `aria-labelledby` or `aria-label` | The toggle element | Accessible name |

### Keyboard Interaction

| Key | Action |
|-----|--------|
| Space | Toggle the switch on/off |
| Enter | (optional) Toggle the switch on/off |

### Implementation

```tsx
import { useCallback, useId } from 'react';

interface SwitchProps {
  label: string;
  checked: boolean;
  onChange: (checked: boolean) => void;
  description?: string;
  disabled?: boolean;
}

export function Switch({ label, checked, onChange, description, disabled = false }: SwitchProps) {
  const baseId = useId();
  const labelId = `${baseId}-label`;
  const descId = description ? `${baseId}-desc` : undefined;

  const toggle = useCallback(() => {
    if (!disabled) onChange(!checked);
  }, [checked, disabled, onChange]);

  const handleKeydown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === ' ' || e.key === 'Enter') {
        e.preventDefault();
        toggle();
      }
    },
    [toggle]
  );

  return (
    <div className="switch-container">
      <span id={labelId}>{label}</span>
      {description && (
        <span id={descId} className="switch-description">
          {description}
        </span>
      )}
      <button
        role="switch"
        aria-checked={checked}
        aria-labelledby={labelId}
        aria-describedby={descId}
        aria-disabled={disabled || undefined}
        onClick={toggle}
        onKeyDown={handleKeydown}
        className={`switch ${checked ? 'switch-on' : 'switch-off'} ${disabled ? 'switch-disabled' : ''}`}
      >
        <span className="switch-thumb" aria-hidden="true" />
      </button>
    </div>
  );
}
```

---

## 10. Disclosure (Show/Hide)

A simple show/hide toggle for a single content section. Simpler than accordion — no group behavior.

### ARIA Roles and Properties

| Attribute | Element | Purpose |
|-----------|---------|---------|
| `aria-expanded="true/false"` | Trigger button | Indicates content visibility |
| `aria-controls` | Trigger button | Points to the content container |

### Keyboard Interaction

| Key | Action |
|-----|--------|
| Enter / Space | Toggle content visibility |

### Implementation

```tsx
import { useState, useId } from 'react';

interface DisclosureProps {
  label: string;
  children: React.ReactNode;
  defaultOpen?: boolean;
}

export function Disclosure({ label, children, defaultOpen = false }: DisclosureProps) {
  const [isOpen, setIsOpen] = useState(defaultOpen);
  const baseId = useId();
  const contentId = `${baseId}-content`;

  return (
    <div className="disclosure">
      <button
        aria-expanded={isOpen}
        aria-controls={contentId}
        onClick={() => setIsOpen((prev) => !prev)}
      >
        <span aria-hidden="true">{isOpen ? '▼' : '▶'}</span>
        {label}
      </button>

      <div id={contentId} hidden={!isOpen}>
        {children}
      </div>
    </div>
  );
}
```

### Native HTML Alternative

When JavaScript is not required or for progressive enhancement, use the native `<details>` element:

```html
<details>
  <summary>Show more information</summary>
  <p>This content is hidden by default and revealed when the user activates the summary.</p>
</details>
```

The `<details>`/`<summary>` pattern provides built-in keyboard support, screen reader support, and `aria-expanded` semantics with zero JavaScript. Prefer this whenever the design allows.
