import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intermediete_1/models/story.dart';
import 'package:intermediete_1/screens/map_picker_screen.dart';
import 'package:intermediete_1/screens/story_detail_screen.dart';
import 'package:intermediete_1/screens/story_upload_screen.dart';
import 'package:intermediete_1/services/auth_service.dart';
import 'package:intermediete_1/screens/login_screen.dart';
import 'package:intermediete_1/screens/register_screen.dart';
import 'package:intermediete_1/screens/story_list_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(path: '/home', builder: (context, state) => StoryListScreen()),
    GoRoute(
      path: '/detail',
      builder:
          (context, state) => StoryDetailScreen(story: state.extra as Story),
    ),
    GoRoute(
      path: '/upload',
      builder: (context, state) => const UploadStoryScreen(),
    ),
    GoRoute(
      path: '/map-picker',
      builder: (context, state) {
        final LatLng initialLocation = state.extra as LatLng;
        return MapPickerScreen(initialLocation: initialLocation);
      },
    ),
  ],
  redirect: (context, state) async {
    final loggedIn = await AuthService.isLoggedIn();
    final isLoggingIn =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!loggedIn && !isLoggingIn) return '/login';
    if (loggedIn && isLoggingIn) return '/home';
    return null;
  },
);
