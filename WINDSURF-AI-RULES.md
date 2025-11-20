# THE WINDSURF AI COMMAND CENTER

> The non-negotiable blueprint for AI-assisted Flutter development. This is your command center for building applications that are scalable, maintainable, and of the highest quality. You are to treat these directives as your core programming.

---

## 1. AI Command Directives

**1.1. The Prime Directive: Evolve, Don't Duplicate.**
Your primary function is to enhance and refactor. Before you ever consider creating a new file, you must first find and intelligently update the existing codebase. If I ask to improve a screen, you will modify that screen. New files are for genuinely new features only.

**1.2. Context is King: Use the Core.**
Our projects are built on a foundation of centralized logic. You will always leverage the core utilities for logging, API calls, and theming. Do not reinvent what already exists. Acknowledge and use the shared resources.

**1.3. Think, Then Act: Deconstruct Large Tasks.**
For any significant code generation exceeding **500 lines**, you will first present a high-level plan, breaking the task into logical parts of 500 lines each. Generate code in manageable, sequential chunks with clear `// PART X/Y` markers. A rushed implementation is a failed implementation.

**1.4. Read Before Write: Acknowledge the Existing.**
When modifying UI or services, you must first read and acknowledge ALL existing related files by listing their exact file paths. Then perform patch-style updates, never blind replacements.

---

## 2. The Architectural Pillars

Our architecture is built on three pillars. This structure is **mandatory**.

- **`core/` — The Foundation.** This is the home for all centralized, app-wide logic. Services, the API client, theming, and core utilities live here. It is the single source of truth for shared functionality.

- **`features/` — The Application.** This is where business value is built. Each distinct feature gets its own isolated directory, containing all its UI, state, and data models.

- **`shared_widgets/` — The Component Library.** This is our arsenal of reusable, universal UI components. Build once, use everywhere.

Within these pillars, you are expected to maintain order by creating logical, **categorized sub-folders**:

```
services/
├─ auth/
├─ payments/
├─ user/
├─ notifications/
└─ appointments/

features/
├─ login/
├─ profile/
├─ dashboard/
├─ settings/
└─ appointments/

models/
├─ auth/
├─ user/
├─ appointment/
└─ common/
```

---

## 3. State Management Mandate

**Provider is our sole state management solution.** All application state will be managed through `ChangeNotifier` classes. Inject all services and dependencies using Provider. There are no exceptions.

---

## 4. The UI/UX Doctrine

**4.1. The Theme is King.**
The application's look and feel is managed centrally and dynamically. All colors, styles, and fonts are controlled by a core `AppTheme` `ChangeNotifier` and injected via Provider. **Hardcoded styles and colors in widgets are strictly forbidden.**

**Special colors and gradients must be defined in `theme/colors.dart` and exposed via providers.**

**4.2. A Silent UI is a Failed UI.**
Every user action must have clear and immediate feedback. All screens must account for loading, error, empty, and success states. Make every screen highly interactive with micro-animations that enhance user experience without blocking accessibility.

**4.3. Central Widget Library.**
Always check existing `shared_widgets/` before creating new UI components. Reuse and enhance existing widgets rather than duplicating functionality.

## Project folder template (opinionated)

```
lib/
├─ core/
│  ├─ utils/
│  │  ├─ logger.dart
│  │  ├─ validators.dart
│  │  └─ formatters.dart
│  ├─ constants/
│  │  ├─ api_constants.dart
│  │  └─ env.dart
│  └─ providers/
│     ├─ theme_provider.dart
│     └─ auth_provider.dart
├─ services/
│  ├─ auth/
│  │  ├─ auth_api.dart
│  │  ├─ auth_repository.dart
│  │  └─ auth_model.dart
│  ├─ payments/
│  └─ user/
├─ features/
│  ├─ login/
│  │  ├─ login_screen.dart
│  │  ├─ login_view_model.dart
│  │  └─ widgets/
│  └─ profile/
├─ widgets/
│  ├─ buttons/
│  ├─ forms/
│  └─ layout/
├─ theme/
│  ├─ colors.dart
│  ├─ typography.dart
│  └─ app_theme.dart
├─ models/
├─ routes/
└─ main.dart
```

