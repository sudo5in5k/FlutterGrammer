// graphql_codegen経由でとれたものをたしかめるだけ
import 'package:flutter_app_syakyou/api/graphql.dart';
import 'package:flutter_app_syakyou/graphql/queries/get_pokemons.graphql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/web.dart';

typedef GetPokemonResult = Query$GetPokemons; // 可視性のためにtypealiasを作るのあり

Future<GetPokemonResult> fetchPokemons() async {
  final client = await initGraphQL();
  final result = await client.query(
    QueryOptions(document: documentNodeQueryGetPokemons),
  );

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }
  return GetPokemonResult.fromJson(result.data!);
}

Future<void> main(List<String> args) async {
  final logger = Logger();
  final data = await fetchPokemons();
  for (var pokemon in data.pokemons ?? []) {
    logger.i(
      'Name: ${pokemon?.name}, Classification: ${pokemon?.classification}',
    );
  }
}
