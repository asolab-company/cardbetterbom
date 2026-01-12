import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';

class StorageService {
  static const String _itemsKey = 'items';
  static const String _savedAmountKey = 'saved_amount';

  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<List<ItemModel>> getItems() async {
    final jsonString = _prefs?.getString(_itemsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => ItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveItems(List<ItemModel> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    await _prefs?.setString(_itemsKey, jsonEncode(jsonList));
  }

  Future<void> addItem(ItemModel item) async {
    final items = await getItems();
    items.add(item);
    await saveItems(items);
  }

  Future<void> updateItem(ItemModel updatedItem) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      await saveItems(items);
    }
  }

  Future<void> deleteItem(String id) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == id);
    await saveItems(items);
  }

  Future<double> getSavedAmount() async {
    return _prefs?.getDouble(_savedAmountKey) ?? 0.0;
  }

  Future<void> setSavedAmount(double amount) async {
    await _prefs?.setDouble(_savedAmountKey, amount);
  }

  Future<void> addToSavedAmount(double amount) async {
    final current = await getSavedAmount();
    await setSavedAmount(current + amount);
  }
}
