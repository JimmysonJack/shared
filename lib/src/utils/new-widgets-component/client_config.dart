import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_component/shared_component.dart';

Future<ValueNotifier<GraphQLClient>> graphClient(context) async {
  Api api = Api();
  String? token = await api.userToken(false, context);
  final HttpLink httpLink =
      HttpLink('${Environment.getInstance().getServerUrl()}/graphql');
  final AuthLink authLink = AuthLink(getToken: () async => 'Bearer $token');
  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(link: link, cache: GraphQLCache(store: HiveStore())));
  return client;
}