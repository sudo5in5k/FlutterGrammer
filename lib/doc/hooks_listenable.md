# Flutter: ViewModelのState管理 vs ローカル状態管理（Listenable/Hooks）完全ガイド

## 目次

  * 状態管理の2つのアプローチ
  * ViewModelのStateに含めるべきもの
  * ローカル状態（Listenable/Hooks）で管理すべきもの
  * Listenableとは
  * useListenableの使い方
  * 実践的な使い分けガイド
  * パフォーマンス比較
  * ベストプラクティス

-----

## 状態管理の2つのアプローチ

### アプローチ1: ViewModelのState（Riverpod Provider）

```dart
@freezed
class TodoListState with _$TodoListState {
  const factory TodoListState({
    @Default(AsyncValue.loading()) AsyncValue<List<TodoTask>> tasks,
    @Default(TodoFilter.all) TodoFilter filter,
    @Default(false) bool isCreating,
    String? pendingError,
  }) = _TodoListState;
}

// 使い方
final state = ref.watch(todoListViewModelProvider);
// state.tasksが変わる → 全体が再ビルド
```

  * **特徴**: グローバルな状態管理
  * `ref.watch()`で自動的に変更を検知
  * State更新時に監視しているすべてのウィジェットが再ビルド

### アプローチ2: ローカル状態（Flutter Hooks + Listenable）

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final controller = useTextEditingController();
  useListenable(controller);
  
  // controller.textが変わる → このウィジェットのみ再ビルド
  return TextField(controller: controller);
}
```

  * **特徴**: ウィジェット内のローカル状態管理
  * `useListenable()`で明示的に監視
  * 該当ウィジェットのみ再ビルド（パフォーマンス良）

-----

## ViewModelのStateに含めるべきもの

### ✅ Stateで管理すべき状態

**1. ビジネスロジックに関わるデータ**

```dart
@freezed
class TodoListState {
  const factory TodoListState({
    AsyncValue<List<TodoTask>> tasks,     // ✅ ドメインデータ
    @Default(TodoFilter.all) TodoFilter filter,  // ✅ ビジネスルール
    @Default(false) bool isCreating,      // ✅ 処理状態
    String? pendingError,                 // ✅ エラー状態
  }) = _TodoListState;
}
```

  * **理由**:
      * アプリケーションの中核となるデータ
      * 複数のウィジェットから参照される
      * テストで検証したい

**2. 複数画面で共有される状態**

```dart
@freezed
class AppState {
  const factory AppState({
    User? currentUser,           // ✅ 全画面で必要
    @Default(false) bool isDarkMode,  // ✅ アプリ全体の設定
    String searchQuery,          // ✅ 複数画面で使用
  }) = _AppState;
}

// 画面A
Widget buildScreenA() {
  final state = ref.watch(appStateProvider);
  return Text('ユーザー: ${state.currentUser?.name}');
}

// 画面B（別画面でも同じユーザー情報を使用）
Widget buildScreenB() {
  final state = ref.watch(appStateProvider);
  return Avatar(user: state.currentUser);
}
```

**3. 永続化が必要な状態**

```dart
@freezed
class SettingsState {
  const factory SettingsState({
    @Default(TodoFilter.all) TodoFilter lastUsedFilter,  // ✅ 保存したい
    @Default(TodoSort.createdAt) TodoSort sortOrder,     // ✅ 保存したい
  }) = _SettingsState;
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  Future<void> saveFilter(TodoFilter filter) async {
    state = state.copyWith(lastUsedFilter: filter);
    await _storage.save('filter', filter); // 永続化
  }
}
```

**4. 画面遷移後も保持したい状態**

```dart
@freezed
class FormState {
  const factory FormState({
    @Default('') String draftTitle,      // ✅ 下書き保持
    @Default('') String draftDescription,
    @Default([]) List<String> selectedTags,
  }) = _FormState;
}

// 画面A → 画面B → 画面Aに戻っても値が保持される
```

### ❌ Stateに含めるべきでないもの

**1. 一時的な入力値**

```dart
// ❌ 悪い例
@freezed
class TodoListState {
  final String newTaskInput;  // 送信後に破棄される一時的な値
}

// ✅ 良い例
Widget build(BuildContext context) {
  final controller = useTextEditingController(); // ローカルで管理
  useListenable(controller);
}
```

**2. UI固有の状態**

```dart
// ❌ 悪い例
@freezed
class TodoListState {
  final double scrollOffset;      // スクロール位置
  final bool isDialogOpen;        // ダイアログ開閉
  final double animationProgress; // アニメーション進行度
}

