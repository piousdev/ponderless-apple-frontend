<!-- OPENSPEC:START -->
<!-- OPENSPEC:START -->

# OpenSpec Instructions

You MUST always use the AskUserQuestion tool with multiple choice options when asking ANY questions. This is mandatory for speed and accuracy. Always include a "Type custom response" option for questions requiring additional context or nuance.

These instructions are for AI assistants working in this project.

# MCP Servers - When to Use

## **serena**

**Use when:** Managing project context and documentation

- Maintaining project memory across sessions
- Storing and retrieving project-specific knowledge
- Managing architectural decisions and patterns
- Keeping track of conventions and standards
- Building institutional knowledge for the codebase

## **context7**

**Use when:** Handling broader codebase context

- Analyzing large-scale code relationships
- Understanding cross-file dependencies
- Getting holistic views of your architecture
- Searching across multiple repositories or projects
- Maintaining context for complex, multiservice systems

---

**Typical Workflow Integration:**
- **serena/context7** for maintaining project knowledge as your agency scales

CRITICAL RULE - Documentation First:
Before providing implementation advice for any framework, library, or tool:

1. Use Context7 to fetch the current official documentation
2. Never rely solely on training data for framework-specific patterns
3. If you're unsure whether docs have changed, default to checking

Trigger this rule when:

- User asks about "best practices" or "recommended approach"
- User mentions specific framework versions (Next.js, React, etc.)
- Implementation involves third-party libraries or APIs
- You detect potential outdated patterns in your knowledge

Exception: Only skip doc check for truly stable, fundamental concepts
(e.g., JavaScript fundamentals, HTTP basics) that are unlikely to change.

Always use context7 when I need code generation, setup or configuration steps, or
library/API documentation. This means you should automatically use the Context7 MCP
tools to resolve library id and get library docs without me having to explicitly ask.

Always open `@/openspec/AGENTS.md` when the request:

- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:

- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Specialized Agents - When to Use

Use specialized agents for complex, domain-specific tasks that require deep expertise. Invoke agents through the Task tool when you detect scenarios matching their expertise domains. There are 8 specialized agents available for different technical domains.

## **prompt-engineer**

**Use when:** Optimizing LLM prompts, reducing costs, or improving AI system reliability

**Proactive Triggers:**
- User implements basic prompts that need optimization
- LLM response quality issues or inconsistency detected
- Token usage or cost concerns mentioned
- Multiple prompt variations need evaluation

**Reactive Triggers:**
- Setting up few-shot learning or chain-of-thought reasoning
- Implementing prompt templates or variable management
- Addressing prompt injection or safety concerns
- Managing multi-model routing logic

**Key Metrics:** Accuracy >90%, Token reduction >30%, Latency <2s

## **typescript-pro**

**Use when:** Working with TypeScript in any capacity, from setup to advanced type system features

**Proactive Triggers:**
- TypeScript compilation errors or slow build times
- Complex generic types or utility types needed
- Migration from JavaScript to TypeScript required
- Full-stack type safety implementation needed

**Reactive Triggers:**
- Configuring tsconfig.json or project references
- Implementing advanced type patterns (conditional types, mapped types, discriminated unions)
- Type-safe API design with tRPC or GraphQL codegen
- Debugging cryptic type errors or improving type inference
- Optimizing TypeScript build performance in monorepos

**Example Usage:**
- Creating end-to-end type-safe APIs from frontend to backend
- Resolving "Type instantiation is excessively deep" errors
- Setting up TypeScript monorepo with project references
- Implementing type-driven development patterns

**Key Metrics:** 100% type coverage, zero `any` usage, <5s build time, strict mode compliance

## **database-administrator**

**Use when:** Managing databases for high availability, performance, or disaster recovery

**Proactive Triggers:**
- Slow query performance (>1s response times)
- Database setup or migration needed
- N+1 queries or inefficient patterns detected

**Reactive Triggers:**
- Query performance tuning and index optimization
- Replication and high-availability setup
- Backup/recovery implementation (RTO <1hr, RPO <5min)
- Zero-downtime migration planning

**Key Metrics:** 99.99% uptime, sub-second queries, automated backups

## **sre-engineer**

**Use when:** Establishing system reliability or improving operational excellence

**Proactive Triggers:**
- New service needs production readiness review
- High manual operation burden or frequent alerts
- Reliability issues with frequent outages

**Reactive Triggers:**
- SLO/SLI definition and implementation
- Chaos engineering program setup
- Toil reduction through automation
- Incident response improvement

