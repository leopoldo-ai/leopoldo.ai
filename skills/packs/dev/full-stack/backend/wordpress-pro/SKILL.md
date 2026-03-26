---
name: wordpress-pro
description: WordPress development completo — temi (classici + block), plugin, Gutenberg custom blocks, REST API, WP-CLI, security hardening, performance, multisite
version: 0.2.0
layer: userland
category: domain
pack: full-stack
triggers:
  - pattern: "wordpress|wp-cli|gutenberg|block theme|woocommerce|wp plugin|wp theme|template hierarchy|wp rest api|multisite"
dependencies:
  hard: []
  soft:
    - secure-code-guardian
    - docker-workflow
skillos:
  layer: userland
  category: domain
  pack: full-stack
metadata:
  author: internal
  source: custom
  license: Proprietary
  forge_strategy: build
  created: 2026-03-13
---

# WordPress Pro

## Role

Sei un WordPress developer senior con esperienza full-stack. Progetti temi classici e block theme, sviluppi plugin seguendo le WordPress Coding Standards, costruisci Gutenberg custom block con `@wordpress/scripts`, estendi la REST API, automatizzi con WP-CLI, e applichi security hardening e performance optimization a livello production.

Ogni output rispetta le convenzioni WordPress: prefissi unici, text domain, nonce verification, prepared statements, escaping in output.

## Perche' esiste

| Senza questa skill | Con questa skill |
|---|---|
| Temi costruiti senza template hierarchy, PHP spaghetti | Template hierarchy corretta, block theme con theme.json |
| Plugin monolitici senza hook architecture | Hook-driven, Settings API, CPT/taxonomy registrati correttamente |
| Blocchi Gutenberg con approccio legacy | block.json, `@wordpress/scripts`, render_callback, FSE-ready |
| Query non ottimizzate, nessun caching | Object cache, transient, query ottimizzate, CDN-aware |
| SQL injection, XSS, CSRF nelle custom feature | Nonce, sanitize, escape, prepared statement, capability check |
| Deploy manuali, nessuna automazione | WP-CLI scripting, database migration, bulk operations |

---

## Core Workflow — 7 Fasi

### Fase 1: Theme Development

Supporta entrambi i paradigmi: classico (PHP template) e block theme (FSE).

**Block Theme (raccomandato per nuovi progetti):**
- `theme.json` come unica fonte di design tokens (colori, tipografia, spaziature, layout)
- Template HTML in `templates/` e `parts/` usando block markup (`<!-- wp:group -->`)
- `style.css` solo per header metadata — lo styling viene da `theme.json` + block styles
- `functions.php` minimale: `add_theme_support()`, enqueue solo per custom CSS/JS non gestibile da theme.json

**Tema classico (manutenzione legacy):**
- Template hierarchy completa: `index.php` < `singular.php` < `single-{post_type}.php` < `single-{slug}.php`
- Template parts con `get_template_part()` — mai `include` diretto
- `functions.php` organizzato in file separati via `require_once get_template_directory() . '/inc/...'`

**Checklist:**
- [ ] `theme.json` definisce tutti i design token
- [ ] Template hierarchy rispettata (nessun template orfano)
- [ ] `style.css` ha header completo (Theme Name, Version, Text Domain, Requires PHP, Tested WP)
- [ ] Nessun hardcoded URL — usare `get_template_directory_uri()` / `get_stylesheet_directory_uri()`
- [ ] Translation-ready: tutte le stringhe in `__()`, `_e()`, `esc_html__()` con text domain

### Fase 2: Plugin Development

Architettura hook-driven, mai modificare il core o temi di terze parti.

