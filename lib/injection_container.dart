import 'package:aura_mart/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aura_mart/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aura_mart/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura_mart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aura_mart/features/cart/data/data_sources/cart_remote_data_source.dart';
import 'package:aura_mart/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:aura_mart/features/cart/domain/repositories/cart_repository.dart';
import 'package:aura_mart/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aura_mart/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_bloc.dart';
import 'package:aura_mart/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:aura_mart/features/orders/data/repositories/order_repository_impl.dart';
import 'package:aura_mart/features/orders/domain/repositories/order_repository.dart';
import 'package:aura_mart/features/products/data/datasources/product_remote_data_source.dart';
import 'package:aura_mart/features/products/data/repositories/product_repository_impl.dart';
import 'package:aura_mart/features/products/domain/repositories/product_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Blocs ---
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => CartBloc(cartRepository: sl()));
  sl.registerFactory(() => OrderBloc(orderRepository: sl()));
  sl.registerFactory(() => ProductBloc(productRepository: sl()));

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Data Sources ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(db: sl(), auth: sl()),
  );
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(db: sl(), auth: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(db: sl(), auth: sl()),
  );

  // --- External ---
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
