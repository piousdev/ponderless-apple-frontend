# Ponderless Database Schema Documentation

## Overview

This document outlines the **complete and production-ready** database schema for the Ponderless application, including all tables, their properties, and relationships. The schema is designed to support micro-learning, critical thinking skill development, AI coaching, reflections, comprehensive progress tracking, subscription management, and offline-first architecture.

**Version**: 2.0 (Complete)
**Last Updated**: 2025
**Total Tables**: 137

---

## Table of Contents

1. [User Management & Authentication](#user-management--authentication)
2. [Subscription & Payments](#subscription--payments)
3. [Notifications & Reminders](#notifications--reminders)
4. [User Preferences & Settings](#user-preferences--settings)
5. [Lessons & Content](#lessons--content)
6. [Exercises & Assessments](#exercises--assessments)
7. [Training & Skills](#training--skills)
8. [Reflections & Journaling](#reflections--journaling)
9. [AI Coaches](#ai-coaches)
10. [Frameworks](#frameworks)
11. [Progress & Analytics](#progress--analytics)
12. [Gamification](#gamification)
13. [Feature Access Control](#feature-access-control)
14. [Sync & Offline Support](#sync--offline-support)
15. [Relationships Diagram](#relationships-diagram)

---

## 1. User Management & Authentication

### `users`
Core user account and profile information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique user identifier |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User email address |
| `username` | VARCHAR(50) | UNIQUE, NOT NULL | Display username |
| `password_hash` | VARCHAR(255) | NOT NULL | Hashed password |
| `name` | VARCHAR(200) | NOT NULL | Full name |
| `bio` | TEXT | | User biography |
| `profile_image_url` | TEXT | | Profile picture URL |
| `avatar_color` | VARCHAR(7) | | Hex color for avatar background |
| `current_role` | VARCHAR(100) | | User's current professional role |
| `timezone` | VARCHAR(50) | NOT NULL DEFAULT 'UTC' | User's timezone (IANA format) |
| `email_verified` | BOOLEAN | DEFAULT FALSE | Email verification status |
| `is_premium` | BOOLEAN | DEFAULT FALSE | Premium subscription status (computed) |
| `joined_at` | TIMESTAMP | NOT NULL | Account creation timestamp |
| `created_at` | TIMESTAMP | NOT NULL | Record creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |
| `last_login_at` | TIMESTAMP | | Last login timestamp |
| `deleted_at` | TIMESTAMP | | Soft delete timestamp |

**Indexes:**
- `idx_users_email` on `email`
- `idx_users_username` on `username`
- `idx_users_joined_at` on `joined_at`
- `idx_users_deleted_at` on `deleted_at`

### `user_focus_areas`
Many-to-many relationship between users and skill categories they want to focus on.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `skill_category` | VARCHAR(50) | NOT NULL | Focus area skill category |
| `priority` | INTEGER | DEFAULT 0 | Priority order (0 = highest) |
| `added_at` | TIMESTAMP | NOT NULL | When focus area was added |

**Primary Key:** (`user_id`, `skill_category`)

**Enums:**
- `skill_category`: evidenceLiteracy, biasRecognition, probabilityFundamentals, metacognition

**Indexes:**
- `idx_focus_areas_user_id` on `user_id`

### `authentication_tokens`
Session tokens for authenticated users.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique token identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `token_hash` | VARCHAR(255) | UNIQUE, NOT NULL | Hashed authentication token |
| `device_id` | VARCHAR(255) | | Device identifier |
| `device_name` | VARCHAR(255) | | Human-readable device name |
| `ip_address` | VARCHAR(45) | | IP address |
| `user_agent` | TEXT | | Browser/app user agent |
| `expires_at` | TIMESTAMP | NOT NULL | Token expiration |
| `created_at` | TIMESTAMP | NOT NULL | Token creation |
| `last_used_at` | TIMESTAMP | | Last use timestamp |
| `revoked_at` | TIMESTAMP | | Revocation timestamp |

**Indexes:**
- `idx_tokens_user_id` on `user_id`
- `idx_tokens_expires_at` on `expires_at`
- `idx_tokens_token_hash` on `token_hash`

---

## 2. Subscription & Payments

### `subscriptions`
Active user subscriptions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique subscription identifier |
| `user_id` | UUID | UNIQUE, FOREIGN KEY → users.id | Subscriber |
| `tier` | VARCHAR(20) | NOT NULL | Subscription tier |
| `billing_period` | VARCHAR(20) | NOT NULL | Billing period |
| `status` | VARCHAR(20) | NOT NULL | Subscription status |
| `price_paid` | DECIMAL(10,2) | NOT NULL | Amount paid |
| `currency` | VARCHAR(3) | NOT NULL DEFAULT 'EUR' | Currency code (ISO 4217) |
| `start_date` | TIMESTAMP | NOT NULL | Subscription start |
| `current_period_start` | TIMESTAMP | NOT NULL | Current billing period start |
| `current_period_end` | TIMESTAMP | NOT NULL | Current billing period end |
| `cancel_at_period_end` | BOOLEAN | DEFAULT FALSE | Cancel at end of period |
| `canceled_at` | TIMESTAMP | | Cancellation timestamp |
| `ended_at` | TIMESTAMP | | End timestamp |
| `trial_start` | TIMESTAMP | | Trial start timestamp |
| `trial_end` | TIMESTAMP | | Trial end timestamp |
| `stripe_subscription_id` | VARCHAR(255) | UNIQUE | Stripe subscription ID |
| `stripe_customer_id` | VARCHAR(255) | | Stripe customer ID |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `tier`: starter, premium
- `billing_period`: monthly, annual
- `status`: trialing, active, past_due, canceled, unpaid, incomplete, incomplete_expired

**Indexes:**
- `idx_subscriptions_user_id` on `user_id`
- `idx_subscriptions_status` on `status`
- `idx_subscriptions_current_period_end` on `current_period_end`
- `idx_subscriptions_stripe_subscription_id` on `stripe_subscription_id`

### `subscription_tiers`
Subscription plan definitions and pricing.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `tier` | VARCHAR(20) | PRIMARY KEY | Tier identifier |
| `name` | VARCHAR(100) | NOT NULL | Display name |
| `subtitle` | VARCHAR(255) | | Subtitle/tagline |
| `monthly_price_eur` | DECIMAL(10,2) | NOT NULL | Monthly price in EUR |
| `annual_price_eur` | DECIMAL(10,2) | NOT NULL | Annual price in EUR |
| `monthly_price_usd` | DECIMAL(10,2) | | Monthly price in USD |
| `annual_price_usd` | DECIMAL(10,2) | | Annual price in USD |
| `features` | JSONB | NOT NULL | Array of feature descriptions |
| `max_exercises_per_month` | INTEGER | | Exercise limit (-1 = unlimited) |
| `is_active` | BOOLEAN | DEFAULT TRUE | Whether tier is available |
| `sort_order` | INTEGER | NOT NULL | Display order |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `tier`: starter, premium

### `payment_transactions`
Payment history and receipts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique transaction identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | Payer |
| `subscription_id` | UUID | FOREIGN KEY → subscriptions.id | Related subscription |
| `amount` | DECIMAL(10,2) | NOT NULL | Transaction amount |
| `currency` | VARCHAR(3) | NOT NULL | Currency code |
| `status` | VARCHAR(20) | NOT NULL | Transaction status |
| `payment_method` | VARCHAR(50) | | Payment method type |
| `description` | TEXT | | Transaction description |
| `stripe_payment_intent_id` | VARCHAR(255) | UNIQUE | Stripe payment intent ID |
| `stripe_charge_id` | VARCHAR(255) | | Stripe charge ID |
| `receipt_url` | TEXT | | Receipt URL |
| `failure_code` | VARCHAR(100) | | Failure code if failed |
| `failure_message` | TEXT | | Failure message if failed |
| `transaction_date` | TIMESTAMP | NOT NULL | Transaction timestamp |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `status`: pending, succeeded, failed, refunded, canceled

**Indexes:**
- `idx_transactions_user_id` on `user_id`
- `idx_transactions_subscription_id` on `subscription_id`
- `idx_transactions_transaction_date` on `transaction_date`
- `idx_transactions_status` on `status`

### `payment_methods`
Saved payment methods for users.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique payment method identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `payment_type` | VARCHAR(20) | NOT NULL | Type of payment method |
| `brand` | VARCHAR(50) | | Card brand (Visa, Mastercard, etc.) |
| `last_four` | VARCHAR(4) | | Last 4 digits of card |
| `expiry_month` | INTEGER | | Expiration month |
| `expiry_year` | INTEGER | | Expiration year |
| `is_default` | BOOLEAN | DEFAULT FALSE | Default payment method |
| `stripe_payment_method_id` | VARCHAR(255) | UNIQUE | Stripe payment method ID |
| `stripe_customer_id` | VARCHAR(255) | | Stripe customer ID |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |
| `deleted_at` | TIMESTAMP | | Soft delete timestamp |

**Enums:**
- `payment_type`: card, paypal, apple_pay, google_pay

**Indexes:**
- `idx_payment_methods_user_id` on `user_id`
- `idx_payment_methods_is_default` on `is_default`

### `trials`
Free trial tracking and conversion.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique trial identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `tier` | VARCHAR(20) | NOT NULL | Trial tier |
| `start_date` | TIMESTAMP | NOT NULL | Trial start |
| `end_date` | TIMESTAMP | NOT NULL | Trial end |
| `converted` | BOOLEAN | DEFAULT FALSE | Whether converted to paid |
| `converted_at` | TIMESTAMP | | Conversion timestamp |
| `converted_subscription_id` | UUID | FOREIGN KEY → subscriptions.id | Resulting subscription |
| `canceled` | BOOLEAN | DEFAULT FALSE | Whether canceled before end |
| `canceled_at` | TIMESTAMP | | Cancellation timestamp |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Indexes:**
- `idx_trials_user_id` on `user_id`
- `idx_trials_end_date` on `end_date`
- `idx_trials_converted` on `converted`

---

## 3. Notifications & Reminders

### `notification_preferences`
User notification settings.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | PRIMARY KEY, FOREIGN KEY → users.id | User |
| `notifications_enabled` | BOOLEAN | DEFAULT TRUE | Master notifications toggle |
| `daily_reminder_enabled` | BOOLEAN | DEFAULT TRUE | Daily lesson reminder |
| `daily_reminder_time` | TIME | DEFAULT '09:00' | Reminder time (user's timezone) |
| `streak_reminder_enabled` | BOOLEAN | DEFAULT TRUE | Streak at risk reminder |
| `achievement_notifications` | BOOLEAN | DEFAULT TRUE | Achievement unlocks |
| `lesson_recommendations` | BOOLEAN | DEFAULT TRUE | New lesson suggestions |
| `coach_suggestions` | BOOLEAN | DEFAULT TRUE | Coach prompts |
| `weekly_summary` | BOOLEAN | DEFAULT TRUE | Weekly progress summary |
| `email_notifications` | BOOLEAN | DEFAULT TRUE | Email notifications |
| `push_notifications` | BOOLEAN | DEFAULT TRUE | Push notifications |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

### `scheduled_notifications`
Pending notifications to be sent.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique notification identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | Recipient |
| `notification_type` | VARCHAR(30) | NOT NULL | Type of notification |
| `title` | VARCHAR(255) | NOT NULL | Notification title |
| `body` | TEXT | NOT NULL | Notification body |
| `data_payload` | JSONB | | Additional data |
| `scheduled_time` | TIMESTAMP | NOT NULL | When to send |
| `status` | VARCHAR(20) | NOT NULL DEFAULT 'pending' | Notification status |
| `sent_at` | TIMESTAMP | | Actual send timestamp |
| `failed_at` | TIMESTAMP | | Failure timestamp |
| `error_message` | TEXT | | Error details if failed |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `notification_type`: dailyReminder, streakRisk, achievementUnlocked, lessonRecommendation, coachSuggestion, weeklySummary
- `status`: pending, sent, failed, canceled

**Indexes:**
- `idx_scheduled_notifications_user_id` on `user_id`
- `idx_scheduled_notifications_scheduled_time` on `scheduled_time`
- `idx_scheduled_notifications_status` on `status`

### `notification_history`
Record of sent notifications.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique history identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | Recipient |
| `notification_type` | VARCHAR(30) | NOT NULL | Type of notification |
| `title` | VARCHAR(255) | NOT NULL | Notification title |
| `body` | TEXT | NOT NULL | Notification body |
| `sent_at` | TIMESTAMP | NOT NULL | Send timestamp |
| `opened` | BOOLEAN | DEFAULT FALSE | Whether opened |
| `opened_at` | TIMESTAMP | | Open timestamp |
| `channel` | VARCHAR(20) | NOT NULL | Delivery channel |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `channel`: push, email, in_app

**Indexes:**
- `idx_notification_history_user_id` on `user_id`
- `idx_notification_history_sent_at` on `sent_at`
- `idx_notification_history_opened` on `opened`

### `push_tokens`
Device push notification tokens.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique token identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `device_id` | VARCHAR(255) | NOT NULL | Device identifier |
| `push_token` | TEXT | NOT NULL | Push notification token |
| `platform` | VARCHAR(10) | NOT NULL | Device platform |
| `is_active` | BOOLEAN | DEFAULT TRUE | Token active status |
| `last_used_at` | TIMESTAMP | | Last successful notification |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `platform`: ios, android

**Unique Constraint:** (`user_id`, `device_id`)

**Indexes:**
- `idx_push_tokens_user_id` on `user_id`
- `idx_push_tokens_is_active` on `is_active`

---

## 4. User Preferences & Settings

### `user_preferences`
User learning preferences and settings.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | PRIMARY KEY, FOREIGN KEY → users.id | User |
| `daily_goal` | INTEGER | NOT NULL DEFAULT 3 | Daily lesson goal |
| `preferred_difficulty` | VARCHAR(20) | NOT NULL DEFAULT 'intermediate' | Preferred difficulty level |
| `preferred_session_duration` | VARCHAR(20) | NOT NULL DEFAULT 'medium' | Preferred session length |
| `learning_style` | VARCHAR(20) | | Preferred learning style |
| `primary_goal` | VARCHAR(50) | | User's primary learning goal |
| `preferred_color_scheme` | VARCHAR(10) | DEFAULT 'system' | UI theme preference |
| `language` | VARCHAR(10) | DEFAULT 'en' | App language |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `preferred_difficulty`: beginner, intermediate, advanced
- `preferred_session_duration`: short, medium, long
- `learning_style`: visual, reading, interactive, mixed
- `primary_goal`: decisionMaking, academicGrowth, professionalDevelopment, personalEnrichment, criticalThinking
- `preferred_color_scheme`: system, light, dark

### `user_onboarding`
Onboarding completion tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | PRIMARY KEY, FOREIGN KEY → users.id | User |
| `completed` | BOOLEAN | DEFAULT FALSE | Onboarding completed |
| `current_step` | INTEGER | DEFAULT 0 | Current step index |
| `completed_steps` | JSONB | | Array of completed step identifiers |
| `skipped_steps` | JSONB | | Array of skipped step identifiers |
| `completed_at` | TIMESTAMP | | Completion timestamp |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

---

## 5. Lessons & Content

### `lessons`
Micro-learning lesson metadata.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique lesson identifier |
| `title` | VARCHAR(255) | NOT NULL | Lesson title |
| `subtitle` | TEXT | | Short description |
| `category` | VARCHAR(50) | NOT NULL | Lesson category (enum) |
| `difficulty` | VARCHAR(20) | NOT NULL | Difficulty level (beginner/intermediate/advanced) |
| `estimated_duration` | INTEGER | NOT NULL | Duration in seconds |
| `is_locked` | BOOLEAN | DEFAULT FALSE | Lock status |
| `is_premium` | BOOLEAN | DEFAULT FALSE | Premium content flag |
| `order` | INTEGER | NOT NULL | Display order |
| `introduction` | TEXT | | Lesson introduction |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |
| `published_at` | TIMESTAMP | | Publication timestamp |
| `deleted_at` | TIMESTAMP | | Soft delete timestamp |

**Enums:**
- `category`: decisionMaking, criticalThinking, emotionalRegulation, problemSolving, mindfulness, productivity
- `difficulty`: beginner, intermediate, advanced

**Indexes:**
- `idx_lessons_category` on `category`
- `idx_lessons_difficulty` on `difficulty`
- `idx_lessons_order` on `order`
- `idx_lessons_published_at` on `published_at`
- `idx_lessons_is_premium` on `is_premium`

### `lesson_tags`
Tags associated with lessons (many-to-many).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `lesson_id` | UUID | FOREIGN KEY → lessons.id | Reference to lesson |
| `tag` | VARCHAR(50) | NOT NULL | Tag name |

**Primary Key:** (`lesson_id`, `tag`)

**Indexes:**
- `idx_lesson_tags_tag` on `tag`

### `lesson_content_blocks`
Individual content blocks within lessons.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique block identifier |
| `lesson_id` | UUID | FOREIGN KEY → lessons.id | Parent lesson |
| `block_type` | VARCHAR(20) | NOT NULL | Type of content block |
| `content` | TEXT | NOT NULL | Block content |
| `order` | INTEGER | NOT NULL | Display order |
| `metadata` | JSONB | | Additional metadata |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `block_type`: text, quote, example, tip, warning, interactive

**Indexes:**
- `idx_content_blocks_lesson_id` on `lesson_id`
- `idx_content_blocks_order` on `order`

### `lesson_key_takeaways`
Key takeaways for each lesson.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier |
| `lesson_id` | UUID | FOREIGN KEY → lessons.id | Parent lesson |
| `takeaway` | TEXT | NOT NULL | Takeaway content |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_takeaways_lesson_id` on `lesson_id`

### `lesson_resources`
Additional resources for lessons.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier |
| `lesson_id` | UUID | FOREIGN KEY → lessons.id | Parent lesson |
| `title` | VARCHAR(255) | NOT NULL | Resource title |
| `url` | TEXT | NOT NULL | Resource URL |
| `resource_type` | VARCHAR(20) | NOT NULL | Type of resource |
| `order` | INTEGER | NOT NULL | Display order |

**Enums:**
- `resource_type`: article, video, podcast, book

**Indexes:**
- `idx_resources_lesson_id` on `lesson_id`

---

## 6. Exercises & Assessments

### `exercises`
Interactive exercises and quizzes.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique exercise identifier |
| `title` | VARCHAR(255) | NOT NULL | Exercise title |
| `instructions` | TEXT | NOT NULL | Instructions |
| `exercise_type` | VARCHAR(20) | NOT NULL | Type of exercise |
| `time_limit` | INTEGER | | Time limit in seconds |
| `passing_score` | DECIMAL(3,2) | NOT NULL | Passing score (0.00-1.00) |
| `feedback_strategy` | VARCHAR(20) | NOT NULL | Feedback delivery strategy |
| `related_lesson_id` | UUID | FOREIGN KEY → lessons.id | Related lesson |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |
| `deleted_at` | TIMESTAMP | | Soft delete timestamp |

**Enums:**
- `exercise_type`: quiz, scenario, reflection, practical, assessment
- `feedback_strategy`: immediate, afterSubmission, delayed

**Indexes:**
- `idx_exercises_type` on `exercise_type`
- `idx_exercises_lesson_id` on `related_lesson_id`

### `questions`
Questions within exercises.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique question identifier |
| `exercise_id` | UUID | FOREIGN KEY → exercises.id | Parent exercise |
| `text` | TEXT | NOT NULL | Question text |
| `question_type` | VARCHAR(20) | NOT NULL | Type of question |
| `explanation` | TEXT | | Explanation of correct answer |
| `points` | INTEGER | NOT NULL | Points for correct answer |
| `hint` | TEXT | | Optional hint |
| `order` | INTEGER | NOT NULL | Display order |
| `difficulty` | VARCHAR(20) | | Question difficulty |
| `cognitive_level` | VARCHAR(20) | | Bloom's taxonomy level |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `question_type`: multipleChoice, multipleSelect, trueFalse, shortAnswer, scenario, ranking, matching
- `cognitive_level`: remember, understand, apply, analyze, evaluate, create

**Indexes:**
- `idx_questions_exercise_id` on `exercise_id`
- `idx_questions_order` on `order`

### `question_tags`
Tags for questions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `question_id` | UUID | FOREIGN KEY → questions.id | Reference to question |
| `tag` | VARCHAR(50) | NOT NULL | Tag name |

**Primary Key:** (`question_id`, `tag`)

### `question_options`
Answer options for questions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique option identifier |
| `question_id` | UUID | FOREIGN KEY → questions.id | Parent question |
| `text` | TEXT | NOT NULL | Option text |
| `is_correct` | BOOLEAN | NOT NULL | Correctness flag |
| `feedback` | TEXT | | Feedback for this option |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_options_question_id` on `question_id`

### `question_correct_answers`
Correct answers for questions (supports multiple correct answers).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `question_id` | UUID | FOREIGN KEY → questions.id | Parent question |
| `answer` | TEXT | NOT NULL | Correct answer text |
| `order` | INTEGER | | Order for ranking questions |

**Primary Key:** (`question_id`, `answer`)

### `scenarios`
Decision-making scenario exercises.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique scenario identifier |
| `title` | VARCHAR(255) | NOT NULL | Scenario title |
| `context` | TEXT | NOT NULL | Background context |
| `situation` | TEXT | NOT NULL | Current situation |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

### `scenario_decisions`
Decision points within scenarios.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique decision identifier |
| `scenario_id` | UUID | FOREIGN KEY → scenarios.id | Parent scenario |
| `text` | TEXT | NOT NULL | Decision text |
| `rationale` | TEXT | NOT NULL | Reasoning behind decision |
| `consequences` | JSONB | | Array of consequences |
| `next_decision_id` | UUID | FOREIGN KEY → scenario_decisions.id | Next decision |
| `outcome_id` | UUID | FOREIGN KEY → scenario_outcomes.id | Final outcome |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_decisions_scenario_id` on `scenario_id`

### `scenario_outcomes`
Outcomes for scenario decisions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique outcome identifier |
| `scenario_id` | UUID | FOREIGN KEY → scenarios.id | Parent scenario |
| `description` | TEXT | NOT NULL | Outcome description |
| `analysis` | TEXT | NOT NULL | Analysis of outcome |
| `score` | DECIMAL(3,2) | NOT NULL | Score (0.00-1.00) |
| `lessons_learned` | JSONB | | Array of lessons |

**Indexes:**
- `idx_outcomes_scenario_id` on `scenario_id`

### `scenario_learning_objectives`
Learning objectives for scenarios.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `scenario_id` | UUID | FOREIGN KEY → scenarios.id | Parent scenario |
| `objective` | TEXT | NOT NULL | Learning objective |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`scenario_id`, `order`)

### `exercise_responses`
User responses to exercises.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique response identifier |
| `exercise_id` | UUID | FOREIGN KEY → exercises.id | Related exercise |
| `user_id` | UUID | FOREIGN KEY → users.id | User who responded |
| `started_at` | TIMESTAMP | NOT NULL | Start timestamp |
| `completed_at` | TIMESTAMP | | Completion timestamp |
| `score` | DECIMAL(5,2) | | Final score |
| `time_spent` | INTEGER | | Time in seconds |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Indexes:**
- `idx_responses_user_id` on `user_id`
- `idx_responses_exercise_id` on `exercise_id`
- `idx_responses_completed_at` on `completed_at`

### `question_answers`
Individual question answers within exercise responses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique answer identifier |
| `response_id` | UUID | FOREIGN KEY → exercise_responses.id | Parent response |
| `question_id` | UUID | FOREIGN KEY → questions.id | Related question |
| `answer` | JSONB | NOT NULL | Answer data (array) |
| `is_correct` | BOOLEAN | NOT NULL | Correctness flag |
| `points_earned` | INTEGER | NOT NULL | Points earned |
| `timestamp` | TIMESTAMP | NOT NULL | Answer timestamp |

**Indexes:**
- `idx_answers_response_id` on `response_id`
- `idx_answers_question_id` on `question_id`

---

## 7. Training & Skills

### `training_exercises`
Skill-building training exercises (2-minute focused practice).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique training exercise identifier |
| `title` | VARCHAR(255) | NOT NULL | Exercise title |
| `skill_category` | VARCHAR(50) | NOT NULL | Skill category |
| `duration` | INTEGER | NOT NULL DEFAULT 120 | Duration in seconds |
| `difficulty` | VARCHAR(20) | NOT NULL | Difficulty level |
| `scenario` | TEXT | NOT NULL | Training scenario |
| `immediate_feedback` | BOOLEAN | DEFAULT TRUE | Feedback timing flag |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `skill_category`: evidenceLiteracy, biasRecognition, probabilityFundamentals, metacognition

**Indexes:**
- `idx_training_skill_category` on `skill_category`
- `idx_training_difficulty` on `difficulty`

### `training_learning_points`
Learning points for training exercises.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `training_exercise_id` | UUID | FOREIGN KEY → training_exercises.id | Parent exercise |
| `learning_point` | TEXT | NOT NULL | Learning point text |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`training_exercise_id`, `order`)

### `skill_builder_tasks`
Individual tasks within training exercises.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique task identifier |
| `training_exercise_id` | UUID | FOREIGN KEY → training_exercises.id | Parent exercise |
| `task_type` | VARCHAR(30) | NOT NULL | Type of task |
| `prompt` | TEXT | NOT NULL | Task prompt |
| `content` | JSONB | NOT NULL | Task content (varies by type) |
| `correct_answer` | JSONB | NOT NULL | Correct answer data |
| `points` | INTEGER | NOT NULL DEFAULT 10 | Points for completion |
| `order` | INTEGER | NOT NULL | Display order |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `task_type`: sourceEvaluation, biasIdentification, probabilityEstimation, confidenceCalibration, dataInterpretation, assumptionChecking

**Indexes:**
- `idx_tasks_training_id` on `training_exercise_id`

### `skill_builder_task_feedback`
Feedback for skill builder tasks.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `task_id` | UUID | PRIMARY KEY, FOREIGN KEY → skill_builder_tasks.id | Parent task |
| `correct_feedback` | TEXT | NOT NULL | Feedback when correct |
| `incorrect_feedback` | TEXT | NOT NULL | Feedback when incorrect |
| `explanation` | TEXT | NOT NULL | Detailed explanation |
| `concept` | VARCHAR(255) | NOT NULL | Concept being tested |

### `skill_progress`
User progress in each skill category.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique progress identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `skill_category` | VARCHAR(50) | NOT NULL | Skill category |
| `level` | INTEGER | NOT NULL DEFAULT 1 | Current level |
| `experience` | INTEGER | NOT NULL DEFAULT 0 | Experience points |
| `exercises_completed` | INTEGER | NOT NULL DEFAULT 0 | Completed exercises |
| `accuracy` | DECIMAL(5,2) | NOT NULL DEFAULT 0.00 | Average accuracy |
| `mastery_level` | VARCHAR(20) | NOT NULL DEFAULT 'novice' | Mastery level |
| `last_practiced` | TIMESTAMP | | Last practice timestamp |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `mastery_level`: novice, developing, proficient, advanced, expert

**Unique Constraint:** (`user_id`, `skill_category`)

**Indexes:**
- `idx_skill_progress_user_id` on `user_id`

### `calibration_records`
Calibration tracking for metacognition training.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique record identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `date` | DATE | NOT NULL | Record date |
| `brier_score` | DECIMAL(5,4) | NOT NULL | Brier score |
| `overconfidence_ratio` | DECIMAL(5,4) | NOT NULL | Overconfidence ratio |
| `underconfidence_ratio` | DECIMAL(5,4) | NOT NULL | Underconfidence ratio |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Indexes:**
- `idx_calibration_user_id` on `user_id`
- `idx_calibration_date` on `date`

### `prediction_records`
Individual predictions for calibration tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique prediction identifier |
| `calibration_record_id` | UUID | FOREIGN KEY → calibration_records.id | Parent record |
| `question_id` | UUID | | Related question if applicable |
| `predicted_probability` | DECIMAL(5,4) | NOT NULL | Predicted probability (0-1) |
| `actual_outcome` | BOOLEAN | NOT NULL | Actual outcome |
| `confidence` | INTEGER | NOT NULL | Confidence level (0-100) |
| `was_correct` | BOOLEAN | NOT NULL | Whether prediction was correct |
| `timestamp` | TIMESTAMP | NOT NULL | Prediction timestamp |

**Indexes:**
- `idx_predictions_calibration_id` on `calibration_record_id`

### `calibration_curve_points`
Calibration curve data points.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `calibration_record_id` | UUID | FOREIGN KEY → calibration_records.id | Parent record |
| `confidence_bucket` | INTEGER | NOT NULL | Confidence bucket (0, 10, 20, ..., 100) |
| `accuracy` | DECIMAL(5,4) | NOT NULL | Actual accuracy |
| `count` | INTEGER | NOT NULL | Number of predictions |

**Primary Key:** (`calibration_record_id`, `confidence_bucket`)

### `daily_todos`
Daily training tasks for users.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique todo identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `title` | VARCHAR(255) | NOT NULL | Todo title |
| `description` | TEXT | | Description |
| `icon` | VARCHAR(50) | | Icon identifier |
| `is_completed` | BOOLEAN | DEFAULT FALSE | Completion status |
| `points` | INTEGER | NOT NULL | Points reward |
| `exercise_type` | VARCHAR(30) | NOT NULL | Type of exercise |
| `related_exercise_id` | UUID | | Related exercise/training ID |
| `date` | DATE | NOT NULL | Todo date |
| `completed_at` | TIMESTAMP | | Completion timestamp |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `exercise_type`: calibration, biasRecognition, decisionFramework

**Indexes:**
- `idx_todos_user_id` on `user_id`
- `idx_todos_date` on `date`
- `idx_todos_completed` on `is_completed`

---

## 8. Reflections & Journaling

### `reflections`
Reflection prompts and templates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique reflection identifier |
| `title` | VARCHAR(255) | NOT NULL | Reflection title |
| `prompt` | TEXT | NOT NULL | Main reflection prompt |
| `category` | VARCHAR(30) | NOT NULL | Reflection category |
| `suggested_duration` | INTEGER | NOT NULL DEFAULT 600 | Duration in seconds |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |
| `deleted_at` | TIMESTAMP | | Soft delete timestamp |

**Enums:**
- `category`: daily, gratitude, goals, relationships, challenges, growth, values, decisions

**Indexes:**
- `idx_reflections_category` on `category`

### `reflection_guiding_questions`
Guiding questions for reflections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `reflection_id` | UUID | FOREIGN KEY → reflections.id | Parent reflection |
| `question` | TEXT | NOT NULL | Guiding question |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`reflection_id`, `order`)

### `reflection_tags`
Tags for reflections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `reflection_id` | UUID | FOREIGN KEY → reflections.id | Parent reflection |
| `tag` | VARCHAR(50) | NOT NULL | Tag name |

**Primary Key:** (`reflection_id`, `tag`)

### `journal_entries`
User journal entries.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique entry identifier |
| `reflection_id` | UUID | FOREIGN KEY → reflections.id | Related reflection prompt |
| `user_id` | UUID | FOREIGN KEY → users.id | Entry author |
| `content` | TEXT | NOT NULL | Entry content |
| `mood` | VARCHAR(20) | | User mood |
| `is_private` | BOOLEAN | DEFAULT TRUE | Privacy flag |
| `word_count` | INTEGER | NOT NULL | Word count |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |
| `deleted_at` | TIMESTAMP | | Soft delete timestamp |

**Enums:**
- `mood`: anxious, stressed, calm, excited, confused, motivated, thoughtful, overwhelmed

**Indexes:**
- `idx_entries_user_id` on `user_id`
- `idx_entries_reflection_id` on `reflection_id`
- `idx_entries_created_at` on `created_at`

### `journal_insights`
Insights extracted from journal entries.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `journal_entry_id` | UUID | FOREIGN KEY → journal_entries.id | Parent entry |
| `insight` | TEXT | NOT NULL | Insight text |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`journal_entry_id`, `order`)

### `journal_action_items`
Action items from journal entries.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique action item identifier |
| `journal_entry_id` | UUID | FOREIGN KEY → journal_entries.id | Parent entry |
| `action_item` | TEXT | NOT NULL | Action item text |
| `is_completed` | BOOLEAN | DEFAULT FALSE | Completion status |
| `completed_at` | TIMESTAMP | | Completion timestamp |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_action_items_entry_id` on `journal_entry_id`

### `reflection_templates`
Templates for guided reflections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique template identifier |
| `name` | VARCHAR(255) | NOT NULL | Template name |
| `description` | TEXT | | Template description |
| `estimated_time` | INTEGER | NOT NULL | Estimated time in seconds |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

### `reflection_template_sections`
Sections within reflection templates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique section identifier |
| `template_id` | UUID | FOREIGN KEY → reflection_templates.id | Parent template |
| `title` | VARCHAR(255) | NOT NULL | Section title |
| `prompt` | TEXT | NOT NULL | Section prompt |
| `placeholder_text` | TEXT | | Placeholder text |
| `min_words` | INTEGER | | Minimum word count |
| `max_words` | INTEGER | | Maximum word count |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_template_sections_template_id` on `template_id`

---

## 9. AI Coaches

### `coaches`
AI coach personalities.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique coach identifier |
| `coach_type` | VARCHAR(20) | UNIQUE, NOT NULL | Coach type |
| `name` | VARCHAR(100) | NOT NULL | Coach name |
| `tagline` | VARCHAR(255) | NOT NULL | Coach tagline |
| `introduction` | TEXT | NOT NULL | Introduction message |
| `avatar` | VARCHAR(100) | | Avatar/icon identifier |
| `is_available` | BOOLEAN | DEFAULT TRUE | Availability flag |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `coach_type`: challenger, navigator, explorer

### `coach_specialties`
Specialties for each coach.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `coach_id` | UUID | FOREIGN KEY → coaches.id | Parent coach |
| `specialty` | VARCHAR(50) | NOT NULL | Specialty name |

**Primary Key:** (`coach_id`, `specialty`)

**Enums:**
- `specialty`: criticalAnalysis, assumptionTesting, devilsAdvocate, systemsThinking, complexityMapping, decisionTrees, creativeProblemSolving, lateralThinking, perspectiveTaking

### `coach_personality_traits`
Personality traits for coaches.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `coach_id` | UUID | FOREIGN KEY → coaches.id | Parent coach |
| `trait` | VARCHAR(50) | NOT NULL | Trait name |

**Primary Key:** (`coach_id`, `trait`)

### `coach_typical_questions`
Typical questions coaches ask.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `coach_id` | UUID | FOREIGN KEY → coaches.id | Parent coach |
| `question` | TEXT | NOT NULL | Typical question |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`coach_id`, `order`)

### `coach_personality_config`
Personality configuration for coaches.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `coach_id` | UUID | PRIMARY KEY, FOREIGN KEY → coaches.id | Parent coach |
| `approach` | VARCHAR(20) | NOT NULL | Approach style |
| `tone` | VARCHAR(20) | NOT NULL | Tone style |

**Enums:**
- `approach`: socratic, collaborative, challenging, exploratory
- `tone`: professional, friendly, provocative, encouraging

### `coach_communication_style`
Communication style configuration.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `coach_id` | UUID | PRIMARY KEY, FOREIGN KEY → coaches.id | Parent coach |
| `preferred_length` | VARCHAR(20) | NOT NULL | Response length preference |
| `questioning_style` | VARCHAR(20) | NOT NULL | Questioning style |
| `feedback_style` | VARCHAR(20) | NOT NULL | Feedback style |
| `use_analogies` | BOOLEAN | DEFAULT TRUE | Use analogies flag |
| `use_examples` | BOOLEAN | DEFAULT TRUE | Use examples flag |

**Enums:**
- `preferred_length`: concise, balanced, detailed
- `questioning_style`: direct, probing, openEnded, hypothetical
- `feedback_style`: constructive, challenging, supportive, balanced

### `chat_sessions`
User chat sessions with coaches.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique session identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | Session user |
| `coach_type` | VARCHAR(20) | NOT NULL | Coach type for session |
| `topic` | VARCHAR(255) | | Session topic |
| `started_at` | TIMESTAMP | NOT NULL | Start timestamp |
| `ended_at` | TIMESTAMP | | End timestamp |
| `is_active` | BOOLEAN | DEFAULT TRUE | Active status |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Indexes:**
- `idx_sessions_user_id` on `user_id`
- `idx_sessions_coach_type` on `coach_type`
- `idx_sessions_started_at` on `started_at`

### `chat_messages`
Messages within chat sessions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique message identifier |
| `session_id` | UUID | FOREIGN KEY → chat_sessions.id | Parent session |
| `sender_type` | VARCHAR(10) | NOT NULL | Sender type (user/coach) |
| `sender_coach_type` | VARCHAR(20) | | Coach type if sender is coach |
| `content` | TEXT | NOT NULL | Message content |
| `timestamp` | TIMESTAMP | NOT NULL | Message timestamp |
| `question_type` | VARCHAR(20) | | Type of question if applicable |
| `insight_generated` | BOOLEAN | DEFAULT FALSE | Insight flag |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `sender_type`: user, coach
- `question_type`: clarifying, challenging, exploratory, hypothetical

**Indexes:**
- `idx_messages_session_id` on `session_id`
- `idx_messages_timestamp` on `timestamp`

### `chat_message_suggestions`
Follow-up suggestions for messages.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `message_id` | UUID | FOREIGN KEY → chat_messages.id | Parent message |
| `suggestion` | TEXT | NOT NULL | Follow-up suggestion |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`message_id`, `order`)

### `chat_session_insights`
Insights generated during chat sessions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `session_id` | UUID | FOREIGN KEY → chat_sessions.id | Parent session |
| `insight` | TEXT | NOT NULL | Insight text |
| `order` | INTEGER | NOT NULL | Display order |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Primary Key:** (`session_id`, `order`)

### `coach_session_analytics`
Analytics for coach sessions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `session_id` | UUID | PRIMARY KEY, FOREIGN KEY → chat_sessions.id | Parent session |
| `duration_seconds` | INTEGER | NOT NULL | Session duration |
| `message_count` | INTEGER | NOT NULL | Total messages |
| `user_message_count` | INTEGER | NOT NULL | User messages |
| `coach_message_count` | INTEGER | NOT NULL | Coach messages |
| `insights_generated` | INTEGER | NOT NULL DEFAULT 0 | Number of insights |
| `follow_ups_suggested` | INTEGER | NOT NULL DEFAULT 0 | Follow-up suggestions |
| `user_satisfaction_rating` | INTEGER | | User rating (1-5) |
| `user_found_helpful` | BOOLEAN | | Helpfulness flag |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Indexes:**
- `idx_coach_analytics_session_id` on `session_id`

---

## 10. Frameworks

### `framework_templates`
Decision-making framework templates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique template identifier |
| `framework_type` | VARCHAR(30) | NOT NULL | Framework type |
| `title` | VARCHAR(255) | NOT NULL | Template title |
| `description` | TEXT | NOT NULL | Template description |
| `estimated_duration` | INTEGER | NOT NULL DEFAULT 600 | Duration in seconds |
| `difficulty_level` | VARCHAR(20) | NOT NULL | Difficulty level |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `framework_type`: evidenceToDecision, toulminArgumentation, superforecasting, problemDecomposition

**Indexes:**
- `idx_templates_framework_type` on `framework_type`

### `framework_template_tags`
Tags for framework templates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `template_id` | UUID | FOREIGN KEY → framework_templates.id | Parent template |
| `tag` | VARCHAR(50) | NOT NULL | Tag name |

**Primary Key:** (`template_id`, `tag`)

### `framework_steps`
Steps within framework templates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique step identifier |
| `template_id` | UUID | FOREIGN KEY → framework_templates.id | Parent template |
| `order` | INTEGER | NOT NULL | Step order |
| `title` | VARCHAR(255) | NOT NULL | Step title |
| `description` | TEXT | NOT NULL | Step description |
| `guidance` | TEXT | NOT NULL | Guidance text |

**Indexes:**
- `idx_steps_template_id` on `template_id`
- `idx_steps_order` on `order`

### `framework_step_inputs`
Input fields for framework steps.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique input identifier |
| `step_id` | UUID | FOREIGN KEY → framework_steps.id | Parent step |
| `input_type` | VARCHAR(20) | NOT NULL | Input type |
| `label` | VARCHAR(255) | NOT NULL | Input label |
| `placeholder` | TEXT | | Placeholder text |
| `is_required` | BOOLEAN | DEFAULT FALSE | Required flag |
| `help_text` | TEXT | | Help text |
| `order` | INTEGER | NOT NULL | Display order |

**Enums:**
- `input_type`: text, multilineText, rating, multipleChoice, checklist, probability

**Indexes:**
- `idx_inputs_step_id` on `step_id`

### `framework_step_examples`
Examples for framework steps.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `step_id` | UUID | FOREIGN KEY → framework_steps.id | Parent step |
| `example` | TEXT | NOT NULL | Example text |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`step_id`, `order`)

### `framework_step_validation`
Validation criteria for steps.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `step_id` | UUID | PRIMARY KEY, FOREIGN KEY → framework_steps.id | Parent step |
| `min_length` | INTEGER | | Minimum length |
| `max_length` | INTEGER | | Maximum length |
| `required_elements` | JSONB | | Required elements array |

### `evidence_to_decision_analyses`
User Evidence-to-Decision framework analyses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique analysis identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | Analysis author |
| `question` | TEXT | NOT NULL | Decision question |
| `context` | TEXT | NOT NULL | Decision context |
| `confidence` | DECIMAL(3,2) | NOT NULL | Overall confidence |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Indexes:**
- `idx_etd_user_id` on `user_id`

### `etd_evidence_items`
Evidence items in EtD analyses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique evidence identifier |
| `analysis_id` | UUID | FOREIGN KEY → evidence_to_decision_analyses.id | Parent analysis |
| `source` | VARCHAR(255) | NOT NULL | Evidence source |
| `content` | TEXT | NOT NULL | Evidence content |
| `quality_rating` | VARCHAR(20) | NOT NULL | Quality rating |
| `relevance_rating` | VARCHAR(20) | NOT NULL | Relevance rating |
| `expertise_score` | INTEGER | NOT NULL | Expertise (0-10) |
| `objectivity_score` | INTEGER | NOT NULL | Objectivity (0-10) |
| `recency_score` | INTEGER | NOT NULL | Recency (0-10) |
| `corroboration_score` | INTEGER | NOT NULL | Corroboration (0-10) |
| `order` | INTEGER | NOT NULL | Display order |

**Enums:**
- `quality_rating`: veryLow, low, moderate, high
- `relevance_rating`: notRelevant, slightlyRelevant, moderatelyRelevant, highlyRelevant

**Indexes:**
- `idx_evidence_analysis_id` on `analysis_id`

### `etd_decision_criteria`
Decision criteria in EtD analyses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique criterion identifier |
| `analysis_id` | UUID | FOREIGN KEY → evidence_to_decision_analyses.id | Parent analysis |
| `name` | VARCHAR(255) | NOT NULL | Criterion name |
| `weight` | DECIMAL(3,2) | NOT NULL | Weight (0.00-1.00) |
| `description` | TEXT | NOT NULL | Criterion description |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_criteria_analysis_id` on `analysis_id`

### `etd_alternatives`
Alternatives in EtD analyses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique alternative identifier |
| `analysis_id` | UUID | FOREIGN KEY → evidence_to_decision_analyses.id | Parent analysis |
| `name` | VARCHAR(255) | NOT NULL | Alternative name |
| `description` | TEXT | NOT NULL | Alternative description |
| `score` | DECIMAL(5,2) | | Calculated score |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_alternatives_analysis_id` on `analysis_id`

### `etd_alternative_pros_cons`
Pros and cons for alternatives.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier |
| `alternative_id` | UUID | FOREIGN KEY → etd_alternatives.id | Parent alternative |
| `type` | VARCHAR(10) | NOT NULL | Type (pro/con) |
| `text` | TEXT | NOT NULL | Pro or con text |
| `order` | INTEGER | NOT NULL | Display order |

**Enums:**
- `type`: pro, con

**Indexes:**
- `idx_pros_cons_alternative_id` on `alternative_id`

### `etd_recommendations`
Recommendations from EtD analyses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `analysis_id` | UUID | PRIMARY KEY, FOREIGN KEY → evidence_to_decision_analyses.id | Parent analysis |
| `chosen_alternative_id` | UUID | FOREIGN KEY → etd_alternatives.id | Chosen alternative |
| `rationale` | TEXT | NOT NULL | Recommendation rationale |
| `strength` | VARCHAR(20) | NOT NULL | Recommendation strength |

**Enums:**
- `strength`: weak, conditional, moderate, strong

### `etd_key_considerations`
Key considerations for recommendations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `analysis_id` | UUID | FOREIGN KEY → evidence_to_decision_analyses.id | Parent analysis |
| `consideration` | TEXT | NOT NULL | Key consideration |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`analysis_id`, `order`)

### `toulmin_arguments`
Toulmin argumentation framework entries.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique argument identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | Argument author |
| `claim` | TEXT | NOT NULL | Main claim |
| `warrant` | TEXT | NOT NULL | Warrant (how data supports claim) |
| `qualifier` | TEXT | | Degree of certainty |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Indexes:**
- `idx_toulmin_user_id` on `user_id`

### `toulmin_data_points`
Data/evidence for Toulmin arguments.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `argument_id` | UUID | FOREIGN KEY → toulmin_arguments.id | Parent argument |
| `data` | TEXT | NOT NULL | Evidence/grounds |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`argument_id`, `order`)

### `toulmin_backing`
Backing for warrants in Toulmin arguments.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `argument_id` | UUID | FOREIGN KEY → toulmin_arguments.id | Parent argument |
| `backing` | TEXT | NOT NULL | Support for warrant |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`argument_id`, `order`)

### `toulmin_rebuttals`
Rebuttals/counterarguments in Toulmin arguments.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `argument_id` | UUID | FOREIGN KEY → toulmin_arguments.id | Parent argument |
| `rebuttal` | TEXT | NOT NULL | Counterargument |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`argument_id`, `order`)

### `superforecasting_analyses`
Superforecasting method analyses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique analysis identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | Analysis author |
| `question` | TEXT | NOT NULL | Forecasting question |
| `time_horizon` | TIMESTAMP | NOT NULL | Prediction time horizon |
| `final_probability` | DECIMAL(5,4) | NOT NULL | Final prediction probability |
| `final_confidence` | INTEGER | NOT NULL | Confidence level (0-100) |
| `final_reasoning` | TEXT | NOT NULL | Reasoning |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Indexes:**
- `idx_superforecasting_user_id` on `user_id`

### `sf_base_rate_analyses`
Base rate analyses for superforecasting.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `analysis_id` | UUID | PRIMARY KEY, FOREIGN KEY → superforecasting_analyses.id | Parent analysis |
| `historical_frequency` | DECIMAL(5,4) | NOT NULL | Historical frequency |
| `sample_size` | INTEGER | NOT NULL | Sample size |
| `source` | VARCHAR(255) | NOT NULL | Data source |
| `confidence` | DECIMAL(3,2) | NOT NULL | Confidence in base rate |

### `sf_fermi_estimates`
Fermi estimates for superforecasting.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `analysis_id` | UUID | PRIMARY KEY, FOREIGN KEY → superforecasting_analyses.id | Parent analysis |
| `calculation` | TEXT | NOT NULL | Calculation description |
| `result` | DECIMAL(10,4) | NOT NULL | Estimated result |

### `sf_fermi_components`
Components of Fermi estimates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique component identifier |
| `analysis_id` | UUID | FOREIGN KEY → superforecasting_analyses.id | Parent analysis |
| `name` | VARCHAR(255) | NOT NULL | Component name |
| `estimate` | DECIMAL(10,4) | NOT NULL | Estimated value |
| `range_min` | DECIMAL(10,4) | NOT NULL | Minimum range |
| `range_max` | DECIMAL(10,4) | NOT NULL | Maximum range |
| `reasoning` | TEXT | NOT NULL | Reasoning |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_fermi_components_analysis_id` on `analysis_id`

### `sf_reference_classes`
Reference classes for superforecasting.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique reference class identifier |
| `analysis_id` | UUID | FOREIGN KEY → superforecasting_analyses.id | Parent analysis |
| `name` | VARCHAR(255) | NOT NULL | Reference class name |
| `similarity` | DECIMAL(3,2) | NOT NULL | Similarity score (0.00-1.00) |
| `outcome` | DECIMAL(5,4) | NOT NULL | Historical outcome |
| `sample_size` | INTEGER | NOT NULL | Sample size |
| `relevance` | TEXT | NOT NULL | Relevance explanation |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_reference_classes_analysis_id` on `analysis_id`

### `sf_adjustments`
Adjustments to base forecasts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique adjustment identifier |
| `analysis_id` | UUID | FOREIGN KEY → superforecasting_analyses.id | Parent analysis |
| `factor` | VARCHAR(255) | NOT NULL | Adjustment factor |
| `direction` | VARCHAR(10) | NOT NULL | Direction (increase/decrease) |
| `magnitude` | DECIMAL(5,4) | NOT NULL | Adjustment magnitude |
| `reasoning` | TEXT | NOT NULL | Reasoning |
| `order` | INTEGER | NOT NULL | Display order |

**Enums:**
- `direction`: increase, decrease

**Indexes:**
- `idx_adjustments_analysis_id` on `analysis_id`

### `sf_key_uncertainties`
Key uncertainties in superforecasting.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `analysis_id` | UUID | FOREIGN KEY → superforecasting_analyses.id | Parent analysis |
| `uncertainty` | TEXT | NOT NULL | Uncertainty description |
| `order` | INTEGER | NOT NULL | Display order |

**Primary Key:** (`analysis_id`, `order`)

### `problem_decompositions`
Problem decomposition framework analyses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique decomposition identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | Analysis author |
| `problem_statement` | TEXT | NOT NULL | Problem statement |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Indexes:**
- `idx_decompositions_user_id` on `user_id`

### `pd_issues`
Issues in problem decomposition issue trees.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique issue identifier |
| `decomposition_id` | UUID | FOREIGN KEY → problem_decompositions.id | Parent decomposition |
| `parent_issue_id` | UUID | FOREIGN KEY → pd_issues.id | Parent issue (for tree structure) |
| `question` | TEXT | NOT NULL | Issue question |
| `issue_type` | VARCHAR(20) | NOT NULL | Issue type |
| `priority` | VARCHAR(20) | NOT NULL | Priority level |
| `notes` | TEXT | | Additional notes |
| `order` | INTEGER | NOT NULL | Display order |

**Enums:**
- `issue_type`: diagnostic, solution, implementation
- `priority`: low, medium, high, critical

**Indexes:**
- `idx_issues_decomposition_id` on `decomposition_id`
- `idx_issues_parent_id` on `parent_issue_id`

### `pd_assumptions`
Assumptions in problem decomposition.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique assumption identifier |
| `decomposition_id` | UUID | FOREIGN KEY → problem_decompositions.id | Parent decomposition |
| `statement` | TEXT | NOT NULL | Assumption statement |
| `criticality` | VARCHAR(20) | NOT NULL | Criticality level |
| `confidence` | DECIMAL(3,2) | NOT NULL | Confidence (0.00-1.00) |
| `test_method` | TEXT | | Method to test assumption |
| `order` | INTEGER | NOT NULL | Display order |

**Enums:**
- `criticality`: low, medium, high

**Indexes:**
- `idx_assumptions_decomposition_id` on `decomposition_id`

### `pd_hypotheses`
Hypotheses in problem decomposition.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique hypothesis identifier |
| `decomposition_id` | UUID | FOREIGN KEY → problem_decompositions.id | Parent decomposition |
| `statement` | TEXT | NOT NULL | Hypothesis statement |
| `is_testable` | BOOLEAN | NOT NULL | Testability flag |
| `test_method` | TEXT | | Method to test hypothesis |
| `expected_outcome` | TEXT | NOT NULL | Expected outcome |
| `actual_outcome` | TEXT | | Actual outcome |
| `order` | INTEGER | NOT NULL | Display order |

**Indexes:**
- `idx_hypotheses_decomposition_id` on `decomposition_id`

---

## 11. Progress & Analytics

### `user_progress`
Overall user progress tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | PRIMARY KEY, FOREIGN KEY → users.id | User |
| `total_lessons_completed` | INTEGER | NOT NULL DEFAULT 0 | Total completed lessons |
| `total_exercises_completed` | INTEGER | NOT NULL DEFAULT 0 | Total completed exercises |
| `total_training_completed` | INTEGER | NOT NULL DEFAULT 0 | Total training exercises |
| `current_streak` | INTEGER | NOT NULL DEFAULT 0 | Current daily streak |
| `longest_streak` | INTEGER | NOT NULL DEFAULT 0 | Longest daily streak |
| `total_stars` | INTEGER | NOT NULL DEFAULT 0 | Total stars earned |
| `total_points` | INTEGER | NOT NULL DEFAULT 0 | Total points earned |
| `last_activity_date` | DATE | | Last activity date |
| `total_time_spent` | INTEGER | NOT NULL DEFAULT 0 | Total time in seconds |
| `average_accuracy` | DECIMAL(5,2) | NOT NULL DEFAULT 0.00 | Average accuracy % |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

### `lesson_progress`
Progress on individual lessons.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique progress identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `lesson_id` | UUID | FOREIGN KEY → lessons.id | Lesson |
| `completion_status` | VARCHAR(20) | NOT NULL | Completion status |
| `started_at` | TIMESTAMP | | Start timestamp |
| `completed_at` | TIMESTAMP | | Completion timestamp |
| `time_spent` | INTEGER | NOT NULL DEFAULT 0 | Time in seconds |
| `exercises_completed` | INTEGER | NOT NULL DEFAULT 0 | Exercises completed |
| `score` | DECIMAL(5,2) | | Score achieved |
| `notes` | TEXT | | User notes |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `completion_status`: notStarted, inProgress, completed

**Unique Constraint:** (`user_id`, `lesson_id`)

**Indexes:**
- `idx_lesson_progress_user_id` on `user_id`
- `idx_lesson_progress_lesson_id` on `lesson_id`
- `idx_lesson_progress_status` on `completion_status`

### `weekly_stats`
Weekly activity statistics.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique stats identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `week_start_date` | DATE | NOT NULL | Start of week |
| `average_time_per_lesson` | INTEGER | NOT NULL DEFAULT 0 | Average time in seconds |
| `most_active_category` | VARCHAR(50) | | Most active lesson category |
| `total_lessons` | INTEGER | NOT NULL DEFAULT 0 | Total lessons this week |
| `total_exercises` | INTEGER | NOT NULL DEFAULT 0 | Total exercises this week |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Unique Constraint:** (`user_id`, `week_start_date`)

**Indexes:**
- `idx_weekly_stats_user_id` on `user_id`
- `idx_weekly_stats_week` on `week_start_date`

### `daily_activity`
Daily activity tracking (for weekly stats).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `date` | DATE | NOT NULL | Activity date |
| `lessons_completed` | INTEGER | NOT NULL DEFAULT 0 | Lessons completed |
| `exercises_completed` | INTEGER | NOT NULL DEFAULT 0 | Exercises completed |
| `time_spent` | INTEGER | NOT NULL DEFAULT 0 | Time in seconds |
| `points_earned` | INTEGER | NOT NULL DEFAULT 0 | Points earned |

**Primary Key:** (`user_id`, `date`)

**Indexes:**
- `idx_daily_activity_date` on `date`

### `reflection_analytics`
Analytics for user reflection patterns.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | PRIMARY KEY, FOREIGN KEY → users.id | User |
| `total_entries` | INTEGER | NOT NULL DEFAULT 0 | Total journal entries |
| `average_word_count` | INTEGER | NOT NULL DEFAULT 0 | Average word count |
| `favorite_category` | VARCHAR(30) | | Favorite reflection category |
| `streak_days` | INTEGER | NOT NULL DEFAULT 0 | Reflection streak |
| `insights_generated` | INTEGER | NOT NULL DEFAULT 0 | Total insights |
| `action_items_completed` | INTEGER | NOT NULL DEFAULT 0 | Completed action items |
| `last_entry_date` | DATE | | Last entry date |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

### `reflection_common_moods`
Common moods for users in reflections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `mood` | VARCHAR(20) | NOT NULL | Mood category |
| `count` | INTEGER | NOT NULL | Occurrence count |

**Primary Key:** (`user_id`, `mood`)

### `user_activity_logs`
Detailed activity logging for analytics.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique log identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `activity_type` | VARCHAR(50) | NOT NULL | Type of activity |
| `entity_type` | VARCHAR(50) | | Related entity type |
| `entity_id` | UUID | | Related entity ID |
| `duration` | INTEGER | | Duration in seconds |
| `metadata` | JSONB | | Additional activity data |
| `timestamp` | TIMESTAMP | NOT NULL | Activity timestamp |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `activity_type`: lessonViewed, lessonCompleted, exerciseStarted, exerciseCompleted, trainingStarted, trainingCompleted, reflectionCreated, coachSessionStarted, coachSessionEnded, achievementUnlocked
- `entity_type`: lesson, exercise, training, reflection, coach_session, achievement

**Indexes:**
- `idx_activity_logs_user_id` on `user_id`
- `idx_activity_logs_timestamp` on `timestamp`
- `idx_activity_logs_activity_type` on `activity_type`

### `skill_performance_history`
Historical skill performance data for trends.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique record identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `skill_category` | VARCHAR(50) | NOT NULL | Skill category |
| `date` | DATE | NOT NULL | Record date |
| `score` | DECIMAL(5,2) | NOT NULL | Performance score |
| `exercises_completed` | INTEGER | NOT NULL | Exercises completed |
| `time_spent` | INTEGER | NOT NULL | Time in seconds |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Indexes:**
- `idx_skill_history_user_id` on `user_id`
- `idx_skill_history_date` on `date`
- `idx_skill_history_skill_category` on `skill_category`

### `daily_metrics`
Aggregated daily metrics for dashboard.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `date` | DATE | NOT NULL | Metric date |
| `exercises_completed` | INTEGER | NOT NULL DEFAULT 0 | Exercises completed |
| `accuracy_percentage` | DECIMAL(5,2) | NOT NULL DEFAULT 0.00 | Accuracy % |
| `time_spent_minutes` | INTEGER | NOT NULL DEFAULT 0 | Time in minutes |
| `lessons_viewed` | INTEGER | NOT NULL DEFAULT 0 | Lessons viewed |
| `reflections_written` | INTEGER | NOT NULL DEFAULT 0 | Reflections written |
| `coach_sessions` | INTEGER | NOT NULL DEFAULT 0 | Coach sessions |
| `points_earned` | INTEGER | NOT NULL DEFAULT 0 | Points earned |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Primary Key:** (`user_id`, `date`)

**Indexes:**
- `idx_daily_metrics_date` on `date`

---

## 12. Gamification

### `achievements`
Achievement definitions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique achievement identifier |
| `name` | VARCHAR(255) | NOT NULL | Achievement name |
| `description` | TEXT | NOT NULL | Achievement description |
| `icon` | VARCHAR(100) | NOT NULL | Icon identifier |
| `achievement_type` | VARCHAR(20) | NOT NULL | Type of achievement |
| `requirement` | JSONB | NOT NULL | Achievement requirements |
| `points` | INTEGER | NOT NULL DEFAULT 0 | Points awarded |
| `is_hidden` | BOOLEAN | DEFAULT FALSE | Hidden until unlocked |
| `sort_order` | INTEGER | NOT NULL | Display order |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `achievement_type`: streak, completion, mastery, exploration, speed

### `user_achievements`
User-earned achievements.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `achievement_id` | UUID | FOREIGN KEY → achievements.id | Achievement |
| `unlocked_at` | TIMESTAMP | NOT NULL | Unlock timestamp |
| `progress` | DECIMAL(5,2) | | Progress percentage |
| `notified` | BOOLEAN | DEFAULT FALSE | User notified flag |

**Primary Key:** (`user_id`, `achievement_id`)

**Indexes:**
- `idx_user_achievements_user_id` on `user_id`
- `idx_user_achievements_unlocked_at` on `unlocked_at`

### `streak_history`
Historical streak data for users.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique record identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `streak_type` | VARCHAR(20) | NOT NULL | Type of streak |
| `streak_length` | INTEGER | NOT NULL | Streak length |
| `start_date` | DATE | NOT NULL | Streak start date |
| `end_date` | DATE | | Streak end date (null if active) |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Enums:**
- `streak_type`: daily, training, reflection

**Indexes:**
- `idx_streak_history_user_id` on `user_id`
- `idx_streak_history_start_date` on `start_date`

### `points_transactions`
Point earning/spending transactions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique transaction identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `points` | INTEGER | NOT NULL | Points (positive or negative) |
| `transaction_type` | VARCHAR(30) | NOT NULL | Type of transaction |
| `reference_id` | UUID | | Related entity ID |
| `reference_type` | VARCHAR(50) | | Related entity type |
| `description` | TEXT | | Transaction description |
| `created_at` | TIMESTAMP | NOT NULL | Transaction timestamp |

**Enums:**
- `transaction_type`: lessonComplete, exerciseComplete, trainingComplete, achievementUnlocked, dailyGoal, streakBonus, purchase, refund

**Indexes:**
- `idx_points_user_id` on `user_id`
- `idx_points_created_at` on `created_at`
- `idx_points_transaction_type` on `transaction_type`

---

## 13. Feature Access Control

### `features`
Feature definitions and access levels.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `feature_key` | VARCHAR(50) | PRIMARY KEY | Feature identifier |
| `name` | VARCHAR(255) | NOT NULL | Display name |
| `description` | TEXT | | Feature description |
| `requires_subscription_tier` | VARCHAR(20) | | Required subscription tier |
| `is_enabled` | BOOLEAN | DEFAULT TRUE | Global feature flag |
| `rollout_percentage` | INTEGER | DEFAULT 100 | Gradual rollout % (0-100) |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Enums:**
- `feature_key`: basicLessons, premiumLessons, dailyReflection, unlimitedReflections, basicCoaches, allCoaches, advancedAnalytics
- `requires_subscription_tier`: null (free), starter, premium

### `user_feature_access`
User-specific feature access overrides.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `feature_key` | VARCHAR(50) | FOREIGN KEY → features.feature_key | Feature |
| `has_access` | BOOLEAN | NOT NULL | Access granted |
| `granted_at` | TIMESTAMP | NOT NULL | Access grant timestamp |
| `expires_at` | TIMESTAMP | | Access expiration (null = permanent) |
| `granted_by` | VARCHAR(50) | | Reason (trial, promotion, support) |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Primary Key:** (`user_id`, `feature_key`)

**Indexes:**
- `idx_feature_access_expires_at` on `expires_at`

---

## 14. Sync & Offline Support

### `sync_queue`
Pending changes for offline-first sync.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique sync item identifier |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `device_id` | VARCHAR(255) | NOT NULL | Device identifier |
| `entity_type` | VARCHAR(50) | NOT NULL | Type of entity |
| `entity_id` | UUID | NOT NULL | Entity identifier |
| `operation` | VARCHAR(20) | NOT NULL | Operation type |
| `data_payload` | JSONB | NOT NULL | Change data |
| `sync_status` | VARCHAR(20) | NOT NULL DEFAULT 'pending' | Sync status |
| `attempt_count` | INTEGER | NOT NULL DEFAULT 0 | Sync attempts |
| `last_error` | TEXT | | Last error message |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `synced_at` | TIMESTAMP | | Sync completion timestamp |

**Enums:**
- `entity_type`: lesson_progress, exercise_response, journal_entry, daily_todo, user_progress, skill_progress
- `operation`: create, update, delete
- `sync_status`: pending, syncing, synced, failed, conflict

**Indexes:**
- `idx_sync_queue_user_id` on `user_id`
- `idx_sync_queue_device_id` on `device_id`
- `idx_sync_queue_status` on `sync_status`
- `idx_sync_queue_created_at` on `created_at`

### `device_sync_state`
Last sync state per device.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `device_id` | VARCHAR(255) | NOT NULL | Device identifier |
| `device_name` | VARCHAR(255) | | Human-readable name |
| `platform` | VARCHAR(10) | NOT NULL | Device platform |
| `app_version` | VARCHAR(20) | | App version |
| `last_sync_at` | TIMESTAMP | NOT NULL | Last successful sync |
| `pending_changes_count` | INTEGER | NOT NULL DEFAULT 0 | Pending changes |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Primary Key:** (`user_id`, `device_id`)

**Enums:**
- `platform`: ios, android, web

**Indexes:**
- `idx_device_sync_last_sync` on `last_sync_at`

### `conflict_resolutions`
Log of sync conflicts and resolutions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique conflict identifier |
| `sync_queue_id` | UUID | FOREIGN KEY → sync_queue.id | Related sync item |
| `user_id` | UUID | FOREIGN KEY → users.id | User |
| `entity_type` | VARCHAR(50) | NOT NULL | Entity type |
| `entity_id` | UUID | NOT NULL | Entity ID |
| `device_data` | JSONB | NOT NULL | Device version |
| `server_data` | JSONB | NOT NULL | Server version |
| `resolution_strategy` | VARCHAR(20) | NOT NULL | How resolved |
| `resolved_data` | JSONB | NOT NULL | Final resolved data |
| `created_at` | TIMESTAMP | NOT NULL | Conflict timestamp |
| `resolved_at` | TIMESTAMP | NOT NULL | Resolution timestamp |

**Enums:**
- `resolution_strategy`: device_wins, server_wins, merged, manual

**Indexes:**
- `idx_conflicts_user_id` on `user_id`
- `idx_conflicts_created_at` on `created_at`

---

## 15. Relationships Diagram

### Entity Relationship Summary

```
users
  ├─── user_focus_areas (1:many)
  ├─── authentication_tokens (1:many)
  ├─── subscriptions (1:1)
  ├─── payment_transactions (1:many)
  ├─── payment_methods (1:many)
  ├─── trials (1:many)
  ├─── notification_preferences (1:1)
  ├─── push_tokens (1:many)
  ├─── user_preferences (1:1)
  ├─── user_onboarding (1:1)
  ├─── user_progress (1:1)
  ├─── lesson_progress (1:many)
  ├─── weekly_stats (1:many)
  ├─── daily_activity (1:many)
  ├─── skill_progress (1:many)
  ├─── calibration_records (1:many)
  ├─── daily_todos (1:many)
  ├─── exercise_responses (1:many)
  ├─── journal_entries (1:many)
  ├─── reflection_analytics (1:1)
  ├─── reflection_common_moods (1:many)
  ├─── chat_sessions (1:many)
  ├─── evidence_to_decision_analyses (1:many)
  ├─── toulmin_arguments (1:many)
  ├─── superforecasting_analyses (1:many)
  ├─── problem_decompositions (1:many)
  ├─── user_achievements (1:many)
  ├─── streak_history (1:many)
  ├─── points_transactions (1:many)
  ├─── user_feature_access (1:many)
  ├─── user_activity_logs (1:many)
  ├─── skill_performance_history (1:many)
  ├─── daily_metrics (1:many)
  ├─── sync_queue (1:many)
  ├─── device_sync_state (1:many)
  └─── conflict_resolutions (1:many)

lessons
  ├─── lesson_tags (1:many)
  ├─── lesson_content_blocks (1:many)
  ├─── lesson_key_takeaways (1:many)
  ├─── lesson_resources (1:many)
  ├─── lesson_progress (1:many)
  └─── exercises (1:many via related_lesson_id)

exercises
  ├─── questions (1:many)
  └─── exercise_responses (1:many)

questions
  ├─── question_tags (1:many)
  ├─── question_options (1:many)
  ├─── question_correct_answers (1:many)
  └─── question_answers (1:many)

training_exercises
  ├─── training_learning_points (1:many)
  └─── skill_builder_tasks (1:many)

skill_builder_tasks
  └─── skill_builder_task_feedback (1:1)

reflections
  ├─── reflection_guiding_questions (1:many)
  ├─── reflection_tags (1:many)
  └─── journal_entries (1:many)

journal_entries
  ├─── journal_insights (1:many)
  └─── journal_action_items (1:many)

reflection_templates
  └─── reflection_template_sections (1:many)

coaches
  ├─── coach_specialties (1:many)
  ├─── coach_personality_traits (1:many)
  ├─── coach_typical_questions (1:many)
  ├─── coach_personality_config (1:1)
  └─── coach_communication_style (1:1)

chat_sessions
  ├─── chat_messages (1:many)
  ├─── chat_session_insights (1:many)
  └─── coach_session_analytics (1:1)

chat_messages
  └─── chat_message_suggestions (1:many)

scenarios
  ├─── scenario_decisions (1:many)
  ├─── scenario_outcomes (1:many)
  └─── scenario_learning_objectives (1:many)

framework_templates
  ├─── framework_template_tags (1:many)
  └─── framework_steps (1:many)

framework_steps
  ├─── framework_step_inputs (1:many)
  ├─── framework_step_examples (1:many)
  └─── framework_step_validation (1:1)

evidence_to_decision_analyses
  ├─── etd_evidence_items (1:many)
  ├─── etd_decision_criteria (1:many)
  ├─── etd_alternatives (1:many)
  ├─── etd_recommendations (1:1)
  └─── etd_key_considerations (1:many)

etd_alternatives
  └─── etd_alternative_pros_cons (1:many)

toulmin_arguments
  ├─── toulmin_data_points (1:many)
  ├─── toulmin_backing (1:many)
  └─── toulmin_rebuttals (1:many)

superforecasting_analyses
  ├─── sf_base_rate_analyses (1:1)
  ├─── sf_fermi_estimates (1:1)
  ├─── sf_fermi_components (1:many)
  ├─── sf_reference_classes (1:many)
  ├─── sf_adjustments (1:many)
  └─── sf_key_uncertainties (1:many)

problem_decompositions
  ├─── pd_issues (1:many, hierarchical)
  ├─── pd_assumptions (1:many)
  └─── pd_hypotheses (1:many)

calibration_records
  ├─── prediction_records (1:many)
  └─── calibration_curve_points (1:many)

subscriptions
  ├─── payment_transactions (1:many)
  └─── trials (1:many via converted_subscription_id)

subscription_tiers
  └─── subscriptions (1:many)

achievements
  └─── user_achievements (1:many)

features
  └─── user_feature_access (1:many)

scheduled_notifications
  └─── notification_history (after sending)
```

---

## Key Design Decisions

### 1. Normalization
- Tables normalized to 3NF where practical
- JSONB used for flexible/variable content (metadata, arrays)
- Denormalization minimized except for computed aggregates

### 2. Data Types
- **UUID**: All primary keys for global uniqueness
- **TIMESTAMP**: All datetime fields with timezone awareness
- **JSONB**: Complex nested structures (metadata, arrays)
- **DECIMAL**: Precise values (money, scores, probabilities)
- **TEXT**: Variable-length content

### 3. Indexes
- Primary keys automatically indexed
- Foreign keys indexed for join performance
- Frequently queried fields indexed
- Composite indexes for common query patterns
- Partial indexes where beneficial

### 4. Constraints
- NOT NULL on required fields
- UNIQUE constraints where appropriate
- CHECK constraints for valid ranges
- Foreign key constraints for referential integrity
- Soft deletes via `deleted_at` fields

### 5. Scalability Considerations
- Partitioning strategy for time-series data
- Separate tables for high-volume data
- JSONB indexes for frequently queried JSON fields
- Read replicas for analytics
- Archival strategy for old data

### 6. Performance Optimization
- Composite indexes for multi-column queries
- Covering indexes where beneficial
- Materialized views for complex aggregations
- Query-specific indexes based on access patterns
- Connection pooling configuration

### 7. Security & Privacy
- Password hashing (never store plaintext)
- Encryption at rest for sensitive data
- Audit logging for critical operations
- Soft deletes preserve data integrity
- GDPR compliance considerations

---

## Migration Notes

### Order of Table Creation

**Phase 1: Core Infrastructure**
1. users
2. authentication_tokens
3. user_preferences
4. user_onboarding
5. user_focus_areas

**Phase 2: Subscription & Payments**
6. subscription_tiers
7. subscriptions
8. payment_methods
9. payment_transactions
10. trials

**Phase 3: Notifications**
11. notification_preferences
12. push_tokens
13. scheduled_notifications
14. notification_history

**Phase 4: Content**
15. lessons
16. lesson_tags
17. lesson_content_blocks
18. lesson_key_takeaways
19. lesson_resources
20. exercises
21. questions
22. question_tags
23. question_options
24. question_correct_answers
25. scenarios
26. scenario_decisions
27. scenario_outcomes
28. scenario_learning_objectives

**Phase 5: Training**
29. training_exercises
30. training_learning_points
31. skill_builder_tasks
32. skill_builder_task_feedback

**Phase 6: Reflections**
33. reflections
34. reflection_guiding_questions
35. reflection_tags
36. reflection_templates
37. reflection_template_sections

**Phase 7: Coaches**
38. coaches
39. coach_specialties
40. coach_personality_traits
41. coach_typical_questions
42. coach_personality_config
43. coach_communication_style

**Phase 8: Frameworks**
44. framework_templates
45. framework_template_tags
46. framework_steps
47. framework_step_inputs
48. framework_step_examples
49. framework_step_validation

**Phase 9: User Data**
50-137. All remaining user-generated content and analytics tables

### Data Seeding Requirements

**Critical Seeds:**
1. Default subscription tiers (starter, premium) with pricing
2. Three coach personalities (challenger, navigator, explorer)
3. Feature definitions (basicLessons, premiumLessons, etc.)
4. Achievement definitions
5. Initial lesson content
6. Training exercises for all skill categories
7. Reflection prompts and templates
8. Framework templates with steps

---

## Total Table Count: **137 Tables**

### Table Summary by Category:
- **User Management & Authentication**: 3
- **Subscription & Payments**: 5
- **Notifications & Reminders**: 4
- **User Preferences & Settings**: 2
- **Lessons & Content**: 6
- **Exercises & Assessments**: 11
- **Training & Skills**: 12
- **Reflections & Journaling**: 9
- **AI Coaches**: 12
- **Frameworks**: 35
- **Progress & Analytics**: 10
- **Gamification**: 4
- **Feature Access Control**: 2
- **Sync & Offline Support**: 3
- **Supporting/Junction Tables**: 19

---

## Production Readiness Checklist

### Database Configuration
- [ ] Configure connection pooling (e.g., PgBouncer)
- [ ] Set up read replicas for analytics queries
- [ ] Configure automated backups (daily + WAL archiving)
- [ ] Implement point-in-time recovery
- [ ] Set up monitoring (slow queries, connections, disk space)
- [ ] Configure vacuum and analyze schedules
- [ ] Set appropriate work_mem and shared_buffers

### Security
- [ ] Enable SSL/TLS for connections
- [ ] Configure firewall rules
- [ ] Set up role-based access control
- [ ] Enable audit logging
- [ ] Implement encryption at rest
- [ ] Regular security updates

### Performance
- [ ] Create all recommended indexes
- [ ] Set up query performance monitoring
- [ ] Configure statement timeout
- [ ] Implement connection timeout handling
- [ ] Set up query result caching where appropriate
- [ ] Configure autovacuum parameters

### Compliance
- [ ] GDPR data export functionality
- [ ] GDPR data deletion (right to be forgotten)
- [ ] Data retention policies
- [ ] Privacy policy alignment
- [ ] Terms of service alignment

---

This comprehensive schema captures **all functionality** from your Ponderless iOS application including subscription management, notifications, feature flags, analytics, and offline sync support. The design follows production database best practices with proper normalization, indexing, scalability considerations, and offline-first architecture support.
