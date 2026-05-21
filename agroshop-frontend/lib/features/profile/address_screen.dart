import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/dummy_data.dart';
import '../../models/user.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  // Ambil list alamat dari DummyData
  List<Map<String, dynamic>> get _addresses => DummyData.dummyAddresses;

  void _refresh() {
    setState(() {});
  }

  // Set Alamat Utama / Default
  void _setDefaultAddress(int id) {
    setState(() {
      String newMainAddressText = '';
      for (var addr in _addresses) {
        if (addr['id'] == id) {
          addr['isDefault'] = true;
          newMainAddressText = addr['detail'];
        } else {
          addr['isDefault'] = false;
        }
      }

      // Sinkronkan alamat default ke currentUser
      final currentUser = DummyData.currentUser;
      DummyData.currentUser = User(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        role: currentUser.role,
        phone: currentUser.phone,
        imageUrl: currentUser.imageUrl,
        address: newMainAddressText,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat utama berhasil diubah!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // Hapus Alamat
  void _deleteAddress(int id) {
    final target = _addresses.firstWhere((element) => element['id'] == id);
    if (target['isDefault'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat utama tidak dapat dihapus!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _addresses.removeWhere((element) => element['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat berhasil dihapus!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // Tampilkan Bottom Sheet untuk Tambah / Edit Alamat
  void _showAddressForm({Map<String, dynamic>? addressToEdit}) {
    final isEdit = addressToEdit != null;
    final formKey = GlobalKey<FormState>();

    final labelController = TextEditingController(text: isEdit ? addressToEdit['label'] : '');
    final nameController = TextEditingController(text: isEdit ? addressToEdit['name'] : '');
    final phoneController = TextEditingController(text: isEdit ? addressToEdit['phone'] : '');
    final detailController = TextEditingController(text: isEdit ? addressToEdit['detail'] : '');
    bool isDefault = isEdit ? addressToEdit['isDefault'] : false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Ubah Alamat' : 'Tambah Alamat Baru',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Label Alamat (e.g. Rumah, Kantor)
                  TextFormField(
                    controller: labelController,
                    decoration: InputDecoration(
                      labelText: 'Label Alamat (cth: Rumah, Kantor)',
                      prefixIcon: const Icon(Icons.bookmark_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Label tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Nama Penerima
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Penerima',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama penerima tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Nomor Telepon Penerima
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon Penerima',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Detail Alamat
                  TextFormField(
                    controller: detailController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap',
                      hintText: 'Nama jalan, nomor rumah, RT/RW, kecamatan, kota, dll.',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Detail alamat tidak boleh kosong';
                      }
                      if (value.trim().length < 10) {
                        return 'Alamat terlalu singkat';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Switch Jadikan Utama
                  SwitchListTile(
                    title: const Text(
                      'Jadikan Alamat Utama',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Gunakan alamat ini untuk pengiriman utama'),
                    value: isDefault,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setModalState(() {
                        isDefault = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          if (isEdit) {
                            // Update Alamat
                            addressToEdit['label'] = labelController.text.trim();
                            addressToEdit['name'] = nameController.text.trim();
                            addressToEdit['phone'] = phoneController.text.trim();
                            addressToEdit['detail'] = detailController.text.trim();
                            
                            if (isDefault) {
                              _setDefaultAddress(addressToEdit['id']);
                            } else {
                              addressToEdit['isDefault'] = false;
                            }
                          } else {
                            // Tambah Alamat Baru
                            final newId = _addresses.isEmpty
                                ? 1
                                : _addresses.map((a) => a['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
                            
                            final newAddress = {
                              'id': newId,
                              'label': labelController.text.trim(),
                              'name': nameController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'detail': detailController.text.trim(),
                              'isDefault': isDefault,
                            };

                            _addresses.add(newAddress);

                            if (isDefault) {
                              _setDefaultAddress(newId);
                            }
                          }
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit ? 'Alamat berhasil diubah!' : 'Alamat baru berhasil ditambahkan!',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Tambah Alamat',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Pengiriman'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Banner Penerangan / Info
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Anda dapat menyimpan beberapa alamat dan memilih salah satu sebagai alamat utama pengiriman belanja.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Alamat
          Expanded(
            child: _addresses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          size: 70,
                          color: AppColors.textHint.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada alamat tersimpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final addr = _addresses[index];
                      final isDefault = addr['isDefault'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDefault ? AppColors.primary : Colors.grey.shade200,
                            width: isDefault ? 2 : 1,
                          ),
                        ),
                        elevation: isDefault ? 2 : 0,
                        color: isDefault ? AppColors.primary.withValues(alpha: 0.01) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label Chip & Default Badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      addr['label'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.green.shade200),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.check, size: 10, color: Colors.green),
                                          SizedBox(width: 4),
                                          Text(
                                            'Utama',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Penerima & Telepon
                              Text(
                                addr['name'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                addr['phone'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Alamat Lengkap
                              Text(
                                addr['detail'],
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const Divider(height: 24),

                              // Actions Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!isDefault)
                                    TextButton.icon(
                                      onPressed: () => _setDefaultAddress(addr['id']),
                                      icon: const Icon(Icons.check_circle_outline, size: 16),
                                      label: const Text('Set Utama', style: TextStyle(fontSize: 12)),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  if (!isDefault) const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _showAddressForm(addressToEdit: addr),
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!isDefault)
                                    TextButton.icon(
                                      onPressed: () => _deleteAddress(addr['id']),
                                      icon: const Icon(Icons.delete_outline, size: 16),
                                      label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Tombol Tambah Alamat Baru
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddressForm(),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Tambah Alamat Baru',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
