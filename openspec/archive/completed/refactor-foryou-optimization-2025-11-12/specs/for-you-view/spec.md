# ForYou View Specification

## ADDED Requirements

### Requirement: Daily Training Dashboard

The system SHALL provide a unified dashboard view that displays daily training exercises, progress tracking, and calibration analytics.

#### Scenario: User opens ForYou view
- **WHEN** user navigates to the ForYou tab
- **THEN** the system displays daily todos section at the top
- **AND** displays judgment tracking section below
- **AND** loads content lazily as user scrolls
- **AND** renders in under 2 seconds on typical devices

#### Scenario: User views in light mode
- **WHEN** device is in light mode
- **THEN** all components use light mode color scheme
- **AND** shadows are visible and appropriate
- **AND** text contrast meets WCAG AA standards

#### Scenario: User views in dark mode
- **WHEN** device is in dark mode
- **THEN** all components use dark mode color scheme
- **AND** shadows are adapted for dark backgrounds
- **AND** text contrast meets WCAG AA standards

#### Scenario: VoiceOver user navigates view
- **WHEN** VoiceOver is enabled
- **THEN** all interactive elements have descriptive labels
- **AND** reading order is logical (top to bottom)
- **AND** state changes are announced
- **AND** all images have alternative text

### Requirement: Daily Todos Section

The system SHALL display a list of daily training exercises with completion tracking, streaks, and stars badges.

#### Scenario: User views daily todos
- **WHEN** ForYou view loads
- **THEN** daily todos section displays "Your Daily Plan" title
- **AND** displays subtitle explaining exercise purpose
- **AND** shows streak badge with current daily streak count
- **AND** shows stars badge with total stars earned
- **AND** lists all available daily exercises with icons, titles, descriptions, and point values

#### Scenario: User views completed todo
- **WHEN** todo is marked as completed
- **THEN** todo displays checkmark icon instead of custom icon
- **AND** todo has reduced opacity (0.6)
- **AND** todo is not tappable
- **AND** "In Progress" badge is hidden

#### Scenario: User views in-progress todo
- **WHEN** todo exercise has been started but not completed
- **THEN** todo displays "In Progress" badge
- **AND** badge shows current step out of total steps
- **AND** todo remains tappable to resume

#### Scenario: User taps streak badge
- **WHEN** user taps flame icon streak badge
- **THEN** streak detail sheet opens
- **AND** displays current streak count with flame icon
- **AND** shows weekly calendar with activity indicators
- **AND** allows navigation between weeks

#### Scenario: User taps stars badge
- **WHEN** user taps star icon stars badge
- **THEN** stars detail sheet opens
- **AND** displays total stars count with star icon
- **AND** shows level progression with milestones
- **AND** indicates next level requirements

### Requirement: Todo Card Component

The system SHALL provide individual todo cards that display exercise information and handle user interaction.

#### Scenario: User taps incomplete todo card
- **WHEN** user taps a todo that is not completed
- **THEN** exercise sheet opens with exercise details
- **AND** exercise starts at step 1 if new
- **AND** exercise resumes at last step if in progress
- **AND** sheet displays with large presentation detent
- **AND** sheet shows drag indicator

#### Scenario: User attempts to tap completed todo
- **WHEN** user taps a completed todo
- **THEN** no action occurs
- **AND** no exercise sheet opens
- **AND** visual feedback indicates completion state

#### Scenario: Todo card displays in compact space
- **WHEN** device has limited horizontal space
- **THEN** card content wraps appropriately
- **AND** all text remains readable
- **AND** minimum touch target size (44pt) is maintained

### Requirement: Track Your Judgment Section

The system SHALL display calibration analytics with metrics and charts to help users assess prediction accuracy.

#### Scenario: User views judgment tracking section
- **WHEN** ForYou view loads
- **THEN** judgment section displays "Track Your Judgment" title
- **AND** displays subtitle explaining calibration tracking
- **AND** shows calibration chart comparing predicted vs actual confidence
- **AND** displays four metric cards: Brier Score, Calibration, Confidence, Predictions

