# Flutter Hooks - useEffect 完全ガイド

## 目次

  * useEffectの基本構造
  * 依存配列のパターン
  * クリーンアップ関数
  * 実践的な使用例
  * 注意点とベストプラクティス
  * 代替手段

-----

## useEffectの基本構造

```dart
useEffect(
  () {
    // 副作用処理
    return () {
      // クリーンアップ処理（オプション）
    };
  },
  [依存配列], // オプション
);
```

### 引数の説明

  * **第1引数: エフェクト関数** - 副作用処理を行う関数。`null`またはクリーンアップ関数を返します。
  * **第2引数: 依存配列（オプション）** - エフェクトの実行タイミングを制御します。

-----

## 依存配列のパターン

### パターン1: 依存配列なし - 毎回実行

```dart
useEffect(() {
  print('毎回のビルドで実行される');
  return null;
}); // 第2引数を省略
```

  * ウィジェットが再ビルドされるたびに実行されます。
  * ほとんど使いません（無限ループのリスクあり）。

### パターン2: 空の依存配列 `[]` - 初回のみ実行

```dart
useEffect(() {
  print('マウント時に1回だけ実行');
  fetchInitialData();
  return null;
}, []); // 空配列
```

  * コンポーネントのマウント時（初回ビルド時）のみ実行されます。
  * `initState`相当です。
  * **用途**: 初期データ取得、タイマー開始、リスナー登録など。

### パターン3: 特定の値を監視 - 値が変わった時のみ実行

```dart
useEffect(() {
  print('userIdが変更された: $userId');
  fetchUserData(userId);
  return null;
}, [userId]); // userIdの変更を監視
```

  * 依存配列内の値が変更された時のみ実行されます。
  * 最も一般的な使い方です。
  * 複数の値を監視可能：`[userId, status, filter]`

-----

## クリーンアップ関数

### クリーンアップが不要な場合

```dart
useEffect(() {
  print('クリーンアップ不要');
  someAction();
  return null; // nullを返す
}, [dependency]);
```

### クリーンアップが必要な場合

```dart
useEffect(() {
  // リスナーやタイマーの登録
  final subscription = stream.listen((data) {
    print(data);
  });
  
  // クリーンアップ関数を返す
  return () {
    subscription.cancel(); // アンマウント時にキャンセル
  };
}, []);
```

### クリーンアップが実行されるタイミング

  * ウィジェットがアンマウント（破棄）される時。
  * 依存配列の値が変わって、次のエフェクトが実行される前。

-----

## 実践的な使用例

### 例1: 初回データ取得

```dart
useEffect(() {
  Future<void> loadData() async {
    final data = await api.fetchData();
    setState(data);
  }
  loadData();
  return null;
}, []); // 初回のみ
```

### 例2: 検索クエリの監視（デバウンス付き）

```dart
final searchQuery = useState('');

useEffect(() {
  if (searchQuery.value.isEmpty) return null;
  
  // デバウンス用のタイマー
  final timer = Timer(Duration(milliseconds: 500), () {
    performSearch(searchQuery.value);
  });
  
  return () => timer.cancel(); // クリーンアップでタイマーキャンセル
}, [searchQuery.value]); // 検索クエリの変更を監視
```

### 例3: StreamSubscription

```dart
useEffect(() {
  final subscription = locationStream.listen((location) {
    updateMap(location);
  });
  
  return () => subscription.cancel();
}, []); // マウント時に登録、アンマウント時に解除
```

### 例4: AnimationController

```dart
useEffect(() {
  final controller = AnimationController(
    vsync: vsync,
    duration: Duration(seconds: 1),
  );
  controller.forward();
  
  return () => controller.dispose();
}, []);
```

### 例5: 複数の依存値

```dart
useEffect(() {
  print('Filter: $filter, Sort: $sortOrder');
  fetchTasks(filter: filter, sortOrder: sortOrder);
  return null;
}, [filter, sortOrder]); // どちらかが変わったら実行
```

### 例6: エラーメッセージの表示（実際のプロジェクト例）

```dart
useEffect(() {
  final error = state.pendingError;
  if (error == null) return null;
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showToast(context, error);
    ref.read(todoListViewModelProvider.notifier).clearPendingError();
  });
  return null;
}, [state.pendingError]);
```

**この実装のポイント:**

  * `pendingError`の変更を監視します。
  * `addPostFrameCallback`でビルド完了後にState変更を行います。
  * `context.mounted`チェックでメモリリークを防ぎます。
  * エラー表示後に`clearPendingError()`でクリアします。

-----

## 注意点とベストプラクティス