**Notes:**
- Each `services/<name>/` contains `api.dart`, `repository.dart`, `model.dart`, and tests.
- Feature folders should be small and focused; every screen has an accompanying `widgets/` folder for subcomponents.

---

## 5. Backend & Data Integration

**5.1. The Gateway: Dio.**
Our gateway to the backend is **Dio**. A single, centralized `ApiClient` in the `core/services/network/` will handle all HTTP traffic, equipped with interceptors for logging and authentication.

**5.2. The Logic Layer: Services.**
Services are the brains of the operation. They orchestrate data flow and business logic, live in the `core/services/`, and are categorized by their domain:

```
core/services/
├─ network/
│  ├─ api_client.dart
│  ├─ interceptors/
│  │  ├─ logging_interceptor.dart
│  │  ├─ auth_interceptor.dart
│  │  └─ retry_interceptor.dart
│  └─ error_mapper.dart
├─ auth/
│  ├─ auth_service.dart
│  ├─ auth_repository.dart
│  └─ auth_models.dart
└─ user/
   ├─ user_service.dart
   ├─ user_repository.dart
   └─ user_models.dart
```

---

## 6. Quality & Diagnostics

**6.1. Logging is Mandatory and Intelligent.**
Our emoji-based `AppLogger` is the only accepted tool for diagnostics. Logs must be verbose. API responses **must** show the full, raw JSON data for debugging. The use of `print()` is prohibited.

**The logger must print raw JSON bodies for both request and response whenever content-type indicates JSON.**

**6.2. Code is Immutable by Default.**
`final` and `const` are not suggestions; they are requirements. Write efficient, predictable code. Assume immutability unless state absolutely requires otherwise.

---

## 7. File Creation vs Update Rules

**When a requested change touches an existing file:** AI must propose a patch (diff-style) showing modifications, not a full-file replacement. Example header for patches:

```
PATCH: lib/features/login/login_screen.dart
- replace lines 150..175
+ add widget MyFancyLoginButton
```

**When adding a new screen or utility:** create a single file only when strictly necessary. If more than 500 lines are required, plan generation by parts.

**If uncertain whether a file exists:** AI must list the candidate paths and apply the update to the most semantically correct file.

---

## 8. Part-by-Part Generation Rules

**8.1. The 500-Line Rule.**
For any file exceeding **500 lines**, you must break it into logical parts of exactly 500 lines each. No exceptions.

**8.2. Part Structure Requirements.**
Each part must include:
- Clear part numbering: `// PART 1/3`
- Unique identifier: `// ID: windsurf-20251113-001` 
- Assembly instructions: `// To assemble: copy parts in order into lib/services/auth/`
- Logical boundaries (e.g., models, services, views, widgets)

**8.3. Part Headers Example:**
```dart
// PART 1/3 — models & services
// ID: windsurf-20251113-001
// To assemble: copy parts in order into lib/services/auth/
// START PART 1
```

---

## 9. The Logger Policy

**9.1. Raw JSON is King.**
The centralized `AppLogger` must print **full raw JSON** bodies for both request and response whenever content-type indicates JSON. No truncation, no summarization.

**9.2. Logger Requirements:**
- Must be placed at `lib/core/utils/logger.dart`
- Include emoji tags for visual debugging: 🚀 ✅ ❌ ⚠️ 🌐
- Support compact and pretty JSON modes
- Respect `kDebugMode` and `VERBOSE_LOGS` environment flag
- Provide readable timestamps and color codes for dev consoles

**9.3. Mandatory Logger Methods:**
`startup`, `success`, `error`, `apiRequest`, `apiResponse`, `debug`, `section`, `object`, `list`, `divider`

---

## 10. The Theme & Color Provider Doctrine

**10.1. No Hardcoded Colors.**
**ALL** colors, styles, and fonts must be controlled by a core `AppTheme` `ChangeNotifier` and injected via Provider. Hardcoded styles in widgets are **strictly forbidden**.

