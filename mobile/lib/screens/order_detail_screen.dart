import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';
import 'edit_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int bookingId;

  const OrderDetailScreen({super.key, required this.bookingId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Booking? booking;
  bool isLoading = true;
  String? errorMessage;
  bool isCancelling = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    loadBooking();
  }

  Future<void> loadBooking() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() {
        errorMessage = 'Session expired. Please log in again.';
        isLoading = false;
      });
      return;
    }

    try {
      final result = await ApiService.getOrder(token, widget.bookingId);
      if (!mounted) return;
      setState(() {
        booking = result;
        isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load order: $e';
        isLoading = false;
      });
    }
  }

  Future<void> cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'This action cannot be undone. Your order will be marked as cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final token = await AuthStorage.getToken();
    if (token == null) return;

    setState(() => isCancelling = true);

    try {
      final updated = await ApiService.cancelOrder(token, widget.bookingId);
      if (!mounted) return;
      setState(() {
        booking = updated;
        isCancelling = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => isCancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isCancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel: $e')),
      );
    }
  }

  Future<void> editOrder() async {
    final order = booking;
    if (order == null) return;

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditOrderScreen(booking: order)),
    );

    if (updated == true) {
      await loadBooking();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> deleteOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete order?'),
        content: const Text(
          'This permanently removes the cancelled order from your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final token = await AuthStorage.getToken();
    if (token == null) return;

    setState(() => isDeleting = true);

    try {
      await ApiService.deleteCancelledOrder(token, widget.bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order deleted.')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  String _formatSchedule(Booking order) {
    if (order.pickupDate == null && order.pickupTime == null) {
      return 'Not scheduled';
    }
    final date = order.pickupDate != null
        ? DateFormat.yMMMd().format(DateTime.parse(order.pickupDate!))
        : 'Date pending';
    if (order.pickupTime == null) return date;
    return '$date at ${formatPickupTime12h(order.pickupTime!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(booking?.bookingNumber ?? 'Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : loadBooking,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: loadBooking, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final order = booking!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusLabel(order.status),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Tracking code: ${order.trackingCode}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DetailSection(
            title: 'Customer',
            rows: [
              _DetailRow('Name', order.fullName),
              _DetailRow('Phone', order.phone),
              if (order.email != null) _DetailRow('Email', order.email!),
              _DetailRow('Address', order.address),
            ],
          ),
          _DetailSection(
            title: 'Schedule',
            rows: [
              _DetailRow('Pickup', _formatSchedule(order)),
              _DetailRow('Weight', '${order.weight} kg'),
              if (order.notes != null && order.notes!.isNotEmpty)
                _DetailRow('Notes', order.notes!),
            ],
          ),
          _DetailSection(
            title: 'Payment',
            rows: [
              _DetailRow('Total', 'PHP ${order.totalPrice.toStringAsFixed(2)}'),
              _DetailRow(
                'Method',
                order.paymentMethod?.toUpperCase() ?? 'CASH',
              ),
              if (order.payment != null)
                _DetailRow(
                  'Status',
                  order.payment!.paymentStatus.toUpperCase(),
                ),
            ],
          ),
          if (order.canEdit)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton.icon(
                onPressed: editOrder,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Order'),
              ),
            ),
          if (order.canCancel)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: OutlinedButton.icon(
                onPressed: isCancelling ? null : cancelOrder,
                icon: isCancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          if (order.canDelete)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: isDeleting ? null : deleteOrder,
                icon: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                label: const Text('Delete Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;

  const _DetailSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        row.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);
}