#### Scenario: User views calibration chart
- **WHEN** judgment section is visible
- **THEN** chart displays perfect calibration line (dashed, gray)
- **AND** chart displays user's actual calibration curve (solid, primary color)
- **AND** chart has X-axis labeled "Predicted Confidence %"
- **AND** chart has Y-axis labeled "Actual Accuracy %"
- **AND** chart scales from 0 to 100 on both axes
- **AND** chart uses smooth curve interpolation

#### Scenario: User views metric cards
- **WHEN** judgment section is visible
- **THEN** each metric card displays metric name
- **AND** displays current metric value
- **AND** shows trend indicator (improving, declining, stable, neutral)
- **AND** provides help text explaining the metric
- **AND** cards are arranged in 2x2 grid

### Requirement: Exercise Sheet Flow

The system SHALL provide multi-step exercise sheets for different exercise types with progress tracking and navigation.

#### Scenario: User starts calibration exercise
- **WHEN** user opens calibration todo
- **THEN** sheet displays "Calibration Exercise" title
- **AND** shows progress bar indicating step 1 of 5
- **AND** displays calibration question
- **AND** provides confidence slider (0-100%, step 5)
- **AND** shows current confidence value
- **AND** displays "Next" button to proceed
- **AND** does not show "Previous" button on first step

#### Scenario: User navigates exercise steps
- **WHEN** user is on step 2 or later
- **THEN** "Previous" button is visible and functional
- **AND** "Next" button is visible if not on last step
- **AND** "Complete" button is visible on last step
- **AND** progress bar updates to reflect current step
- **AND** step counter updates (e.g., "Step 3 of 5")

#### Scenario: User completes exercise
- **WHEN** user clicks "Complete" on final step
- **THEN** exercise is marked as completed
- **AND** todo card updates to show completed state
- **AND** exercise sheet dismisses
- **AND** completion state persists in app state

#### Scenario: User cancels exercise
- **WHEN** user taps "Cancel" in navigation bar
- **THEN** exercise sheet dismisses
- **AND** progress is saved if exercise was in progress
- **AND** todo card shows in-progress state if partially completed

### Requirement: Streak Calendar View

The system SHALL display a weekly calendar showing daily training activity and streak maintenance.

#### Scenario: User views current week streak
- **WHEN** streak sheet opens
- **THEN** displays current week by default
- **AND** shows day labels (Sun, Mon, Tue, Wed, Thu, Fri, Sat)
- **AND** highlights days with training activity
- **AND** shows inactive state for future days
- **AND** displays week date range in header

#### Scenario: User navigates to previous weeks
- **WHEN** user taps left arrow button
- **THEN** calendar shows previous week
- **AND** week date range updates in header
- **AND** activity indicators update for that week
- **AND** right arrow becomes enabled

#### Scenario: User navigates to next weeks
- **WHEN** user taps right arrow button on past weeks
- **THEN** calendar shows next week
- **AND** cannot navigate beyond current week
- **AND** right arrow disables when at current week

### Requirement: Stars Progression View

The system SHALL display total stars earned and level progression with visual milestones.

#### Scenario: User views stars progression
- **WHEN** stars sheet opens
- **THEN** displays total stars count
- **AND** shows current level based on stars
- **AND** displays progress to next level
- **AND** shows milestone markers every 100 stars
- **AND** indicates completed levels and upcoming levels

#### Scenario: User reaches new level
- **WHEN** total stars crosses 100-star threshold
- **THEN** level indicator updates
- **AND** progress bar reflects new level progress
- **AND** milestone marker shows as completed

### Requirement: Performance Optimization

The system SHALL optimize rendering performance to ensure smooth scrolling and fast initial load times.

#### Scenario: User scrolls ForYou view
- **WHEN** user scrolls through content
- **THEN** off-screen views are lazily loaded
- **AND** scrolling maintains 60 FPS
- **AND** no stuttering or frame drops occur
- **AND** chart rendering does not block main thread

#### Scenario: User returns to ForYou view
- **WHEN** user navigates back to ForYou tab
- **THEN** previously loaded content remains in memory (within reason)
- **AND** view state is preserved
- **AND** no unnecessary re-renders occur
- **AND** load time is under 500ms

### Requirement: Accessibility Support

The system SHALL provide comprehensive accessibility support for users with disabilities.

