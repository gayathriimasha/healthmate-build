import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../providers/health_records_provider.dart';
import '../../models/health_record.dart';
import 'add_edit_record_screen.dart';
import 'record_details_screen.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({Key? key}) : super(key: key);

  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
  // Local state - no provider BS
  List<HealthRecord> _allRecords = [];
  List<HealthRecord>? _filteredRecords;
  bool _isLoading = false;
  String? _filterDate;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    // Load records when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
    });
  }

  Future<void> _loadRecords() async {
    if (!mounted || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<HealthRecordsProvider>(context, listen: false);
    final records = await provider.loadRecords();

    if (mounted) {
      setState(() {
        _allRecords = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _applyFilter() async {
    if (_filterDate == null && _dateRange == null) {
      // Clear filter
      setState(() {
        _filteredRecords = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<HealthRecordsProvider>(context, listen: false);
    List<HealthRecord> records;

    if (_filterDate != null) {
      records = await provider.getRecordsByDateRange(_filterDate!, _filterDate!);
    } else if (_dateRange != null) {
      final startDate = DateHelper.formatDate(_dateRange!.start);
      final endDate = DateHelper.formatDate(_dateRange!.end);
      records = await provider.getRecordsByDateRange(startDate, endDate);
    } else {
      records = _allRecords;
    }

    if (mounted) {
      setState(() {
        _filteredRecords = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAddRecord() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEditRecordScreen(),
      ),
    );

    // Reload if a record was added
    if (result == true) {
      _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddRecord,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final records = _filteredRecords ?? _allRecords;

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No records found',
              style: AppTextStyles.body1,
            ),
            if (_allRecords.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh',
                style: AppTextStyles.body2,
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecordDetailsScreen(record: record),
                  ),
                );
                // Reload if record was modified/deleted
                if (result == true) {
                  _loadRecords();
                }
              },
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                DateHelper.formatDisplayDate(
                  DateHelper.parseDate(record.date),
                ),
                style: AppTextStyles.heading3,
              ),
              subtitle: Text(
                '${record.steps} steps • ${record.calories} cal • ${record.water} ml',
                style: AppTextStyles.body2,
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Records'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.today),
                title: const Text('Single Date'),
                onTap: () async {
                  Navigator.pop(context);
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _filterDate = DateHelper.formatDate(date);
                      _dateRange = null;
                    });
                    _applyFilter();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Date Range'),
                onTap: () async {
                  Navigator.pop(context);
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (range != null) {
                    setState(() {
                      _dateRange = range;
                      _filterDate = null;
                    });
                    _applyFilter();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear),
                title: const Text('Clear Filter'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _filterDate = null;
                    _dateRange = null;
                  });
                  _applyFilter();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
