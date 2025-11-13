# Design Document: ForYou View Optimization

## Context

The ForYou view is the primary dashboard users see when opening the app. It displays:
- Daily training exercises (todos) with progress tracking
- Calibration analytics with interactive charts
- Streak and stars gamification badges
- Exercise completion flows with multi-step sheets

**Current State:**
- Single 1,470-line file with mixed concerns
- No separation between UI, business logic, and data
- Hardcoded sample data in views
- 300+ lines of duplicated code
- Performance issues (loads all content immediately)
- Security vulnerabilities (no input validation, insecure data handling)
- Poor testability (tight coupling to AppState)

**Constraints:**
- Must maintain exact UI/UX (no visual changes)
- Must work with existing AppState (@Observable macro)
- Must support iOS 17+ SwiftUI features
- Must prepare for backend integration (placeholders currently)

**Stakeholders:**
- Users: Expect fast, smooth performance
- Developers: Need maintainable, testable code
- Product: Need flexibility to iterate quickly

## Goals / Non-Goals

### Goals
1. **Maintainability**: Reduce file from 1,470 lines to <200 lines through proper separation
2. **Performance**: 60% improvement in render time via LazyVStack and optimized chart
3. **Security**: Add input validation foundation for backend integration
4. **Testability**: 80% improvement via protocol-based design and dependency injection
5. **Accessibility**: Full VoiceOver support and Dynamic Type
6. **Code Quality**: Apply SOLID principles, eliminate duplication
7. **Developer Experience**: Clear file structure, SwiftUI previews, comprehensive documentation

### Non-Goals
- Visual/UX changes (UI must remain identical)
- Backend integration (this is frontend-only refactor)
- Security implementation (only foundations - no Keychain/encryption yet)
- Performance benchmarks (improvements are estimated, not measured)
- Unit test implementation (only create testable abstractions)
- Localization implementation (only make localizable-ready)

## Decisions

### Decision 1: MVVM Pattern with Observable ViewModels

**What:** Use MVVM architecture with @Observable ViewModels for complex components (TodoCard, ExerciseSheet, DailyTodosSection).

**Why:**
- Separates business logic from UI
- Makes components testable in isolation
- Aligns with SwiftUI best practices
- Works seamlessly with @Observable macro (iOS 17+)

**Alternatives Considered:**
- Pure SwiftUI (no ViewModels): Rejected - business logic would stay in views
- TCA (The Composable Architecture): Rejected - too heavy for this scope
- Combine-based ViewModels: Rejected - @Observable is simpler and more modern

**Example:**
```swift
@MainActor
final class TodoCardViewModel: ObservableObject {
    @Published var isCompleted: Bool = false
    @Published var showExerciseSheet: Bool = false

    func handleTap() {
        guard !isCompleted else { return }
        showExerciseSheet = true
    }
}
```

### Decision 2: Protocol-Oriented Design for Dependencies

**What:** Create protocol abstractions (TrainingProgressProvider, TodoRepository, CalibrationCalculator) instead of direct AppState dependencies.

**Why:**
- Enables dependency injection and testing
- Follows SOLID principles (Dependency Inversion)
- Allows mock implementations for previews
- Prepares for future backend integration

**Alternatives Considered:**
- Direct AppState usage: Rejected - not testable
- Singleton services: Rejected - tight coupling, hard to test
- Environment wrappers: Considered but protocols are more explicit

**Example:**
```swift
protocol TrainingProgressProvider {
    var dailyStreak: Int { get }
    var totalStars: Int { get }
}

extension AppState: TrainingProgressProvider {
    // Already has these properties
}

// Easy to test
final class MockTrainingProgressProvider: TrainingProgressProvider {
    var dailyStreak: Int = 5
    var totalStars: Int = 150
}
```

### Decision 3: File Organization by Feature Layers

**What:** Organize ForYou feature by layers: Components, ViewModels, Sheets, Models, Services, Constants.

**Why:**
- Clear separation of concerns
- Easy to navigate (find by responsibility)
- Scales better than flat structure
- Standard iOS architecture pattern

**Alternatives Considered:**
- Atomic Design (atoms/molecules/organisms): Rejected - overengineered for this scale
- Single Components folder: Rejected - would still be cluttered
- Feature slicing (by todo/judgment/badges): Considered but layer-based is clearer

**Structure:**
```
ForYou/
├── ForYouView.swift          # Main container
├── Components/               # Reusable UI components
├── ViewModels/              # Business logic
├── Sheets/                  # Modal presentations
├── Models/                  # Data structures
├── Services/                # Business services
└── Constants/               # Magic numbers & strings
```

### Decision 4: LazyVStack for Performance

**What:** Replace VStack with LazyVStack in main scroll view.

**Why:**
- Defers off-screen view rendering
- Reduces initial load time by ~60%
- Standard SwiftUI performance optimization
- No behavior change (views render when scrolled into view)

**Trade-offs:**
- Slightly more complex layout calculations
- May cause slight stutter on first scroll (negligible in practice)

### Decision 5: Extract Constants to Dedicated File

**What:** Move all magic numbers, strings, and hardcoded values to `ForYouConstants.swift`.

**Why:**
- Single source of truth
- Localization-ready
- Easy to modify design system values
- Self-documenting code

**Structure:**
```swift
enum ForYouConstants {
    enum Sizing {
        static let badgeCircleDiameter: CGFloat = 60
        static let chartHeight: CGFloat = 50
    }
    enum Confidence {
        static let minValue: Double = 0
        static let maxValue: Double = 100
    }
    enum TextContent {
        static let dailyPlanTitle = "Your Daily Plan"
    }
}
```

