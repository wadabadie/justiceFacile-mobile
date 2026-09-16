import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class _Cas {
  const _Cas({
    required this.id,
    required this.code,
    required this.categorie,
    required this.resume,
    required this.estUrgent,
    required this.dateCreation,
  });
  final int id;
  final String code, categorie, resume;
  final bool estUrgent;
  final DateTime dateCreation;

  factory _Cas.fromJson(Map<String, dynamic> j) => _Cas(
    id: j['id'] as int,
    code: j['code_reference'] as String? ?? '',
    categorie: j['categorie_display'] as String? ?? j['categorie'] as String? ?? '',
    resume: j['resume_public'] as String? ?? '',
    estUrgent: j['est_urgent'] as bool? ?? false,
    dateCreation: DateTime.tryParse(j['date_creation'] as String? ?? '') ?? DateTime.now(),
  );
}

class CasDisponiblesScreen extends StatefulWidget {
  const CasDisponiblesScreen({super.key});

  @override
  State<CasDisponiblesScreen> createState() => _CasDisponiblesScreenState();
}

class _CasDisponiblesScreenState extends State<CasDisponiblesScreen> {
  List<_Cas> _cas = [];
  bool _loading = true;
  String? _error;
  final Set<int> _proposing = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.instance.get(ApiConstants.demandesDisponibles);
      final list = (res.data as List<dynamic>)
          .map((e) => _Cas.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() { _cas = list; _loading = false; });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = ApiService.extractError(e.response?.data);
      });
    }
  }

  Future<void> _proposer(_Cas cas) async {
    final s = AppStrings.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.casProposeConfirmTitle),
        content: Text(s.casProposeConfirmMsg(cas.code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.btnCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.bleuNuit),
            child: Text(s.casProposeConfirmBtn,
                style: const TextStyle(color: AppColors.blanc)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _proposing.add(cas.id));
    try {
      await ApiService.instance.post(ApiConstants.demandeProposer(cas.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.casProposeSuccess),
        backgroundColor: AppColors.emeraude,
      ));
      setState(() => _cas.removeWhere((c) => c.id == cas.id));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response?.data != null
            ? ApiService.extractError(e.response?.data)
            : s.casProposeError),
        backgroundColor: AppColors.rouge,
      ));
    } finally {
      if (mounted) setState(() => _proposing.remove(cas.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _Header(count: _cas.length, s: s),
          Expanded(child: _buildBody(s)),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.casDispo),
    );
  }

  Widget _buildBody(AppStrings s) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grisLight),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(
              fontFamily: 'GoogleSans', color: AppColors.grisMid,
            )),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(s.btnRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bleuNuit, foregroundColor: AppColors.blanc,
              ),
            ),
          ],
        ),
      );
    }
    if (_cas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: AppColors.orLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.inbox_rounded, size: 46, color: AppColors.or),
              ),
              const SizedBox(height: 20),
              Text(s.casEmptyTitle,
                  style: AppTextStyles.h3.copyWith(color: AppColors.bleuNuit)),
              const SizedBox(height: 8),
              Text(s.casEmptyDesc, textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.grisMid, height: 1.5)),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _cas.length,
        itemBuilder: (_, i) => _CasCard(
          cas: _cas[i],
          proposing: _proposing.contains(_cas[i].id),
          onPropose: () => _proposer(_cas[i]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.s});
  final int count;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.casTitle,
                        style: AppTextStyles.h1.copyWith(color: AppColors.blanc)),
                    const SizedBox(height: 2),
                    Text(s.casSubtitle,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 13,
                          color: Color(0xB3FFFFFF),
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.or,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$count',
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 20,
                      fontWeight: FontWeight.w800, color: AppColors.blanc,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CasCard extends StatelessWidget {
  const _CasCard({required this.cas, required this.proposing, required this.onPropose});
  final _Cas cas;
  final bool proposing;
  final VoidCallback onPropose;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: cas.estUrgent ? AppColors.rouge : AppColors.or,
            width: 4,
          ),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cas.code,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 13,
                      fontWeight: FontWeight.w700, color: AppColors.orDark,
                      letterSpacing: 0.5,
                    )),
                Text(_fmt(cas.dateCreation),
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 12, color: AppColors.grisMid,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(cas.categorie,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 13,
                        fontWeight: FontWeight.w600, color: AppColors.bleuMid,
                      )),
                ),
                if (cas.estUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.rougeLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.priority_high_rounded, size: 12, color: AppColors.rouge),
                        const SizedBox(width: 4),
                        Text(s.statusUrgent,
                            style: const TextStyle(
                              fontFamily: 'GoogleSans', fontSize: 12,
                              fontWeight: FontWeight.w700, color: AppColors.rouge,
                            )),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(cas.resume,
                maxLines: 4, overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 14,
                  color: AppColors.gris, height: 1.5,
                )),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: proposing ? null : onPropose,
                icon: proposing
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                      )
                    : const Icon(Icons.handshake_rounded, size: 18),
                label: Text(s.casProposeBtn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleuNuit,
                  foregroundColor: AppColors.blanc,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
