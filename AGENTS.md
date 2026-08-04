Start with [CLAUDE.md](CLAUDE.md) — it lists which document to read for what, and
the domain rules that are easy to get wrong.

| File | Contents |
|---|---|
| [docs/SPEC.md](docs/SPEC.md) | Client specification (cite as §n, BR-nn, UAT-nn) |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Design decisions: role shell, localization, forms |
| [PLAN.md](PLAN.md) | Milestones in dependency order |
| [TODO.md](TODO.md) | Working checklist + what is blocked |
| [MEMORY.md](MEMORY.md) | Why decisions were made; traps already paid for |
| [README.md](README.md) | Prerequisites, commands, run instructions |

Quick orientation:

- **Product:** Universal HeadHunter — mobile-only recruitment platform; one app
  for candidates, employers **and** admins; four interface variants (Uzbek
  Latin/Cyrillic, Russian, English)
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
