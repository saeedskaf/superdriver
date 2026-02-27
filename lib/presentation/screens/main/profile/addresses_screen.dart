import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/address/address_bloc.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/screens/main/profile/add_edit_address_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

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

class _AddressesScreenContent extends StatelessWidget {
  const _AddressesScreenContent();

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ColorsCustom.error : ColorsCustom.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: AppBar(
        backgroundColor: ColorsCustom.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: ColorsCustom.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: ColorsCustom.primary,
              ),
            ),
          ),
        ),
        title: TextCustom(
          text: l10n.addressesTitle,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            _showSnackBar(context, state.message, isError: true);
          } else if (state is AddressDeleteSuccess) {
            _showSnackBar(context, l10n.addressDeletedSuccessfully);
            context.read<AddressBloc>().add(const AddressListRequested());
          } else if (state is AddressSetCurrentSuccess) {
            _showSnackBar(context, l10n.addressSetAsDefault);
            context.read<AddressBloc>().add(const AddressListRequested());
          }
        },
        builder: (context, state) {
          return _buildBody(context, state, l10n);
        },
      ),
      floatingActionButton: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, state) {
          if (state is AddressListLoaded && state.addresses.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => _navigateToAddAddress(context),
              backgroundColor: ColorsCustom.primary,
              elevation: 4,
              child: const Icon(
                Icons.add_rounded,
                color: ColorsCustom.textOnPrimary,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Body ──

  Widget _buildBody(
    BuildContext context,
    AddressState state,
    AppLocalizations l10n,
  ) {
    if (state is AddressLoading || state is AddressInitial) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
        ),
      );
    }

    if (state is AddressError) {
      return _buildErrorState(context, state.message, l10n);
    }

    if (state is AddressListLoaded) {
      if (state.addresses.isEmpty) {
        return _buildEmptyState(context, l10n);
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<AddressBloc>().add(const AddressListRequested());
        },
        color: ColorsCustom.primary,
        backgroundColor: ColorsCustom.surface,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: state.addresses.length,
          itemBuilder: (context, index) {
            final address = state.addresses[index];
            return _AddressCard(
              address: address,
              onTap: () => _navigateToEditAddress(context, address.id),
              onEdit: () => _navigateToEditAddress(context, address.id),
              onSetDefault: () => context.read<AddressBloc>().add(
                AddressSetCurrentRequested(id: address.id),
              ),
              onDelete: () => _showDeleteDialog(context, address.id, l10n),
            );
          },
        ),
      );
    }

    if (state is AddressOperationInProgress) {
      return Stack(
        children: [
          BlocBuilder<AddressBloc, AddressState>(
            buildWhen: (previous, current) => current is AddressListLoaded,
            builder: (context, cachedState) {
              final addresses = context.read<AddressBloc>().cachedAddresses;
              if (addresses.isEmpty) return const SizedBox.shrink();
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  return _AddressCard(
                    address: addresses[index],
                    onTap: () {},
                    onEdit: () {},
                    onSetDefault: () {},
                    onDelete: () {},
                  );
                },
              );
            },
          ),
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
              ),
            ),
          ),
        ],
      );
    }

    // Fallback: cached
    final cachedAddresses = context.read<AddressBloc>().cachedAddresses;
    if (cachedAddresses.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<AddressBloc>().add(const AddressListRequested());
        },
        color: ColorsCustom.primary,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: cachedAddresses.length,
          itemBuilder: (context, index) {
            final address = cachedAddresses[index];
            return _AddressCard(
              address: address,
              onTap: () => _navigateToEditAddress(context, address.id),
              onEdit: () => _navigateToEditAddress(context, address.id),
              onSetDefault: () => context.read<AddressBloc>().add(
                AddressSetCurrentRequested(id: address.id),
              ),
              onDelete: () => _showDeleteDialog(context, address.id, l10n),
            );
          },
        ),
      );
    }

    return _buildEmptyState(context, l10n);
  }

  // ── Error State ──

  Widget _buildErrorState(
    BuildContext context,
    String message,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: ColorsCustom.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: ColorsCustom.error,
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: message,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ButtonCustom.primary(
              text: l10n.retry,
              onPressed: () {
                context.read<AddressBloc>().add(const AddressListRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ──

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: ColorsCustom.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 48,
                color: ColorsCustom.primary.withAlpha(153),
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: l10n.noAddressesSaved,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: l10n.addNewAddressToStart,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
            ),
            const SizedBox(height: 28),
            ButtonCustom.primary(
              text: l10n.addAddress,
              onPressed: () => _navigateToAddAddress(context),
              icon: const Icon(
                Icons.add_location_alt_outlined,
                color: ColorsCustom.textOnPrimary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation ──

  void _navigateToAddAddress(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<AddressBloc>();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const AddEditAddressScreen(),
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      _showSnackBar(context, l10n.addressAddedSuccessfully);
    }
    bloc.add(const AddressListRequested());
  }

  void _navigateToEditAddress(BuildContext context, int addressId) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<AddressBloc>();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AddEditAddressScreen(addressId: addressId),
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      _showSnackBar(context, l10n.addressUpdatedSuccessfully);
    }
    bloc.add(const AddressListRequested());
  }

  // ── Delete Dialog ──

  void _showDeleteDialog(
    BuildContext context,
    int addressId,
    AppLocalizations l10n,
  ) {
    final bloc = context.read<AddressBloc>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorsCustom.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: ColorsCustom.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: ColorsCustom.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              TextCustom(
                text: l10n.deleteAddress,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextCustom(
                text: l10n.deleteAddressConfirmation,
                fontSize: 14,
                color: ColorsCustom.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ButtonCustom.secondary(
                      text: l10n.cancel,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonCustom.primary(
                      text: l10n.delete,
                      onPressed: () {
                        Navigator.pop(ctx);
                        bloc.add(AddressDeleteRequested(id: addressId));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// ADDRESS CARD
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
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isCurrent ? ColorsCustom.primary : ColorsCustom.border,
          width: address.isCurrent ? 1.5 : 1,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: address.isCurrent
                      ? ColorsCustom.primarySoft
                      : ColorsCustom.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  address.isCurrent
                      ? Icons.location_on_rounded
                      : Icons.location_on_outlined,
                  color: address.isCurrent
                      ? ColorsCustom.primary
                      : ColorsCustom.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: TextCustom(
                            text: address.title,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ColorsCustom.textPrimary,
                          ),
                        ),
                        if (address.isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: ColorsCustom.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.defaultAddress,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: ColorsCustom.textOnPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextCustom(
                      text: '${address.governorateName} - ${address.areaName}',
                      fontSize: 13,
                      color: ColorsCustom.textSecondary,
                    ),
                  ],
                ),
              ),

              // Menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: ColorsCustom.textHint,
                  size: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: ColorsCustom.surface,
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
                    Icons.delete_outline_rounded,
                    l10n.delete,
                    'delete',
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    IconData icon,
    String text,
    String value, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? ColorsCustom.error : ColorsCustom.textPrimary;
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
