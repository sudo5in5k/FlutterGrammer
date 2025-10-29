import 'package:gql/ast.dart';

class Fragment$PokemonFields {
  Fragment$PokemonFields({
    this.name,
    this.classification,
    this.$__typename = 'Pokemon',
  });

  factory Fragment$PokemonFields.fromJson(Map<String, dynamic> json) {
    final l$name = json['name'];
    final l$classification = json['classification'];
    final l$$__typename = json['__typename'];
    return Fragment$PokemonFields(
      name: (l$name as String?),
      classification: (l$classification as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? name;

  final String? classification;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$classification = classification;
    _resultData['classification'] = l$classification;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$classification = classification;
    final l$$__typename = $__typename;
    return Object.hashAll([l$name, l$classification, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PokemonFields || runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$classification = classification;
    final lOther$classification = other.classification;
    if (l$classification != lOther$classification) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PokemonFields on Fragment$PokemonFields {
  CopyWith$Fragment$PokemonFields<Fragment$PokemonFields> get copyWith =>
      CopyWith$Fragment$PokemonFields(this, (i) => i);
}

abstract class CopyWith$Fragment$PokemonFields<TRes> {
  factory CopyWith$Fragment$PokemonFields(
    Fragment$PokemonFields instance,
    TRes Function(Fragment$PokemonFields) then,
  ) = _CopyWithImpl$Fragment$PokemonFields;

  factory CopyWith$Fragment$PokemonFields.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PokemonFields;

  TRes call({String? name, String? classification, String? $__typename});
}

class _CopyWithImpl$Fragment$PokemonFields<TRes>
    implements CopyWith$Fragment$PokemonFields<TRes> {
  _CopyWithImpl$Fragment$PokemonFields(this._instance, this._then);

  final Fragment$PokemonFields _instance;

  final TRes Function(Fragment$PokemonFields) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? classification = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$PokemonFields(
      name: name == _undefined ? _instance.name : (name as String?),
      classification: classification == _undefined
          ? _instance.classification
          : (classification as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$PokemonFields<TRes>
    implements CopyWith$Fragment$PokemonFields<TRes> {
  _CopyWithStubImpl$Fragment$PokemonFields(this._res);

  TRes _res;

  call({String? name, String? classification, String? $__typename}) => _res;
}

const fragmentDefinitionPokemonFields = FragmentDefinitionNode(
  name: NameNode(value: 'PokemonFields'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Pokemon'), isNonNull: false),
  ),
  directives: [],
  selectionSet: SelectionSetNode(
    selections: [
      FieldNode(
        name: NameNode(value: 'name'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'classification'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ],
  ),
);
const documentNodeFragmentPokemonFields = DocumentNode(
  definitions: [fragmentDefinitionPokemonFields],
);
