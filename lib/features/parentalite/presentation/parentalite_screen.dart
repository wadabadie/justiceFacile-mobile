import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

// ─── Modèles ──────────────────────────────────────────────────────────────────

class _Contenu {
  _Contenu({
    required this.id,
    required this.titre,
    required this.corps,
    required this.categorie,
    required this.lu,
  });
  final int id;
  final String titre;
  final String corps;
  final String categorie;
  bool lu;

  factory _Contenu.fromJson(Map<String, dynamic> j) => _Contenu(
        id:        j['id'] as int,
        titre:     j['titre'] as String? ?? '',
        corps:     j['contenu'] as String? ?? j['corps'] as String? ?? '',
        categorie: j['categorie'] as String? ?? 'general',
        lu:        j['lu'] as bool? ?? false,
      );

  Color get catColor => switch (categorie.toLowerCase()) {
    'nutrition'  => AppColors.emeraude,
    'education'  => AppColors.bleuMid,
    'sante'      => AppColors.rouge,
    'psychologie'=> AppColors.or,
    _            => AppColors.grisMid,
  };

  IconData get catIcon => switch (categorie.toLowerCase()) {
    'nutrition'  => Icons.restaurant_rounded,
    'education'  => Icons.school_rounded,
    'sante'      => Icons.health_and_safety_rounded,
    'psychologie'=> Icons.psychology_rounded,
    _            => Icons.article_rounded,
  };
}

class _Option {
  _Option({required this.id, required this.texte});
  final int id;
  final String texte;

  factory _Option.fromJson(Map<String, dynamic> j) => _Option(
        id:    j['id'] as int,
        texte: j['texte'] as String? ?? '',
      );
}

class _Question {
  _Question({required this.id, required this.question, required this.options});
  final int id;
  final String question;
  final List<_Option> options;
  int? selectedOptionId;

  factory _Question.fromJson(Map<String, dynamic> j) => _Question(
        id:       j['id'] as int,
        question: j['question'] as String? ?? '',
        options:  (j['options'] as List<dynamic>? ?? [])
                      .map((o) => _Option.fromJson(o as Map<String, dynamic>))
                      .toList(),
      );
}

class _Progression {
  _Progression({
    required this.contenuTitre,
    required this.lu,
    required this.scoreQuiz,
  });
  final String contenuTitre;
  final bool lu;
  final int? scoreQuiz;

  factory _Progression.fromJson(Map<String, dynamic> j) {
    final contenu = j['contenu'];
    return _Progression(
      contenuTitre: contenu is Map
          ? (contenu['titre'] as String? ?? 'Contenu')
          : (j['contenu_titre'] as String? ?? 'Contenu'),
      lu:           j['lu'] as bool? ?? false,
      scoreQuiz:    j['score_quiz'] as int?,
    );
  }
}

// ─── Messages agent ───────────────────────────────────────────────────────────

enum _Sender { user, ai }

class _ChatMsg {
  _ChatMsg({required this.text, required this.sender, DateTime? time})
      : time = time ?? DateTime.now();
  final String text;
  final _Sender sender;
  final DateTime time;
}

// ─── Écran principal ──────────────────────────────────────────────────────────

class ParentaliteScreen extends StatefulWidget {
  const ParentaliteScreen({super.key});

  @override
  State<ParentaliteScreen> createState() => _ParentaliteScreenState();
}

