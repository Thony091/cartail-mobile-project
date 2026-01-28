import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/offline_first/offline_first_executor.dart';
import '../../../sync_queue/domain/entities/sync_queue_item.dart';
import '../../../sync_queue/domain/repositories/sync_queue_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/user_local_datasource.dart';
import '../datasources/user_datasource.dart';
import '../datasources/user_datasource_impl.dart';
import '../../../shared/data/models/isar_domain_models.dart' as isar_models;

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    UserDatasource? remoteDatasource,
    UserLocalDatasource? localDatasource,
    ConnectivityService? connectivityService,
    SyncQueueRepository? syncQueueRepository,
  })  : _remoteDatasource = remoteDatasource ?? UserDatasourceImpl(),
        _localDatasource = localDatasource,
        _offlineFirstExecutor = (connectivityService != null &&
                syncQueueRepository != null)
            ? OfflineFirstExecutor(
                connectivityService: connectivityService,
                syncQueueRepository: syncQueueRepository,
              )
            : null;

  final UserDatasource _remoteDatasource;
  final UserLocalDatasource? _localDatasource;
  final OfflineFirstExecutor? _offlineFirstExecutor;

  bool get _offlineReady => _localDatasource != null && _offlineFirstExecutor != null;

  @override
  Future<User> checkAuthStatus(String token) async {
    if (!_offlineReady) {
      return _remoteDatasource.checkAuthStatus(token);
    }
    return _offlineFirstExecutor!.read<User>(
      local: () async {
        final model = await _localDatasource!.getByBackendId(token);
        if (model == null) {
          throw StateError('User not found locally for token');
        }
        return _isarToEntity(model);
      },
      remote: () => _remoteDatasource.checkAuthStatus(token),
      cache: (user) async {
        await _localDatasource!.upsert(_entityToIsar(user, isSynced: true));
      },
    );
  }

  @override
  Future<void> deleteUser() async {
    await _remoteDatasource.deleteUser();
  }

  @override
  Future<User> getUser(String collectionName, String uid) async {
    if (!_offlineReady) {
      return _remoteDatasource.getUser(collectionName, uid);
    }
    return _offlineFirstExecutor!.read<User>(
      local: () async {
        final model = await _localDatasource!.getByBackendId(uid);
        if (model == null) {
          throw StateError('User not found locally: $uid');
        }
        return _isarToEntity(model);
      },
      remote: () => _remoteDatasource.getUser(collectionName, uid),
      cache: (user) async {
        await _localDatasource!.upsert(_entityToIsar(user, isSynced: true));
      },
    );
  }

  @override
  Future<firebase_auth.UserCredential> login(String email, String password) {
    return _remoteDatasource.login(email, password);
  }

  @override
  Future<bool> register(
    String email,
    String password,
    String name,
    String rut,
    String birthday,
    String phone,
    String uid,
  ) {
    return _remoteDatasource.register(email, password, name, rut, birthday, phone, uid);
  }

  @override
  Future<User> updateUser(Map<String, dynamic> userSimilar, String uid) async {
    if (!_offlineReady) {
      return _remoteDatasource.updateUser(userSimilar, uid);
    }

    final entity = _userFromMap(userSimilar, uid);

    return _offlineFirstExecutor!.write<User>(
      localWrite: () async {
        await _localDatasource!.upsert(_entityToIsar(entity, isSynced: false));
        return entity;
      },
      remoteWrite: () => _remoteDatasource.updateUser(userSimilar, uid),
      cache: (user) async {
        await _localDatasource!.upsert(_entityToIsar(user, isSynced: true));
      },
      queueItem: () => SyncQueueItem.newItem(
        action: SyncActionType.update,
        entity: SyncEntityType.user,
        payload: Map<String, dynamic>.from(userSimilar)..['uid'] = uid,
      ),
    );
  }

  @override
  Future<void> resetPasswordByEmail(String email) {
    return _remoteDatasource.resetPasswordByEmail(email);
  }

  User _isarToEntity(isar_models.UserModel model) {
    final role = UserRole.fromJson(model.role);
    return User(
      uid: model.backendId,
      nombre: model.nombre,
      rut: model.rut,
      fechaNacimiento: model.fechaNacimiento,
      email: model.email,
      telefono: model.telefono,
      direccion: model.direccion,
      password: model.passwordHash ?? '',
      imagenPerfil: model.imagenPerfil ?? '',
      bio: model.bio ?? '',
      role: role,
      isAdmin: role == UserRole.admin,
    );
  }

  isar_models.UserModel _entityToIsar(User user, {required bool isSynced}) {
    return isar_models.UserModel()
      ..backendId = user.uid
      ..email = user.email
      ..nombre = user.nombre
      ..rut = user.rut
      ..fechaNacimiento = user.fechaNacimiento
      ..telefono = user.telefono
      ..direccion = user.direccion
      ..passwordHash = user.password.isEmpty ? null : user.password
      ..imagenPerfil = user.imagenPerfil
      ..bio = user.bio
      ..role = user.role.name
      ..isSynced = isSynced
      ..updatedAt = DateTime.now();
  }

  User _userFromMap(Map<String, dynamic> data, String uid) {
    final roleValue = data['role']?.toString() ?? data['rol']?.toString() ?? 'user';
    final role = UserRole.fromJson(roleValue);
    return User(
      uid: uid,
      nombre: data['nombre']?.toString() ?? '',
      rut: data['rut']?.toString() ?? '',
      fechaNacimiento: data['fechaNacimiento']?.toString() ??
          data['fecha_nacimiento']?.toString() ??
          '',
      email: data['email']?.toString() ?? '',
      telefono: data['telefono']?.toString() ?? '',
      direccion: data['direccion']?.toString() ?? '',
      password: data['password']?.toString() ?? '',
      imagenPerfil: data['imagenPerfil']?.toString() ?? '',
      bio: data['bio']?.toString() ?? '',
      role: role,
      isAdmin: role == UserRole.admin,
    );
  }
}
