import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';
import 'create_order_screen.dart';
import 'login_screen.dart';
import 'order_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool embedded;

  const HomeScreen({super.key, this.embedded = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Booking> orders = [];
  bool isLoading = true;
  String? errorMessage;
  String? token;
  User? user;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    token = await AuthStorage.getToken();
    user = await AuthStorage.getUser();

    if (token == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      final result = await ApiService.getOrders(token!);
      if (!mounted) return;
      setState(() {
        orders = result;
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
        errorMessage = 'Failed to load orders: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _openCreateOrder() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
    );
    if (created == true) {
      loadOrders();
    }
  }

  Widget _buildBody() {
    if (isLoading) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Center(
            child: FilledButton(
              onPressed: loadOrders,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (orders.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.muted),
          const SizedBox(height: 16),
          const Text(
            'No orders yet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "New Order" to schedule your first pickup.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final order = orders[index];
        final dateLabel = order.pickupDate != null
            ? DateFormat.yMMMd().format(DateTime.parse(order.pickupDate!))
            : 'Not scheduled';
        final color = statusColor(order.status);

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              order.bookingNumber,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Pickup: $dateLabel'),
                Text('Total: PHP ${order.totalPrice.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Chip(
                  label: Text(statusLabel(order.status)),
                  backgroundColor: color.withValues(alpha: 0.12),
                  labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(bookingId: order.id),
                ),
              );
              if (updated == true) {
                loadOrders();
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: loadOrders,
      color: AppColors.sky,
      child: _buildBody(),
    );

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openCreateOrder,
          icon: const Icon(Icons.add),
          label: const Text('New Order'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(user?.name ?? businessName)),
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateOrder,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
}