// ✅ 良い例
Widget build(BuildContext context) {
  final scrollController = useScrollController();
  final showDialog = useState(false);
  final animationController = useAnimationController(...);
}
```

**3. 高頻度で変更される値**

```dart
// ❌ 悪い例（1文字ごとにState更新）
void onTextChanged(String text) {
  state = state.copyWith(searchInput: text);
  // → 全ウィジェットが再ビルド（重い！）
}

// ✅ 良い例（ローカルで管理、必要な時だけViewModelに送信）
final controller = useTextEditingController();
useListenable(controller);

// 送信時のみViewModelに渡す
onSubmitted: () => viewModel.search(controller.text)
```

-----

## ローカル状態（Listenable/Hooks）で管理すべきもの

### ✅ ローカルで管理すべき状態

**1. フォーム入力（一時的）**

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final titleController = useTextEditingController();
  final descController = useTextEditingController();
  useListenable(titleController);
  useListenable(descController);
  
  final isValid = titleController.text.isNotEmpty;
  
  return Column([
    TextField(controller: titleController),
    TextField(controller: descController),
    ElevatedButton(
      onPressed: isValid ? () {
        viewModel.submit(
          titleController.text,
          descController.text,
        );
        titleController.clear();
        descController.clear();
      } : null,
      child: Text('送信'),
    ),
  ]);
}
```

**2. スクロール位置**

```dart
Widget build(BuildContext context) {
  final scrollController = useScrollController();
  useListenable(scrollController);
  
  final showBackToTop = scrollController.hasClients && 
                        scrollController.offset > 100;
  
  return Stack([
    ListView(controller: scrollController),
    if (showBackToTop)
      FloatingActionButton(
        onPressed: () {
          scrollController.animateTo(0, ...);
        },
      ),
  ]);
}
```

**3. アニメーション状態**

```dart
Widget build(BuildContext context) {
  final animationController = useAnimationController(
    duration: Duration(milliseconds: 300),
  );
  useListenable(animationController);
  
  useEffect(() {
    animationController.forward();
    return null;
  }, []);
  
  return FadeTransition(
    opacity: animationController,
    child: child,
  );
}
```

**4. 単一ウィジェット内の一時状態**

```dart
Widget build(BuildContext context) {
  final isExpanded = useState(false);
  final selectedIndex = useState(0);
  
  return ExpansionTile(
    onExpansionChanged: (expanded) {
      isExpanded.value = expanded;
    },
    // ...
  );
}
```

-----

## Listenableとは

### 定義

Listenableは変更通知を送信できるオブジェクトのインターフェースです。

```dart
abstract class Listenable {
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
}
```

### Listenableを実装している主なクラス

1.  **ChangeNotifier**

    ```dart
    class Counter extends ChangeNotifier {
      int _count = 0;
      int get count => _count;
      
      void increment() {
        _count++;
        notifyListeners(); // リスナーに通知
      }
    }

    // 使用例
    final counter = useMemoized(() => Counter());
    useListenable(counter);

    return Text('Count: ${counter.count}');
    ```

2.  **ValueNotifier\<T\>**

    ```dart
    final counter = ValueNotifier<int>(0);
    useListenable(counter);

    return Column([
      Text('Count: ${counter.value}'),
      ElevatedButton(
        onPressed: () => counter.value++,
        child: Text('Increment'),
      ),
    ]);
    ```

3.  **TextEditingController**

    ```dart
    final controller = useTextEditingController();
    useListenable(controller);

    return Column([
      TextField(controller: controller),
      Text('文字数: ${controller.text.length}'),
    ]);
    ```

4.  **ScrollController**

    ```dart
    final scrollController = useScrollController();
    useListenable(scrollController);

    final offset = scrollController.hasClients 
        ? scrollController.offset 
        : 0.0;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverAppBar(
          pinned: offset > 100, // スクロール量で固定
        ),
      ],
    );
    ```

5.  **AnimationController**

    ```dart
    final animationController = useAnimationController(
      duration: Duration(seconds: 1),
    );
    useListenable(animationController);

    return Opacity(
      opacity: animationController.value,
      child: child,
    );
    ```

6.  **TabController**

    ```dart
    final tabController = useTabController(initialLength: 3);
    useListenable(tabController);

    return Column([
      TabBar(controller: tabController),
      Text('現在のタブ: ${tabController.index}'),
    ]);
    ```

7.  **PageController**

    ```dart
    final pageController = usePageController();
    useListenable(pageController);

    final currentPage = pageController.hasClients 
        ? pageController.page ?? 0 
        : 0;

    return Column([
      PageView(controller: pageController),
      Text('ページ ${currentPage.round() + 1}/3'),
    ]);
    ```

