import '../database/database_helper.dart';
import '../models/stock_movement.dart';

class StockMovementRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<StockMovement>> getAllStockMovements() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT sm.*, p.name as product_name
      FROM stock_movements sm
      JOIN products p ON sm.product_id = p.id
      ORDER BY sm.created_at DESC
    ''');
    return List.generate(maps.length, (i) => StockMovement.fromMap(maps[i]));
  }

  Future<List<StockMovement>> getStockMovementsByProduct(int productId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT sm.*, p.name as product_name
      FROM stock_movements sm
      JOIN products p ON sm.product_id = p.id
      WHERE sm.product_id = ?
      ORDER BY sm.created_at DESC
    ''',
      [productId],
    );
    return List.generate(maps.length, (i) => StockMovement.fromMap(maps[i]));
  }

  Future<int> insertStockMovement(StockMovement movement) async {
    final db = await _dbHelper.database;
    return await db.insert('stock_movements', movement.toMap());
  }

  Future<void> recordStockIn(int productId, int quantity, String reason) async {
    final movement = StockMovement(
      productId: productId,
      type: 'in',
      quantity: quantity,
      reason: reason,
      createdAt: DateTime.now().toString(),
    );
    await insertStockMovement(movement);
  }

  Future<void> recordStockOut(
    int productId,
    int quantity,
    String reason,
  ) async {
    final movement = StockMovement(
      productId: productId,
      type: 'out',
      quantity: quantity,
      createdAt: DateTime.now().toString(),
      reason: reason,
    );
    await insertStockMovement(movement);
  }
}
