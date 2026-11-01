import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class InvoiceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Invoice>> getAllInvoices() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, c.name as customer_name
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      ORDER BY i.created_at DESC
    ''');
    return List.generate(maps.length, (i) => Invoice.fromMap(maps[i]));
  }

  Future<Invoice?> getInvoiceById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT i.*, c.name as customer_name
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.id = ?
    ''',
      [id],
    );
    if (maps.isNotEmpty) {
      Invoice invoice = Invoice.fromMap(maps.first);
      invoice.items = await getInvoiceItems(invoice.id!);
      return invoice;
    }
    return null;
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT ii.*, p.name as product_name
      FROM invoice_items ii
      JOIN products p ON ii.product_id = p.id
      WHERE ii.invoice_id = ?
    ''',
      [invoiceId],
    );
    return List.generate(maps.length, (i) => InvoiceItem.fromMap(maps[i]));
  }

  Future<String> generateInvoiceNumber() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM invoices 
      WHERE strftime('%Y%m%d', created_at) = ?
    ''',
      [dateStr],
    );
    final count = result.first['count'] as int;
    return 'INV$dateStr${(count + 1).toString().padLeft(4, '0')}';
  }

  Future<int> insertInvoice(Invoice invoice) async {
    final db = await _dbHelper.database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<void> insertInvoiceItems(List<InvoiceItem> items) async {
    final db = await _dbHelper.database;
    Batch batch = db.batch();
    for (var item in items) {
      batch.insert('invoice_items', item.toMap());
    }
    await batch.commit();
  }

  Future<int> updateInvoice(Invoice invoice) async {
    final db = await _dbHelper.database;
    return await db.update(
      'invoices',
      invoice.toMap(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> deleteInvoice(int id) async {
    final db = await _dbHelper.database;
    await db.delete('invoice_items', where: 'invoice_id = ?', whereArgs: [id]);
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalSales({String? period}) async {
    final db = await _dbHelper.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (period != null) {
      switch (period) {
        case 'today':
          whereClause = "WHERE date(created_at) = date('now')";
          break;
        case 'month':
          whereClause =
              "WHERE strftime('%Y-%m', created_at) = strftime('%Y-%m', 'now')";
          break;
        case 'year':
          whereClause =
              "WHERE strftime('%Y', created_at) = strftime('%Y', 'now')";
          break;
      }
    }

    final result = await db.rawQuery(
      'SELECT SUM(grand_total) as total FROM invoices $whereClause',
      whereArgs,
    );
    return result.first['total'] as double? ?? 0.0;
  }

  /// Fetch invoices for the current month
  Future<List<Invoice>> getMonthlyInvoices() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, c.name as customer_name
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE strftime('%Y-%m', i.created_at) = strftime('%Y-%m', 'now')
      ORDER BY i.created_at DESC
    ''');
    return List.generate(maps.length, (i) => Invoice.fromMap(maps[i]));
  }

  /// Fetch invoices for a specific month and year
  Future<List<Invoice>> getInvoicesByMonthYear(
      {required int month, required int year}) async {
    final db = await _dbHelper.database;
    final monthStr = month.toString().padLeft(2, '0');
    final yearMonthStr = '$year-$monthStr';

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, c.name as customer_name
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE strftime('%Y-%m', i.created_at) = ?
      ORDER BY i.created_at DESC
    ''', [yearMonthStr]);

    return List.generate(maps.length, (i) => Invoice.fromMap(maps[i]));
  }
}
