import 'package:flutter/material.dart';
import 'package:frontend/models/dashboard_stats.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:frontend/widgets/metric_card.dart';
import 'package:frontend/widgets/suggestion_hero_card.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const DashboardScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final stats = studyProvider.dashboardStats;
    final suggestion = studyProvider.suggestion;
    final theme = Theme.of(context);

    if (studyProvider.isLoading && stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => studyProvider.loadAllData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header (Responsive with Expanded)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, Estudante! 🚀',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Foque na constância e domine seu ciclo de estudos.',
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
                IconButton(
                  onPressed: () => studyProvider.loadAllData(),
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Atualizar dados',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hero "Continuar de Onde Parou" Suggestion Card
            SuggestionHeroCard(
              suggestion: suggestion,
              onStartStudy: () {
                if (suggestion != null) {
                  studyProvider.prepareFromSuggestion(suggestion);
                  onNavigateToTab(1); // Aba de Registro
                }
              },
            ),
            const SizedBox(height: 24),

            // Key Metrics Grid
            Text(
              'SEU DESEMPENHO GERAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final crossAxisCount = isWide ? 4 : 2;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: isWide ? 1.4 : 1.25,
                  children: [
                    MetricCard(
                      title: 'Tempo Total',
                      value: stats?.formattedTotalTime ?? '0h 00m',
                      subtitle: '${stats?.totalSessions ?? 0} sessões',
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFF6366F1),
                    ),
                    MetricCard(
                      title: 'Questões',
                      value: '${stats?.totalQuestions ?? 0}',
                      subtitle: '${stats?.totalCorrect ?? 0} acertos',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: const Color(0xFF10B981),
                    ),
                    MetricCard(
                      title: 'Taxa de Acerto',
                      value:
                          '${(stats?.overallAccuracyRate ?? 0).toStringAsFixed(1)}%',
                      subtitle: 'Desempenho',
                      icon: Icons.pie_chart_outline_rounded,
                      iconColor: const Color(0xFFF59E0B),
                    ),
                    MetricCard(
                      title: 'Páginas Lidas',
                      value: '${stats?.totalPagesRead ?? 0}',
                      subtitle: 'PDFs e livros',
                      icon: Icons.auto_stories_outlined,
                      iconColor: const Color(0xFF06B6D4),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Disciplines in the Cycle Overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'DISCIPLINAS NO CICLO',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab(2), // Ciclo
                  child: const Text('Ver Ciclo →', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (studyProvider.activeSubjects.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.school_outlined,
                          size: 44, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text(
                        'Nenhuma disciplina ativa no ciclo.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: () => onNavigateToTab(3), // Disciplinas
                        child: const Text('Cadastrar / Ativar'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: studyProvider.activeSubjects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final sub = studyProvider.activeSubjects[index];
                  final matchingMetrics = stats?.subjectMetrics
                          .where((m) => m.subjectId == sub.id)
                          .toList() ??
                      [];
                  final SubjectMetric? metric =
                      matchingMetrics.isNotEmpty ? matchingMetrics.first : null;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 38,
                          decoration: BoxDecoration(
                            color: sub.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${sub.cycleOrder}º no ciclo • Meta: ${sub.targetMinutes}m',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              metric?.formattedDuration ?? '0m',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${metric?.totalQuestions ?? 0}q • ${metric?.totalPagesRead ?? 0}p',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 28),

            // Recent Sessions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'ÚLTIMAS SESSÕES',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab(4), // Histórico
                  child: const Text('Ver Todas →', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (studyProvider.sessions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Nenhuma sessão registrada ainda.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: studyProvider.sessions.take(4).length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final sess = studyProvider.sessions[index];
                  final isQ = sess.studyType == StudyType.questions;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: sess.subjectColor.withOpacity(0.15),
                          radius: 16,
                          child: Icon(
                            isQ
                                ? Icons.format_list_numbered_rounded
                                : Icons.menu_book_rounded,
                            color: sess.subjectColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sess.subjectName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isQ
                                    ? '${sess.correctQuestions ?? 0}/${sess.totalQuestions ?? 0} acertos • ${sess.topic ?? "Geral"}'
                                    : 'Pág ${sess.pageStopped ?? 0} • ${sess.materialTitle ?? "PDF"}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sess.formattedDuration,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