class _ParentaliteScreenState extends State<ParentaliteScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Contenus
  List<_Contenu> _contenus = [];
  bool _loadingContenus = true;
  String? _errorContenus;

  // Progressions
  List<_Progression> _progressions = [];
  bool _loadingProgress = true;
  String? _errorProgress;

  // Agent chat
  final _chatCtrl = TextEditingController();
  final _chatScroll = ScrollController();
  final _chatMsgs = <_ChatMsg>[];
  bool _chatTyping = false;
  bool _chatHistoryLoaded = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (_tab.index == 1 && _loadingProgress) _loadProgressions();
        if (_tab.index == 2 && !_chatHistoryLoaded) _loadChatHistory();
      });
    _loadContenus();
  }

  @override
  void dispose() {
    _tab.dispose();
    _chatCtrl.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  // ── Contenus ──────────────────────────────────────────────────────────────

  Future<void> _loadContenus() async {
    setState(() { _loadingContenus = true; _errorContenus = null; });
    try {
      final res = await ApiService.instance.get(ApiConstants.parentaliteContenus);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _contenus = list
            .map((e) => _Contenu.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingContenus = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorContenus = ApiService.extractError(e.response?.data);
        _loadingContenus = false;
      });
    }
  }

  void _openContenu(_Contenu c) {
    // Mark as read optimistically
    if (!c.lu) {
      ApiService.instance
          .post(ApiConstants.parentaliteContenuLu(c.id))
          .then((_) {
        if (mounted) setState(() => c.lu = true);
      }).catchError((_) {});
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContenuSheet(contenu: c),
    );
  }

  // ── Progressions ──────────────────────────────────────────────────────────

  Future<void> _loadProgressions() async {
    setState(() { _loadingProgress = true; _errorProgress = null; });
    try {
      final res =
          await ApiService.instance.get(ApiConstants.parentaliteProgressions);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _progressions = list
            .map((e) => _Progression.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingProgress = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorProgress = ApiService.extractError(e.response?.data);
        _loadingProgress = false;
      });
    }
  }

  // ── Agent parentalité ─────────────────────────────────────────────────────

  Future<void> _loadChatHistory() async {
    _chatHistoryLoaded = true;
    try {
      final res = await ApiService.instance
          .get(ApiConstants.agentParentaliteHistorique);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      final msgs = <_ChatMsg>[];
      for (final item in list) {
        final date =
            DateTime.tryParse(item['date_creation'] as String? ?? '')
                ?.toLocal() ??
            DateTime.now();
        msgs.add(_ChatMsg(
            text: item['question'] as String? ?? '',
            sender: _Sender.user,
            time: date));
        msgs.add(_ChatMsg(
            text: item['reponse'] as String? ?? '',
            sender: _Sender.ai,
            time: date));
      }
      setState(() => _chatMsgs.addAll(msgs));
      if (msgs.isNotEmpty) _scrollChat();
    } on DioException {
      // History load failure is silent
    }
  }

  Future<void> _sendChat(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _chatTyping) return;
    _chatCtrl.clear();
    setState(() {
      _chatMsgs.add(_ChatMsg(text: trimmed, sender: _Sender.user));
      _chatTyping = true;
    });
    _scrollChat();
    try {
      final res = await ApiService.instance
          .post(ApiConstants.agentParentalite, data: {'question': trimmed});
      if (!mounted) return;
      final reponse = res.data['reponse'] as String? ?? '';
      final date =
          DateTime.tryParse(res.data['date_creation'] as String? ?? '')
              ?.toLocal() ??
          DateTime.now();
      setState(() {
        _chatTyping = false;
        _chatMsgs.add(
            _ChatMsg(text: reponse, sender: _Sender.ai, time: date));
      });
      _scrollChat();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _chatTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  void _scrollChat() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _ParentaliteHeader(
              onBack: () => context.go('/home'), tabController: _tab),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildContenus(),
                _buildProgressions(),
                _buildAgent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1 : Contenus ──────────────────────────────────────────────────────

  Widget _buildContenus() {
    if (_loadingContenus) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }
    if (_errorContenus != null) {
      return _ErrorRetry(error: _errorContenus!, onRetry: _loadContenus);
    }
    if (_contenus.isEmpty) {
      return _EmptyState(
          icon: Icons.menu_book_rounded,
          message: AppStrings.of(context).parentaliteEmpty);
    }
    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _loadContenus,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: _contenus.length,
        itemBuilder: (_, i) => _ContenuCard(
          contenu: _contenus[i],
          onTap: () => _openContenu(_contenus[i]),
        ),
      ),
    );
  }

  // ── Tab 2 : Mon parcours ──────────────────────────────────────────────────

  Widget _buildProgressions() {
    if (_loadingProgress) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }
    if (_errorProgress != null) {
      return _ErrorRetry(error: _errorProgress!, onRetry: _loadProgressions);
    }
    if (_progressions.isEmpty) {
      return _EmptyState(
          icon: Icons.timeline_rounded,
          message: AppStrings.of(context).parentaliteProgressEmpty);
    }

    final total = _progressions.length;
    final lus = _progressions.where((p) => p.lu).length;
    final avecScore =
        _progressions.where((p) => p.scoreQuiz != null).toList();
    final avgScore = avecScore.isEmpty
        ? null
        : avecScore.map((p) => p.scoreQuiz!).reduce((a, b) => a + b) ~/
            avecScore.length;

    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _loadProgressions,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          // Résumé
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.bleuNuit, AppColors.emeraude],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatMini(
                      label: AppStrings.of(context).parentaliteLus,
                      value: '$lus / $total',
                      icon: Icons.check_circle_rounded),
                ),
                Container(
                    width: 1, height: 40, color: Colors.white24),
                Expanded(
                  child: _StatMini(
                      label: AppStrings.of(context).parentaliteScoreMoyen,
                      value: avgScore != null ? '$avgScore%' : '—',
                      icon: Icons.star_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._progressions.map((p) => _ProgressionTile(item: p)),
        ],
      ),
    );
  }

  // ── Tab 3 : Agent parentalité ─────────────────────────────────────────────

  Widget _buildAgent() {
    return Column(
      children: [
        // Mini bannière agent
        Container(
          color: AppColors.emeraudeLight,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Builder(builder: (ctx) {
            final s = AppStrings.of(ctx);
            return Row(
              children: [
                const Icon(Icons.smart_toy_rounded,
                    size: 16, color: AppColors.emeraude),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.parentaliteAgentBanner,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 12,
                        color: AppColors.emeraude,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          }),
        ),
        Expanded(
          child: _chatMsgs.isEmpty && !_chatTyping
              ? Center(
                  child: Builder(builder: (ctx) {
                    final s = AppStrings.of(ctx);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.child_care_rounded,
                            size: 56, color: AppColors.grisLight),
                        const SizedBox(height: 14),
                        Text(
                          s.parentaliteAgentEmpty,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 15,
                              color: AppColors.grisMid),
                        ),
                      ],
                    );
                  }),
                )
              : ListView.builder(
                  controller: _chatScroll,
                  padding:
                      const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount:
                      _chatMsgs.length + (_chatTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _chatMsgs.length) {
                      return const _TypingDots();
                    }
                    return _ChatBubble(msg: _chatMsgs[i]);
                  },
                ),
        ),
        _ChatInput(
            controller: _chatCtrl,
            sending: _chatTyping,
            onSend: _sendChat),
      ],
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ParentaliteHeader extends StatelessWidget {
  const _ParentaliteHeader(
      {required this.onBack, required this.tabController});
  final VoidCallback onBack;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bleuNuit, AppColors.emeraude],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.blanc, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Builder(builder: (ctx) {
                      final s = AppStrings.of(ctx);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.parentaliteTitle,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blanc)),
                          Text(s.parentaliteSubtitle,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 13,
                                  color: Color(0x99FFFFFF))),
                        ],
                      );
                    }),
                  ),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.child_care_rounded,
                        color: AppColors.orPale, size: 20),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: tabController,
              indicatorColor: AppColors.orPale,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
              unselectedLabelStyle:
                  const TextStyle(fontFamily: 'GoogleSans', fontSize: 13),
              labelColor: AppColors.blanc,
              unselectedLabelColor: const Color(0x80FFFFFF),
              tabs: [
                Tab(text: AppStrings.of(context).parentaliteTab1),
                Tab(text: AppStrings.of(context).parentaliteTab2),
                Tab(text: AppStrings.of(context).parentaliteTab3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carte contenu ────────────────────────────────────────────────────────────

class _ContenuCard extends StatelessWidget {
  const _ContenuCard({required this.contenu, required this.onTap});
  final _Contenu contenu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = contenu;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 80,
              decoration: BoxDecoration(
                color: c.catColor,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                  color: c.catColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(c.catIcon, color: c.catColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.titre,
                        style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bleuNuit),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(c.categorie.toUpperCase(),
                        style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.catColor,
                            letterSpacing: 0.8)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                c.lu
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: c.lu ? 20 : 14,
                color: c.lu ? AppColors.emeraude : AppColors.grisLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheet — contenu + quiz ───────────────────────────────────────────

class _ContenuSheet extends StatefulWidget {
  const _ContenuSheet({required this.contenu});
  final _Contenu contenu;

  @override
  State<_ContenuSheet> createState() => _ContenuSheetState();
}

class _ContenuSheetState extends State<_ContenuSheet> {
  List<_Question> _questions = [];
  bool _loadingQuiz = false;
  bool _submittingQuiz = false;
  int? _scoreResult;
  bool _quizMode = false;

  Future<void> _loadQuiz() async {
    setState(() { _loadingQuiz = true; });
    try {
      final res = await ApiService.instance
          .get(ApiConstants.parentaliteQuiz(widget.contenu.id));
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _questions = list
            .map((e) => _Question.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingQuiz = false;
        _quizMode = _questions.isNotEmpty;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loadingQuiz = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  Future<void> _submitQuiz() async {
    final allAnswered = _questions.every((q) => q.selectedOptionId != null);
    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).parentaliteRepondreToutes,
              style: const TextStyle(fontFamily: 'GoogleSans')),
          backgroundColor: AppColors.or,
        ),
      );
      return;
    }

    setState(() => _submittingQuiz = true);
    try {
      // Submit to each quiz question's quiz id (using question id as quiz id)
      final reponses = _questions
          .map((q) => {
                'question_id': q.id,
                'option_id': q.selectedOptionId,
              })
          .toList();
      // Use the first question's id as the quiz reference, or the contenu id
      final res = await ApiService.instance.post(
        ApiConstants.parentaliteQuizSoumettre(widget.contenu.id),
        data: {'reponses': reponses},
      );
      if (!mounted) return;
      final score = res.data['score'] as int?
          ?? res.data['score_pourcentage'] as int?
          ?? 0;
      setState(() {
        _scoreResult = score;
        _submittingQuiz = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _submittingQuiz = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contenu;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Poignée
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                    color: const Color(0x20000000),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Titre + catégorie
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                      color: c.catColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(c.catIcon, color: c.catColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.titre,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bleuNuit)),
                      Text(c.categorie.toUpperCase(),
                          style: TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: c.catColor,
                              letterSpacing: 0.8)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (!_quizMode) ...[
              // Corps du contenu
              Text(c.corps,
                  style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 14,
                      color: AppColors.gris,
                      height: 1.6)),
              const SizedBox(height: 20),
              // Bouton quiz
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadingQuiz ? null : _loadQuiz,
                  icon: _loadingQuiz
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.blanc))
                      : const Icon(Icons.quiz_rounded),
                  label: Text(AppStrings.of(context).parentaliteDemarrerQuiz,
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bleuNuit,
                    foregroundColor: AppColors.blanc,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ] else if (_scoreResult != null) ...[
              // Résultat du quiz
              _ScoreResult(score: _scoreResult!),
            ] else ...[
              // Questions du quiz
              Text(AppStrings.of(context).parentaliteQuizTitle,
                  style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bleuNuit)),
              const SizedBox(height: 14),
              ..._questions.asMap().entries.map((e) => _QuestionWidget(
                    index: e.key,
                    question: e.value,
                    onSelect: (optionId) =>
                        setState(() => e.value.selectedOptionId = optionId),
                  )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submittingQuiz ? null : _submitQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraude,
                    foregroundColor: AppColors.blanc,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _submittingQuiz
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.blanc))
                      : Text(AppStrings.of(context).parentaliteSoumettre,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Widget question ──────────────────────────────────────────────────────────

class _QuestionWidget extends StatelessWidget {
  const _QuestionWidget(
      {required this.index, required this.question, required this.onSelect});
  final int index;
  final _Question question;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Q${index + 1}. ${question.question}',
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bleuNuit,
                  height: 1.4)),
          const SizedBox(height: 10),
          ...question.options.map((opt) {
            final selected = question.selectedOptionId == opt.id;
            return GestureDetector(
              onTap: () => onSelect(opt.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color:
                      selected ? AppColors.bleuNuit : AppColors.fond,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppColors.bleuNuit
                        : const Color(0x18000000),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.orPale
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? AppColors.orPale
                              : AppColors.grisLight,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              size: 12, color: AppColors.bleuNuit)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(opt.texte,
                          style: TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 14,
                              color: selected
                                  ? AppColors.blanc
                                  : AppColors.gris)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Résultat quiz ────────────────────────────────────────────────────────────

class _ScoreResult extends StatelessWidget {
  const _ScoreResult({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? AppColors.emeraude
        : score >= 40
            ? AppColors.or
            : AppColors.rouge;
    final s = AppStrings.of(context);
    final label = score >= 70
        ? s.parentaliteExcellent
        : score >= 40
            ? s.parentaliteBien
            : s.parentaliteReviser;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Icon(score >= 70 ? Icons.emoji_events_rounded : Icons.refresh_rounded,
              color: color, size: 48),
          const SizedBox(height: 12),
          Text('$score%',
              style: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: color)),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

// ─── Tuile progression ────────────────────────────────────────────────────────

class _ProgressionTile extends StatelessWidget {
  const _ProgressionTile({required this.item});
  final _Progression item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color:
                  item.lu ? AppColors.emeraudeLight : AppColors.fond2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.lu
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color:
                  item.lu ? AppColors.emeraude : AppColors.grisLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.contenuTitre,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bleuNuit),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(item.lu
                        ? AppStrings.of(context).parentaliteLu
                        : AppStrings.of(context).parentaliteNonLu,
                    style: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 12,
                        color: item.lu
                            ? AppColors.emeraude
                            : AppColors.grisLight)),
              ],
            ),
          ),
          if (item.scoreQuiz != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: item.scoreQuiz! >= 70
                    ? AppColors.emeraudeLight
                    : AppColors.orLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${item.scoreQuiz}%',
                  style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: item.scoreQuiz! >= 70
                          ? AppColors.emeraude
                          : AppColors.or)),
            ),
        ],
      ),
    );
  }
}