### ⚠️ 注意点1: State変更はPostFrameCallbackで

```dart
// ❌ NG: ビルド中にState変更
useEffect(() {
  viewModel.updateState(); // エラーになる
  return null;
}, [dependency]);

// ✅ OK: PostFrameCallbackで遅延実行
useEffect(() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    viewModel.updateState();
  });
  return null;
}, [dependency]);
```

  * **理由**: `useEffect`はビルドフェーズ中に実行されるため、State変更すると`setState() or markNeedsBuild() called during build.`エラーが発生します。

### ⚠️ 注意点2: `context.mounted`チェック

```dart
useEffect(() {
  Future<void> loadData() async {
    final data = await api.fetchData();
    if (!context.mounted) return; // 非同期処理後は必ずチェック
    showDialog(context: context, ...);
  }
  loadData();
  return null;
}, []);
```

  * **理由**: 非同期処理中にウィジェットが破棄される可能性があるためです。

### ⚠️ 注意点3: 無限ループに注意

```dart
// ❌ NG: 無限ループ
final count = useState(0);
useEffect(() {
  count.value++; // これがuseEffectを再トリガー
  return null;
}, [count.value]); // count.valueが変わるたびに実行 → 無限ループ

// ✅ OK: 依存配列を空にするか、条件を付ける
useEffect(() {
  if (count.value < 10) {
    count.value++;
  }
  return null;
}, []); // 初回のみ
```

### ⚠️ 注意点4: 依存配列に必要な値を全て含める

```dart
// ❌ NG: userIdが変わっても実行されない
useEffect(() {
  fetchData(userId);
  return null;
}, []); // userIdを依存配列に入れていない

// ✅ OK
useEffect(() {
  fetchData(userId);
  return null;
}, [userId]);
```

### `addPostFrameCallback`が必要なケース vs 不要なケース

**✅ 必要なケース**

```dart
// State変更を伴う場合
useEffect(() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    viewModel.clearError(); // State変更
  });
  return null;
}, [error]);
```

**❌ 不要なケース**

```dart
// State変更しない場合
useEffect(() {
  showToast(context, error); // 表示のみ
  return null;
}, [error]);

// ボタンタップなどビルド外の処理
onPressed: () {
  viewModel.someAction(); // 既にビルド外なので不要
  showToast(context, 'Success');
}
```

-----

## 代替手段

### `ref.listen` (Riverpod)

Stateの変更を監視してアクションを実行します。

```dart
ref.listen(
  todoListViewModelProvider.select((state) => state.pendingError),
  (previous, next) {
    if (next != null) {
      showToast(context, next);
      ref.read(todoListViewModelProvider.notifier).clearPendingError();
    }
  },
);
```

  * **メリット**: `addPostFrameCallback`が不要です（ビルド外で実行されるため）。

### `useAsyncEffect`（カスタムフック）

`async/await`を使いやすくしたラッパーです。

```dart
useAsyncEffect(() async {
  final data = await fetchData();
  setState(data);
}, []);
```

-----

## まとめ

### 依存配列の使い分け

| 依存配列 | 実行タイミング | 用途 |
| :--- | :--- | :--- |
| なし | 毎回のビルド | ほぼ使わない |
| `[]` | 初回のみ | 初期化処理 |
| `[value]` | `value`が変わった時 | 最も一般的 |

### 戻り値の使い分け

  * `return null` → クリーンアップ不要
  * `return () => cleanup()` → リソースの解放が必要（Timer、Subscription、Controllerなど）

### チェックリスト

  * [ ] 非同期処理後に`context.mounted`をチェックしているか
  * [ ] State変更時に`addPostFrameCallback`を使っているか
  * [ ] 無限ループが発生しないか
  * [ ] 依存配列に必要な値を全て含めているか
  * [ ] クリーンアップが必要なリソースを適切に解放しているか

-----

### 参考: よくあるパターン早見表

```dart
// 1. 初回データ取得
useEffect(() {
  fetchData();
  return null;
}, []);

// 2. 値の変更を監視
useEffect(() {
  onValueChanged(value);
  return null;
}, [value]);

// 3. タイマー・定期実行
useEffect(() {
  final timer = Timer.periodic(Duration(seconds: 1), (_) {
    tick();
  });
  return () => timer.cancel();
}, []);

// 4. Stream監視
useEffect(() {
  final sub = stream.listen((data) => handle(data));
  return () => sub.cancel();
}, []);

// 5. エラー表示（State変更あり）
useEffect(() {
  if (error == null) return null;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showError(context, error);
    clearError();
  });
  return null;
}, [error]);
```