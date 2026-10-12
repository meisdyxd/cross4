import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  final talker = TalkerFlutter.init();
  final dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com', connectTimeout: const Duration(seconds: 8)))
    ..interceptors.add(TalkerDioLogger(talker: talker));
  runApp(CatalogApiApp(repository: ProductRepository(dio), talker: talker));
}

class Product extends Equatable {
  const Product({required this.id, required this.title, required this.description, required this.thumbnail});
  final int id;
  final String title;
  final String description;
  final String thumbnail;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        thumbnail: json['thumbnail'] as String,
      );

  @override
  List<Object> get props => [id, title, description, thumbnail];
}

abstract interface class ProductRepositoryInterface {
  Future<List<Product>> getProducts();
}

class ProductRepository implements ProductRepositoryInterface {
  ProductRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Product>> getProducts() async {
    final response = await _dio.get('/products', queryParameters: {'limit': 20});
    return (response.data['products'] as List)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();
  @override
  List<Object?> get props => [];
}

final class CatalogRequested extends CatalogEvent {
  const CatalogRequested();
}

sealed class CatalogState extends Equatable {
  const CatalogState();
  @override
  List<Object?> get props => [];
}

final class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

final class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

final class CatalogSuccess extends CatalogState {
  const CatalogSuccess(this.products);
  final List<Product> products;
  @override
  List<Object?> get props => [products];
}

final class CatalogFailure extends CatalogState {
  const CatalogFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(this._repository, this._talker) : super(const CatalogInitial()) {
    on<CatalogRequested>(_load);
  }
  final ProductRepositoryInterface _repository;
  final Talker _talker;

  Future<void> _load(CatalogRequested event, Emitter<CatalogState> emit) async {
    emit(const CatalogLoading());
    try {
      emit(CatalogSuccess(await _repository.getProducts()));
    } catch (error, stackTrace) {
      _talker.handle(error, stackTrace);
      emit(CatalogFailure(error.toString()));
    }
  }
}

class CatalogApiApp extends StatelessWidget {
  const CatalogApiApp({required this.repository, required this.talker, super.key});
  final ProductRepositoryInterface repository;
  final Talker talker;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF14344E), useMaterial3: true),
        home: BlocProvider(
          create: (_) => CatalogBloc(repository, talker)..add(const CatalogRequested()),
          child: const CatalogScreen(),
        ),
      );
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Товары из API')),
        body: BlocBuilder<CatalogBloc, CatalogState>(
          builder: (context, state) => switch (state) {
            CatalogInitial() || CatalogLoading() => const Center(child: CircularProgressIndicator()),
            CatalogFailure(:final message) => Center(
                child: FilledButton.icon(
                  onPressed: () => context.read<CatalogBloc>().add(const CatalogRequested()),
                  icon: const Icon(Icons.refresh),
                  label: Text('Повторить: $message'),
                ),
              ),
            CatalogSuccess(:final products) => RefreshIndicator(
                onRefresh: () async {
                  context.read<CatalogBloc>().add(const CatalogRequested());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => ProductCard(product: products[index]),
                ),
              ),
          },
        ),
      );
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});
  final Product product;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Image.network(product.thumbnail, width: 56, height: 56, fit: BoxFit.cover),
          title: Text(product.title),
          subtitle: Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      );
}
