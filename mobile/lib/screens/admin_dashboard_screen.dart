import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  final bool embedded;

  const AdminDashboardScreen({super.key, this.embedded = false});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? dashboard;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
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
      final result = await ApiService.getAdminDashboard(token);
      if (!mounted) return;
      setState(() {
        dashboard = result;
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
        errorMessage = 'Failed to load dashboard: $e';
        isLoading = false;
      });
    }
  }

  num _stat(String key) {
    final stats = dashboard?['stats'];
    if (stats is Map<String, dynamic>) {
      final value = stats[key];
      if (value is num) return value;
      return num.tryParse(value?.toString() ?? '') ?? 0;
    }
    return 0;
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
          FilledButton(onPressed: loadDashboard, child: const Text('Retry')),
        ],
      );
    }

    final breakdown = dashboard?['status_breakdown'];
    final statusBreakdown =
        breakdown is Map<String, dynamic> ? breakdown : <String, dynamic>{};

    return RefreshIndicator(
      onRefresh: loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 720 ? 4 : 2,
            childAspectRatio: 1.45,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _MetricCard(
                label: 'Orders',
                value: _stat('total_orders').toStringAsFixed(0),
                icon: Icons.receipt_long,
              ),
              _MetricCard(
                label: 'Pending',
                value: _stat('pending_orders').toStringAsFixed(0),
                icon: Icons.pending_actions,
              ),
              _MetricCard(
                label: 'Customers',
                value: _stat('total_customers').toStringAsFixed(0),
                icon: Icons.people,
              ),
              _MetricCard(
                label: 'Revenue',
                value: 'PHP ${_stat('total_revenue').toStringAsFixed(0)}',
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workflow',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const _WorkflowStep(
                    icon: Icons.person_add_alt,
                    title: 'Customer books',
                    subtitle: 'A customer creates an order from mobile or web.',
                  ),
                  const _WorkflowStep(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin manages',
                    subtitle: 'Admin confirms, updates status, and assigns rider.',
                  ),
                  const _WorkflowStep(
                    icon: Icons.notifications_active_outlined,
                    title: 'Customer tracks',
                    subtitle: 'The same booking updates in customer tracking.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Breakdown',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (statusBreakdown.isEmpty)
                    const Text('No status data yet.')
                  else
                    ...statusBreakdown.entries.map((entry) {
                      final count = num.tryParse(entry.value.toString()) ?? 0;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor:
                              statusColor(entry.key).withValues(alpha: 0.12),
                          child: Icon(
                            Icons.circle,
                            color: statusColor(entry.key),
                            size: 14,
                          ),
                        ),
                        title: Text(statusLabel(entry.key)),
                        trailing: Text(count.toStringAsFixed(0)),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: _buildBody(),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.navy),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
            ),
            Text(label, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _WorkflowStep({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.skyLight,
        child: Icon(icon, color: AppColors.navy),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
