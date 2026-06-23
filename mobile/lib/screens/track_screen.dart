import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class TrackScreen extends StatefulWidget {
  final bool embedded;

  const TrackScreen({super.key, this.embedded = false});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final trackingController = TextEditingController();
  Booking? booking;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    trackingController.dispose();
    super.dispose();
  }

  Future<void> trackOrder() async {
    final code = trackingController.text.trim();
    if (code.isEmpty) {
      setState(() => errorMessage = 'Enter a tracking code.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      booking = null;
    });

    try {
      final result = await ApiService.trackOrder(code);
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
        errorMessage = 'Failed to track order: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter your tracking code to check order status in real time.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: trackingController,
            decoration: const InputDecoration(
              labelText: 'Tracking Code',
              hintText: 'Enter your tracking code',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FilledButton(
                  onPressed: trackOrder,
                  child: const Text('Track Order'),
                ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (booking != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking!.bookingNumber,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(statusLabel(booking!.status)),
                      backgroundColor:
                          statusColor(booking!.status).withValues(alpha: 0.12),
                      labelStyle: TextStyle(
                        color: statusColor(booking!.status),
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide.none,
                    ),
                    const SizedBox(height: 12),
                    Text('Customer: ${booking!.fullName}'),
                    if (booking!.pickupDate != null)
                      Text(
                        'Pickup: ${DateFormat.yMMMd().format(DateTime.parse(booking!.pickupDate!))}',
                      ),
                    Text('Total: PHP ${booking!.totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody();

    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: _buildBody(),
    );
  }
}
