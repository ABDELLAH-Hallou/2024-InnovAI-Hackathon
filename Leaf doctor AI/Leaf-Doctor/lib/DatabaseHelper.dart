import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

class DatabaseHelper {
  // Existing database constants
  static final _databaseName = 'leafDoctor.db';
  static final _databaseVersion = 3; // Increment version for new table

  // Status table constants (existing)
  static final statusTable = 'status';
  static final columnId = 'id';
  static final columnImage = 'image';
  static final columnLeafName = 'leaf_name';
  static final columnStatus = 'status';
  static final columnDiseaseName = 'disease_name';

  // New forum post table constants
  static final forumPostTable = 'forum_posts';
  static final columnPostId = 'post_id';
  static final columnUsername = 'username';
  static final columnAvatar = 'avatar';
  static final columnTitle = 'title';
  static final columnContent = 'content';
  static final columnPostDate = 'date';
  static final columnPostImage = 'post_image';

  static final repliesTable = 'replies';
  static const columnReplyId = 'reply_id';
  static const columnReplyUsername = 'reply_username';
  static const columnReplyAvatar = 'reply_avatar';
  static const columnReplyContent = 'reply_content';
  static const columnReplyDate = 'reply_date';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // final path = await getDatabasesPath();
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Existing status table
    await db.execute('''
      CREATE TABLE $statusTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnImage TEXT NOT NULL,
        $columnLeafName TEXT NOT NULL,
        $columnStatus TEXT NOT NULL,
        $columnDiseaseName TEXT
      )
    ''');

    // New forum posts table
    await db.execute('''
      CREATE TABLE $forumPostTable (
        $columnPostId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT NOT NULL,
        $columnAvatar TEXT,
        $columnTitle TEXT,
        $columnContent TEXT NOT NULL,
        $columnPostDate TEXT NOT NULL,
        $columnPostImage TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $repliesTable (
        $columnReplyId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPostId INTEGER NOT NULL,
        $columnReplyUsername TEXT NOT NULL,
        $columnReplyAvatar TEXT,
        $columnReplyContent TEXT NOT NULL,
        $columnReplyDate TEXT NOT NULL,
        FOREIGN KEY ($columnPostId) REFERENCES $forumPostTable ($columnPostId) ON DELETE CASCADE
      )
    ''');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Add forum posts table if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $forumPostTable (
          $columnPostId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnUsername TEXT NOT NULL,
          $columnAvatar TEXT,
          $columnTitle TEXT,
          $columnContent TEXT NOT NULL,
          $columnPostDate TEXT NOT NULL,
          $columnPostImage TEXT
        )
      ''');
    }
  }

  // Existing methods for status table...
  Future<int> insertData({
    required String image,
    required String leafName,
    required String status,
    required String diseaseName,
  }) async {
    final db = await database;
    final docsDirPath = (await getApplicationDocumentsDirectory()).path;

    print(image);
    final cacheImagePath = image;
    image = image.split("/").last;
    final docsImagePath = '$docsDirPath/$image';
    final imageFile = File(cacheImagePath);

    if (!await imageFile.exists()) {
      throw FileSystemException(
          'File does not exist in cache directory', image);
    }

    await imageFile.copy(docsImagePath);

    return await db.insert(
      statusTable,
      {
        columnImage: docsImagePath,
        columnLeafName: leafName,
        columnStatus: status,
        columnDiseaseName: diseaseName,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final db = await database;
    return await db.query(statusTable);
  }

  Future<int> deleteData(int id) async {
    final db = await database;
    return await db.delete(
      statusTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // New methods for forum posts
  Future<int> insertForumPost({
    required String username,
    String? avatar,
    String? title,
    required String content,
    required String date,
    String? image,
  }) async {
    final db = await database;

    // If an image is provided, copy it to documents directory
    String? processedImagePath;
    if (image != null) {
      final docsDirPath = (await getApplicationDocumentsDirectory()).path;
      final imageName = image.split("/").last;
      processedImagePath = '$docsDirPath/$imageName';

      final imageFile = File(image);
      if (await imageFile.exists()) {
        await imageFile.copy(processedImagePath);
      } else {
        processedImagePath = null;
      }
    }

    return await db.insert(
      forumPostTable,
      {
        columnUsername: username,
        columnAvatar: avatar,
        columnTitle: title,
        columnContent: content,
        columnPostDate: date,
        columnPostImage: processedImagePath,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getForumPosts() async {
    final db = await database;
    return await db.query(forumPostTable, orderBy: '$columnPostId DESC');
  }

  Future<int> deleteForumPost(int postId) async {
    final db = await database;
    return await db.delete(
      forumPostTable,
      where: '$columnPostId = ?',
      whereArgs: [postId],
    );
  }

  // New methods for replies
  Future<int> insertReply({
    required int postId,
    required String username,
    String? avatar,
    required String content,
    required String date,
  }) async {
    final db = await database;
    return await db.insert(
      repliesTable,
      {
        columnPostId: postId,
        columnReplyUsername: username,
        columnReplyAvatar: avatar ?? 'assets/default_avatar.png',
        columnReplyContent: content,
        columnReplyDate: date,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getRepliesForPost(int postId) async {
    final db = await database;
    return await db.query(
      repliesTable,
      where: '$columnPostId = ?',
      whereArgs: [postId],
      orderBy: '$columnReplyId ASC',
    );
  }

  Future<void> deleteRepliesForPost(int postId) async {
    final db = await database;
    await db.delete(
      repliesTable,
      where: '$columnPostId = ?',
      whereArgs: [postId],
    );
  }

  // Update deleteForumPost to cascade delete replies
  Future<void> deleteForumPostWithReplies(int postId) async {
    final db = await database;
    // First delete all replies for this post
    await deleteRepliesForPost(postId);
    // Then delete the post
    await db.delete(
      forumPostTable,
      where: 'post_id = ?',
      whereArgs: [postId],
    );
  }

}