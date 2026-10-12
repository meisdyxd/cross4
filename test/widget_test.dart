import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab4_api_bloc_home/main.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  test('Модель Product корректно читается из JSON', () {
    final product = Product.fromJson({'id': 1, 'title': 'Тест', 'description': 'Описание', 'thumbnail': 'https://example.test/image.png'});
    expect(product.id, 1);
    expect(product.title, 'Тест');
  });

  testWidgets('Экран показывает состояние загрузки', (tester) async {
    await tester.pumpWidget(CatalogApiApp(repository: ProductRepository(Dio()), talker: TalkerFlutter.init()));
    expect(find.text('Товары из API'), findsOneWidget);
  });
}
