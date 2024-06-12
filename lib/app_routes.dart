import 'package:booksclub/app/start_page.dart';
import 'package:booksclub/app/ui/pages/book/pages/book_page.dart';
import 'package:booksclub/app/ui/pages/home/pages/tabs_page.dart';
import 'package:booksclub/app/ui/pages/talk/pages/talk_page.dart';
import 'package:booksclub/app/ui/pages/user/pages/login_page.dart';
import 'package:go_router/go_router.dart';

final routes = GoRouter(
    
    initialLocation: '/',
    routes: [
      
      GoRoute(
          path: ('/'),
          builder: (_,__) => const StartPage(),
          name: 'start'
      ),
       GoRoute(
          path: ('/login'),
          builder: (context,state) => const LoginPage(),
          name: 'login'
      ),
       GoRoute(
          path: ('/tabs'),
          builder: (context,state) => const TabsPage(),
          name: 'tabs'
      ),
      GoRoute(
          path: ('/book/:itemId'),
          builder: (context,state) => BookPage(itemId: state.uri.pathSegments[1]),
          name: 'book'
      ),
      GoRoute(
          path: ('/talk/:itemId'),
          builder: (context,state) => TalkPage(itemId: state.uri.pathSegments[1]),
          name: 'talk'
      ),
  ]);