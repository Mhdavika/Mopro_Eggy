String formatRupiah(int amount) {
  final str = amount.toString();
  final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final formatted = str.replaceAllMapped(regExp, (Match m) => '${m[1]}.');
  return 'Rp $formatted';
}
