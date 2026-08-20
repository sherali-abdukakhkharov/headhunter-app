/// §8.1's application stages and who may move between them.
///
/// Kept as plain data rather than an enum so an unrecognised stage from a
/// newer server is carried and displayed rather than crashing the list — the
/// same rule as an unknown field kind.
abstract final class ApplicationStage {
  /// Where every application starts, and the one stage §6.2 counts: an
  /// application still at `submitted` is one nobody has looked at.
  static const String submitted = 'submitted';

  /// The hiring progression, in order. `rejected` and `withdrawn` are outside
  /// it because they are exits, not steps.
  static const List<String> progression = [
    submitted,
    'viewed',
    'shortlisted',
    'interview',
    'offer',
    'hired',
  ];

  /// Stages an **employer** may set (§8.1). `submitted` is the starting point
  /// and `withdrawn` is the candidate's alone.
  static const employerSettable = [
    'viewed',
    'shortlisted',
    'interview',
    'offer',
    'hired',
    'rejected',
  ];

  /// Stages nothing can move on from.
  static const terminal = {'hired', 'rejected', 'withdrawn'};

  /// What this employer may move [status] to next.
  ///
  /// **Forward only, and skipping is allowed** — real hiring skips, so an
  /// employer may go straight from `submitted` to `offer`. Backwards is
  /// refused by the server, so offering it would be offering a failure.
  ///
  /// `rejected` is available from any live stage: a decision can be made at
  /// any point, and it is an exit rather than a step backwards.
  ///
  /// An unrecognised status yields nothing rather than throwing. A server that
  /// adds a seventh stage should grey the controls, not crash the screen.
  static List<String> nextFor(String status) {
    if (terminal.contains(status)) return const [];

    final current = progression.indexOf(status);
    if (current < 0) return const [];

    return [
      for (final stage in employerSettable)
        if (stage == 'rejected' || progression.indexOf(stage) > current) stage,
    ];
  }
}
