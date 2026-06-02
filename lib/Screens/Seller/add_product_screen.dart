import 'package:eloria_collection/core_services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Fashion';
  bool _isLoading = false;

  final List<String> _categories = ['Fashion', 'Electronics', 'Home', 'Beauty', 'Toys', 'Sports', 'Books', 'Appliances'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ProductService.addProduct({
          'name': _nameController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'image': _imageController.text.trim(),
          'description': _descController.text.trim(),
          'category': _selectedCategory,
        });
        Fluttertoast.showToast(msg: "Product listed successfully!");
        if (mounted) Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('List New Item', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Product Details", isDarkMode),
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _nameController,
                label: "Product Name",
                icon: Icons.shopping_bag_outlined,
                isDarkMode: isDarkMode,
                validator: (v) => v!.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: "Price (\$)",
                      icon: Icons.attach_money,
                      isDarkMode: isDarkMode,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Enter price" : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildCategoryDropdown(isDarkMode),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _imageController,
                label: "Image URL",
                icon: Icons.link,
                isDarkMode: isDarkMode,
                onChanged: (v) => setState(() {}),
                validator: (v) => v!.isEmpty ? "Enter image URL" : null,
              ),
              const SizedBox(height: 10),
              _buildImagePreview(isDarkMode),
              
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descController,
                label: "Description",
                icon: Icons.description_outlined,
                isDarkMode: isDarkMode,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? "Enter description" : null,
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("LIST PRODUCT NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.deepPurple, width: 2)),
      ),
      validator: validator,
    );
  }

  Widget _buildCategoryDropdown(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
          items: _categories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildImagePreview(bool isDarkMode) {
    if (_imageController.text.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withAlpha(50)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CachedNetworkImage(
          imageUrl: _imageController.text,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
        ),
      ),
    );
  }
}
