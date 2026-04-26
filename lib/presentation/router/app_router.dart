import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/item_model.dart';
import '../screens/auth/auth_wrapper.dart';
import '../screens/home/home_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/item/add_item_screen.dart';
import '../screens/item/item_detail_screen.dart';
import '../screens/item/requests_screen.dart';
import '../screens/chat/conversation_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/common/main_shell.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isAuth = auth.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/auth';

      if (!isAuth && !isAuthRoute) {
        return '/auth';
      }
      if (isAuth && isAuthRoute) {
        return '/';
      }
      return null;
    },
    refreshListenable: context.read<AuthProvider>(),
    routes: [
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthWrapper(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (_, __) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/add',
            builder: (_, __) => const AddItemScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (_, __) => const ConversationListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) {
          final item = state.extra as ItemModel;
          return ItemDetailScreen(item: item);
        },
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final otherId = state.pathParameters['userId']!;
          final otherName = state.extra as String? ?? 'User';
          return ChatScreen(otherId: otherId, otherName: otherName);
        },
      ),
      GoRoute(
        path: '/requests',
        builder: (_, __) => const RequestsScreen(),
      ),
    ],
  );
}