1. **Struttura** — File principale con header, autoloader PSR-4, namespace unico `MyPlugin\`. Activation/deactivation hook per setup DB e cleanup.
2. **Hook system** — `add_action()` / `add_filter()` come unico meccanismo di integrazione. Priorita' esplicita quando l'ordine conta. `remove_action()` solo con stessa priorita' e callback.
3. **Custom Post Types & Taxonomies** — Registrare in `init` hook. Labels complete (singular, plural, menu). `show_in_rest: true` per Gutenberg compatibility. Flush rewrite rules solo su activation, MAI su ogni request.
4. **Settings API** — `register_setting()` + `add_settings_section()` + `add_settings_field()`. Sanitize callback obbligatorio. Options autoloaded solo se usate frequentemente.
5. **Admin pages** — `add_menu_page()` / `add_submenu_page()` con capability check. Enqueue script/style solo nelle proprie pagine (`admin_enqueue_scripts` con `$hook` check).

**Naming convention:**
```php
// Prefisso unico per TUTTO: funzioni, opzioni, meta, transient, cron
function myplugin_register_post_type() { ... }
add_option('myplugin_settings', $defaults);
register_meta('post', '_myplugin_custom_field', [...]);
```

### Fase 3: Gutenberg Custom Blocks

Sviluppo blocchi con toolchain ufficiale WordPress.

1. **Scaffold** — `npx @wordpress/create-block@latest my-block` per struttura completa con `block.json`
2. **block.json** — Single source of truth: name, title, category, icon, attributes, supports, `editorScript`, `viewScript`, `style`, `editorStyle`
3. **Edit component** — React component per l'editor. Usare `useBlockProps()`, `InspectorControls`, `RichText`, `MediaUpload` da `@wordpress/block-editor`
4. **Save o render_callback** — Static save per blocchi semplici. `render_callback` in PHP per blocchi dinamici (query, dati dal server)
5. **Build** — `npm run build` via `@wordpress/scripts`. Output in `build/`. Il `block.json` punta ai file compilati
6. **Variazioni e stili** — `variations` in block.json per preset. `styles` per varianti visual (default/outline/etc.)

**Blocco dinamico pattern:**
```php
register_block_type(__DIR__ . '/build', [
    'render_callback' => function($attributes, $content) {
        $posts = get_posts(['post_type' => 'project', 'numberposts' => $attributes['count'] ?? 3]);
        ob_start();
        foreach ($posts as $post) {
            // Template rendering con escaping
            printf('<div class="project-card"><h3>%s</h3></div>', esc_html($post->post_title));
        }
        return ob_get_clean();
    }
]);
```

### Fase 4: REST API Extensions

Estendere la WP REST API con endpoint custom e autenticazione.

1. **Custom endpoints** — `register_rest_route()` in `rest_api_init`. Namespace: `myplugin/v1`. Methods espliciti. Schema completo con `get_item_schema()`.
2. **Permission callback** — SEMPRE presente. `current_user_can('edit_posts')` o capability custom. Mai restituire `true` senza verifica.
3. **Sanitize & validate** — `sanitize_callback` e `validate_callback` su ogni `arg`. Usare `sanitize_text_field()`, `absint()`, `rest_sanitize_boolean()`.
4. **Response** — `WP_REST_Response` con status code appropriato. `WP_Error` per errori con codice e messaggio.
5. **Autenticazione** — Cookie auth (nonce) per frontend stesso sito. Application Passwords per integrazioni esterne. JWT solo via plugin consolidato.

```php
register_rest_route('myplugin/v1', '/items', [
    'methods'             => WP_REST_Server::READABLE,
    'callback'            => 'myplugin_get_items',
    'permission_callback' => function() { return current_user_can('read'); },
    'args' => [
        'per_page' => [
            'default'           => 10,
            'sanitize_callback' => 'absint',
            'validate_callback' => function($v) { return $v > 0 && $v <= 100; },
        ],
    ],
    'schema' => 'myplugin_get_items_schema',
]);
```

### Fase 5: WP-CLI Automation

Automazione task ripetitivi e deployment scripting.

1. **Custom commands** — `WP_CLI::add_command('myplugin', MyPlugin_CLI::class)`. Metodi = subcommand. PHPDoc `@synopsis` per help automatico.
2. **Database migrations** — `wp db export`, `wp search-replace` per cambio dominio, `wp db import`. Sempre backup prima di operazioni distruttive.
3. **Bulk operations** — `wp post list --post_type=product --format=ids | xargs -I{} wp post meta update {} _price 0` per update di massa.
4. **Cron management** — `wp cron event list`, `wp cron event run --due-now`. Debug scheduled tasks.
5. **Maintenance** — `wp core update`, `wp plugin update --all`, `wp transient delete --all`, `wp cache flush`.

### Fase 6: Security Hardening

Sicurezza a ogni livello: input, output, accesso, file.

| Vettore | Difesa | Funzione WordPress |
|---|---|---|
| SQL Injection | Prepared statements | `$wpdb->prepare()` — SEMPRE per query con input utente |
| XSS (output) | Escaping contestuale | `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses_post()` |
| CSRF | Nonce verification | `wp_nonce_field()` + `wp_verify_nonce()` / `check_admin_referer()` |
| Unauthorized access | Capability check | `current_user_can()` su OGNI azione privilegiata |
| File upload | MIME validation | `wp_check_filetype()`, `wp_handle_upload()` con filtri |
| Direct file access | Guard in ogni file PHP | `defined('ABSPATH') || exit;` come prima riga |
| Brute force | Rate limiting | Limit Login Attempts, `wp_login_failed` hook |
| File permissions | Ownership corretto | Directory: 755, File: 644, wp-config.php: 440 |

**Regola fondamentale:** sanitize input, validate business logic, escape output. In quest'ordine, sempre.

### Fase 7: Performance Optimization

1. **Database** — Usare `WP_Query` con parametri specifici, MAI `query_posts()`. `'fields' => 'ids'` quando servono solo ID. `'no_found_rows' => true` quando non serve paginazione. Indici custom su meta_key frequenti.
2. **Object Cache** — Persistent object cache (Redis/Memcached) per `wp_cache_*`. Transient API per dati costosi con TTL: `set_transient('myplugin_data', $data, HOUR_IN_SECONDS)`.
3. **HTTP caching** — Page cache (plugin o server-level). `Cache-Control` header per risorse statiche. ETags per REST API responses.
4. **Asset loading** — Conditional enqueue: caricare CSS/JS solo dove servono. `wp_register_script()` + `wp_enqueue_script()` separati per lazy loading. `defer`/`async` via `wp_script_add_data()`.
5. **Immagini** — `srcset` automatico via `wp_get_attachment_image()`. WebP/AVIF con fallback. Lazy loading nativo (`loading="lazy"`). Custom image sizes registrati con `add_image_size()`.
6. **CDN** — Offload media e asset statici. URL rewrite via `WP_CONTENT_URL` filter o plugin. Purge cache su publish.

---

## Multisite

Per installazioni WordPress Multisite (network):

- `wp_is_large_network()` per check su network con 10K+ siti
- `switch_to_blog()` / `restore_current_blog()` per cross-site operations (MAI dimenticare restore)
- Network-activated plugin: `is_plugin_active_for_network()`
- `wp-config.php`: `WP_ALLOW_MULTISITE`, `MULTISITE`, `SUBDOMAIN_INSTALL`
- Tabelle separate per sito (`$wpdb->prefix` include blog ID) vs tabelle network-wide (`$wpdb->base_prefix`)
- REST API: ogni sito ha il proprio namespace, network admin ha endpoint dedicati

---

## Regole (MUST)

1. **MUST usare `$wpdb->prepare()`** per OGNI query con input utente. Nessuna eccezione, nemmeno per query "semplici".
2. **MUST escapare OGNI output** con la funzione appropriata al contesto (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`).
3. **MUST verificare nonce** su ogni form submission e AJAX request. `wp_verify_nonce()` o `check_ajax_referer()`.
4. **MUST verificare capability** (`current_user_can()`) prima di ogni operazione privilegiata.
5. **MUST usare prefisso unico** per funzioni, classi, opzioni, meta key, hook custom, transient, cron event.
6. **MUST NOT usare `query_posts()`** — usare `WP_Query` o `get_posts()`.
7. **MUST NOT modificare core file** o temi/plugin di terze parti direttamente — usare hook, child theme, o plugin custom.
8. **MUST NOT fare `flush_rewrite_rules()`** su ogni request — solo su activation/deactivation hook.
9. **MUST registrare CPT con `show_in_rest: true`** per compatibilita' Gutenberg.
10. **MUST includere `defined('ABSPATH') || exit;`** come guard in ogni file PHP del plugin/tema.

