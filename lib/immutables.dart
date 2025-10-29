class ImmutableHoge {
  final num x;
  const ImmutableHoge(this.x);
}

/// では引数が2つあってxだけで同じインスタンスの判定をするにはどうしたらいいだろうか？
/// factoryの出番
class ImmutableHoge2 {
  final num x, y;
  static final _cache = <num, ImmutableHoge2>{};

  ImmutableHoge2._internal(this.x, this.y);

  factory ImmutableHoge2(num x, num y) {
    return _cache.putIfAbsent(x, () => ImmutableHoge2._internal(x, y));
  }
}

/// もしくは同一インスタンスではないか、値として等しいとみなすことはできる
class ImmutableHoge3 {
  final num x, y;
  const ImmutableHoge3(this.x, this.y);

  @override
  bool operator ==(Object other) {
    return other is ImmutableHoge3 && other.x == x;
  }

  @override
  int get hashCode => x.hashCode;
}

void constPractice({int? age}) {
  print("hoge");
  var x = const ImmutableHoge(1);
  var y = const ImmutableHoge(1);
  identical(x, y); // constとして引数を同じにしたためこれは同じインスタンスになる
  x = const ImmutableHoge(2);
  identical(x, y); // 別の引数になり違うインスタンスになる
}

void factoryPractice() {
  var a = ImmutableHoge2(1, 100);
  var b = ImmutableHoge2(1, 99);
  identical(a, b);
  print(a.y); // 想定通り100
  print(b.y); // インスタンスを共有しているので99ではなく100

  const c = ImmutableHoge3(1, 100);
  const d = ImmutableHoge3(1, 999);

  print(c == d); //これは同じなのでOK
  identical(c, d); //ただしインスタンスは違う
}