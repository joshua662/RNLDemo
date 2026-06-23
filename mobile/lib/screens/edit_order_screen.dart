import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';

class EditOrderScreen extends StatefulWidget {
  final Booking booking;

  const EditOrderScreen({super.key, required this.booking});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController weightController;
  late final TextEditingController notesController;
  DateTime? pickupDate;
  String? pickupTime;
  late String customerType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final order = widget.booking;
    fullNameController = TextEditingController(text: order.fullName);
    phoneController = TextEditingController(text: order.phone);
    addressController = TextEditingController(text: order.address);
    weightController = TextEditingController(text: order.weight.toString());
    notesController = TextEditingController(text: order.notes ?? '');
    pickupDate =
        order.pickupDate == null ? null : DateTime.tryParse(order.pickupDate!);
    pickupTime = order.pickupTime;
    customerType = order.customerType ?? 'pick_up';
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
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
    final initialDate = pickupDate != null && pickupDate!.isAfter(today)
        ? pickupDate!
        : today;
    final chosen = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (chosen != null) {
      setState(() => pickupDate = chosen);
    }
  }

  Future<void> updateOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (pickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a pickup date.')),
      );
      return;
    }

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
      await ApiService.updateOrder(
        token: token,
        id: widget.booking.id,
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        pickupDate: DateFormat('yyyy-MM-dd').format(pickupDate!),
        pickupTime: pickupTime!,
        weight: double.parse(weightController.text),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        customerType: customerType,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order updated.')),
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
        SnackBar(content: Text('Failed to update order: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.booking.bookingNumber}')),
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
                  : FilledButton.icon(
                      onPressed: updateOrder,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
