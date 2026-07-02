// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intermediete_1/models/story.dart';
import 'package:intermediete_1/services/story_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
// jika pakai .env

class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  final List<Story> _stories = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1;
  final int _size = 15;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadStories();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadStories();
      }
    });
  }

  Future<void> _loadStories({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _stories.clear();
        _currentPage = 1;
        _hasMore = true;
      });
    }

    setState(() => _isLoading = true);
    try {
      final newStories = await StoryService.fetchStories(
        page: _currentPage,
        size: _size,
      );
      setState(() {
        _stories.addAll(newStories);
        _currentPage++;
        if (newStories.length < _size) {
          _hasMore = false;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Cerita"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: "Logout",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadStories(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _stories.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _stories.length) {
              final story = _stories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(story.photoUrl),
                ),
                title: Text(story.name),
                subtitle: Text(
                  story.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  context.push('/detail', extra: story);
                },
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<bool>('/upload');
          if (result == true) {
            await _loadStories(refresh: true);
          }
        },
        tooltip: 'Tambah Cerita',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