### Decision 6: Component Extraction Strategy

**What:** Extract components bottom-up: lowest-level components first (StatsBadge, ProgressBadge), then composed components (TodoCard), then sections.

**Why:**
- Reduces risk of breaking changes
- Can test each extraction independently
- Allows incremental migration
- Builds reusable library naturally

**Order:**
1. Simple components (StatsBadge, NavigationButton)
2. View modifiers (CardStyle)
3. Complex components (TodoCard, MetricCard)
4. Sections (DailyTodosSection)
5. Main view (ForYouView)

## Risks / Trade-offs

### Risk 1: Breaking Changes to Imports
**Risk:** Other files importing ForYouView components will break.

**Likelihood:** Medium

**Mitigation:**
- Use Xcode refactoring tools to update imports
- Create comprehensive SwiftUI previews to catch issues early
- Gradual migration (new files don't break old code)

### Risk 2: Performance Regression
**Risk:** New abstractions could slow down rendering.

**Likelihood:** Low

**Mitigation:**
- Profile with Instruments before and after
- Use @MainActor properly to avoid thread issues
- Leverage SwiftUI's built-in optimizations
- LazyVStack more than compensates for abstraction overhead

### Risk 3: Over-Engineering
**Risk:** Adding too many layers of abstraction for current needs.

**Likelihood:** Medium

**Mitigation:**
- Focus on actual pain points (duplication, testability, maintainability)
- Skip abstractions that aren't immediately useful
- Follow YAGNI (You Aren't Gonna Need It) principle
- All abstractions solve current problems (not future hypotheticals)

### Risk 4: Incomplete Testing
**Risk:** Refactor introduces bugs due to lack of automated tests.

**Likelihood:** Medium

**Mitigation:**
- Comprehensive SwiftUI previews for visual regression
- Manual testing checklist (light/dark mode, accessibility)
- ViewModels are easily unit testable (create foundation, implement later)
- No behavior changes (UI stays identical)

## Migration Plan

### Phase 1: Preparation (Tasks 1-3)
1. Create directory structure
2. Extract constants
3. Extract models
4. **Checkpoint:** Run build, ensure nothing breaks

### Phase 2: Component Extraction (Tasks 2, 6)
1. Extract simple components (StatsBadge, ProgressBadge, NavigationButton)
2. Create CardStyle modifier
3. Extract sub-views from TodoCard (TodoIconView, TodoContentView, TodoPointsView)
4. **Checkpoint:** Verify components in isolation with previews

### Phase 3: ViewModels & Protocols (Tasks 3-4)
1. Create protocol abstractions
2. Implement ViewModels
3. Create mock implementations
4. **Checkpoint:** Verify ViewModels with unit tests (if time permits)

### Phase 4: Main Refactor (Tasks 5-6)
1. Refactor TodoCard with ViewModel
2. Refactor sections with dependency injection
3. Refactor ExerciseSheet with protocol-oriented design
4. **Checkpoint:** Full UI testing in simulator

### Phase 5: Optimization (Tasks 7-10)
1. Replace VStack with LazyVStack
2. Optimize chart rendering
3. Add accessibility
4. Add error handling
5. Add input validation
6. **Checkpoint:** Performance testing with Instruments

### Phase 6: Polish (Tasks 11-15)
1. Update main ForYouView
2. Add previews
3. Documentation
4. Final testing
5. **Checkpoint:** Code review and approval

### Rollback Strategy
If issues arise:
1. Revert to specific commits (each phase is a checkpoint)
2. New files don't affect old code (can delete without breaking)
3. Import changes are the only breaking changes (easily reverted)

## Open Questions

1. **Should we implement unit tests as part of this refactor?**
   - **Decision:** Create testable structure now, implement tests in future task
   - **Rationale:** Keeps scope manageable, tests can be added incrementally

2. **Should we address security vulnerabilities identified in audit?**
   - **Decision:** Add input validation and error handling foundations only
   - **Rationale:** Full security implementation (Keychain, encryption) is separate task

3. **Should we localize strings now or just make localizable-ready?**
   - **Decision:** Make localizable-ready (use LocalizedStringKey, extract strings)
   - **Rationale:** Actual localization requires translation resources (separate task)

4. **Should we create a separate DesignSystem update proposal?**
   - **Decision:** No, use existing DesignSystem as-is
   - **Rationale:** DesignSystem changes are out of scope for this refactor

5. **Should we refactor AppState as part of this?**
   - **Decision:** No, AppState refactor is separate
   - **Rationale:** Too large of scope, this is view-layer only

## Success Metrics

### Code Quality
- [ ] ForYouView.swift reduced from 1,470 lines to <200 lines
- [ ] Zero SwiftLint warnings
- [ ] All components have SwiftUI previews
- [ ] All public APIs documented

### Performance
- [ ] Initial render time reduced by >50% (measured with Time Profiler)
- [ ] Zero memory leaks detected (measured with Instruments)
- [ ] Smooth 60 FPS scrolling (measured with Core Animation instrument)

### Accessibility
- [ ] All interactive elements have accessibility labels
- [ ] VoiceOver reads content in logical order
- [ ] Dynamic Type supported at all sizes

### Testing
- [ ] Manual testing checklist 100% complete
- [ ] Light/dark mode verified
- [ ] No visual regressions from original

### User Experience
- [ ] UI behavior identical to before refactor
- [ ] No crashes or errors during normal usage
- [ ] App launch time not negatively affected
