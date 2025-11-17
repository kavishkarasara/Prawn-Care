import 'package:flutter/material.dart';
import '../../models/feeding_schedule.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';
import 'dart:async';

class FeedingSchedulePage extends StatefulWidget {
  const FeedingSchedulePage({super.key});

  @override
  State<FeedingSchedulePage> createState() => _FeedingSchedulePageState();
}

class _FeedingSchedulePageState extends State<FeedingSchedulePage> {
  final ApiService _apiService = ApiService();
  List<FeedingScheduleItem> _schedule = [];
  List<FeedingScheduleItem> _filteredSchedule = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedPondId;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<int> _pondIds = [];
  List<int> _filteredPondIds = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final schedule = await _apiService.getFeedingSchedule();
      setState(() {
        _schedule = schedule;
        _pondIds = schedule.map((item) => item.pondID).toSet().toList()..sort();
        _filteredPondIds = _pondIds;
        _filteredSchedule = _selectedPondId == null
            ? schedule
            : schedule.where((item) => item.pondID == _selectedPondId).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final query = _searchController.text.toLowerCase();
        setState(() {
          _filteredPondIds =
              _pondIds.where((id) => id.toString().contains(query)).toList();
        });
      }
    });
  }

  void _filterByPondId(int? pondId) {
    setState(() {
      _selectedPondId = pondId;
      _filteredSchedule = pondId == null
          ? _schedule
          : _schedule.where((item) => item.pondID == pondId).toList();
    });
  }

  Map<int, List<FeedingScheduleItem>> _groupByPondId(
      List<FeedingScheduleItem> items) {
    final Map<int, List<FeedingScheduleItem>> grouped = {};
    for (final item in items) {
      if (!grouped.containsKey(item.pondID)) {
        grouped[item.pondID] = [];
      }
      grouped[item.pondID]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 40.0 : 20.0;
    final titleFontSize = isTablet ? 32.0 : 28.0;
    final subtitleFontSize = isTablet ? 22.0 : 20.0;
    final cardFontSize = isTablet ? 18.0 : 16.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, Color(0xFF4CAF50)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: 60, left: padding, right: padding, bottom: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: Colors.white, size: isTablet ? 32 : 28),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                      padding: const EdgeInsets.all(12),
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: isTablet ? 36 : 32, color: primaryColor),
                          const SizedBox(width: 10),
                          Text(
                            'Feeding Schedule',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_pondIds.length > 5) ...[
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Pond ID',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                      ],
                      DropdownButtonFormField<int?>(
                        value: _selectedPondId,
                        decoration: InputDecoration(
                          labelText: 'Filter by Pond ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All Ponds'),
                          ),
                          ..._filteredPondIds
                              .map((pondId) => DropdownMenuItem<int>(
                                    value: pondId,
                                    child: Text('Pond $pondId'),
                                  )),
                        ],
                        onChanged: _filterByPondId,
                      ),
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                ),
                              )
                            : _error != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error_outline,
                                            size: 64, color: Colors.red),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Failed to load feeding schedule. Please check your connection and try again.',
                                          style:
                                              TextStyle(fontSize: cardFontSize),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _fetchSchedule,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                          ),
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _fetchSchedule,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      itemCount:
                                          _groupByPondId(_filteredSchedule)
                                              .length,
                                      itemBuilder: (context, index) {
                                        final entry =
                                            _groupByPondId(_filteredSchedule)
                                                .entries
                                                .elementAt(index);
                                        final pondId = entry.key;
                                        final items = entry.value;
                                        return TweenAnimationBuilder(
                                          tween:
                                              Tween<double>(begin: 0, end: 1),
                                          duration:
                                              const Duration(milliseconds: 300),
                                          builder:
                                              (context, double value, child) {
                                            return Opacity(
                                              opacity: value,
                                              child: Transform.translate(
                                                offset:
                                                    Offset(0, 20 * (1 - value)),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16.0),
                                                child: Text(
                                                  'Pond $pondId',
                                                  style: TextStyle(
                                                    fontSize: subtitleFontSize,
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ),
                                              ...items.map((item) =>
                                                  _buildExpandableCard(
                                                      item, cardFontSize)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard(FeedingScheduleItem item, double fontSize) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Expandable functionality can be added here if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time: ${item.feedingTime}',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Add more details if available in the model
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
