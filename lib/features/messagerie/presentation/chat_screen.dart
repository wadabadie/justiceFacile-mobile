import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

// ─── Modèle message ───────────────────────────────────────────────────────────

class _Message {
  const _Message({required this.text, required this.isMine, required this.heure});
  final String text, heure;
  final bool isMine;
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.contactName});
  final String? contactName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  final _messages = <_Message>[
    const _Message(text: 'Bonjour, j\'ai bien reçu votre dossier concernant votre situation.', isMine: false, heure: '14:20'),
    const _Message(text: 'Pouvez-vous me fournir les preuves dont vous disposez ? (contrats, courriers, photos…)', isMine: false, heure: '14:21'),
    const _Message(text: 'Bonjour Maître, merci de me répondre. Je vais rassembler les documents ce soir.', isMine: true, heure: '14:28'),
    const _Message(text: 'J\'ai les relevés de salaires et les mails échangés avec mon employeur.', isMine: true, heure: '14:29'),
    const _Message(text: 'Parfait. Envoyez-les dès que possible. J\'ai besoin de votre contrat de travail original aussi.', isMine: false, heure: '14:32'),
  ];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isMine: true, heure: _now()));
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  String _now() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.contactName ?? 'Spécialiste';

    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE8),
      body: Column(
        children: [
          _ChatHeader(name: name, onBack: () => context.go('/messagerie')),
          const _EncryptionBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _Bubble(message: _messages[i]),
            ),
          ),
          _ChatInput(controller: _ctrl, onSend: _send),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.name, required this.onBack});
  final String name;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .replaceAll(RegExp(r'^(Me\.|Dr\.)'), '')
        .trim()
        .split(' ')
        .take(2)
        .map((p) => p.isNotEmpty ? p[0] : '')
        .join()
        .toUpperCase();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bleuNuit, AppColors.bleuMid],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.blanc, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.or.withAlpha(200),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 16,
                          fontWeight: FontWeight.w700, color: AppColors.blanc)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 17,
                            fontWeight: FontWeight.w700, color: AppColors.blanc)),
                    Row(
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(color: AppColors.emeraude, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        const Text('En ligne',
                            style: TextStyle(fontFamily: 'GoogleSans', fontSize: 13,
                                color: Color(0x99FFFFFF))),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.more_vert_rounded, color: AppColors.blanc, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bannière chiffrement ─────────────────────────────────────────────────────

class _EncryptionBanner extends StatelessWidget {
  const _EncryptionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      color: AppColors.emeraudeLight,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded, size: 13, color: AppColors.emeraude),
          SizedBox(width: 6),
          Text('Messages chiffrés de bout en bout · Confidentialité garantie',
              style: TextStyle(fontFamily: 'GoogleSans', fontSize: 12,
                  color: AppColors.emeraude, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Bulle de message ─────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(color: AppColors.bleuMid, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.blanc, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              decoration: BoxDecoration(
                color: isMine ? AppColors.bleuNuit : AppColors.blanc,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMine ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMine ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(message.text,
                      style: TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 15,
                        color: isMine ? AppColors.blanc : AppColors.gris,
                        height: 1.45,
                      )),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message.heure,
                          style: TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 11,
                            color: isMine ? const Color(0x80FFFFFF) : AppColors.grisLight,
                          )),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all_rounded, size: 14, color: AppColors.orPale),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMine) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─── Zone de saisie ──────────────────────────────────────────────────────────

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blanc,
      padding: EdgeInsets.fromLTRB(12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.fond2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.attach_file_rounded, color: AppColors.grisMid, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.fond,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x1A000000)),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.gris),
                decoration: const InputDecoration(
                  hintText: 'Votre message...',
                  hintStyle: TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.grisLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.bleuMid, AppColors.bleuNuit],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.bleuNuit.withAlpha(80), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.send_rounded, color: AppColors.blanc, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
