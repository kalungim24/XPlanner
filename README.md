# XPlanner - Student Task Planner App

A modern, smooth, and intuitive task planner app designed for students to organize their daily tasks, track deadlines, and maintain productivity.

## Features

### 🏠 Dashboard

- **Daily Overview**: View today's date and a motivational quote.
- **Top Priorities**: Quickly see your top 3 most urgent tasks.
- **Progress Tracking**: Visual progress bar for daily task completion.
- **Upcoming Deadlines**: Get a glimpse of what's due in the next 7 days.
- **Daily Reflection**: Access the reflection journal.

### 📅 Schedule

- **Weekly Calendar**: View your class schedule and events.
- **Add Classes**: Easily add classes with time, location, and color coding.
- **Day View**: See detailed schedule for selected days.

### ✅ To-Do List

- **Categorized Lists**: Separate tasks by School, Personal, and Projects.
- **Swipe Actions**: Swipe to delete tasks.
- **Prioritization**: Set priority levels (High, Medium, Low).
- **Due Dates**: Track when assignments are due.

### 📈 Habit Tracker

- **Daily Habits**: Track recurring habits like reading or coding.
- **Streak Counter**: Visualize your consistency with streaks.
- **Weekly History**: See your completion history for the last 7 days.

### 📝 Notes

- **Quick Notes**: Capture ideas and reminders.
- **Rich Interface**: Clean and simple note-taking experience.

### 🧠 Daily Reflection

- **End-of-Day Review**: Reflect on accomplishments and improvements.
- **Planning**: Set priorities for tomorrow.
- **History**: Review past reflections.

## Technical Details

- **Framework**: Flutter
- **State Management**: Provider
- **Local Storage**: SharedPreferences (JSON serialization)
- **UI Components**: Material Design 3, Custom Widgets
- **Packages Used**:
  - `provider`
  - `shared_preferences`
  - `table_calendar`
  - `flutter_slidable`
  - `intl`
  - `google_fonts`
  - `animations`
  - `uuid`

## Getting Started

1.  **Prerequisites**: Ensure you have Flutter installed.
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

## Project Structure

- `lib/models`: Data models (Task, Note, Habit, etc.)
- `lib/providers`: State management logic (TaskProvider, etc.)
- `lib/screens`: UI Screens (Dashboard, Schedule, etc.)
- `lib/services`: Data persistence services.
- `lib/widgets`: Reusable UI components.
- `lib/utils`: Theme and utility functions.

## Customization

- **Theme**: Modify `lib/utils/theme.dart` to change colors and fonts.
- **Data**: The app uses local storage. To clear data, uninstall the app or clear app data in settings.
