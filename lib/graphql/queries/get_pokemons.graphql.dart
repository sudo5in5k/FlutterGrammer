import '../fragments/pokemon_fields.graphql.dart';
import 'package:gql/ast.dart';

class Query$GetPokemons {
  Query$GetPokemons({this.pokemons, this.$__typename = 'Query'});

  factory Query$GetPokemons.fromJson(Map<String, dynamic> json) {
    final l$pokemons = json['pokemons'];
    final l$$__typename = json['__typename'];
    return Query$GetPokemons(
      pokemons: (l$pokemons as List<dynamic>?)
          ?.map(
            (e) => e == null
                ? null
                : Fragment$PokemonFields.fromJson((e as Map<String, dynamic>)),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$PokemonFields?>? pokemons;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pokemons = pokemons;
    _resultData['pokemons'] = l$pokemons?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pokemons = pokemons;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pokemons == null ? null : Object.hashAll(l$pokemons.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetPokemons || runtimeType != other.runtimeType) {
      return false;
    }
    final l$pokemons = pokemons;
    final lOther$pokemons = other.pokemons;
    if (l$pokemons != null && lOther$pokemons != null) {
      if (l$pokemons.length != lOther$pokemons.length) {
        return false;
      }
      for (int i = 0; i < l$pokemons.length; i++) {
        final l$pokemons$entry = l$pokemons[i];
        final lOther$pokemons$entry = lOther$pokemons[i];
        if (l$pokemons$entry != lOther$pokemons$entry) {
          return false;
        }
      }
    } else if (l$pokemons != lOther$pokemons) {
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

extension UtilityExtension$Query$GetPokemons on Query$GetPokemons {
  CopyWith$Query$GetPokemons<Query$GetPokemons> get copyWith =>
      CopyWith$Query$GetPokemons(this, (i) => i);
}

abstract class CopyWith$Query$GetPokemons<TRes> {
  factory CopyWith$Query$GetPokemons(
    Query$GetPokemons instance,
    TRes Function(Query$GetPokemons) then,
  ) = _CopyWithImpl$Query$GetPokemons;

  factory CopyWith$Query$GetPokemons.stub(TRes res) =
      _CopyWithStubImpl$Query$GetPokemons;

  TRes call({List<Fragment$PokemonFields?>? pokemons, String? $__typename});
  TRes pokemons(
    Iterable<Fragment$PokemonFields?>? Function(
      Iterable<CopyWith$Fragment$PokemonFields<Fragment$PokemonFields>?>?,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$GetPokemons<TRes>
    implements CopyWith$Query$GetPokemons<TRes> {
  _CopyWithImpl$Query$GetPokemons(this._instance, this._then);

  final Query$GetPokemons _instance;

  final TRes Function(Query$GetPokemons) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pokemons = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$GetPokemons(
      pokemons: pokemons == _undefined
          ? _instance.pokemons
          : (pokemons as List<Fragment$PokemonFields?>?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes pokemons(
    Iterable<Fragment$PokemonFields?>? Function(
      Iterable<CopyWith$Fragment$PokemonFields<Fragment$PokemonFields>?>?,
    )
    _fn,
  ) => call(
    pokemons: _fn(
      _instance.pokemons?.map(
        (e) => e == null ? null : CopyWith$Fragment$PokemonFields(e, (i) => i),
      ),
    )?.toList(),
  );
}

class _CopyWithStubImpl$Query$GetPokemons<TRes>
    implements CopyWith$Query$GetPokemons<TRes> {
  _CopyWithStubImpl$Query$GetPokemons(this._res);

  TRes _res;

  call({List<Fragment$PokemonFields?>? pokemons, String? $__typename}) => _res;

  pokemons(_fn) => _res;
}

const documentNodeQueryGetPokemons = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'GetPokemons'),
      variableDefinitions: [],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'pokemons'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'first'),
                value: IntValueNode(value: '10'),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FragmentSpreadNode(
                  name: NameNode(value: 'PokemonFields'),
                  directives: [],
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
    ),
    fragmentDefinitionPokemonFields,
  ],
);
