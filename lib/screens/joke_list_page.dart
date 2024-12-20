import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/joke.dart';
import '../services/joke_service.dart';
import '../theme/app_theme.dart';

class JokeListPage extends StatefulWidget {
  final SharedPreferences prefs;

  const JokeListPage({Key? key, required this.prefs}) : super(key: key);

  @override
  _JokeListPageState createState() => _JokeListPageState();
}

class _JokeListPageState extends State<JokeListPage>
    with SingleTickerProviderStateMixin {
  late final JokeService _jokeService;
  late final AnimationController _animationController;
  List<Joke> _jokes = [];
  bool _isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _jokeService = JokeService(widget.prefs);
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animations['normal']!,
    );
    _loadJokes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadJokes({bool forceRefresh = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final jokes = await _jokeService.fetchJokes(forceRefresh: forceRefresh);
      setState(() {
        _jokes = jokes;
        _isLoading = false;
      });
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildJokeCard(Joke joke, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeOut,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: AppTheme.borderRadius['lg'],
            boxShadow: AppTheme.cardShadow,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: const Color(0xFF85A5FF).withOpacity(0.5),
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF85A5FF),
                          borderRadius: AppTheme.borderRadius['full'],
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF85A5FF).withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          joke.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.emoji_emotions_outlined,
                        color: const Color(0xFF85A5FF).withOpacity(0.7),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (joke.isTwoPart) ...[
                    Text(
                      joke.setup,
                      style: const TextStyle(
                        color: Color(0xFF030852),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      joke.delivery,
                      style: TextStyle(
                        color: const Color(0xFF030852).withOpacity(0.8),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ] else
                    Text(
                      joke.joke,
                      style: const TextStyle(
                        color: Color(0xFF030852),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [AppTheme.headerShadow],
      ),
      child: Column(
        children: [
          const Text(
            'Daily Jokes',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF030852),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your daily dose of humor',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF030852).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _isLoading ? null : () => _loadJokes(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF85A5FF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                elevation: 2,
                shadowColor: const Color(0xFF85A5FF).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadius['lg']!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else ...[
                    const Icon(Icons.refresh, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Get Fresh Jokes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_emotions_outlined,
            size: 64,
            color: const Color(0xFF85A5FF).withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'No jokes available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF030852),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the refresh button to load some jokes!',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF030852).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () => _loadJokes(forceRefresh: true),
                color: const Color(0xFF85A5FF),
                child: _jokes.isEmpty && !_isLoading
                    ? CustomScrollView(
                        slivers: [
                          SliverFillRemaining(
                            child: _buildEmptyState(),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: _jokes.length,
                        itemBuilder: (context, index) =>
                            _buildJokeCard(_jokes[index], index),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