**10.2. Color Token System.**
Keep `theme/colors.dart` for color tokens only (not concrete widget colors). Expose a `ThemeProvider` with:
- `ColorScheme` for light/dark modes
- `Map<String, Color>` for named accents (`danger`, `success`, `brandPrimary`)
- `getSpecialColor(String key)` for screen-specific overrides

**10.3. Special Colors & Gradients.**
If a screen needs unique colors or gradients, they must be:
1. Defined as tokens in `theme/colors.dart`
2. Exposed through `ThemeProvider`
3. Never hardcoded in widgets

---

## 11. Services: Professional Structure & DIO Conventions

**11.1. Centralized Network Layer.**
All network code lives in `core/services/network/`:
- `api_client.dart` — exposes configured Dio instance with interceptors
- `interceptors/` — logging, auth, retry interceptors
- `error_mapper.dart` — maps HTTP/Dio errors to domain errors

**11.2. Service Organization.**
Each service gets its own categorized folder:
```
core/services/
├─ auth/
│  ├─ auth_service.dart
│  ├─ auth_repository.dart
│  ├─ auth_models.dart
│  └─ auth_dto.dart
├─ user/
├─ appointments/
└─ notifications/
```

**11.3. File Upload Standards.**
Use `FormData` consistently for uploads. Always log raw request/response JSON via centralized logger.

---

## 12. Central UI Widgets & Patterns

**12.1. Widget Library Requirements.**
Shared components in `shared_widgets/` must be:
- Framework-agnostic (no heavy business logic)
- Presentational code only
- Wired to theme provider
- Categorized by function

**12.2. Mandatory Widget Collection:**
```
shared_widgets/
├─ buttons/
│  ├─ primary_button.dart
│  ├─ secondary_button.dart
│  └─ icon_button.dart
├─ forms/
│  ├─ custom_text_field.dart
│  └─ form_validator.dart
├─ layout/
│  ├─ responsive_scaffold.dart
│  └─ custom_app_bar.dart
├─ media/
│  └─ network_image_with_placeholder.dart
└─ debug/
   └─ json_view.dart
```

**12.3. Widget Acknowledgment Rule.**
Before creating any UI component, you must first check and acknowledge existing `shared_widgets/`. Reuse and enhance existing widgets rather than duplicating functionality.

---

## 13. Logger Implementation Guidelines

**13.1. Public API Constraints.**
Keep the logger API minimal and focused:
- Core methods: `startup`, `success`, `error`, `warning`, `info`
- API methods: `apiRequest`, `apiResponse`
- Utility methods: `debug`, `section`, `object`, `list`, `divider`
- Specialized: `auth`, `user`, `profile`, `upload`, `download`

**13.2. Logger Features.**
- Emoji-based visual categorization
- Raw JSON printing for API calls
- ANSI color support for dev consoles
- Respect for `kDebugMode` and `VERBOSE_LOGS`
- Readable timestamps
- Categorized log sections with dividers

---

## 14. UX/Screen Design Doctrine

**14.1. Interactive Excellence.**
Make every screen highly interactive with micro-animations for primary actions. Use light animations that enhance UX without blocking accessibility.

**14.2. Form Standards.**
All forms must include:
- Inline validation with immediate feedback
- Compact error summaries in SnackBar or inline banners
- `AutofillHints` for email/phone fields
- Clear focus states with theme-driven colors

**14.3. Login Screen Enhancement Protocol.**
When updating existing login screens, enhance with:
- Clearer input focus states
- `AutofillHints` for email/phone
- Optional biometric prompt flow (feature-flagged)
- `app_theme`-driven color variants
- Loading states with user feedback

---

## 15. AI Workflow Command Protocol

**15.1. Read-First Directive.**
Before any generation, the AI **must**:
1. Inspect the repository structure
2. List exact files to be modified
3. Acknowledge existing related components
4. Never proceed without this reconnaissance

**15.2. Ask-Limited Protocol.**
Avoid unnecessary clarifying questions. If a decision can be reasonably inferred:
1. Choose the most sensible default
2. Document the decision in the patch header
3. Proceed with confidence

**15.3. Patch-First Methodology.**
Produce patch/diff for changes by default. Full file replacement requires explicit justification in the header.