#### Scenario: User with large text size
- **WHEN** device is set to larger Dynamic Type size
- **THEN** all text scales appropriately
- **AND** layout adapts to larger text
- **AND** no text is truncated
- **AND** touch targets remain appropriately sized

#### Scenario: VoiceOver user interacts with todo
- **WHEN** VoiceOver user focuses on todo card
- **THEN** announces todo title and description
- **AND** announces completion state
- **AND** announces points value
- **AND** provides hint about tapping to start
- **AND** announces if in progress with step count

#### Scenario: VoiceOver user interacts with chart
- **WHEN** VoiceOver user focuses on calibration chart
- **THEN** announces "Calibration Chart"
- **AND** provides summary of calibration quality
- **AND** allows navigation through data points
- **AND** announces each point's confidence and accuracy values

### Requirement: Error Handling

The system SHALL gracefully handle errors and provide appropriate user feedback.

#### Scenario: Data loading fails
- **WHEN** daily todos fail to load
- **THEN** error state view is displayed
- **AND** error message explains the issue
- **AND** retry button is provided
- **AND** user can retry loading

#### Scenario: Exercise completion fails
- **WHEN** exercise completion request fails
- **THEN** error alert is shown
- **AND** exercise state is preserved
- **AND** user can retry completion
- **AND** exercise sheet remains open

#### Scenario: Invalid input provided
- **WHEN** user enters invalid text in exercise
- **THEN** input is sanitized before processing
- **AND** length limits are enforced
- **AND** dangerous characters are filtered
- **AND** user receives feedback if input modified

### Requirement: Input Validation

The system SHALL validate and sanitize all user inputs to prevent security issues and data corruption.

#### Scenario: User enters text in exercise
- **WHEN** user types in text editor
- **THEN** input is limited to 5000 characters
- **AND** input is trimmed of excess whitespace
- **AND** dangerous characters are filtered
- **AND** remaining character count is shown

#### Scenario: User adjusts confidence slider
- **WHEN** user moves confidence slider
- **THEN** value is constrained to 0-100 range
- **AND** value is rounded to nearest 5%
- **AND** current value is displayed in real-time
- **AND** slider updates smoothly without lag

### Requirement: Component Reusability

The system SHALL provide reusable components that maintain consistent styling and behavior.

#### Scenario: Developer uses StatsBadge component
- **WHEN** StatsBadge is instantiated with icon, value, and color
- **THEN** badge displays icon with specified color
- **AND** badge displays value in bold
- **AND** badge has consistent padding and sizing
- **AND** badge has pill shape with border
- **AND** badge maintains minimum touch target size

#### Scenario: Developer applies CardStyle modifier
- **WHEN** view applies cardStyle modifier
- **THEN** view has consistent card padding
- **AND** view has secondary background color
- **AND** view has rounded corners (32pt radius)
- **AND** view has 1pt border in border color
- **AND** view has appropriate shadow

### Requirement: Testability

The system SHALL provide protocol-based abstractions that enable unit testing and preview mocking.

#### Scenario: Developer creates preview with mock data
- **WHEN** developer creates SwiftUI preview
- **THEN** mock implementations of protocols are available
- **AND** preview data is separate from production data
- **AND** preview compiles and displays correctly
- **AND** preview supports different states (loading, error, success)

#### Scenario: Developer writes unit test for ViewModel
- **WHEN** developer creates unit test for TodoCardViewModel
- **THEN** ViewModel can be instantiated independently
- **AND** mock dependencies can be injected
- **AND** state changes can be observed and tested
- **AND** async operations can be tested with expectations

### Requirement: Code Organization

The system SHALL organize code into logical layers with clear separation of concerns.

#### Scenario: Developer navigates codebase
- **WHEN** developer looks for ForYou feature code
- **THEN** feature is organized in Features/ForYou/ directory
- **AND** components are in Components/ subdirectory
- **AND** view models are in ViewModels/ subdirectory
- **AND** sheets are in Sheets/ subdirectory
- **AND** models are in Models/ subdirectory
- **AND** constants are in Constants/ subdirectory

#### Scenario: Developer modifies existing component
- **WHEN** developer needs to change TodoCard
- **THEN** component is in single dedicated file
- **AND** file is under 200 lines
- **AND** dependencies are clear from initializer
- **AND** component has comprehensive preview
