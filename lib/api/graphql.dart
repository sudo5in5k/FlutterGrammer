import 'package:flutter_app_syakyou/api/Pokemon.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/web.dart';

Future<GraphQLClient> initGraphQL() async {
  final httpLink = HttpLink('https://graphql-pokemon2.vercel.app');
  final cache = await HiveStore.open(boxName: 'pokeCache');
  return GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: cache),
  );
}

Future<List<Pokemon>> fetchPokemons(GraphQLClient client) async {
  final logger = Logger();
  // 勉強用にあえてFragement記法にする
  const pokemonFieldsFragment = r'''
fragment PokemonFields on Pokemon {
    name
    classification
  }
''';
  const query = '''
$pokemonFieldsFragment
query {
  pokemons(first:10) {
    ...PokemonFields
  }
}
''';
  final result = await client.query(
    QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    ),
  );
  if (result.hasException) {
    logger.e('GraphQL Error: ${result.exception}');
    throw Exception(result.exception.toString());
  }
  final List<dynamic> pokes = result.data?['pokemons'] ?? [];
  return pokes.map((json) => Pokemon.fromJson(json)).toList();
}

void main(List<String> args) async {
  final logger = Logger();
  final client = await initGraphQL();
  final pokemons = await fetchPokemons(client);
  for (var pokemon in pokemons) {
    logger.i(pokemon.toString());
  }
}
