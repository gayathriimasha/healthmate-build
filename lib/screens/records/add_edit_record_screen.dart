import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/health_record.dart';
import '../../providers/health_records_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditRecordScreen extends StatefulWidget {
  final HealthRecord? record;

  const AddEditRecordScreen({Key? key, this.record}) : super(key: key);

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _waterController = TextEditingController();

  bool get isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _selectedDate = DateHelper.parseDate(widget.record!.date);
      _stepsController.text = widget.record!.steps.toString();
      _caloriesController.text = widget.record!.calories.toString();
      _waterController.text = widget.record!.water.toString();
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final record = HealthRecord(
      id: widget.record?.id,
      date: DateHelper.formatDate(_selectedDate),
      steps: int.parse(_stepsController.text),
      calories: int.parse(_caloriesController.text),
      water: int.parse(_waterController.text),
    );

    final provider = Provider.of<HealthRecordsProvider>(context, listen: false);
    final success = isEditing
        ? await provider.updateRecord(record)
        : await provider.addRecord(record);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Record updated successfully' : 'Record added successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save record'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Record' : 'Add Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Date',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateHelper.formatDisplayDate(_selectedDate),
                        style: AppTextStyles.body1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Steps',
                hint: 'Enter steps count',
                controller: _stepsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => ValidationHelper.validateNumber(value, 'Steps'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Calories',
                hint: 'Enter calories burned',
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => ValidationHelper.validateNumber(value, 'Calories'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Water (ml)',
                hint: 'Enter water intake in ml',
                controller: _waterController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => ValidationHelper.validateNumber(value, 'Water'),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: isEditing ? 'Update Record' : 'Add Record',
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
