# Task Manager

A modern Flutter Task Manager assignment app with a splash screen, responsive task UI, form validation, and REST API CRUD integration.

## Features

- Splash screen with a local task/checklist logo asset
- Task dashboard with total, pending, and completed counts
- List/read tasks from a REST API
- Create new tasks with validation
- View task details
- Edit/update tasks
- Delete tasks with confirmation
- Mark tasks completed or pending
- Pull-to-refresh task loading
- Loading, success, error, and empty states
- Clean Material 3 UI suitable for a university assignment

## API Configuration

The app uses JSONPlaceholder as the default REST backend because this starter project did not include an existing API configuration.

Default base URL:

```text
https://jsonplaceholder.typicode.com
```

Endpoints used:

- `GET /todos?_limit=20`
- `POST /todos`
- `PUT /todos/{id}`
- `DELETE /todos/{id}`

To use another compatible API, pass a Dart define when running or building:

```bash
flutter run --dart-define=TASK_API_BASE_URL=https://your-api.example.com
```

Expected task JSON fields are flexible: `id`, `title`, `description` or `body`, `completed` or `isCompleted`, and optional `createdAt`.

## Install and Run

```bash
flutter pub get
flutter run
```

## Analyze and Test

```bash
dart format .
flutter analyze
flutter test
```

## Build

```bash
flutter build apk --debug
```

## Project Structure

```text
lib/
  main.dart
  models/task.dart
  services/task_api_service.dart
  screens/
  widgets/
assets/images/task_logo.png
```
