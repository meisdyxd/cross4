# Лабораторная работа №4 — API и BLoC для первого экрана

## Что сделано

Отдельное приложение получает каталог товаров из публичного API DummyJSON и
показывает его на первом экране. Запрос выполняет `Dio`; данные преобразуются в
модель `Product` в репозитории; состояния экрана контролирует `CatalogBloc`.

## Выполнение задач

| Задача | Выполнение |
| --- | --- |
| HTTP-клиент | Создан `Dio` с `baseUrl=https://dummyjson.com`, тайм-аутом и `TalkerDioLogger`. |
| Модель и репозиторий | `Product.fromJson` читает ответ API, `ProductRepository.getProducts()` выполняет `GET /products?limit=20`. |
| BLoC | Событие `CatalogRequested` переключает состояния `CatalogLoading`, `CatalogSuccess` либо `CatalogFailure`. |
| Интеграция UI | `BlocProvider` создаёт блок, `BlocBuilder` отображает индикатор, список или кнопку повторной попытки. |
| Тесты | Проверяется десериализация модели и отображение заголовка экрана. |

## Запуск

```powershell
flutter pub get
flutter run -d edge --release
```

## Источники и зависимости

Данные берутся из [DummyJSON API](https://dummyjson.com/docs/products), который не
требует ключа. Пакеты скачиваются командой `flutter pub get` с [pub.dev](https://pub.dev):
[dio](https://pub.dev/packages/dio), [flutter_bloc](https://pub.dev/packages/flutter_bloc),
[equatable](https://pub.dev/packages/equatable), [talker_flutter](https://pub.dev/packages/talker_flutter).
