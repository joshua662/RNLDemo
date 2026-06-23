import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';

class CreateOrderScreen extends StatefulWidget {
  final bool adminMode;

  const CreateOrderScreen({super.key, this.adminMode = false});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final weightController = TextEditingController(text: '8');
  final notesController = TextEditingController();
  DateTime? pickupDate;
  String? pickupTime;
  String customerType = 'pick_up';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillFromUser();
  }

  Future<void> _prefillFromUser() async {
    if (widget.adminMode) return;
    final user = await AuthStorage.getUser();
    if (user == null) return;
    fullNameController.text = user.name;
    if (user.phone != null) {
      phoneController.text = user.phone!;
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    weightController.dispose();
    notesController.dispose();
    super.dispose();
  }

  double get estimatedPrice {
    final weight = double.tryParse(weightController.text) ?? 0;
    return calculatePrice(weight);
  }

  Future<void> selectPickupDate() async {
    final today = DateTime.now();
    final chosen = await showDatePicker(
      context: context,
      initialDate: pickupDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (chosen != null) {
      setState(() => pickupDate = chosen);
    }
  }

  Future<void> createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await AuthStorage.getToken();
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in again.')),
      );
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final pickupDateValue = DateFormat('yyyy-MM-dd').format(pickupDate!);
      final notes = notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim();
      final email = emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim();

      if (!mounted) return;
      if (widget.adminMode) {
        final result = await ApiService.createAdminOrder(
          token: token,
          fullName: fullNameController.text.trim(),
          phone: phoneController.text.trim(),
          email: email,
          address: addressController.text.trim(),
          pickupDate: pickupDateValue,
          pickupTime: pickupTime!,
          weight: double.parse(weightController.text),
          notes: notes,
          customerType: customerType,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.message}\nTracking code: ${result.booking.trackingCode}',
            ),
          ),
        );
        Navigator.of(context).pop(true);
        return;
      }

      final result = await ApiService.createOrder(
        token: token,
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        pickupDate: pickupDateValue,
        pickupTime: pickupTime!,
        weight: double.parse(weightController.text),
        notes: notes,
        customerType: customerType,
      );
      final trackingInfo =
          result.trackingMessage ?? 'Tracking code: ${result.booking.trackingCode}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.message}\n$trackingInfo')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create order: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.adminMode ? 'Create Customer Order' : 'Create Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              if (widget.adminMode) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    return value.contains('@') ? null : 'Enter a valid email';
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: customerType,
                decoration: const InputDecoration(
                  labelText: 'Customer Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pick_up', child: Text('Pick-up')),
                  DropdownMenuItem(value: 'walk_in', child: Text('Walk-in')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => customerType = value);
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: selectPickupDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Pickup Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    pickupDate == null
                        ? 'Select date'
                        : DateFormat.yMMMd().format(pickupDate!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: pickupTime,
                decoration: const InputDecoration(
                  labelText: 'Pickup Time',
                  border: OutlineInputBorder(),
                ),
                items: pickupTimeSlots
                    .map(
                      (slot) => DropdownMenuItem(
                        value: slot,
                        child: Text(formatPickupTime12h(slot)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => pickupTime = value),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                  helperText: 'Base price PHP 99 for up to 8 kg, PHP 12/kg after',
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final weight = double.tryParse(value ?? '');
                  if (weight == null || weight <= 0 || weight > 100) {
                    return 'Enter a valid weight from 0 to 100 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Estimated total: PHP ${estimatedPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton(
                      onPressed: () {
                        if (pickupDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Select a pickup date.')),
                          );
                          return;
                        }
                        createOrder();
                      },
                      child: const Text('Submit Order'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