// ─── Stat mini (résumé parcours) ──────────────────────────────────────────────

class _StatMini extends StatelessWidget {
  const _StatMini(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.orPale, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.blanc)),
        Text(label,
            style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 12,
                color: Color(0x99FFFFFF))),
      ],
    );
  }
}

// ─── Chat bubbles & input ─────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.msg});
  final _ChatMsg msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.sender == _Sender.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.emeraude,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.blanc, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isUser ? AppColors.bleuNuit : AppColors.blanc,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ],
              ),
              child: Text(msg.text,
                  style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 14,
                      color: isUser ? AppColors.blanc : AppColors.gris,
                      height: 1.45)),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        3,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 500)));
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160),
          () { if (mounted) _ctrls[i].repeat(reverse: true); });
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
                color: AppColors.emeraude,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.smart_toy_rounded,
                color: AppColors.blanc, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.blanc,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  3,
                  (i) => AnimatedBuilder(
                        animation: _ctrls[i],
                        builder: (_, child) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.emeraude.withAlpha(
                                (80 + _ctrls[i].value * 175).toInt()),
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

class _ChatInput extends StatelessWidget {
  const _ChatInput(
      {required this.controller,
      required this.sending,
      required this.onSend});
  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blanc,
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.fond,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x1A000000)),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 14,
                    color: AppColors.gris),
                decoration: InputDecoration(
                  hintText: AppStrings.of(context).parentaliteHint,
                  hintStyle: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 14,
                      color: AppColors.grisLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: onSend,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: sending ? null : () => onSend(controller.text),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: sending ? AppColors.grisLight : AppColors.emeraude,
                shape: BoxShape.circle,
                boxShadow: sending
                    ? []
                    : [
                        BoxShadow(
                            color: AppColors.emeraude.withAlpha(80),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.blanc))
                  : const Icon(Icons.send_rounded,
                      color: AppColors.blanc, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Utilitaires ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
                color: AppColors.fond2, shape: BoxShape.circle),
            child: Icon(icon, size: 36, color: AppColors.grisLight),
          ),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bleuNuit)),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.grisLight),
          const SizedBox(height: 16),
          Text(error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 15,
                  color: AppColors.grisMid)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AppStrings.of(context).btnRetry),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bleuNuit,
                foregroundColor: AppColors.blanc),
          ),
        ],
      ),
    );
  }
}
