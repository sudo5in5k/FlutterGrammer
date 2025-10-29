void main(List<String> args) {
  final newList = listOperation();
  print(newList);
  print(newList.contains("black"));

  searchPractice();
}

List<String> listOperation() {
  List<String> color1 = ["red", "blue"];
  List<String> color2 = ["black"];
  color1.addAll(color2);

  color1.remove("black");
  color1.removeWhere((String s) => s.length >= 4);
  return color1;
}

void searchPractice() {
  List<int> numbers = [for (var i = 0; i < 10; i++) i];
  final filteredItems = numbers.firstWhere((int i) => i >= 3, orElse: () => -1);
  print(filteredItems);
}

void mapPractice() {
  final numbers = [for (var i = 0; i < 10; i++) i];
  // アロー関数形式でmapを使う
  final doubled = numbers.map((n) => n * 2);
  // 無名関数のブロックがあるタイプ、これはKotlinの書き方に近いかもね
  final doubledAnother = numbers.map((n) {
    return n * 2;
  });
  final even = numbers.where((n) {
    return n.isEven;
  });
}
