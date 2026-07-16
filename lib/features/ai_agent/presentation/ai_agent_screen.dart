import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
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

// ─── Réponses simulées ────────────────────────────────────────────────────────

String _mockResponse(String query) {
  final q = query.toLowerCase();

  if (q.contains('vbg') || q.contains('violence') || q.contains('agression') || q.contains('conjugal')) {
    return 'En cas de violence basée sur le genre, vous êtes protégé(e) par les articles 292 à 297 du Code pénal camerounais (Loi n° 2016/007).\n\n'
        '**Vos droits immédiats :**\n'
        '• Porter plainte auprès de la police (✆ 117) ou du parquet\n'
        '• Demander une ordonnance de protection\n'
        '• Accéder gratuitement à un accompagnement VBG via ce module\n\n'
        'Voulez-vous que je vous aide à préparer un signalement ?';
  }

  if (q.contains('licenci') || q.contains('travail') || q.contains('emploi') || q.contains('contrat')) {
    return 'Le Code du travail camerounais (Loi n° 92/007) protège les travailleurs contre les licenciements abusifs.\n\n'
        '**Points clés :**\n'
        '• Tout licenciement doit être justifié par une cause réelle et sérieuse\n'
        '• Un préavis est obligatoire (durée selon l\'ancienneté)\n'
        '• En cas de licenciement abusif : droit à des dommages-intérêts (art. 67)\n\n'
        'Avez-vous reçu une lettre de licenciement ? Je peux vous aider à l\'analyser.';
  }

  if (q.contains('terrain') || q.contains('foncier') || q.contains('propriété') || q.contains('heritage') || q.contains('héritage')) {
    return 'Les litiges fonciers au Cameroun sont régis par l\'Ordonnance n° 74-1 du 6 juillet 1974.\n\n'
        '**À savoir :**\n'
        '• La propriété est prouvée par le titre foncier ou l\'immatriculation\n'
        '• Les droits coutumiers sont reconnus mais doivent être formalisés\n'
        '• En cas de conflit : saisine du tribunal de grande instance\n\n'
        'Disposez-vous d\'un titre foncier ou d\'un acte notarié ?';
  }

  if (q.contains('mariage') || q.contains('divorce') || q.contains('pension') || q.contains('famille')) {
    return 'Le droit de la famille camerounais est encadré par l\'Ordonnance n° 81-02 et le Code civil.\n\n'
        '**En matière de divorce :**\n'
        '• Divorce possible par consentement mutuel ou pour faute\n'
        '• La pension alimentaire est fixée par le juge selon les ressources\n'
        '• La garde des enfants suit l\'intérêt supérieur de l\'enfant\n\n'
        'Souhaitez-vous des informations sur une situation particulière ?';
  }

  if (q.contains('plainte') || q.contains('porter plainte') || q.contains('signalement')) {
    return 'Pour porter plainte au Cameroun :\n\n'
        '**Étapes à suivre :**\n'
        '1. Rendez-vous au commissariat ou à la gendarmerie le plus proche\n'
        '2. Demandez à "déposer une plainte" ou à faire une "déclaration"\n'
        '3. Conservez le procès-verbal remis par l\'agent\n'
        '4. Vous pouvez aussi saisir directement le Procureur de la République\n\n'
        'Via Justice Facile, vous pouvez également faire un signalement anonyme dans le module VBG.';
  }

  if (q.contains('droit') || q.contains('loi') || q.contains('texte')) {
    return 'La bibliothèque juridique de Justice Facile contient les principaux textes de loi camerounais :\n\n'
        '• Code pénal (2016)\n'
        '• Code du travail (1992)\n'
        '• Code de procédure pénale (2005)\n'
        '• Loi sur la protection de l\'enfant (2019)\n'
        '• Régime foncier (1974)\n\n'
        'Vous pouvez y accéder depuis la section **Textes de Loi**. Sur quel texte voulez-vous des précisions ?';
  }

  if (q.contains('bonjour') || q.contains('salut') || q.contains('bonsoir') || q.contains('aide')) {
    return 'Bonjour ! Je suis l\'Assistant IA de Justice Facile.\n\n'
        'Je peux vous aider à :\n'
        '• Comprendre vos droits\n'
        '• Identifier les lois applicables à votre situation\n'
        '• Préparer vos démarches juridiques\n'
        '• Vous orienter vers le bon spécialiste\n\n'
        'Quelle est votre situation ?';
  }

  return 'Je comprends votre question. Pour vous apporter une réponse précise et adaptée à votre situation, '
      'je vous recommande de :\n\n'
      '• Consulter la section **Textes de Loi** pour les références légales\n'
      '• Contacter un **Juriste** disponible sur la plateforme\n'
      '• Ouvrir un **dossier** pour un suivi personnalisé\n\n'
      'Pouvez-vous me donner plus de détails sur votre situation ?';
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

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _ctrl.clear();

    setState(() {
      _messages.add(_AiMessage(text: trimmed, sender: _Sender.user));
      _isTyping = true;
    });
    _scrollDown();

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(_AiMessage(text: _mockResponse(trimmed), sender: _Sender.ai));
    });
    _scrollDown();
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
            child: _messages.isEmpty
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
          _InputBar(controller: _ctrl, onSend: _send),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assistant IA',
                        style: TextStyle(fontFamily: 'GoogleSans', fontSize: 19,
                            fontWeight: FontWeight.w700, color: AppColors.blanc)),
                    Text('Conseil juridique intelligent',
                        style: TextStyle(fontFamily: 'GoogleSans', fontSize: 13,
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
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: AppColors.emeraude),
                    SizedBox(width: 5),
                    Text('En ligne',
                        style: TextStyle(fontFamily: 'GoogleSans', fontSize: 12,
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
                const Text('Bonjour ! Je suis JF·IA',
                    style: TextStyle(fontFamily: 'GoogleSans', fontSize: 22,
                        fontWeight: FontWeight.w700, color: AppColors.blanc)),
                const SizedBox(height: 8),
                const Text(
                  'Votre assistant juridique intelligent.\nPosez-moi n\'importe quelle question sur vos droits au Cameroun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'GoogleSans', fontSize: 15,
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
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.orPale, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Les réponses sont informatives. Consultez un juriste pour un avis professionnel.',
                          style: TextStyle(fontFamily: 'GoogleSans', fontSize: 13,
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
              Text('Questions fréquentes', style: AppTextStyles.h2.copyWith(fontSize: 18)),
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

// ─── Zone de saisie ──────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blanc,
      padding: EdgeInsets.fromLTRB(14, 10, 14, MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: AppColors.fond2, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.mic_none_rounded, color: AppColors.grisMid, size: 22),
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
                  hintText: 'Posez votre question juridique...',
                  hintStyle: TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.grisLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
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
    );
  }
}
