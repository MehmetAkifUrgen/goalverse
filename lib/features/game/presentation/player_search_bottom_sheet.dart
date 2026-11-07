import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/freezed/entity_models.dart';

class PlayerSearchBottomSheet extends ConsumerStatefulWidget {
  final String? rowTeamName;
  final String? rowTeamLogoUrl;
  final String? rowTeamColorHex;
  final String? colTeamName;
  final String? colTeamLogoUrl;
  final String? colTeamColorHex;
  final int? cellIndex;

  const PlayerSearchBottomSheet({
    super.key,
    this.rowTeamName,
    this.rowTeamLogoUrl,
    this.rowTeamColorHex,
    this.colTeamName,
    this.colTeamLogoUrl,
    this.colTeamColorHex,
    this.cellIndex,
  });

  @override
  ConsumerState<PlayerSearchBottomSheet> createState() =>
      _PlayerSearchBottomSheetState();
}

class _PlayerSearchBottomSheetState
    extends ConsumerState<PlayerSearchBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Player> _results = const [];
  bool _loading = false;
  Timer? _debounceTimer;

  static const List<String> _quickQueries = [
    'Ronaldo',
    'Messi',
    'Zlatan',
    'Arda',
    'Hakan',
    'Icardi',
    'Osimhen',
    'Sneijder',
    'Quaresma',
    'Mbappe',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = const [];
        _loading = false;
      });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 90), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(playerRepositoryProvider);
      final results = await repo.searchPlayers(query, limit: 20);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildTargetCellHeader(BuildContext context) {
    if (widget.rowTeamName == null || widget.colTeamName == null) {
      return const SizedBox.shrink();
    }
    final cellLabel = widget.cellIndex != null
        ? 'HÜCRE ${(widget.cellIndex! ~/ 3) + 1}-${(widget.cellIndex! % 3) + 1}'
        : 'SEÇİLİ HÜCRE';

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 12, 18, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pitchGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.electricLime.withValues(alpha: 0.65),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          AppTheme.clubCrestWidget(
            logoUrl: widget.rowTeamLogoUrl,
            teamName: widget.rowTeamName,
            primaryColorHex: widget.rowTeamColorHex,
            size: 30,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.rowTeamName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(
                fontSize: 12.5,
                color: AppColors.warmWhite,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.electricLime.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '×  $cellLabel',
              style: AppTypography.label(
                fontSize: 10,
                color: AppColors.electricLime,
              ),
            ),
          ),
          Expanded(
            child: Text(
              widget.colTeamName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTypography.label(
                fontSize: 12.5,
                color: AppColors.warmWhite,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AppTheme.clubCrestWidget(
            logoUrl: widget.colTeamLogoUrl,
            teamName: widget.colTeamName,
            primaryColorHex: widget.colTeamColorHex,
            size: 30,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              _buildTargetCellHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: l10n.searchPlayerHint,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: scheme.primary,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _debounceTimer?.cancel();
                              _controller.clear();
                              setState(() => _results = const []);
                            },
                          )
                        : null,
                  ),
                  onChanged: _onTextChanged,
                ),
              ),
              if (_controller.text.trim().isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Popüler Aramalar',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickQueries.map((q) {
                          return ActionChip(
                            label: Text(q),
                            onPressed: () {
                              _controller.text = q;
                              _controller.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(offset: q.length),
                                  );
                              _search(q);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                )
              else if (_loading)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                )
              else if (_results.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.errorPlayerNotFound,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final player = _results[index];
                      final flag = AppTheme.nationalityFlag(player.nationality);
                      final posColor = AppTheme.positionColor(player.position);

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: AppTheme.playerAvatarWidget(
                            name: player.name,
                            overall: player.eaFcOverall,
                            position: player.position,
                            nationality: player.nationality,
                            size: 44,
                          ),
                          title: Text(
                            player.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              if (player.position != null &&
                                  player.position!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: posColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    player.position!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: posColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                '$flag ${player.nationality ?? ''}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: player.eaFcOverall != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: (player.eaFcOverall ?? 0) >= 90
                                        ? AppTheme.goldGradient
                                        : AppTheme.emeraldGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${player.eaFcOverall}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.of(context).pop(player),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
