import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/item_model.dart';
import '../services/storage_service.dart';

class _DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final regExp = RegExp(r'^\d*\.?\d{0,2}$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTime? _selectedDate;

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _selectedDate != null &&
        double.tryParse(_priceController.text) != null;
  }

  void _showDatePicker() {
    if (Platform.isAndroid) {
      _showMaterialDatePicker();
    } else {
      _showCupertinoDatePicker();
    }
  }

  void _showCupertinoDatePicker() {
    // Create a single DateTime instance to avoid millisecond differences
    final now = DateTime.now();
    // Truncate to the start of the day for date-only mode
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = _selectedDate ?? today;
    // Ensure initialDate is not before today
    final safeInitialDate = initialDate.isBefore(today) ? today : initialDate;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: AppColors.dark,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Done',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: safeInitialDate,
                maximumDate: today.add(const Duration(days: 365)),
                minimumDate: today,
                onDateTimeChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMaterialDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.dark,
              onSurface: AppColors.white,
            ),
            dialogBackgroundColor: AppColors.dark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _onSave() async {
    final item = ItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      date: _selectedDate!,
      createdAt: DateTime.now(),
      status: ItemStatus.pending,
    );
    final storage = await StorageService.getInstance();
    await storage.addItem(item);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Row(
                        children: [
                          Icon(
                            CupertinoIcons.back,
                            color: AppColors.white,
                            size: 24,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Add item',
                            style: TextStyle(
                              fontSize: 17,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/app_ic_add.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    CupertinoTextField(
                      controller: _nameController,
                      placeholder: 'Item name',
                      placeholderStyle: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.5),
                      ),
                      style: const TextStyle(color: AppColors.white),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    CupertinoTextField(
                      controller: _priceController,
                      placeholder: 'Price',
                      placeholderStyle: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.5),
                      ),
                      style: const TextStyle(color: AppColors.white),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                        _DecimalTextInputFormatter(),
                      ],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showDatePicker,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(_selectedDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: _selectedDate != null
                                      ? AppColors.white
                                      : AppColors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            Icon(
                              CupertinoIcons.calendar,
                              color: AppColors.white.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_isFormValid)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _onSave,
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
