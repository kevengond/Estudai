import 'package:flutter/material.dart';
import 'package:frontend/models/dashboard_stats.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:frontend/widgets/metric_card.dart';
import 'package:frontend/widgets/suggestion_hero_card.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) aoNavegarParaAba;

  const DashboardScreen({
    super.key,
    Function(int)? aoNavegarParaAba,
    Function(int)? onNavigateToTab,
  }) : aoNavegarParaAba = aoNavegarParaAba ?? onNavigateToTab ?? _funcaoVazia;

  static void _funcaoVazia(int _) {}

  // Getter de compatibilidade
  Function(int) get onNavigateToTab => aoNavegarParaAba;

  @override
  Widget build(BuildContext context) {
    final provedorEstudo = context.watch<StudyProvider>();
    final estatisticas = provedorEstudo.estatisticasPainel;
    final sugestao = provedorEstudo.sugestao;
    final tema = Theme.of(context);
    final ehModoEscuro = tema.brightness == Brightness.dark;

    if (provedorEstudo.estaCarregando && estatisticas == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => provedorEstudo.carregarTodosDados(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho de Boas-vindas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, Estudante! 🚀',
                        style: tema.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Foque na constância e domine seu ciclo de estudos.',
                        style: TextStyle(
                          color: ehModoEscuro
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => provedorEstudo.carregarTodosDados(),
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Atualizar dados',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Destaque: Continuar de Onde Parou
            SuggestionHeroCard(
              sugestao: sugestao,
              aoIniciarEstudo: () {
                if (sugestao != null) {
                  provedorEstudo.prepararAPartirDeSugestao(sugestao);
                  aoNavegarParaAba(1); // Aba de Registro
                }
              },
            ),
            const SizedBox(height: 24),

            // Grade de Métricas Principais
            Text(
              'SEU DESEMPENHO GERAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: ehModoEscuro
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (contextoLayout, restricoes) {
                final ehTelaLarga = restricoes.maxWidth > 600;
                final quantidadeColunas = ehTelaLarga ? 4 : 2;

                return GridView.count(
                  crossAxisCount: quantidadeColunas,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: ehTelaLarga ? 1.4 : 1.25,
                  children: [
                    MetricCard(
                      titulo: 'Tempo Total',
                      valor: estatisticas?.tempoTotalFormatado ?? '0h 00m',
                      subtitulo: '${estatisticas?.totalSessoes ?? 0} sessões',
                      icone: Icons.timer_outlined,
                      corIcone: const Color(0xFF6366F1),
                    ),
                    MetricCard(
                      titulo: 'Questões',
                      valor: '${estatisticas?.totalQuestoes ?? 0}',
                      subtitulo: '${estatisticas?.totalAcertos ?? 0} acertos',
                      icone: Icons.check_circle_outline_rounded,
                      corIcone: const Color(0xFF10B981),
                    ),
                    MetricCard(
                      titulo: 'Taxa de Acerto',
                      valor:
                          '${(estatisticas?.taxaAcertoGeral ?? 0).toStringAsFixed(1)}%',
                      subtitulo: 'Desempenho',
                      icone: Icons.pie_chart_outline_rounded,
                      corIcone: const Color(0xFFF59E0B),
                    ),
                    MetricCard(
                      titulo: 'Páginas Lidas',
                      valor: '${estatisticas?.totalPaginasLidas ?? 0}',
                      subtitulo: 'PDFs e livros',
                      icone: Icons.auto_stories_outlined,
                      corIcone: const Color(0xFF06B6D4),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Visão Geral das Disciplinas no Ciclo
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
                      color: ehModoEscuro
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => aoNavegarParaAba(2), // Aba Ciclo
                  child: const Text('Ver Ciclo →', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (provedorEstudo.disciplinasAtivas.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: tema.cardTheme.color,
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
                        onPressed: () => aoNavegarParaAba(3), // Aba Disciplinas
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
                itemCount: provedorEstudo.disciplinasAtivas.length,
                separatorBuilder: (contextoSeparador, indice) =>
                    const SizedBox(height: 8),
                itemBuilder: (contextoItem, indice) {
                  final disciplina = provedorEstudo.disciplinasAtivas[indice];
                  final metricasCorrespondentes = estatisticas?.metricasDisciplinas
                          .where((metricaItem) =>
                              metricaItem.idDisciplina == disciplina.id)
                          .toList() ??
                      [];
                  final SubjectMetric? metrica = metricasCorrespondentes.isNotEmpty
                      ? metricasCorrespondentes.first
                      : null;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tema.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ehModoEscuro
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
                            color: disciplina.cor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                disciplina.nome,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${disciplina.ordemCiclo}º no ciclo • Meta: ${disciplina.metaMinutos}m',
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
                              metrica?.duracaoFormatada ?? '0m',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${metrica?.totalQuestoes ?? 0}q • ${metrica?.totalPaginasLidas ?? 0}p',
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

            // Últimas Sessões
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
                      color: ehModoEscuro
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => aoNavegarParaAba(4), // Aba Histórico
                  child: const Text('Ver Todas →', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (provedorEstudo.sessoes.isEmpty)
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
                itemCount: provedorEstudo.sessoes.take(4).length,
                separatorBuilder: (contextoSeparador, indice) =>
                    const SizedBox(height: 8),
                itemBuilder: (contextoItem, indice) {
                  final sessao = provedorEstudo.sessoes[indice];
                  final ehQuestoes =
                      sessao.tipoEstudo == TipoEstudo.questoes;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tema.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ehModoEscuro
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              sessao.corDisciplina.withOpacity(0.15),
                          radius: 16,
                          child: Icon(
                            ehQuestoes
                                ? Icons.format_list_numbered_rounded
                                : Icons.menu_book_rounded,
                            color: sessao.corDisciplina,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sessao.nomeDisciplina,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ehQuestoes
                                    ? '${sessao.questoesCorretas ?? 0}/${sessao.totalQuestoes ?? 0} acertos • ${sessao.topico ?? "Geral"}'
                                    : 'Pág ${sessao.paginaParada ?? 0} • ${sessao.tituloMaterial ?? "PDF"}',
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
                          sessao.duracaoFormatada,
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