8.  **FocusNode**

    ```dart
    final focusNode = useFocusNode();
    useListenable(focusNode);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: focusNode.hasFocus ? Colors.blue : Colors.grey,
        ),
      ),
      child: TextField(focusNode: focusNode),
    );
    ```

9.  **Animation\<T\>**

    ```dart
    final animation = useAnimationController(
      duration: Duration(seconds: 2),
    ).drive(Tween(begin: 0.0, end: 1.0));

    useListenable(animation);

    return Transform.scale(
      scale: animation.value,
      child: child,
    );
    ```

-----

## useListenableの使い方

### 基本構文

```dart
final listenable = /* Listenableオブジェクト */;
useListenable(listenable);

// listenableが変更されるたびにウィジェットが再ビルドされる
```

### useListenableが必要なケース vs 不要なケース

**✅ 必要: 値をUIで使う**

```dart
final controller = useTextEditingController();
useListenable(controller); // ← 必要

final isEmpty = controller.text.isEmpty;
return ElevatedButton(
  onPressed: isEmpty ? null : onSubmit,
  //         ↑ controller.textの値を使っている
  child: Text('送信'),
);
```

**❌ 不要: Widgetに渡すだけ**

```dart
final controller = useTextEditingController();
// useListenableは不要

return TextField(
  controller: controller, // ← 渡すだけ
  // TextFieldが内部で変更を処理する
);
```

**❌ 不要: イベント時のみ使用**

```dart
final controller = useTextEditingController();
// useListenableは不要

return TextField(
  controller: controller,
  onSubmitted: (value) {
    // このタイミングでのみ値を使う
    print(controller.text);
  },
);
```

### `useListenable` vs `useValueListenable`

  * **useListenable**
    ```dart
    final notifier = ValueNotifier<int>(0);
    useListenable(notifier);

    return Text('Count: ${notifier.value}'); // 値を手動で取得
    ```
  * **useValueListenable**（ValueNotifier専用）
    ```dart
    final notifier = ValueNotifier<int>(0);
    final value = useValueListenable(notifier); // 値を直接取得

    return Text('Count: $value'); // より簡潔
    ```

### `useListenable` vs `useAnimation`

  * **useListenable**（汎用）
    ```dart
    final animation = useAnimationController(...);
    useListenable(animation);

    return Opacity(
      opacity: animation.value,
      child: child,
    );
    ```
  * **useAnimation**（Animation専用）
    ```dart
    final animation = useAnimationController(...);
    final value = useAnimation(animation); // 値を直接取得

    return Opacity(
      opacity: value,
      child: child,
    );
    ```

### 複数のListenableを監視

```dart
final controller1 = useTextEditingController();
final controller2 = useTextEditingController();
useListenable(controller1);
useListenable(controller2);

final bothFilled = controller1.text.isNotEmpty && 
                   controller2.text.isNotEmpty;

return ElevatedButton(
  onPressed: bothFilled ? onSubmit : null,
  child: Text('送信'),
);
```

-----

## 実践的な使い分けガイド

### シナリオ1: 新規タスク作成フォーム

```dart
// ✅ 推奨: ローカル管理
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(todoListViewModelProvider);
  final viewModel = ref.read(todoListViewModelProvider.notifier);
  
  // 一時的な入力値 → ローカルで管理
  final titleController = useTextEditingController();
  useListenable(titleController);
  
  // ViewModelのStateで管理するのは処理状態のみ
  final canSubmit = titleController.text.trim().isNotEmpty && 
                    !state.isCreating;
  //                ↑ ローカルで管理             ↑ Stateで管理
  
  return TextField(
    controller: titleController,
    onSubmitted: (_) async {
      final created = await viewModel.createTask(titleController.text);
      if (created) titleController.clear();
    },
  );
}
```

### シナリオ2: 検索機能（複数画面で共有）

```dart
// ✅ 推奨: Stateで管理
@freezed
class TodoListState {
  final String searchQuery; // 複数画面で使うのでStateに含める
  final List<TodoTask> searchResults;
}

class TodoListViewModel {
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _performSearch(query);
  }
}

// 画面A: 検索入力
Widget buildSearchScreen() {
  final state = ref.watch(todoListViewModelProvider);
  return TextField(
    value: state.searchQuery,
    onChanged: viewModel.updateSearchQuery,
  );
}

// 画面B: 検索結果表示（別画面でも検索クエリを表示）
Widget buildResultScreen() {
  final state = ref.watch(todoListViewModelProvider);
  return Column([
    Text('検索中: "${state.searchQuery}"'),
    ListView(children: state.searchResults.map(...)),
  ]);
}
```

