import 'package:flutter/material.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  StudyType? _typeFilter; // null = Todas, questions, pdf
  int? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final allSessions = studyProvider.sessions;
    final subjects = studyProvider.subjects;
    final theme = Theme.of(context);

    // Apply filters
    final filteredSessions = allSessions.where((s) {
      if (_typeFilter != null && s.studyType != _typeFilter) return false;
      if (_selectedSubjectId != null && s.subjectId != _selectedSubjectId) {
        return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histórico de Estudos 📜',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Acompanhe todas as sessões registradas por questões e PDF.',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Filters Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Todas as Sessões'),
                selected: _typeFilter == null,
                onSelected: (selected) {
                  setState(() {
                    _typeFilter = null;
                  });
                },
              ),
              FilterChip(
                avatar: const Icon(Icons.format_list_numbered_rounded, size: 16),
                label: const Text('Questões'),
                selected: _typeFilter == StudyType.questions,
                onSelected: (selected) {
                  setState(() {
                    _typeFilter = selected ? StudyType.questions : null;
                  });
                },
              ),
              FilterChip(
                avatar: const Icon(Icons.menu_book_rounded, size: 16),
                label: const Text('PDF / Leituras'),
                selected: _typeFilter == StudyType.pdf,
                onSelected: (selected) {
                  setState(() {
                    _typeFilter = selected ? StudyType.pdf : null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Subject dropdown filter if multiple subjects exist
          if (subjects.isNotEmpty)
            DropdownButtonFormField<int?>(
              value: _selectedSubjectId,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                hintText: 'Filtrar por Disciplina',
                prefixIcon: Icon(Icons.filter_list_rounded),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todas as Disciplinas'),
                ),
                ...subjects.map((sub) {
                  return DropdownMenuItem<int?>(
                    value: sub.id,
                    child: Text(sub.name),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedSubjectId = val;
                });
              },
            ),
          const SizedBox(height: 24),

          if (filteredSessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.history_toggle_off_rounded,
                        size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Nenhum registro encontrado para este filtro.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSessions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sess = filteredSessions[index];
                final isQ = sess.studyType == StudyType.questions;
                final dateFormatted =
                    DateFormat('dd/MM/yyyy • HH:mm').format(sess.sessionDate);

                return Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Subject badge + Date + Duration
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: sess.subjectColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isQ
                                        ? Icons.format_list_numbered_rounded
                                        : Icons.menu_book_rounded,
                                    size: 14,
                                    color: sess.subjectColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    sess.subjectName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: sess.subjectColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    sess.formattedDuration,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Title / Topic
                        if (sess.topic != null && sess.topic!.isNotEmpty)
                          Text(
                            sess.topic!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        const SizedBox(height: 6),

                        // Metrics content (Questions details or PDF details)
                        if (isQ) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (sess.accuracyRate ?? 0) >= 70
                                      ? const Color(0xFF10B981).withOpacity(0.12)
                                      : const Color(0xFFF59E0B).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${sess.correctQuestions ?? 0} de ${sess.totalQuestions ?? 0} acertos (${(sess.accuracyRate ?? 0).toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (sess.accuracyRate ?? 0) >= 70
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Parou na Pág: ${sess.pageStopped ?? 0}${sess.pagesReadCount != null && sess.pagesReadCount! > 0 ? " • ${sess.pagesReadCount} pág lidas" : ""}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0891B2),
                                  ),
                                ),
                              ),
                              if (sess.materialTitle != null &&
                                  sess.materialTitle!.isNotEmpty)
                                Text(
                                  '(${sess.materialTitle})',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ],

                        if (sess.notes != null && sess.notes!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            sess.notes!,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // Bottom date + Delete action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateFormatted,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.red),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _confirmDeleteSession(context, sess),
                              tooltip: 'Excluir registro',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _confirmDeleteSession(BuildContext context, StudySession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir Registro'),
        content: const Text(
          'Deseja realmente remover esta sessão do seu histórico?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final p = context.read<StudyProvider>();
              await p.deleteSession(session.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sessão removida do histórico.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
