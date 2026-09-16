import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/voice_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

// ─── Modèle message ───────────────────────────────────────────────────────────

enum _Sender { user, ai }

class _AiMessage {
  _AiMessage({required this.text, required this.sender, DateTime? time})
      : time = time ?? DateTime.now();
  final String text;
  final _Sender sender;
  final DateTime time;
}

// ─── Questions suggérées ──────────────────────────────────────────────────────

const _suggestions = [
  'Quels sont mes droits en cas de violence conjugale ?',
  'Comment contester un licenciement abusif ?',
  'Comment porter plainte ?',
  'Quelles lois protègent les victimes de VBG ?',
  'Règlement d\'un litige foncier',
  'Mes droits lors d\'un divorce',
];

// ─── Écran ────────────────────────────────────────────────────────────────────

class AIAgentScreen extends StatefulWidget {
  const AIAgentScreen({super.key});

  @override
  State<AIAgentScreen> createState() => _AIAgentScreenState();
}

class _AIAgentScreenState extends State<AIAgentScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_AiMessage>[];
  bool _isTyping = false;
  bool _loadingHistory = true;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    VoiceService.instance.addListener(_onVoiceChanged);
    _loadHistory();
  }

  void _onVoiceChanged() {
    if (!VoiceService.instance.isListening && _isListening) {
      setState(() => _isListening = false);
    }
  }

  Future<void> _loadHistory() async {
    try {
      final res = await ApiService.instance.get(ApiConstants.agentJuridiqueHistorique);
      final sorted = (res.data as List<dynamic>).toList()
        ..sort((a, b) {
          final dA = DateTime.tryParse((a as Map)['date_creation'] as String? ?? '') ?? DateTime(0);
          final dB = DateTime.tryParse((b as Map)['date_creation'] as String? ?? '') ?? DateTime(0);
          return dA.compareTo(dB);
        });
      if (!mounted) return;
      final msgs = <_AiMessage>[];
      for (final item in sorted) {
        final date = DateTime.tryParse(item['date_creation'] as String? ?? '')?.toLocal()
            ?? DateTime.now();
        msgs.add(_AiMessage(text: item['question'] as String? ?? '', sender: _Sender.user, time: date));
        msgs.add(_AiMessage(text: item['reponse'] as String? ?? '', sender: _Sender.ai, time: date));
      }
      setState(() {
        _messages.addAll(msgs);
        _loadingHistory = false;
      });
      if (msgs.isNotEmpty) _scrollDown();
    } on DioException {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
    }
  }

  @override
  void dispose() {
    VoiceService.instance.removeListener(_onVoiceChanged);
    VoiceService.instance.stopSpeaking();
    VoiceService.instance.stopListening();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final voice = VoiceService.instance;
    if (_isListening) {
      // stopListening() fires onFinal with the full accumulated text
      await voice.stopListening();
      return;
    }
    if (!voice.sttAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Reconnaissance vocale non disponible sur cet appareil.'),
        backgroundColor: AppColors.rouge,
      ));
      return;
    }
    setState(() => _isListening = true);
    final started = await voice.startListening(
      onPartial: (text) {
        if (text.isNotEmpty && mounted) setState(() => _ctrl.text = text);
      },
      onFinal: (text) {
        if (mounted) setState(() {
          _isListening = false;
          if (text.isNotEmpty) _ctrl.text = text;
        });
      },
    );
    if (!started && mounted) setState(() => _isListening = false);
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isTyping) return;
    _ctrl.clear();

    setState(() {
      _messages.add(_AiMessage(text: trimmed, sender: _Sender.user));
      _isTyping = true;
    });
    _scrollDown();

    try {
      final res = await ApiService.instance.post(
        ApiConstants.agentJuridique,
        data: {'question': trimmed},
      );
      if (!mounted) return;
      final reponse = res.data['reponse'] as String? ?? '';
      final date = DateTime.tryParse(res.data['date_creation'] as String? ?? '')?.toLocal()
          ?? DateTime.now();
      setState(() {
        _isTyping = false;
        _messages.add(_AiMessage(text: reponse, sender: _Sender.ai, time: date));
      });
      _scrollDown();
      VoiceService.instance.speak(reponse);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data)),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE8),
      body: Column(
        children: [
          const _AIHeader(),
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator(color: AppColors.bleuNuit))
                : _messages.isEmpty
                    ? _WelcomeView(onSuggestion: _send)
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == _messages.length) return const _TypingIndicator();
                          return _MessageBubble(message: _messages[i]);
                        },
                      ),
          ),
          _InputBar(
            controller: _ctrl,
            onSend: _send,
            isListening: _isListening,
            onMicTap: _toggleMic,
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.ia),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AIHeader extends StatelessWidget {
  const _AIHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bleuNuit, Color(0xFF1A3A6B)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.blanc, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.or, AppColors.orDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.blanc, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.of(context).aiTitle,
                        style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 19,
                            fontWeight: FontWeight.w700, color: AppColors.blanc)),
                    Text(AppStrings.of(context).aiSubtitle,
                        style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 13,
                            color: Color(0x80FFFFFF))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.emeraude.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.emeraude.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppColors.emeraude),
                    const SizedBox(width: 5),
                    Text(AppStrings.of(context).aiOnline,
                        style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 12,
                            fontWeight: FontWeight.w600, color: AppColors.emeraude)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Vue d'accueil (pas encore de messages) ───────────────────────────────────

