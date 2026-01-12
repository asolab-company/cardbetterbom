import 'package:flutter/cupertino.dart';
import '../constants/app_constants.dart';
import '../models/item_model.dart';
import '../services/storage_service.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double _savedAmount = 0.00;
  List<ItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = await StorageService.getInstance();
    final items = await storage.getItems();
    final savedAmount = await storage.getSavedAmount();
    setState(() {
      _items = items;
      _savedAmount = savedAmount;
    });
  }

  List<ItemModel> get _pendingItems =>
      _items.where((item) => item.isPending).toList();

  List<ItemModel> get _completedItems =>
      _items.where((item) => !item.isPending).toList();

  Future<void> _openSettings() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const SettingsScreen()));
    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _openAddItem() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const AddItemScreen()));
    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _onBuyItem(ItemModel item) async {
    final storage = await StorageService.getInstance();
    final updatedItem = item.copyWith(
      status: ItemStatus.purchased,
      completedAt: DateTime.now(),
    );
    await storage.updateItem(updatedItem);
    await _loadData();
  }

  Future<void> _onSkipItem(ItemModel item) async {
    final storage = await StorageService.getInstance();
    final updatedItem = item.copyWith(
      status: ItemStatus.skipped,
      completedAt: DateTime.now(),
    );
    await storage.updateItem(updatedItem);
    await storage.addToSavedAmount(item.price);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageWidth = screenWidth * 0.55;
    final imageHeight = screenHeight * 0.43;
    final topMargin = screenHeight * 0.005;
    final leftMargin = screenWidth * 0.06;
    final boxTop = topMargin + imageHeight * 0.45;

    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _openSettings,
                      child: const Icon(
                        CupertinoIcons.settings,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: imageHeight + topMargin + 10,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: boxTop,
                      left: leftMargin + imageWidth * 0.3,
                      right: screenWidth * 0.06,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1F1F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: Text(
                          '\$${_savedAmount.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: '.SF Pro Display',
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            height: 1.0,
                            letterSpacing: 0,
                            color: AppColors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: topMargin,
                      left: leftMargin,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_ic_woman.png',
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: topMargin + imageHeight - 120,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.4, 1.0],
                            colors: [
                              const Color(0xFF1A1A1A).withValues(alpha: 0),
                              const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                              const Color(0xFF1A1A1A),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: boxTop - 44,
                      right: screenWidth * 0.075,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: '.SF Pro Display',
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                height: 0.8,
                                letterSpacing: 0,
                                decoration: TextDecoration.none,
                              ),
                              children: [
                                TextSpan(
                                  text: 'YOU ',
                                  style: TextStyle(color: AppColors.white),
                                ),
                                TextSpan(
                                  text: 'SAVED',
                                  style: TextStyle(color: AppColors.accent),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            right: 14,
                            child: Image.asset(
                              'assets/images/Vector 3.png',
                              width: 56,
                              height: 12,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    children: [
                      TextSpan(text: 'Pause. Reflect. '),
                      TextSpan(
                        text: 'Spend smarter.',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _openAddItem,
                    child: const Text(
                      'ADD ITEM',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              if (_items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    'Items you\'re currently reviewing. Come back after 24 hours to make a final choice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              Expanded(
                child: _items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.cube_box,
                                size: 64,
                                color: AppColors.white.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No pending items. Add your first item to start controlling impulse purchases.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount:
                            _pendingItems.length +
                            (_completedItems.isNotEmpty
                                ? _completedItems.length + 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index < _pendingItems.length) {
                            final item = _pendingItems[index];
                            return PendingItemCard(
                              item: item,
                              onBuy: () => _onBuyItem(item),
                              onSkip: () => _onSkipItem(item),
                            );
                          }
                          final completedIndex =
                              index - _pendingItems.length - 1;
                          if (completedIndex == -1) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 8,
                              ),
                              child: Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            );
                          }
                          final item = _completedItems[completedIndex];
                          return CompletedItemCard(item: item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
