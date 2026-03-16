import 'package:aura_mart/Services/AddressService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Addresses', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AddressService.addressesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          final addresses = snapshot.data ?? [];

          return Column(
            children: [
              // Add New Address Button (Flipkart Style)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: InkWell(
                  onTap: () => _showAddressForm(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple.withAlpha(50)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.deepPurple),
                        SizedBox(width: 15),
                        Text("Add a new address", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: addresses.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return _buildAddressCard(address, isDarkMode);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, bool isDarkMode) {
    bool isDefault = address['isDefault'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDefault ? Colors.deepPurple : Colors.grey.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(address['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                child: Text(address['type'] ?? 'Home', style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              if (isDefault)
                const Icon(Icons.check_circle, color: Colors.deepPurple, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text("${address['house']}, ${address['area']}", style: const TextStyle(fontSize: 14)),
          Text("${address['city']}, ${address['state']} - ${address['pincode']}", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          Text(address['phone'], style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          Row(
            children: [
              TextButton(onPressed: () => _showAddressForm(address: address), child: const Text("EDIT")),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => AddressService.deleteAddress(address['id']), 
                child: const Text("REMOVE", style: TextStyle(color: Colors.red))
              ),
              const Spacer(),
              if (!isDefault)
                ElevatedButton(
                  onPressed: () => AddressService.setDefaultAddress(address['id']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  child: const Text("SET AS DEFAULT"),
                )
            ],
          )
        ],
      ),
    );
  }

  void _showAddressForm({Map<String, dynamic>? address}) {
    final nameController = TextEditingController(text: address?['name']);
    final phoneController = TextEditingController(text: address?['phone']);
    final pinController = TextEditingController(text: address?['pincode']);
    final houseController = TextEditingController(text: address?['house']);
    final areaController = TextEditingController(text: address?['area']);
    final cityController = TextEditingController(text: address?['city']);
    final stateController = TextEditingController(text: address?['state']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Address Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone),
              Row(
                children: [
                  Expanded(child: TextField(controller: pinController, decoration: const InputDecoration(labelText: "Pincode"), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: cityController, decoration: const InputDecoration(labelText: "City"))),
                ],
              ),
              TextField(controller: houseController, decoration: const InputDecoration(labelText: "House No., Building Name")),
              TextField(controller: areaController, decoration: const InputDecoration(labelText: "Road name, Area, Colony")),
              TextField(controller: stateController, decoration: const InputDecoration(labelText: "State")),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: () async {
                    final data = {
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'pincode': pinController.text,
                      'house': houseController.text,
                      'area': areaController.text,
                      'city': cityController.text,
                      'state': stateController.text,
                      'type': 'Home',
                    };
                    await AddressService.saveAddress(data, docId: address?['id']);
                    if (mounted) {
                      Navigator.pop(context);
                      Fluttertoast.showToast(msg: "Address saved successfully");
                    }
                  },
                  child: const Text("SAVE ADDRESS"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: isDarkMode ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 15),
          const Text("No addresses saved yet.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
