import '../database/database_helper.dart';
import '../models/supplier.dart';

class SupplierRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Supplier>> getAllSuppliers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'suppliers',
      orderBy: 'name',
    );
    return List.generate(maps.length, (i) => Supplier.fromMap(maps[i]));
  }

  Future<Supplier?> getSupplierById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Supplier.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertSupplier(Supplier supplier) async {
    final db = await _dbHelper.database;
    return await db.insert('suppliers', supplier.toMap());
  }

  Future<int> updateSupplier(Supplier supplier) async {
    final db = await _dbHelper.database;
    return await db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }
}