class _WelcomeView extends StatelessWidget {
  const _WelcomeView({required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bleuNuit, AppColors.bleuMid],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [AppColors.ombre],
            ),
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.or, AppColors.orDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.blanc, size: 38),
                ),
                const SizedBox(height: 16),
                Text(AppStrings.of(context).aiWelcome,
                    style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 22,
                        fontWeight: FontWeight.w700, color: AppColors.blanc)),
                const SizedBox(height: 8),
                Text(
                  AppStrings.of(context).aiSubhead,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15,
                      color: Color(0xA0FFFFFF), height: 1.5),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.orPale, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.of(context).aiDisclaimer,
                          style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 13,
                              color: AppColors.orPale, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(width: 4, height: 20,
                  decoration: BoxDecoration(color: AppColors.or, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text(AppStrings.of(context).aiQuestionsLabel, style: AppTextStyles.h2.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 14),
          ..._suggestions.map((s) => _SuggestionTile(text: s, onTap: () => onSuggestion(s))),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.orLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.help_outline_rounded, color: AppColors.or, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15,
                      fontWeight: FontWeight.w500, color: AppColors.gris)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grisLight),
          ],
        ),
      ),
    );
  }
}

// ─── Bulle de message ─────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _AiMessage message;

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == _Sender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.blanc, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              decoration: BoxDecoration(
                color: isUser ? AppColors.bleuNuit : AppColors.blanc,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _RichText(text: message.text, isUser: isUser),
                  const SizedBox(height: 6),
                  Text(_fmt(message.time),
                      style: TextStyle(fontFamily: 'GoogleSans', fontSize: 11,
                          color: isUser ? const Color(0x70FFFFFF) : AppColors.grisLight)),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _RichText extends StatelessWidget {
  const _RichText({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final baseColor = isUser ? AppColors.blanc : AppColors.gris;
    final boldColor = isUser ? AppColors.orPale : AppColors.bleuNuit;
    final spans = <TextSpan>[];
    final parts = text.split(RegExp(r'(\*\*[^*]+\*\*)'));

    for (final part in parts) {
      if (part.startsWith('**') && part.endsWith('**')) {
        spans.add(TextSpan(
          text: part.substring(2, part.length - 2),
          style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w700,
              color: boldColor, fontSize: 15),
        ));
      } else {
        spans.add(TextSpan(
          text: part,
          style: TextStyle(fontFamily: 'GoogleSans', color: baseColor, fontSize: 15, height: 1.5),
        ));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ─── Indicateur "en train d'écrire" ──────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    ));
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.blanc, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.blanc,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => AnimatedBuilder(
                animation: _ctrls[i],
                builder: (_, child) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.or.withAlpha((80 + (_ctrls[i].value * 175)).toInt()),
                    shape: BoxShape.circle,
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Indicateur d'écoute active ──────────────────────────────────────────────

class _ListeningBanner extends StatefulWidget {
  const _ListeningBanner();

  @override
  State<_ListeningBanner> createState() => _ListeningBannerState();
}

class _ListeningBannerState extends State<_ListeningBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.rouge.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.rouge.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.rouge.withAlpha((120 + (_pulse.value * 135)).toInt()),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.of(context).aiListening,
              style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.rouge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Zone de saisie ──────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.isListening,
    required this.onMicTap,
  });
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final bool isListening;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blanc,
      padding: EdgeInsets.fromLTRB(0, 10, 0, MediaQuery.of(context).padding.bottom + 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => SizeTransition(
              sizeFactor: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: isListening
                ? const _ListeningBanner()
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onMicTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: isListening ? AppColors.rouge : AppColors.fond2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: isListening ? AppColors.blanc : AppColors.grisMid,
                      size: 22,
                    ),
                  ),
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
                      decoration: InputDecoration(
                        hintText: AppStrings.of(context).aiInputHint,
                        hintStyle: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.grisLight),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      onSubmitted: onSend,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => onSend(controller.text),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.or, AppColors.orDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.or.withAlpha(100), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.blanc, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
