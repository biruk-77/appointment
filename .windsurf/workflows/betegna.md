---
description: Implements and updates the Flutter code for the "Hospital Appointment Management & Service Assistance System". All generation must strictly follow the WINDSURF-AI-RULES.md blueprint.
auto_execution_mode: 3
---

# Workflow: Implement Hospital Appointment System

## Directives

You are the WindSurf AI, and your task is to generate and update code for the **Hospital Appointment Management & Service Assistance System** based on the provided proposal documents (Abyssinia Software Technology PLC).

**STRICT ADHERENCE TO WINDSURF-AI-RULES.MD IS REQUIRED.**

## Architectural Mandates

1.  **Architecture:** Always use the three-pillar structure: `lib/core/`, `lib/features/`, and `lib/shared_widgets/`.
2.  **Services:** Create categorized sub-folders under `lib/core/services/` for the proposal's modules:
    *   `appointment/` (Booking logic, models)
    *   `transport/` (Car/ticket arrangement logic)
    *   `nursing/` (Nursing support logic)
    *   `finance/` (Payment processing, invoice generation)
3.  **Features:** Create feature modules under `lib/features/` for the main user flows:
    *   `auth/` (Login, Register)
    *   `booking/` (Appointment & Service selection flow)
    *   `profile/` (User details, document upload, order history)
    *   `admin_dashboard/` (For Admin/Management Module)
4.  **Data Flow:** Ensure all services use the central **Dio** client (`lib/core/services/network/`) and adhere to the `_api.dart`, `_repository.dart`, `_model.dart` pattern.
5.  **Logging:** Use `AppLogger` for all diagnostics. Ensure API requests/responses log the **raw JSON** body as per the AI Rules.
6.  **Theming:** All UI components **must** use the Provider-injected `AppTheme` for colors and styles.

## Current Focus: Customer Module Implementation

The immediate priority is to scaffold the **Customer Module** and its services. When generating code, prioritize the following features from the proposal (Page 3-4):

1.  **Authentication:** Register/Login with phone/email (3.A).
2.  **Service Selection:** Create the UI and underlying models for selecting a combination of services: Hospital Appointment, Transportation, Hotel/Guest House, Nursing Support, Diaspora Order, Return & Follow-Up (3.B.1 - 3.B.6).
3.  **Payment Gateway:** Integrate placeholders for the Online Payment Gateway (CBE Birr, Telebirr, etc.) via a `lib/core/services/finance/` module (3.A).

### Example Response Format Constraint

For a change to `lib/features/auth/login_screen.dart`, you must respond with a patch and acknowledge the rules:

```markdown
// Adhering to WINDSURF-AI-RULES.md: Patch-First Rule.
// Acknowledged files: lib/features/auth/login_screen.dart, lib/core/theme/app_theme_provider.dart

PATCH: lib/features/auth/login_screen.dart
- replace lines 150..175
+ add ThemedLoginForm widget with inline validation and AppTheme usage.
// PART 1/1 — Login Screen Refactor