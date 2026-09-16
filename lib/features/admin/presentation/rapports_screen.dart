import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

// ─── Modèle journal d'audit ───────────────────────────────────────────────────

class _AuditEntry {
  _AuditEntry({
    required this.id,
    required this.action,
    required this.utilisateur,
    required this.details,
    required this.ipAddress,
    required this.date,
  });

  final int id;
  final String action;
  final String utilisateur;
  final String details;
  final String ipAddress;
  final DateTime date;

  factory _AuditEntry.fromJson(Map<String, dynamic> j) => _AuditEntry(
        id:           j['id'] as int? ?? 0,
        action:       j['action'] as String? ?? '',
        utilisateur:  j['utilisateur'] as String?
                          ?? j['user'] as String?
                          ?? 'Inconnu',
        details:      j['details'] as String? ?? '',
        ipAddress:    j['ip_address'] as String? ?? '',
        date:         DateTime.tryParse(j['date'] as String?
                          ?? j['date_action'] as String?
                          ?? '')
                          ?.toLocal()
                      ?? DateTime.now(),
      );

  String get dateLabel {
    final d = date;
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} $h:$m';
  }

  IconData get icon => switch (action.toUpperCase()) {
    String a when a.contains('LOGIN')    => Icons.login_rounded,
    String a when a.contains('CREATE')   => Icons.add_circle_rounded,
    String a when a.contains('DELETE')   => Icons.delete_rounded,
    String a when a.contains('UPDATE')   => Icons.edit_rounded,
    String a when a.contains('EXPORT')   => Icons.download_rounded,
    String a when a.contains('CERTIF')   => Icons.verified_rounded,
    _                                    => Icons.info_outline_rounded,
  };

  Color get iconColor => switch (action.toUpperCase()) {
    String a when a.contains('DELETE')   => AppColors.rouge,
    String a when a.contains('CREATE')   => AppColors.emeraude,
    String a when a.contains('CERTIF')   => AppColors.bleuMid,
    String a when a.contains('LOGIN')    => AppColors.or,
    _                                    => AppColors.grisMid,
  };
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen> {
  List<_AuditEntry> _entries = [];
  bool _loading = true;
  String? _error;
  bool _exportingCsv = false;
  bool _exportingPdf = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.instance.get(ApiConstants.adminJournalAudit);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _entries = list
            .map((e) => _AuditEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ApiService.extractError(e.response?.data);
        _loading = false;
      });
    }
  }

  Future<void> _exportCsv() async {
    if (_exportingCsv) return;
    setState(() => _exportingCsv = true);
    try {
      final res = await ApiService.instance.get(ApiConstants.adminExportDossiersCsv);
      if (!mounted) return;
      final count = (res.data is List)
          ? (res.data as List).length
          : null;
      final s = AppStrings.of(context);
      final msg = count != null
          ? s.rapportsCsvReady(count)
          : s.rapportsCsvSuccess;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.emeraude,
        duration: const Duration(seconds: 3),
      ));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    } finally {
      if (mounted) setState(() => _exportingCsv = false);
    }
  }

  Future<void> _exportPdf() async {
    if (_exportingPdf) return;
    setState(() => _exportingPdf = true);
    try {
      await ApiService.instance.get(ApiConstants.adminExportRapportPdf);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).rapportsPdfSuccess,
              style: const TextStyle(fontFamily: 'GoogleSans')),
          backgroundColor: AppColors.emeraude,
          duration: const Duration(seconds: 3),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _RapportsHeader(onBack: () => context.go('/admin')),
          _ExportBar(
            exportingCsv: _exportingCsv,
            exportingPdf: _exportingPdf,
            onCsv: _exportCsv,
            onPdf: _exportPdf,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.adminRapports),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grisLight),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.grisMid)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppStrings.of(context).btnRetry),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleuNuit, foregroundColor: AppColors.blanc),
            ),
          ],
        ),
      );
    }
    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_rounded, size: 48, color: AppColors.grisLight),
            const SizedBox(height: 14),
            Text(AppStrings.of(context).rapportsEmpty,
                style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bleuNuit)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: _entries.length,
        itemBuilder: (_, i) => _AuditTile(entry: _entries[i]),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _RapportsHeader extends StatelessWidget {
  const _RapportsHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2A), AppColors.bleuNuit],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
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
                      Text(s.rapportsTitle,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blanc)),
                      Text(s.rapportsAuditLog,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 13,
                              color: Color(0x80FFFFFF))),
                    ],
                  );
                }),
              ),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.orPale, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Barre d'exports ─────────────────────────────────────────────────────────

class _ExportBar extends StatelessWidget {
  const _ExportBar({
    required this.exportingCsv,
    required this.exportingPdf,
    required this.onCsv,
    required this.onPdf,
  });
  final bool exportingCsv, exportingPdf;
  final VoidCallback onCsv, onPdf;

  @override
  Widget build(BuildContext context) {
    final isFr = Localizations.localeOf(context).languageCode == 'fr';
    return Container(
      color: AppColors.blanc,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _ExportBtn(
              label: isFr ? 'Exporter CSV' : 'Export CSV',
              icon: Icons.table_chart_rounded,
              color: AppColors.emeraude,
              loading: exportingCsv,
              onTap: onCsv,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ExportBtn(
              label: isFr ? 'Exporter PDF' : 'Export PDF',
              icon: Icons.picture_as_pdf_rounded,
              color: AppColors.rouge,
              loading: exportingPdf,
              onTap: onPdf,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportBtn extends StatelessWidget {
  const _ExportBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: loading ? AppColors.fond2 : color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: loading ? AppColors.grisLight : color.withAlpha(60)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: color),
                  )
                : Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: loading ? AppColors.grisLight : color)),
          ],
        ),
      ),
    );
  }
}

// ─── Tuile journal d'audit ────────────────────────────────────────────────────

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.entry});
  final _AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: entry.iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(entry.icon, color: entry.iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(entry.action,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bleuNuit)),
                    ),
                    Text(entry.dateLabel,
                        style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 11,
                            color: AppColors.grisLight)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(entry.utilisateur,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 12,
                        color: AppColors.bleuMid,
                        fontWeight: FontWeight.w500)),
                if (entry.details.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(entry.details,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 12,
                          color: AppColors.grisMid,
                          height: 1.4)),
                ],
                if (entry.ipAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.router_rounded,
                          size: 11, color: AppColors.grisLight),
                      const SizedBox(width: 4),
                      Text(entry.ipAddress,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 11,
                              color: AppColors.grisLight)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
