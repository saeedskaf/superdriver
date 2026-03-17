import 'package:flutter/material.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/components/main_top_header.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_conversation_section.dart';
import 'package:superdriver/presentation/screens/main/chat/emergency_ticket_screen.dart';
import 'package:superdriver/presentation/screens/main/chat/new_order_chat_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _openNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewOrderChatScreen()),
    );
  }

  void _openEmergency() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyTicketScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      body: Column(
        children: [
          MainTopHeader(
            title: l10n.chatPageTitle,
            iconAsset: 'assets/icons/call_center.png',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: l10n.chatOpenNewOrder,
                    subtitle: l10n.chatNewOrderSubtitle,
                    icon: Icons.add_shopping_cart_rounded,
                    color: ColorsCustom.secondaryDark,
                    onTap: _openNewOrder,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionCard(
                    title: l10n.chatOpenTicket,
                    subtitle: l10n.chatEmergencySubtitle,
                    icon: Icons.support_agent_rounded,
                    color: ColorsCustom.primary,
                    onTap: _openEmergency,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ChatConversationSection(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              showOrderAddress: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 170,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [color, color.withAlpha(200)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const Spacer(),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextCustom(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                TextCustom(
                  text: subtitle,
                  fontSize: 11,
                  color: Colors.white.withAlpha(200),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
