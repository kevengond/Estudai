import 'package:flutter/material.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:provider/provider.dart';

class CycleScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const CycleScreen({super.key, required this.onNavigateToTab});

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  List<Subject> _reorderedList = [];
  bool _isSavingOrder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSavingOrder) {
      final studyProvider = context.watch<StudyProvider>();
      _reorderedList = List.from(studyProvider.activeSubjects);
    }
  }

  Future<void> _moveSubject(int oldIndex, int newIndex) async {
    if (_isSavingOrder) return;
    if (newIndex < 0 || newIndex >= _reorderedList.length) return;

    setState(() {
      _isSavingOrder = true;
      final item = _reorderedList.removeAt(oldIndex);
      _reorderedList.insert(newIndex, item);
    });

    try {
      final studyProvider = context.read<StudyProvider>();
      final ids = _reorderedList.map((s) => s.id).toList();
      await studyProvider.reorderCycle(ids);
    } finally {
      if (mounted) {
        setState(() {
          _isSavingOrder = false;
          _reorderedList = List.from(context.read<StudyProvider>().activeSubjects);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final suggestion = studyProvider.suggestion;
    final theme = Theme.of(context);
    final suggestedSubject = suggestion?.suggestedSubject;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ciclo de Estudos 🔄',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Use as setas ↑ ↓ ou arraste para definir a ordem do ciclo.',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSavingOrder)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),

          if (studyProvider.selectedGroup != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: studyProvider.selectedGroup!.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.layers_rounded,
                      size: 14, color: studyProvider.selectedGroup!.color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Ciclo: ${studyProvider.selectedGroup!.name}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: studyProvider.selectedGroup!.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Hero Banner da Próxima Matéria Sugerida
          if (suggestedSubject != null && _reorderedList.isNotEmpty) ...[
            _buildNextSuggestionHero(context, suggestion!, theme),
            const SizedBox(height: 20),
          ],

          // Lista de disciplinas do ciclo
          if (_reorderedList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.sync_disabled_rounded,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'Nenhuma disciplina ativa no ciclo deste subgrupo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          widget.onNavigateToTab(3), // Disciplinas
                      child: const Text('Ver / Ativar Disciplinas'),
                    ),
                  ],
                ),
              ),
            )
          else
            ReorderableListView.builder(
              buildDefaultDragHandles: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reorderedList.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                _moveSubject(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final subject = _reorderedList[index];
                final isNextSuggested =
                    suggestedSubject?.id == subject.id;

                final isFirst = index == 0;
                final isLast = index == _reorderedList.length - 1;

                return Material(
                  key: ValueKey(subject.id),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      studyProvider.prepareFromSubject(subject);
                      widget.onNavigateToTab(1); // Registro
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isNextSuggested
                              ? theme.colorScheme.primary
                              : (theme.brightness == Brightness.dark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                          width: isNextSuggested ? 2 : 1,
                        ),
                        boxShadow: isNextSuggested
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Ordem no Ciclo
                          CircleAvatar(
                            backgroundColor: subject.color,
                            radius: 15,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Detalhes da matéria
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        subject.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (isNextSuggested) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'PRÓXIMA',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Meta: ${subject.targetMinutes} min • Total: ${(subject.totalStudySeconds / 3600).toStringAsFixed(1)}h',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Ação rápida: Iniciar Estudo
                          IconButton(
                            icon: Icon(
                              Icons.play_circle_fill_rounded,
                              size: 22,
                              color: isNextSuggested
                                  ? theme.colorScheme.primary
                                  : Colors.grey.shade400,
                            ),
                            tooltip: 'Estudar agora',
                            onPressed: () {
                              if (isNextSuggested && suggestion != null) {
                                studyProvider.prepareFromSuggestion(suggestion);
                              } else {
                                studyProvider.prepareFromSubject(subject);
                              }
                              widget.onNavigateToTab(1);
                            },
                          ),

                          // Seta para Cima (↑)
                          IconButton(
                            icon: Icon(
                              Icons.arrow_upward_rounded,
                              size: 19,
                              color: isFirst || _isSavingOrder
                                  ? Colors.grey.withOpacity(0.3)
                                  : theme.colorScheme.primary,
                            ),
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(),
                            tooltip: isFirst ? null : 'Mover para cima no ciclo',
                            onPressed: (isFirst || _isSavingOrder)
                                ? null
                                : () => _moveSubject(index, index - 1),
                          ),
                          const SizedBox(width: 2),

                          // Seta para Baixo (↓)
                          IconButton(
                            icon: Icon(
                              Icons.arrow_downward_rounded,
                              size: 19,
                              color: isLast || _isSavingOrder
                                  ? Colors.grey.withOpacity(0.3)
                                  : theme.colorScheme.primary,
                            ),
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(),
                            tooltip: isLast ? null : 'Mover para baixo no ciclo',
                            onPressed: (isLast || _isSavingOrder)
                                ? null
                                : () => _moveSubject(index, index + 1),
                          ),
                          const SizedBox(width: 2),

                          // Ícone Amarelo: Olho (Remover do Ciclo / Deixar Invisível)
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_off_outlined,
                              size: 19,
                              color: Color(0xFFF59E0B),
                            ),
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(),
                            tooltip: 'Deixar invisível no ciclo (mantém histórico)',
                            onPressed: () =>
                                _confirmRemoveFromCycle(context, subject),
                          ),
                          const SizedBox(width: 2),

                          // Ícone Vermelho: Lixeira (Excluir definitivamente)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 19, color: Colors.redAccent),
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(),
                            tooltip: 'Excluir disciplina definitivamente',
                            onPressed: () =>
                                _confirmDeleteSubject(context, subject),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNextSuggestionHero(
      BuildContext context, dynamic suggestion, ThemeData theme) {
    final subject = suggestion.suggestedSubject;
    final isQuestions = suggestion.suggestionType == StudyType.questions;
    final studyProvider = context.read<StudyProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.brightness == Brightness.dark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.autorenew_rounded,
                        size: 13, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'PRÓXIMA NO CICLO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (suggestion.cycleStatus.isNotEmpty)
                Text(
                  suggestion.cycleStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: subject.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subject.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            suggestion.checkpointDetail ?? 'Pronto para iniciar a sessão',
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                studyProvider.prepareFromSuggestion(suggestion);
                widget.onNavigateToTab(1); // Registro
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text(
                'Estudar Agora',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveFromCycle(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.visibility_off_outlined, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Text('Ocultar do Ciclo'),
          ],
        ),
        content: Text(
          'Deseja ocultar "${subject.name}" do ciclo de estudos ativo? O histórico e o tempo estudado continuarão salvos e você poderá reativá-la a qualquer momento na aba "Matérias".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final studyProvider = context.read<StudyProvider>();
              await studyProvider.toggleSubjectActiveInCycle(subject);
              if (mounted) {
                setState(() {
                  _reorderedList = List.from(studyProvider.activeSubjects);
                });
              }
            },
            child: const Text('Ocultar do Ciclo'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSubject(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Excluir Disciplina'),
          ],
        ),
        content: Text(
          'Deseja excluir "${subject.name}" definitivamente? Isso removerá a matéria do ciclo e apagará o histórico associado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final studyProvider = context.read<StudyProvider>();
              await studyProvider.deleteSubject(subject.id);
              if (mounted) {
                setState(() {
                  _reorderedList = List.from(studyProvider.activeSubjects);
                });
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
