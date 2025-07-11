String formatBytes(int bytes, [int decimals = 2]) {
  if (bytes <= 0) return "0 B";

  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB"];
  final i = (bytes == 0)
      ? 0
      : (bytes.bitLength - 1) ~/ 10;
  final value = bytes / (1 << (10 * i));

  return "${value.toStringAsFixed(decimals)} ${suffixes[i]}";
}