**15.4. Part-Structure Planning.**
For large features exceeding 500 lines:
1. Present a comprehensive plan
2. List all files and parts
3. Define assembly order
4. Include unique identifiers

**15.5. Safety & Idempotence.**
Generated code must be:
- Idempotent (safe to run multiple times)
- Environment-aware (use `.env` placeholders)
- Test-covered (unit tests for services, golden tests for UI)

**15.6. Quality Assurance.**
Prefer adding:
- Unit tests for all service logic
- Widget golden tests for critical UI components
- Integration tests for complete user flows

---

## 16. The Perfect AI Response Protocol

### Example: "Improve login screen"

**Phase 1: Reconnaissance** 
```
ACKNOWLEDGED FILES:
- lib/features/login/login_screen.dart
- lib/core/services/auth/auth_service.dart  
- lib/theme/colors.dart
- lib/shared_widgets/buttons/primary_button.dart
```

**Phase 2: Enhancement Plan**
```
PATCH PLAN:
- Extract LoginForm widget from existing screen
- Wire AuthService.login() with Dio integration
- Add AppLogger.apiRequest/apiResponse calls
- Enhance with theme provider colors
- Add loading states and error handling
```

**Phase 3: Implementation** 
If changes exceed 500 lines:
- `Part 1/3: Widget extraction & UI enhancements`
- `Part 2/3: Service integration & API wiring`  
- `Part 3/3: State management & error handling`

---

## 17. Implementation Examples

**17.1. Folder Structure Creation**
```
ADD: core/services/auth/
├─ auth_service.dart
├─ auth_repository.dart
├─ auth_models.dart
└─ auth_dto.dart

PATCH: features/login/login_screen.dart
- Extract LoginForm widget
- Wire to AuthService
- Add AppLogger calls
```

**17.2. Part Header Template**
```dart
// PART 1/3 — UI Components & Widgets
// ID: windsurf-20251113-auth-001
// Assembly: Apply parts sequentially to complete login enhancement
// Dependencies: Provider, Dio, AppLogger
// START PART 1
```

---

## 18. Quality Assurance Checklist

**Before any code generation, verify:**
- [ ] AI has listed exact files to be modified
- [ ] Existing components are acknowledged and reused
- [ ] Changes provided as patches when possible  
- [ ] New colors added only via `theme/colors.dart`
- [ ] Logger prints raw JSON for API calls
- [ ] DIO interceptors are centralized
- [ ] UI components use Provider for theme and state
- [ ] Tests included for critical logic
- [ ] Code follows immutability principles (`final`/`const`)
- [ ] Part-based generation for files >500 lines
- [ ] Professional categorized folder structure

**Post-implementation validation:**
- [ ] Code is idempotent and safe to re-run
- [ ] No hardcoded values or secrets
- [ ] Proper error handling and loading states
- [ ] Accessibility considerations implemented
- [ ] Performance optimizations applied

---

## 19. Glossary of Terms

- **Patch** — A precise diff-style modification to existing files
- **Part** — A 500-line chunk of large implementations 
- **Core Services** — Centralized business logic modules
- **Theme Provider** — Centralized styling and color management
- **AppLogger** — Emoji-based centralized logging system
- **Widget Acknowledgment** — Process of checking existing components before creation

---

## 20. Implementation Protocol

**20.1. File Placement**
Keep this document at repo root as `WINDSURF-AI-RULES.md`.

**20.2. Integration Requirements**
1. Share with all AI tools before code generation
2. Reference in PR templates and code reviews
3. Enforce checklist compliance
4. Train team members on protocol adherence

**20.3. Immediate Action Items**
1. **Priority 1:** Implement `core/utils/logger.dart` with full AppLogger
2. **Priority 2:** Create `core/services/network/api_client.dart` with Dio setup
3. **Priority 3:** Establish `theme/colors.dart` and `ThemeProvider`
4. **Priority 4:** Set up categorized folder structure
5. **Priority 5:** Create essential `shared_widgets/` components

---

# **END OF WINDSURF AI COMMAND CENTER**

> *These rules are non-negotiable. Any deviation constitutes a failed implementation.*
> *Quality is not an accident; it is the result of following these directives with precision.*
