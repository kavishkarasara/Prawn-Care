import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:prawn__farm/widgets/request_feed_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prawn__farm/services/api_service.dart';
import 'package:prawn__farm/models/supply_order.dart';
import 'package:prawn__farm/widgets/supply_order_list_item.dart';

// Initialize Supabase client
final supabase = Supabase.instance.client;

class RequestORdersScreen extends StatefulWidget {
  const RequestORdersScreen({super.key});

  @override
  State<RequestORdersScreen> createState() => _RequestFeedsScreenState();
}

class _RequestFeedsScreenState extends State<RequestORdersScreen> {
  ApiService _apiService = ApiService();
  String? _supplierId;
  List<SupplyOrder> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSupplierId();
  }

  void _loadSupplierId() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    if (userType == 'supplier') {
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final user = jsonDecode(userJson);
        _supplierId = user['id']?.toString() ?? user['supplier_id']?.toString();
        if (_supplierId != null) {
          _loadOrders();
        } else {
          setState(() {
            _error = 'Supplier ID not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'User data not found';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _error = 'Not logged in as supplier';
        _isLoading = false;
      });
    }
  }

  void _loadOrders() async {
    try {
      final orders = await _apiService.getSupplyOrders(_supplierId!);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          RequestFeedsHeader(onRefresh: _loadOrders),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _orders.isEmpty
                        ? const Center(child: Text('No supply orders yet.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(20.0),
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              final order = _orders[index];
                              return SupplyOrderListItem(
                                order: order,
                                apiService: _apiService,
                                onUpdate: _loadOrders,
                                supplierId: _supplierId!,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
