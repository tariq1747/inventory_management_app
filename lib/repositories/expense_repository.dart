import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Expense>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByPeriod(String period) async {
    final db = await _dbHelper.database;
    String whereClause = '';

    switch (period) {
      case 'today':
        whereClause = "WHERE date(date) = date('now')";
        break;
      case 'month':
        whereClause =
            "WHERE strftime('%Y-%m', date) = strftime('%Y-%m', 'now')";
        break;
      case 'year':
        whereClause = "WHERE strftime('%Y', date) = strftime('%Y', 'now')";
        break;
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM expenses $whereClause ORDER BY date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpenses({String? period}) async {
    final db = await _dbHelper.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (period != null) {
      switch (period) {
        case 'today':
          whereClause = "WHERE date(date) = date('now')";
          break;
        case 'month':
          whereClause =
              "WHERE strftime('%Y-%m', date) = strftime('%Y-%m', 'now')";
          break;
        case 'year':
          whereClause = "WHERE strftime('%Y', date) = strftime('%Y', 'now')";
          break;
      }
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses $whereClause',
      whereArgs,
    );
    return result.first['total'] as double? ?? 0.0;
  }
}
