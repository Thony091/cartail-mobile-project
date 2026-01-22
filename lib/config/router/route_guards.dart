import '../../features/user/domain/entities/user_role.dart';

/// Clase que define las rutas y permisos de acceso basados en roles.
class RouteGuards {
  /// Rutas públicas accesibles para todos (incluyendo invitados)
  static const List<String> publicRoutes = [
    '/',
    '/login',
    '/register',
    '/reset-password',
    '/services',
    '/our-works',
    '/help',
    '/about-us',
    '/reservations',
  ];

  /// Rutas que requieren autenticación (user, operator, admin)
  static const List<String> authenticatedRoutes = [
    '/profile-user',
    '/edit-user-profile',
    '/shoping-cart',
    '/checkout',
    '/payment-methods',
    '/my-history',
    '/my-services',
  ];

  /// Rutas solo para operarios y administradores
  static const List<String> operatorRoutes = [
    '/my-assigned-tickets',
    '/ticket/',
    '/operator/home',
    '/operator/work-orders',
    '/operator/order/',
    '/operator/reception/',
  ];

  /// Rutas solo para administradores
  static const List<String> adminRoutes = [
    '/admin-config-services',
    '/admin-config-works',
    '/admin-config-reservations',
    '/admin-all-tickets',
    '/admin-assign-ticket/',
    '/admin-config-categories',
    '/category-edit/',
  ];

  /// Verifica si un usuario con el rol especificado puede acceder a la ruta
  static bool canAccessRoute(String route, UserRole role) {
    // Rutas públicas son accesibles para todos
    if (publicRoutes.contains(route)) {
      return true;
    }

    // Permitir acceso a rutas de detalles (service/:id, work/:id)
    if (route.startsWith('/service/') || route.startsWith('/work/')) {
      return true;
    }

    // Invitados solo pueden acceder a rutas públicas
    if (role == UserRole.guest) {
      return false;
    }

    // Rutas de administrador
    if (adminRoutes.any((r) => route.startsWith(r))) {
      return role == UserRole.admin;
    }

    // Rutas de operario (operario y admin pueden acceder)
    if (operatorRoutes.any((r) => route.startsWith(r))) {
      return role == UserRole.operator || role == UserRole.admin;
    }

    // Rutas autenticadas (user, operator, admin pueden acceder)
    if (authenticatedRoutes.contains(route)) {
      return role != UserRole.guest;
    }

    // Por defecto, permitir acceso
    return true;
  }

  /// Obtiene la ruta de redirección apropiada cuando el acceso es denegado
  static String getRedirectRoute(String attemptedRoute, UserRole role) {
    // Si es invitado intentando acceder a ruta protegida, redirigir a login
    if (role == UserRole.guest && !publicRoutes.contains(attemptedRoute)) {
      return '/login';
    }

    // Si es usuario autenticado sin permisos suficientes, redirigir a home
    return '/';
  }
}