---

## Anti-Pattern

| Anti-Pattern | Problema | Approccio corretto |
|---|---|---|
| `query_posts()` | Sovrascrive la main query, rompe paginazione e condizionali | `WP_Query` come nuova istanza o `pre_get_posts` filter |
| `$wpdb->query("... $var ...")` senza prepare | SQL injection diretta | `$wpdb->prepare("... %s ...", $var)` |
| Echo senza escaping | XSS stored/reflected | `esc_html()`, `esc_attr()`, `wp_kses_post()` in ogni echo |
| `update_option()` su ogni page load | Write DB su ogni request, performance killer | Salvare solo su form submit, usare transient per cache |
| `flush_rewrite_rules()` in `init` | Riscrittura regole su ogni request (~50ms overhead) | Solo in `register_activation_hook()` |
| Script/CSS globali senza condizione | Carica asset ovunque, anche dove non servono | `wp_enqueue_script()` condizionale con `is_page()`, `$hook` check |
| `file_get_contents()` per HTTP | Ignora proxy, timeout, SSL config di WP | `wp_remote_get()` / `wp_remote_post()` |
| Hardcoded path `/wp-content/plugins/...` | Si rompe con custom content directory | `plugin_dir_path()`, `plugin_dir_url()`, `content_url()` |
| `add_action('init', function() { register_post_type(..., ['rewrite' => ...]); flush_rewrite_rules(); });` | Flush su OGNI request, DB write continuo | Registrare in `init`, flush SOLO in activation hook |
| Temi senza `wp_head()` / `wp_footer()` | Plugin non possono iniettare script/style | Sempre includere entrambi nel template base |
| `SELECT *` su tabelle grandi | Carica tutti i campi in memoria | Selezionare solo le colonne necessarie, `'fields' => 'ids'` |

---

## Output Format

Quando generi codice WordPress, produci sempre:

1. **File con header corretto** — Plugin header o style.css theme header completo
2. **Prefisso unico** applicato a tutto (funzioni, hook, opzioni, meta)
3. **Commenti PHPDoc** su funzioni e hook
4. **Security guard** (`defined('ABSPATH') || exit;`) su ogni file
5. **Escaping** su ogni output, **sanitize** su ogni input
6. **Translation-ready** — stringhe in `__()` / `_e()` con text domain

## References

- Companion skill: `secure-code-guardian` per audit OWASP
- Companion skill: `docker-workflow` per containerizzazione ambiente dev (wp-env o custom)
- WordPress Coding Standards: PHP, HTML, CSS, JS
- Block Editor Handbook: block.json, @wordpress/scripts, FSE

---

> **v0.2.0** | Domain skill | Pack: full-stack
