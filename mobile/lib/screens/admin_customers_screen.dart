import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';

class AdminCustomersScreen extends StatefulWidget {
  final bool embedded;

  const AdminCustomersScreen({super.key, this.embedded = false});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final searchController = TextEditingController();
  List<User> customers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadCustomers() async {
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
      final result = await ApiService.getAdminCustomers(
        token,
        search: searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        customers = result;
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
        errorMessage = 'Failed to load customers: $e';
        isLoading = false;
      });
    }
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
          FilledButton(onPressed: loadCustomers, child: const Text('Retry')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: loadCustomers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: customers.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search customers',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: loadCustomers,
                ),
              ),
              onSubmitted: (_) => loadCustomers(),
            );
          }

          final customer = customers[index - 1];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: AppColors.skyLight,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(customer.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.email),
                  if (customer.phone != null && customer.phone!.isNotEmpty)
                    Text(customer.phone!),
                ],
              ),
              trailing: const Icon(Icons.person_outline),
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
      appBar: AppBar(title: const Text('Customers')),
      body: _buildBody(),
    );
  }
}
