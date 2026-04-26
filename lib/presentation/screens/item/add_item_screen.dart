import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/item_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import 'package:go_router/go_router.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'Books';
  String _selectedCondition = 'Good';
  File? _imageFile;
  bool _isFree = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _post() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final price = _isFree ? 0.0 : double.tryParse(_priceCtrl.text) ?? 0.0;
    final quantity = int.tryParse(_qtyCtrl.text) ?? 1;

    final success = await context.read<ItemProvider>().postItem(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: price,
      quantity: quantity,
      category: _selectedCategory,
      condition: _selectedCondition,
      sellerId: user.id,
      imageFile: _imageFile,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item posted successfully! 🎉'),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.go('/');
    } else if (mounted) {
      final err = context.read<ItemProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Failed to post item'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post an Item'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _imageFile != null
                          ? AppColors.primary
                          : Theme.of(context).brightness == Brightness.dark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                      width: _imageFile != null ? 2 : 1,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: AppColors.primary.withOpacity(0.7),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Photo',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Tap to select from gallery',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              AppTextField(
                controller: _titleCtrl,
                label: 'Item Title',
                hint: 'e.g. Engineering Textbook Vol. 2',
                icon: Icons.title,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _descCtrl,
                label: 'Description (optional)',
                hint: 'What\'s special about this item?',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Price / Free toggle
              Row(
                children: [
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _isFree ? 0.4 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: AppTextField(
                        controller: _priceCtrl,
                        label: 'Price (₹)',
                        hint: '0',
                        icon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                        enabled: !_isFree,
                        validator: (v) {
                          if (_isFree) return null;
                          if (v == null || v.isEmpty) return 'Enter price';
                          if (double.tryParse(v) == null)
                            return 'Enter valid number';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text('Free', style: Theme.of(context).textTheme.bodyMedium),
                      Switch(
                        value: _isFree,
                        onChanged: (v) => setState(() => _isFree = v),
                        activeColor: AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _qtyCtrl,
                label: 'Quantity',
                hint: '1',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter quantity';
                  if (int.tryParse(v) == null || int.parse(v) < 1) {
                    return 'Enter valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              _buildDropdownSection(
                label: 'Category',
                icon: Icons.category_outlined,
                value: _selectedCategory,
                items: AppConstants.categories.where((c) => c != 'All').toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),

              // Condition
              Text('Condition',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  )),
              const SizedBox(height: 10),
              Row(
                children: AppConstants.conditions.map((cond) {
                  final isSelected = _selectedCondition == cond;
                  final color = cond == 'New'
                      ? AppColors.secondary
                      : cond == 'Good'
                          ? AppColors.primary
                          : AppColors.warning;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCondition = cond),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.15) : null,
                          border: Border.all(
                            color: isSelected ? color : AppColors.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              cond == 'New'
                                  ? Icons.star_rounded
                                  : cond == 'Good'
                                      ? Icons.thumb_up_rounded
                                      : Icons.handshake_outlined,
                              color: isSelected ? color : AppColors.textSecondaryLight,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cond,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? color : null,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Post Item 🚀',
                isLoading: itemProvider.isPosting,
                onPressed: _post,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondaryLight),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
      ],
    );
  }
}
