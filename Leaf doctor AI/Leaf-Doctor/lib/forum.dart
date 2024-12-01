import 'dart:io';
import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'createpost.dart';

class ForumPage extends StatefulWidget {
  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<ForumPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final postMaps = await _databaseHelper.getForumPosts();
      final enrichedPosts = <ForumPost>[];

      for (var map in postMaps) {
        final post = ForumPost(
          id: map[DatabaseHelper.columnPostId],
          username: map[DatabaseHelper.columnUsername],
          avatar: map[DatabaseHelper.columnAvatar] ?? 'assets/default_avatar.png',
          title: map[DatabaseHelper.columnTitle] ?? '',
          content: map[DatabaseHelper.columnContent],
          date: map[DatabaseHelper.columnPostDate],
          image: map[DatabaseHelper.columnPostImage],
        );

        // Load replies for each post
        final replyMaps = await _databaseHelper.getRepliesForPost(post.id!);
        post.replies = replyMaps.map((replyMap) => Reply(
          id: replyMap[DatabaseHelper.columnReplyId],
          username: replyMap[DatabaseHelper.columnReplyUsername],
          avatar: replyMap[DatabaseHelper.columnReplyAvatar] ?? 'assets/default_avatar.png',
          content: replyMap[DatabaseHelper.columnReplyContent],
          date: replyMap[DatabaseHelper.columnReplyDate],
        )).toList();

        enrichedPosts.add(post);
      }

      setState(() {
        _posts = enrichedPosts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: $e')),
      );
    }
  }

  Future<void> _deletePost(int postId) async {
    try {
      await _databaseHelper.deleteForumPostWithReplies(postId);
      await _loadPosts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  // New method to add a reply
  Future<void> _addReply(ForumPost post, String replyText) async {
    try {
      await _databaseHelper.insertReply(
        postId: post.id!,
        username: 'Current User', // Replace with actual username
        content: replyText,
        date: DateTime.now().toString(),
      );
      await _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding reply: $e')),
      );
    }
  }

  // Rest of the existing methods...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaf Doctor AI Forum'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPosts,
            tooltip: 'Refresh Posts',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No forum posts yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePostPage()),
              ),
              child: Text('Create First Post'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            return PostCard(
              post: _posts[index],
              onDelete: () => _deletePost(_posts[index].id!),
              onReply: (replyText) => _addReply(_posts[index], replyText),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreatePostPage()),
        ),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final ForumPost post;
  final VoidCallback? onDelete;
  final Function(String)? onReply;

  PostCard({required this.post, this.onDelete, this.onReply});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _replyController = TextEditingController();
  bool _showReplies = false;

  void _submitReply() {
    if (_replyController.text.trim().isNotEmpty) {
      widget.onReply?.call(_replyController.text.trim());
      _replyController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Existing post header with user info and delete option
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(widget.post.avatar),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.post.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete Post',
                  ),
              ],
            ),
            SizedBox(height: 10),

            // Existing post content and image...
            if (widget.post.title.isNotEmpty)
              Text(
                widget.post.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 5),
            Text(widget.post.content),
            if (widget.post.image != null && widget.post.image!.isNotEmpty) ...[
              SizedBox(height: 10),
              Image.file(
                File(widget.post.image!),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
            Text(
              widget.post.date,
              style: TextStyle(color: Colors.grey),
            ),

            // Reply Section
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Add a reply...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _submitReply,
                ),
              ],
            ),

            // Replies Section
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _showReplies = !_showReplies;
                });
              },
              child: Text(
                '${widget.post.replies.length} Replies',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            if (_showReplies)
              ...widget.post.replies.map((reply) => Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage(reply.avatar),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.username,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(reply.content),
                          Text(
                            reply.date,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}

// Complete ForumPost class
class ForumPost {
  final int? id;
  final String username;
  final String avatar;
  final String title;
  final String content;
  final String date;
  final String? image;
  List<Reply> replies;

  ForumPost({
    this.id,
    required this.username,
    required this.avatar,
    this.title = '',
    required this.content,
    required this.date,
    this.image,
    this.replies = const [],
  });
}

// New Reply class
class Reply {
  final int? id;
  final String username;
  final String avatar;
  final String content;
  final String date;

  Reply({
    this.id,
    required this.username,
    required this.avatar,
    required this.content,
    required this.date,
  });
}