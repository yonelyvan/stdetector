/// A generic class that holds a pair of values.
///
/// The [Pair] class can hold two values of any types, specified
/// by the generic parameters [A] and [B].
///
/// Example:
/// ```dart
/// final pair = Pair<int, String>(older: 1, newer: 'one');
/// print(pair); // Output: Pair[1, one]
/// ```
class Pair<A, B> {
  /// The first value in the pair.
  final A older;

  /// The second value in the pair.
  final B newer;

  /// Creates a new pair of values.
  Pair({required this.older, required this.newer});

  /// Returns a string representation of the pair.
  @override
  String toString() => 'Pair($older, $newer)';
}