**Key Metrics:** Toil <50%, MTTR <30min, SLO compliance >99.9%

## **flutter-expert**

**Use when:** Building or optimizing Flutter/Dart cross-platform applications

**Proactive Triggers:**
- New Flutter app architecture needed
- Widget performance issues or jank detected
- State management decision required

**Reactive Triggers:**
- Custom animations and transitions
- Platform-specific features (iOS/Android)
- Bundle size or startup time optimization
- Native module integration

**Key Metrics:** 60 FPS performance, >80% widget test coverage

## **swift-expert**

**Use when:** Working with Swift code, iOS/macOS/watchOS development, or SwiftUI applications

**Proactive Triggers:**
- Swift files being created or modified
- SwiftUI views or UIKit components need implementation
- Async/await concurrency patterns being added
- Protocol-oriented design decisions needed
- Memory management or ARC optimization required
- Performance profiling with Instruments needed

**Reactive Triggers:**
- iOS/macOS app architecture design
- SwiftUI state management implementation
- Combine framework integration
- Core Data or CloudKit integration
- Swift Package Manager configuration
- Actor isolation and thread safety verification

**Example Usage:**
- Creating SwiftUI views with async data loading and proper state management
- Implementing protocol-based architectures with associated types
- Optimizing memory usage and preventing retain cycles
- Setting up structured concurrency with actors and async/await
- Integrating Core Data with SwiftUI using @FetchRequest

**Key Metrics:** SwiftLint compliance (0 warnings), 80%+ test coverage, 0 memory leaks, <2s app launch

## **refactoring-specialist**

**Use when:** Improving code quality or eliminating technical debt

**Proactive Triggers:**
- Code duplication detected across files
- Large classes or methods (>100 lines)
- After major feature implementation

**Reactive Triggers:**
- Code smell remediation
- Complexity metrics exceed thresholds
- Design pattern application required
- Legacy code modernization

**Key Metrics:** Complexity reduction >40%, zero behavior changes

## **mobile-app-developer**

**Use when:** Building native or cross-platform mobile applications

**Proactive Triggers:**
- New mobile feature implementation
- App store submission preparation
- Cross-platform migration evaluation

**Reactive Triggers:**
- iOS/Android native development
- App performance optimization
- Push notifications or device integration
- Offline functionality implementation

**Key Metrics:** App size <50MB, startup <2s, crash rate <0.1%

## **security-engineer**

**Use when:** Implementing security controls or compliance measures

**Proactive Triggers:**
- New infrastructure deployment
- Authentication/payment features added
- Compliance audit preparation

**Reactive Triggers:**
- Container/Kubernetes security hardening
- Vulnerability assessment and remediation
- Secrets management implementation
- DevSecOps pipeline integration

**Key Metrics:** Zero critical vulnerabilities, CIS compliance, automated scanning

## Agent Selection Quick Reference

```
Task Domain → Agent to Use
├── LLM/Prompts → prompt-engineer
├── TypeScript/Types → typescript-pro
├── Database/Data → database-administrator
├── Reliability/Ops → sre-engineer
├── Flutter/Dart → flutter-expert
├── Swift/iOS/macOS → swift-expert
├── Code Quality → refactoring-specialist
├── Mobile Apps → mobile-app-developer
└── Security → security-engineer
```

---

CRITICAL RULE - File Naming Conventions:
Before creating ANY new files or components:

1. **ALWAYS** follow the naming conventions in `apps/web/ARCHITECTURE.md` (File Naming Conventions section)
2. **Use kebab-case** for all filenames (e.g., `login-form.tsx`, `validate-password.ts`)
3. **Avoid adjectives** - No "enhanced-", "custom-", "advanced-" prefixes
4. **Leverage directory context** - Don't repeat parent directory names in filenames

Trigger this rule when:

- Creating new components, hooks, utilities, or any source files
- User asks to "create a file" or "add a component"
- Implementing new features that require new files

**Key Naming Rules**:

- Components: Use nouns (e.g., `form.tsx`, `table.tsx`, not `users-table.tsx` in /users/)
- Hooks: Use "use-" prefix + verb (e.g., `use-auth.ts`, not `use-auth-hook.ts`)
- Utilities: Use verbs for actions (e.g., `validate-password.ts`, not `password-validation.ts`)
- Actions: Use verbs (e.g., `handle-errors.ts`, not `error-handler.ts`)

**Reference**: See `apps/web/ARCHITECTURE.md` → "File Naming Conventions" for complete rules and examples.
<!-- OPENSPEC:END -->