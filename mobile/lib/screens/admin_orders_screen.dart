import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';
import 'create_order_screen.dart';
import 'order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  final bool embedded;

  const AdminOrdersScreen({super.key, this.embedded = false});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final searchController = TextEditingController();
  List<Booking> orders = [];
  bool isLoading = true;
  String? errorMessage;
  String? selectedStatus;
  int? updatingOrderId;

  static const adminStatuses = [
    'pending',
    'confirmed',
    'pickup_scheduled',
    'picked_up',
    'washing',
    'drying',
    'folding',
    'out_for_delivery',
    'delivered',
    'done',
    'cancelled',
  ];

  static const finishedStatuses = ['done', 'delivered', 'cancelled'];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() {
        errorMessage = 'Session expired. Please sign in again.';
        isLoading = false;
      });
      return;
    }

    try {
      final result = await ApiService.getAdminOrders(
        token,
        status: selectedStatus,
        search: searchController.text.trim(),
      );
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

  void _applyStatusFilter(String? status) {
    setState(() {
      selectedStatus = status != null && adminStatuses.contains(status)
          ? status
          : null;
    });
    loadOrders();
  }

  Future<void> _openCreateOrder() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreateOrderScreen(adminMode: true),
      ),
    );

    if (created == true) {
      _applyStatusFilter(null);
    }
  }

  void _openDeletedOrders() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdminDeletedOrdersScreen(),
      ),
    );
  }

  Future<void> _updateStatus(Booking order, String status) async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    setState(() => updatingOrderId = order.id);
    try {
      final updated = await ApiService.updateAdminOrderStatus(
        token: token,
        id: order.id,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        orders = orders
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
        updatingOrderId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order updated to ${statusLabel(status)}.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => updatingOrderId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => updatingOrderId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
    }
  }

  Future<void> _markDone(Booking order) async {
    if (order.isDone || order.status == 'done' || order.status == 'delivered') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This order is already done.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark order done?'),
        content: Text('Mark ${order.bookingNumber} as finished?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark done'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = await AuthStorage.getToken();
    if (token == null) return;

    setState(() => updatingOrderId = order.id);
    try {
      final updated = await ApiService.markAdminOrderDone(token, order.id);
      if (!mounted) return;
      setState(() {
        orders = orders
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
        updatingOrderId = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order marked as done.')));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => updatingOrderId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => updatingOrderId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to mark done: $e')));
    }
  }

  Future<void> _cancelOrder(Booking order) async {
    if (finishedStatuses.contains(order.status) || order.isDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Finished or cancelled orders cannot be cancelled.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: Text('Cancel ${order.bookingNumber} and notify the customer?'),
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

    setState(() => updatingOrderId = order.id);
    try {
      final updated = await ApiService.cancelAdminOrder(token, order.id);
      if (!mounted) return;
      setState(() {
        orders = orders
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
        updatingOrderId = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order cancelled.')));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => updatingOrderId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => updatingOrderId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
    }
  }

  Future<void> _deleteOrder(Booking order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete order?'),
        content: Text(
          'Move ${order.bookingNumber} to the deleted orders bin?\n\nYou can recover it later from "Deleted Orders".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = await AuthStorage.getToken();
    if (token == null) return;

    setState(() => updatingOrderId = order.id);
    try {
      await ApiService.adminTrashOrder(token, order.id);
      if (!mounted) return;
      setState(() {
        orders = orders.where((item) => item.id != order.id).toList();
        updatingOrderId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order deleted. You can recover it from Deleted Orders.'),
          action: SnackBarAction(
            label: 'View Deleted',
            onPressed: _openDeletedOrders,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => updatingOrderId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => updatingOrderId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete order: $e')));
    }
  }

  String _scheduleLabel(Booking order) {
    if (order.pickupDate == null) return 'No pickup date';
    final date = DateFormat.yMMMd().format(DateTime.parse(order.pickupDate!));
    if (order.pickupTime == null) return date;
    return '$date, ${formatPickupTime12h(order.pickupTime!)}';
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search orders',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: loadOrders,
              ),
            ),
            onSubmitted: (_) => loadOrders(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openCreateOrder,
              icon: const Icon(Icons.add),
              label: const Text('Create Order'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String?>(
                  initialValue: adminStatuses.contains(selectedStatus)
                      ? selectedStatus
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Status filter',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All statuses'),
                    ),
                    ...adminStatuses.map(
                      (status) => DropdownMenuItem<String?>(
                        value: status,
                        child: Text(statusLabel(status)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    _applyStatusFilter(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusFilterButton(
                  label: 'Done',
                  icon: Icons.check_circle_outline,
                  selected:
                      selectedStatus == 'done' || selectedStatus == 'delivered',
                  onPressed: () => _applyStatusFilter('delivered'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusFilterButton(
                  label: 'Cancelled',
                  icon: Icons.cancel_outlined,
                  selected: selectedStatus == 'cancelled',
                  onPressed: () => _applyStatusFilter('cancelled'),
                  danger: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusFilterButton(
                  label: 'Deleted',
                  icon: Icons.delete_outline,
                  selected: false,
                  onPressed: _openDeletedOrders,
                  danger: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Text(errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: loadOrders, child: const Text('Retry')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        itemCount: orders.length + 1,
        separatorBuilder: (_, index) =>
            index == 0 ? const SizedBox.shrink() : const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) return _buildFilters();
          final order = orders[index - 1];
          final isUpdating = updatingOrderId == order.id;
          final canMarkDone =
              !isUpdating &&
              !order.isDone &&
              order.status != 'done' &&
              order.status != 'delivered' &&
              order.status != 'cancelled';
          final canCancel =
              !isUpdating &&
              !order.isDone &&
              !finishedStatuses.contains(order.status);
          final color = statusColor(order.status);

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.bookingNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(order.fullName),
                            Text(
                              _scheduleLabel(order),
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(statusLabel(order.status)),
                        backgroundColor: color.withValues(alpha: 0.12),
                        labelStyle: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: adminStatuses.contains(order.status)
                        ? order.status
                        : 'pending',
                    decoration: const InputDecoration(
                      labelText: 'Update status',
                      prefixIcon: Icon(Icons.sync_alt),
                    ),
                    items: adminStatuses
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(statusLabel(status)),
                          ),
                        )
                        .toList(),
                    onChanged: isUpdating
                        ? null
                        : (value) {
                            if (value != null && value != order.status) {
                              _updateStatus(order, value);
                            }
                          },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: isUpdating
                            ? null
                            : () async {
                                final updated = await Navigator.of(context)
                                    .push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailScreen(
                                          bookingId: order.id,
                                        ),
                                      ),
                                    );
                                if (updated == true) loadOrders();
                              },
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('View'),
                      ),
                      FilledButton.icon(
                        onPressed: canMarkDone ? () => _markDone(order) : null,
                        icon: isUpdating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: const Text('Done'),
                      ),
                      OutlinedButton.icon(
                        onPressed: canCancel ? () => _cancelOrder(order) : null,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: isUpdating ? null : () => _deleteOrder(order),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody();
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateOrder,
        icon: const Icon(Icons.add),
        label: const Text('Create Order'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Deleted Orders Screen
// ---------------------------------------------------------------------------

class AdminDeletedOrdersScreen extends StatefulWidget {
  const AdminDeletedOrdersScreen({super.key});

  @override
  State<AdminDeletedOrdersScreen> createState() =>
      _AdminDeletedOrdersScreenState();
}

class _AdminDeletedOrdersScreenState extends State<AdminDeletedOrdersScreen> {
  List<Booking> deletedOrders = [];
  bool isLoading = true;
  String? errorMessage;
  Set<int> _selectedIds = {};
  bool _isBatchProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadDeleted();
  }

  Future<void> _loadDeleted() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() {
        errorMessage = 'Session expired.';
        isLoading = false;
      });
      return;
    }

    try {
      final result = await ApiService.getAdminTrashedOrders(token);
      if (!mounted) return;
      setState(() {
        deletedOrders = result;
        _selectedIds.clear();
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
        errorMessage = 'Failed to load deleted orders: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _restoreOrder(Booking order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore order?'),
        content: Text(
          'Restore ${order.bookingNumber} back to active orders?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = await AuthStorage.getToken();
    if (token == null) return;

    try {
      await ApiService.adminRestoreOrder(token, order.id);
      if (!mounted) return;
      setState(() {
        deletedOrders = deletedOrders.where((o) => o.id != order.id).toList();
        _selectedIds.remove(order.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order restored successfully.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to restore: $e')));
    }
  }

  Future<void> _permanentDelete(Booking order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently delete?'),
        content: Text(
          'This will permanently delete ${order.bookingNumber}.\n\n⚠️ This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = await AuthStorage.getToken();
    if (token == null) return;

    try {
      await ApiService.adminPermanentDeleteOrder(token, order.id);
      if (!mounted) return;
      setState(() {
        deletedOrders = deletedOrders.where((o) => o.id != order.id).toList();
        _selectedIds.remove(order.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order permanently deleted.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to permanently delete: $e')));
    }
  }

  Future<void> _restoreSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore selected orders?'),
        content: Text(
          'Restore ${_selectedIds.length} orders back to active orders?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = await AuthStorage.getToken();
    if (token == null) return;

    setState(() => _isBatchProcessing = true);
    try {
      final idsList = _selectedIds.toList();
      await ApiService.adminBatchRestoreOrders(token, idsList);
      if (!mounted) return;
      setState(() {
        deletedOrders = deletedOrders.where((o) => !_selectedIds.contains(o.id)).toList();
        _selectedIds.clear();
        _isBatchProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected orders restored successfully.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isBatchProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBatchProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to restore: $e')));
    }
  }

  Future<void> _permanentDeleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently delete selected?'),
        content: Text(
          'This will permanently delete ${_selectedIds.length} selected orders.\n\n⚠️ This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = await AuthStorage.getToken();
    if (token == null) return;

    setState(() => _isBatchProcessing = true);
    try {
      final idsList = _selectedIds.toList();
      await ApiService.adminBatchPermanentDeleteOrders(token, idsList);
      if (!mounted) return;
      setState(() {
        deletedOrders = deletedOrders.where((o) => !_selectedIds.contains(o.id)).toList();
        _selectedIds.clear();
        _isBatchProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected orders permanently deleted.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isBatchProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBatchProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deleted Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeleted,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _loadDeleted, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (deletedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No deleted orders',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Deleted orders will appear here so you can recover them.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final allSelected = deletedOrders.isNotEmpty && _selectedIds.length == deletedOrders.length;

    return Column(
      children: [
        if (_isBatchProcessing) const LinearProgressIndicator(),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Checkbox(
                value: allSelected,
                activeColor: AppColors.navy,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedIds = deletedOrders.map((o) => o.id).toSet();
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              const Text(
                'Select All',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const Spacer(),
              if (_selectedIds.isNotEmpty) ...[
                TextButton.icon(
                  onPressed: _isBatchProcessing ? null : _restoreSelected,
                  icon: const Icon(Icons.restore, size: 16),
                  label: Text('Restore (${_selectedIds.length})'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _isBatchProcessing ? null : _permanentDeleteSelected,
                  icon: const Icon(Icons.delete_forever, size: 16),
                  label: const Text('Delete Forever'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDeleted,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: deletedOrders.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = deletedOrders[index];
                final isSelected = _selectedIds.contains(order.id);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.navy : Colors.red.shade100,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: AppColors.navy,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedIds.add(order.id);
                                  } else {
                                    _selectedIds.remove(order.id);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.bookingNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(order.fullName),
                                  Text(
                                    statusLabel(order.status),
                                    style: TextStyle(
                                      color: statusColor(order.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 14,
                                    color: Colors.red.shade400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Deleted',
                                    style: TextStyle(
                                      color: Colors.red.shade400,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isBatchProcessing ? null : () => _restoreOrder(order),
                                icon: const Icon(Icons.restore, size: 18),
                                label: const Text('Recover'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.navy,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isBatchProcessing ? null : () => _permanentDelete(order),
                                icon: const Icon(Icons.delete_forever, size: 18),
                                label: const Text('Delete Forever'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared filter button widget
// ---------------------------------------------------------------------------

class _StatusFilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool danger;
  final VoidCallback onPressed;

  const _StatusFilterButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : AppColors.navy;

    if (selected) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(foregroundColor: color),
    );
  }
}
