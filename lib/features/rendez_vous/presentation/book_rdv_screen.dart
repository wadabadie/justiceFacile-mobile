import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

class BookRdvScreen extends StatefulWidget {
  const BookRdvScreen({
    super.key,
    required this.dossierId,
    required this.canal,
    required this.specialisteNom,
  });

  final int dossierId;
  final String canal;
  final String specialisteNom;

  @override
  State<BookRdvScreen> createState() => _BookRdvScreenState();
}

class _Dispo {
  const _Dispo({
    required this.id,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
  });
  final int id;
  final DateTime date;
  final String heureDebut;
  final String heureFin;
}

class _BookRdvScreenState extends State<BookRdvScreen> {
  List<_Dispo> _dispos = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.instance.get(
        ApiConstants.rdvDisponibilites(widget.dossierId, widget.canal.toLowerCase()),
      );
      final list = (res.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .map((json) => _Dispo(
                id: json['id'] as int,
                date: DateTime.parse(json['date'] as String),
                heureDebut: (json['heure_debut'] as String).substring(0, 5),
                heureFin: (json['heure_fin'] as String).substring(0, 5),
              ))
          .toList();
      if (!mounted) return;
      setState(() { _dispos = list; _loading = false; });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = ApiService.extractError(e.response?.data);
      });
    }
  }

  Future<void> _reserver(_Dispo dispo) async {
    final s = AppStrings.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.rdvConfirmTitle),
        content: Text(s.rdvConfirmMsg(
          widget.specialisteNom,
          _fmtDate(dispo.date),
          dispo.heureDebut,
          dispo.heureFin,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.btnCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.bleuNuit),
            child: Text(s.rdvConfirmBtn, style: const TextStyle(color: AppColors.blanc)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _submitting = true);
    try {
      await ApiService.instance.post(
        ApiConstants.demanderRdv(widget.dossierId, widget.canal.toLowerCase()),
        data: {'disponibilite_id': dispo.id},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.rdvBookedSuccess),
        backgroundColor: AppColors.emeraude,
      ));
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response?.data != null
            ? ApiService.extractError(e.response?.data)
            : s.rdvBookedError),
        backgroundColor: AppColors.rouge,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Map<DateTime, List<_Dispo>> get _grouped {
    final map = <DateTime, List<_Dispo>>{};
    for (final d in _dispos) {
      final key = DateTime(d.date.year, d.date.month, d.date.day);
      map.putIfAbsent(key, () => []).add(d);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _Header(specialisteNom: widget.specialisteNom, canal: widget.canal),
          Expanded(child: _buildBody(s)),
        ],
      ),
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
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'GoogleSans', color: AppColors.grisMid)),
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
    if (_dispos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.orLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.event_busy_rounded, size: 46, color: AppColors.or),
            ),
            const SizedBox(height: 20),
            Text(s.rdvNoSlotsTitle,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 18,
                  fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
                )),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(s.rdvNoSlotsDesc, textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 14,
                    color: AppColors.grisMid, height: 1.5,
                  )),
            ),
          ],
        ),
      );
    }

    final groups = _grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: groups.length,
        itemBuilder: (_, i) {
          final (date, list) = (groups[i].key, groups[i].value);
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DayHeader(date: date),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: list.map((d) => _SlotChip(
                    label: '${d.heureDebut}—${d.heureFin}',
                    disabled: _submitting,
                    onTap: () => _reserver(d),
                  )).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.specialisteNom, required this.canal});
  final String specialisteNom;
  final String canal;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
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
          padding: const EdgeInsets.fromLTRB(6, 4, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.blanc),
                  ),
                  Expanded(
                    child: Text(s.rdvBookTitle,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 22,
                          fontWeight: FontWeight.w700, color: AppColors.blanc,
                        )),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 0, 0),
                child: Text(
                  s.rdvBookSubtitle(specialisteNom),
                  style: const TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 14,
                    color: AppColors.orPale,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date});
  final DateTime date;

  static const _weekdays = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
  ];
  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  @override
  Widget build(BuildContext context) {
    final label = '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppColors.bleuNuit.withAlpha(12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.calendar_today_rounded,
              color: AppColors.bleuNuit, size: 16),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
              fontFamily: 'GoogleSans', fontSize: 15,
              fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
            )),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.onTap,
    required this.disabled,
  });
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              disabled ? AppColors.grisLight : AppColors.or,
              disabled ? AppColors.grisMid : AppColors.orDark,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: disabled ? null : const [AppColors.ombreOr],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time_rounded, size: 16, color: AppColors.blanc),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppColors.blanc,
                )),
          ],
        ),
      ),
    );
  }
}
