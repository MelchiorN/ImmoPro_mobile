import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

class HistoriquePaiementsPage extends StatefulWidget {
  const HistoriquePaiementsPage({super.key});

  @override
  State<HistoriquePaiementsPage> createState() =>
      _HistoriquePaiementsPageState();
}

class _HistoriquePaiementsPageState extends State<HistoriquePaiementsPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 100 &&
        !_loadingMore &&
        _currentPage < _lastPage) {
      _load(reset: false);
    }
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _currentPage = 1;
        _items = [];
      });
    } else {
      setState(() => _loadingMore = true);
      _currentPage++;
    }

    try {
      final res = await ApiClient.instance.getAuth(
        '/mobile/historique-paiements?page=$_currentPage',
      );
      final List<dynamic> data = res['data'] ?? [];
      final lp = res['last_page'] as int? ?? 1;
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
          _lastPage = lp;
          _items.addAll(data.map((e) => e as Map<String, dynamic>));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
          _error = e.toString();
          if (reset) _currentPage = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF003E7E),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF003E7E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Historique des paiements',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _items.isEmpty
                ? _buildError()
                : _items.isEmpty
                    ? _buildEmpty()
                    : _buildList(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Impossible de charger l\'historique',
              style: TextStyle(fontFamily: 'HankenGrotesk')),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () => _load(reset: true),
              child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 72, color: AppColors.outline),
          const SizedBox(height: 16),
          const Text(
            'Aucun paiement',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vos transactions apparaîtront\nici dès votre première location.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _PaymentCard(item: _items[index]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _PaymentCard({required this.item});

  String _formatMontant(dynamic v) {
    if (v == null) return '— FCFA';
    final n = (v as num).toDouble();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)} M FCFA';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)} K FCFA';
    return '${n.toStringAsFixed(0)} FCFA';
  }

  String _formatDate(dynamic d) {
    if (d == null) return '—';
    try {
      final dt = DateTime.parse(d.toString());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return d.toString();
    }
  }

  Color _statutColor(String? statut) {
    switch (statut) {
      case 'valide':
      case 'actif':
        return const Color(0xFF006B3C);
      case 'en_attente':
      case 'initie':
        return const Color(0xFFD97706);
      case 'echoue':
      case 'refuse':
        return AppColors.error;
      default:
        return AppColors.outline;
    }
  }

  String _statutLabel(String? statut) {
    switch (statut) {
      case 'valide':       return 'Validé';
      case 'actif':        return 'Actif';
      case 'en_attente':   return 'En attente';
      case 'initie':       return 'Initié';
      case 'echoue':       return 'Échoué';
      case 'refuse':       return 'Refusé';
      case 'termine':      return 'Terminé';
      default:             return statut ?? '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bien = item['bien'] as Map<String, dynamic>?;
    final paiement = item['paiement'] as Map<String, dynamic>?;
    final recu = item['recu'] as Map<String, dynamic>?;
    final statut = (item['statut'] as String?) ?? '';
    final color = _statutColor(paiement?['statut'] as String? ?? statut);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête : bien + badge statut ─────────────────────────────
            Row(
              children: [
                // Miniature
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: bien?['image'] != null
                        ? Image.network(
                            bien!['image'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imgPlaceholder(),
                          )
                        : _imgPlaceholder(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bien?['titre'] as String? ?? 'Bien inconnu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${bien?['ville'] ?? ''} — ${item['duree_mois'] ?? '?'} mois',
                        style: const TextStyle(
                          fontFamily: 'HankenGrotesk',
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge statut
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statutLabel(
                        paiement?['statut'] as String? ?? statut),
                    style: TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFECEEF0)),
            const SizedBox(height: 12),

            // ── Détails paiement ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailItem(
                  label: 'Montant',
                  value: _formatMontant(paiement?['montant'] ?? item['montant_total']),
                  bold: true,
                  color: const Color(0xFF1A56A0),
                ),
                _DetailItem(
                  label: 'Date',
                  value: _formatDate(paiement?['created_at'] ?? item['created_at']),
                ),
                _DetailItem(
                  label: 'Opérateur',
                  value: (paiement?['operateur_paiement'] as String?)
                          ?.toUpperCase() ??
                      '—',
                ),
              ],
            ),

            // ── Numéro de reçu ──────────────────────────────────────────
            if (recu != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.receipt_outlined,
                      size: 14, color: AppColors.outline),
                  const SizedBox(width: 6),
                  Text(
                    'Reçu n° ${recu['numero_recu']}',
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: const Center(
        child: Icon(Icons.home_outlined, color: AppColors.outline, size: 24),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _DetailItem({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 9,
            letterSpacing: 0.8,
            color: AppColors.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