### シナリオ3: スクロール連動FAB

```dart
// ✅ 推奨: ローカル管理
Widget build(BuildContext context) {
  final scrollController = useScrollController();
  useListenable(scrollController);
  
  final showFab = scrollController.hasClients && 
                  scrollController.offset > 100;
  
  return Scaffold(
    body: ListView(controller: scrollController),
    floatingActionButton: showFab
      ? FloatingActionButton(
          onPressed: () {
            scrollController.animateTo(0, ...);
          },
        )
      : null,
  );
}
```

### シナリオ4: フィルター設定（永続化）

```dart
// ✅ 推奨: Stateで管理
@freezed
class TodoListState {
  @Default(TodoFilter.all) TodoFilter filter; // 永続化するのでState
}

class TodoListViewModel {
  Future<void> setFilter(TodoFilter filter) async {
    state = state.copyWith(filter: filter);
    await _storage.save('filter', filter); // 永続化
  }
}
```

-----

## パフォーマンス比較

### ケース1: テキスト入力（1文字ごと）

#### ❌ Stateで管理（非推奨）

```dart
@freezed
class TodoListState {
  final String inputText;
  final List<TodoTask> tasks; // 100個のタスク
}

void onTextChanged(String text) {
  state = state.copyWith(inputText: text);
  // → 1文字入力するたびに...
}

Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(todoListViewModelProvider);
  // ↓ すべて再ビルド
  return Scaffold(
    appBar: AppBar(...),        // 再ビルド
    body: Column([
      TextField(...),           // 再ビルド
      TaskList(                 // 再ビルド
        tasks: state.tasks,     // 100個のタスクすべて再ビルド！
      ),
      FilterButton(...),        // 再ビルド
    ]),
  );
}
```

  * **パフォーマンス: ❌❌❌**
      * 1文字入力: 全ウィジェット再ビルド
      * 10文字入力: 10回の全体再ビルド
      * 100個のタスクも毎回再ビルド

#### ✅ ローカル管理（推奨）

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(todoListViewModelProvider);
  final controller = useTextEditingController();
  useListenable(controller);
  
  return Scaffold(
    appBar: AppBar(...),        // 再ビルドされない
    body: Column([
      TextField(...),           // 再ビルド（必要）
      TaskList(                 // 再ビルドされない！
        tasks: state.tasks,
      ),
      FilterButton(...),        // 再ビルドされない
    ]),
  );
}
```

  * **パフォーマンス: ✅✅✅**
      * 1文字入力: TextFieldとその親のみ再ビルド
      * TaskListは再ビルドされない
      * 滑らかな入力体験

### ケース2: スクロール（高頻度更新）

  * **❌ Stateで管理**

    ```dart
    void onScroll(double offset) {
      state = state.copyWith(scrollOffset: offset);
      // スクロール中は毎フレーム更新される（60fps = 秒間60回）
    }
    ```

      * **パフォーマンス: ❌❌❌**
          * 秒間60回のState更新
          * 秒間60回の全体再ビルド
          * カクカクする

  * **✅ ローカル管理**

    ```dart
    final scrollController = useScrollController();
    useListenable(scrollController);
    // 必要な部分のみ再ビルド
    ```

      * **パフォーマンス: ✅✅✅**
          * 効率的な再ビルド
          * スムーズなスクロール

-----

## ベストプラクティス

### 1\. 責任の分離

```dart
// ✅ 良い設計
class TodoListState {
  // ビジネスロジックのみ
  final AsyncValue<List<TodoTask>> tasks;
  final TodoFilter filter;
  final bool isCreating;
}

Widget build(BuildContext context, WidgetRef ref) {
  // UI状態はローカルで
  final controller = useTextEditingController();
  final scrollController = useScrollController();
  final showDialog = useState(false);
}
```

### 2\. 判断フローチャート

```
状態を管理したい
    ↓
Q1: 複数画面で共有する？
    YES → Stateで管理
    NO  → Q2へ
    
Q2: 永続化が必要？
    YES → Stateで管理
    NO  → Q3へ
    
Q3: ビジネスロジックと密接？
    YES → Stateで管理
    NO  → Q4へ
    
Q4: 高頻度で変更される？
    YES → ローカルで管理
    NO  → Q5へ
    
Q5: 一時的な値？（送信後に破棄）
    YES → ローカルで管理
    NO  → Stateで管理を検討
