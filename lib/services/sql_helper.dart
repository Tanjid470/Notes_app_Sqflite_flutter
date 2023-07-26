import 'package:sqflite/sqflite.dart' as sql;

class SqlHalper {
  static Future<void> createTables(sql.Database database) async {
    //Creating Database Table
    await database.execute(""" CREATE TABLE items(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    description TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

    )""");
  }

  static Future<sql.Database> db() async {
    //If database not exist then first create it new database
    return sql.openDatabase("database_neme.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int> createItem(String title, String? description) async {
    //Open database connection
    // db is an object of database
    final db = await SqlHalper.db();
    //Put our data in Map format
    final data = {'title': title, 'description': description};
    // insert(table_name,data in map format)
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    //conflicAlgorithm help to reduce duplicate

    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllItem() async {
    final db = await SqlHalper.db();
    // query use to get itemdescription
    return db.query('items', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleItem(int id) async {
    final db = await SqlHalper.db();

    return db.query('items', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SqlHalper.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString()
    };

    final result = await db.update('items', data,
        where: "id =?",
        whereArgs: [id],
       // conflictAlgorithm: sql.ConflictAlgorithm.replace
        );

    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SqlHalper.db();

    try {
      await db.delete('items', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print(e);
    }
  }
}
