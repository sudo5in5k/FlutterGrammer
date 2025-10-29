class User {
  final String id;
  final String? imageUrl;

  User({required this.id, required this.imageUrl}); // 名前付き引数、順番関係なくなるのがgood

  User.newInstance(String newId, String url) : id = newId, imageUrl = url;

  static final User companion = User(id: "0", imageUrl: null); // 定数として持てるのは強み

  /// factoryの使い所
  /// - Singleton実装
  /// - キャッシュからインスタンスを返却する
  /// - その自身のインスタンスではなく、サブタイプのインスタンスを返せたりする、例えばUserを継承したUserA, UserBみたいなものが返せる
  /// - 初期化時に動的なものを入れることができないとき、例えばdatetimeとか
  factory User.fromJson(Map<String, dynamic> json) {
    // json系は基本factoryでやるらしい
    final id = json['id'] as String?;
    final imageUrl = json['profile_image_url'] as String?;
    if (id == null) {
      throw Exception("id is null");
    }
    return User(id: id, imageUrl: imageUrl);
  }

  User.fromJson2(Map<String, dynamic> json) : id = json['id'], imageUrl = null;
}

void main() {
  final User hoge = User(id: "1", imageUrl: null);
  User.companion;
  User.newInstance("1", "");
}

/// Flutter docってめっちゃ便利
/// ```
/// dart pub get
/// dart doc .
/// ```
/// これだけでつくれちゃう
