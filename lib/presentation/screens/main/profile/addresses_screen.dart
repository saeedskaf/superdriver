// lib/presentation/screens/main/profile/addresses_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/address/address_bloc.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/profile/add_edit_address_screen.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressBloc()..add(const AddressListRequested()),
      child: const _AddressesScreenContent(),
    );
  }
}

class _AddressesScreenContent extends StatefulWidget {
  const _AddressesScreenContent();

  @override
  State<_AddressesScreenContent> createState() =>
      _AddressesScreenContentState();
}

class _AddressesScreenContentState extends State<_AddressesScreenContent> {
  List<AddressSummary> _addresses = [];
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context, l10n),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: _handleStateChanges,
        builder: (context, state) => _buildBody(context, state, l10n),
      ),
      floatingActionButton: _buildFAB(context, l10n),
    );
  }

  // ============================================
  // App Bar
  // ============================================
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black87,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: TextCustom(
        text: l10n.addressesTitle,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      centerTitle: true,
    );
  }

  // ============================================
  // State Handler
  // ============================================
  void _handleStateChanges(BuildContext context, AddressState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is AddressListLoaded) {
      setState(() {
        _addresses = state.addresses;
        _isLoading = false;
      });
    } else if (state is AddressLoading && _addresses.isEmpty) {
      setState(() => _isLoading = true);
    } else if (state is AddressError) {
      setState(() => _isLoading = false);
      _showSnackBar(context, state.message, isError: true);
    } else if (state is AddressDeleteSuccess) {
      _showSnackBar(context, l10n.addressDeletedSuccessfully);
      context.read<AddressBloc>().add(const AddressListRequested());
    } else if (state is AddressSetCurrentSuccess) {
      _showSnackBar(context, l10n.addressSetAsDefault);
      context.read<AddressBloc>().add(const AddressListRequested());
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ============================================
  // Body
  // ============================================
  Widget _buildBody(
    BuildContext context,
    AddressState state,
    AppLocalizations l10n,
  ) {
    if (_isLoading && _addresses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
      );
    }

    if (_addresses.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            context.read<AddressBloc>().add(const AddressListRequested());
          },
          color: const Color(0xFFD32F2F),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              return _AddressCard(
                address: _addresses[index],
                onTap: () =>
                    _navigateToEditAddress(context, _addresses[index].id),
                onEdit: () =>
                    _navigateToEditAddress(context, _addresses[index].id),
                onSetDefault: () => context.read<AddressBloc>().add(
                  AddressSetCurrentRequested(id: _addresses[index].id),
                ),
                onDelete: () =>
                    _showDeleteDialog(context, _addresses[index].id, l10n),
              );
            },
          ),
        ),
        if (state is AddressOperationInProgress)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
            ),
          ),
      ],
    );
  }

  // ============================================
  // Empty State
  // ============================================
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 64,
                color: const Color(0xFFD32F2F).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: l10n.noAddressesSaved,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: l10n.addNewAddressToStart,
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddAddress(context),
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(l10n.addAddress),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // FAB
  // ============================================
  Widget _buildFAB(BuildContext context, AppLocalizations l10n) {
    if (_addresses.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: () => _navigateToAddAddress(context),
      backgroundColor: const Color(0xFFD32F2F),
      elevation: 4,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // ============================================
  // Navigation
  // ============================================
  void _navigateToAddAddress(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AddressBloc>(),
          child: const AddEditAddressScreen(),
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      _showSnackBar(context, l10n.addressAddedSuccessfully);
    }
    context.read<AddressBloc>().add(const AddressListRequested());
  }

  void _navigateToEditAddress(BuildContext context, int addressId) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AddressBloc>(),
          child: AddEditAddressScreen(addressId: addressId),
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      _showSnackBar(context, l10n.addressUpdatedSuccessfully);
    }
    context.read<AddressBloc>().add(const AddressListRequested());
  }

  // ============================================
  // Delete Dialog
  // ============================================
  void _showDeleteDialog(
    BuildContext context,
    int addressId,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextCustom(
                text: l10n.deleteAddress,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: TextCustom(
          text: l10n.deleteAddressConfirmation,
          fontSize: 15,
          color: Colors.grey.shade600,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextCustom(
              text: l10n.cancel,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AddressBloc>().add(
                AddressDeleteRequested(id: addressId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Address Card Widget
// ============================================
class _AddressCard extends StatelessWidget {
  final AddressSummary address;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onTap,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: address.isCurrent
            ? Border.all(color: const Color(0xFFD32F2F), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 14),
                Expanded(child: _buildInfo(l10n)),
                _buildMenu(context, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: address.isCurrent
            ? const Color(0xFFD32F2F).withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        address.isCurrent ? Icons.location_on : Icons.location_on_outlined,
        color: address.isCurrent
            ? const Color(0xFFD32F2F)
            : Colors.grey.shade500,
        size: 24,
      ),
    );
  }

  Widget _buildInfo(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: TextCustom(
                text: address.title,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (address.isCurrent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n.defaultAddress,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${address.governorateName} - ${address.areaName}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'set_default':
            onSetDefault();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => [
        _buildMenuItem(Icons.edit_outlined, l10n.edit, 'edit'),
        if (!address.isCurrent)
          _buildMenuItem(
            Icons.check_circle_outline,
            l10n.setAsDefault,
            'set_default',
          ),
        _buildMenuItem(
          Icons.delete_outline,
          l10n.delete,
          'delete',
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    IconData icon,
    String text,
    String value, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade600 : Colors.black87;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