```

### 3\. コード例: 完全な実装

```dart
// ViewModel State（ビジネスロジック）
@freezed
class TodoListState with _$TodoListState {
  const factory TodoListState({
    @Default(AsyncValue.loading()) AsyncValue<List<TodoTask>> tasks,
    @Default(TodoFilter.all) TodoFilter filter,
    @Default(TodoSort.createdAt) TodoSort sortOrder,
    @Default(false) bool isCreating,
    String? pendingError,
  }) = _TodoListState;
}

// UI（ローカル状態管理）
class TodoListPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stateで管理されているもの
    final state = ref.watch(todoListViewModelProvider);
    final viewModel = ref.read(todoListViewModelProvider.notifier);
    
    // ローカルで管理するもの
    final newTaskController = useTextEditingController();
    final scrollController = useScrollController();
    final showFilterMenu = useState(false);
    
    useListenable(newTaskController);
    useListenable(scrollController);
    
    // エラー表示（StateとHooksのハイブリッド）
    useEffect(() {
      final error = state.pendingError;
      if (error == null) return null;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showToast(context, error);
        viewModel.clearPendingError();
      });
      return null;
    }, [state.pendingError]);
    
    // ローカル状態を使った計算
    final canSubmit = newTaskController.text.trim().isNotEmpty && 
                      !state.isCreating;
    
    final showBackToTop = scrollController.hasClients && 
                          scrollController.offset > 100;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('TODOリスト'),
        actions: [
          // Stateの値を使用
          FilterButton(
            current: state.filter,
            onSelected: viewModel.setFilter,
          ),
        ],
      ),
      body: Stack([
        ListView(
          controller: scrollController,
          children: [
            // ローカル状態を使用
            NewTaskField(
              controller: newTaskController,
              canSubmit: canSubmit,
              onSubmit: () async {
                final created = await viewModel.createTask(
                  newTaskController.text,
                );
                if (created) newTaskController.clear();
              },
            ),
            // Stateの値を使用
            TaskList(tasks: state.tasks),
          ],
        ),
        // ローカル状態で表示制御
        if (showBackToTop)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                scrollController.animateTo(0, ...);
              },
              child: Icon(Icons.arrow_upward),
            ),
          ),
      ]),
    );
  }
}
```

### 4\. チェックリスト

#### Stateに追加する前に確認

  * [ ] この状態は複数画面で使う？
  * [ ] この状態は永続化が必要？
  * [ ] この状態はビジネスロジックと密接？
  * [ ] この状態はテストで検証したい？
  * [ ] この状態は低〜中頻度で更新される？
      * すべてNO → **ローカルで管理を検討**

#### ローカル管理する前に確認

  * [ ] この状態は一時的？（送信後破棄）
  * [ ] この状態はUI固有？（スクロール、アニメーション）
  * [ ] この状態は単一画面でのみ使用？
  * [ ] この状態は高頻度で更新される？
  * [ ] ViewModelに含めるとパフォーマンスが悪化する？
      * 多くがYES → **ローカルで管理**

-----

## まとめ表

### 状態管理の使い分け

| 基準 | Stateで管理 | ローカル管理 |
| :--- | :--- | :--- |
| **スコープ** | グローバル・複数画面 | 単一ウィジェット |
| **永続化** | 必要 | 不要 |
| **更新頻度** | 低〜中 | 高 |
| **ライフサイクル** | アプリ全体・画面全体 | ウィジェットと同じ |
| **テスト容易性** | 高い | 中程度 |
| **パフォーマンス** | 更新時に全体再ビルド | 部分的に再ビルド |
| **例** | `tasks`, `filter`, `user` | 入力値, スクロール位置 |

### Listenableの種類と用途

| クラス | 用途 | `useListenable`必要？ |
| :--- | :--- | :--- |
| **TextEditingController** | テキスト入力 | 値を使う場合のみ |
| **ScrollController** | スクロール制御 | 位置を使う場合のみ |
| **AnimationController** | アニメーション | 値を使う場合のみ |
| **TabController** | タブ制御 | インデックスを使う場合のみ |
| **PageController** | ページ制御 | ページ番号を使う場合のみ |
| **FocusNode** | フォーカス管理 | 状態を使う場合のみ |
| **ValueNotifier\<T\>** | 単一値の通知 | 値を使う場合のみ |
| **ChangeNotifier** | カスタム通知 | 値を使う場合のみ |

-----

## 最終的な判断基準

### Stateで管理:

  * ✅ 複数画面で共有
  * ✅ 永続化が必要
  * ✅ ビジネスロジックと密接
  * ✅ テストで検証したい
  * ✅ 画面遷移後も保持

### ローカル管理:

  * ✅ 一時的な入力
  * ✅ UI固有の状態
  * ✅ 単一画面のみ
  * ✅ 高頻度更新
  * ✅ パフォーマンス重視