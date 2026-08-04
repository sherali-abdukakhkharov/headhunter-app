See [CLAUDE.md](CLAUDE.md) for the cross-repo setup, project layout,
conventions, local ports, and the dependency-pinning constraints, and
[README.md](README.md) for prerequisites and commands.

Quick orientation:

- **Stack:** Flutter 3.44.8 / Dart 3.12.2, Riverpod 3 (`@riverpod` codegen),
  go_router, dio, json_serializable
- **App id:** `com.headhunter.app`
- **Backend:** `d:\Dev\tgbots\headhunter-backend` (NestJS), API on port **3001**
- **Emulator reaches the host at `10.0.2.2`**, never `localhost`
- **Before committing:** `flutter analyze` clean, `flutter test` passing, and
  `dart run build_runner build` results committed
- **Do not bump packages casually** — the pins in `pubspec.yaml` are
  load-bearing; CLAUDE.md explains the chain
- **iOS cannot be built on Windows**; CI compiles it with `--no-codesign`
