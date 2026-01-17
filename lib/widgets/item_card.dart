import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/item_model.dart';

class PendingItemCard extends StatefulWidget {
  final ItemModel item;
  final VoidCallback onBuy;
  final VoidCallback onSkip;

  const PendingItemCard({
    super.key,
    required this.item,
    required this.onBuy,
    required this.onSkip,
  });

  @override
  State<PendingItemCard> createState() => _PendingItemCardState();
}

class _PendingItemCardState extends State<PendingItemCard> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    setState(() {
      _timeRemaining = widget.item.timeRemaining;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final is24HoursElapsed = widget.item.is24HoursElapsed;

    return Dismissible(
      key: Key(widget.item.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Row(
          children: [
            Icon(CupertinoIcons.cart_fill, color: AppColors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'BUY',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'SKIP',
              style: TextStyle(
                color: AppColors.dark,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.dark,
              size: 28,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          widget.onBuy();
        } else if (direction == DismissDirection.endToStart) {
          widget.onSkip();
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
                children: [
                  TextSpan(text: '${widget.item.name} '),
                  TextSpan(
                    text: '\$${widget.item.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: widget.onBuy, minimumSize: Size(0, 0),
                    child: const Text(
                      'BUY',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: widget.onSkip, minimumSize: Size(0, 0),
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  CupertinoIcons.bell_fill,
                  size: 20,
                  color: is24HoursElapsed
                      ? AppColors.accent
                      : AppColors.white.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_timeRemaining),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: is24HoursElapsed
                        ? AppColors.accent
                        : AppColors.white.withValues(alpha: 0.7),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedItemCard extends StatelessWidget {
  final ItemModel item;

  const CompletedItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateStr = item.completedAt != null
        ? DateFormat('MMM dd, yyyy').format(item.completedAt!)
        : '';
    final isSkipped = item.isSkipped;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSkipped ? 'Not purchased $dateStr' : 'Purchased $dateStr',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.6),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
              children: [
                TextSpan(text: isSkipped ? 'You saved: ' : 'For '),
                TextSpan(
                  text: '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
