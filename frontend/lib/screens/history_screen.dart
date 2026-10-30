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
  TipoEstudo? _filtroTipoEstudo; // null = Todas, questoes, pdf
  int? _idDisciplinaSelecionada;

  @override
  Widget build(BuildContext context) {
    final provedorEstudo = context.watch<StudyProvider>();
    final todasSessoes = provedorEstudo.sessoes;
    final disciplinas = provedorEstudo.disciplinas;
    final tema = Theme.of(context);
    final ehModoEscuro = tema.brightness == Brightness.dark;

    // Aplicação dos filtros
    final sessoesFiltradas = todasSessoes.where((sessao) {
      if (_filtroTipoEstudo != null &&
          sessao.tipoEstudo != _filtroTipoEstudo) {
        return false;
      }
      if (_idDisciplinaSelecionada != null &&
          sessao.idDisciplina != _idDisciplinaSelecionada) {
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
            style: tema.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Acompanhe todas as sessões registradas por questões e PDF.',
            style: TextStyle(
              color: ehModoEscuro
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Linha de Filtros
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Todas as Sessões'),
                selected: _filtroTipoEstudo == null,
                onSelected: (estaSelecionado) {
                  setState(() {
                    _filtroTipoEstudo = null;
                  });
                },
              ),
              FilterChip(
                avatar: const Icon(Icons.format_list_numbered_rounded, size: 16),
                label: const Text('Questões'),
                selected: _filtroTipoEstudo == TipoEstudo.questoes,
                onSelected: (estaSelecionado) {
                  setState(() {
                    _filtroTipoEstudo =
                        estaSelecionado ? TipoEstudo.questoes : null;
                  });
                },
              ),
              FilterChip(
                avatar: const Icon(Icons.menu_book_rounded, size: 16),
                label: const Text('PDF / Leituras'),
                selected: _filtroTipoEstudo == TipoEstudo.pdf,
                onSelected: (estaSelecionado) {
                  setState(() {
                    _filtroTipoEstudo =
                        estaSelecionado ? TipoEstudo.pdf : null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filtro suspenso por Disciplina
          if (disciplinas.isNotEmpty)
            DropdownButtonFormField<int?>(
              value: _idDisciplinaSelecionada,
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
                ...disciplinas.map((disciplina) {
                  return DropdownMenuItem<int?>(
                    value: disciplina.id,
                    child: Text(disciplina.nome),
                  );
                }),
              ],
              onChanged: (novoId) {
                setState(() {
                  _idDisciplinaSelecionada = novoId;
                });
              },
            ),
          const SizedBox(height: 24),

          if (sessoesFiltradas.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: tema.cardTheme.color,
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
              itemCount: sessoesFiltradas.length,
              separatorBuilder: (contextoSeparador, indice) =>
                  const SizedBox(height: 12),
              itemBuilder: (contextoItem, indice) {
                final sessao = sessoesFiltradas[indice];
                final ehQuestoes =
                    sessao.tipoEstudo == TipoEstudo.questoes;
                final dataSessaoFormatada =
                    DateFormat('dd/MM/yyyy • HH:mm').format(sessao.dataSessao);

                return Container(
                  decoration: BoxDecoration(
                    color: tema.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ehModoEscuro
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Linha Superior: Disciplina + Duração
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
                                color: sessao.corDisciplina.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    ehQuestoes
                                        ? Icons.format_list_numbered_rounded
                                        : Icons.menu_book_rounded,
                                    size: 14,
                                    color: sessao.corDisciplina,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    sessao.nomeDisciplina,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: sessao.corDisciplina,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: ehModoEscuro
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
                                    sessao.duracaoFormatada,
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

                        // Título / Tópico
                        if (sessao.topico != null &&
                            sessao.topico!.isNotEmpty)
                          Text(
                            sessao.topico!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        const SizedBox(height: 6),

                        // Métricas específicas da sessão
                        if (ehQuestoes) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (sessao.taxaAcerto ?? 0) >= 70
                                      ? const Color(0xFF10B981).withOpacity(0.12)
                                      : const Color(0xFFF59E0B).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${sessao.questoesCorretas ?? 0} de ${sessao.totalQuestoes ?? 0} acertos (${(sessao.taxaAcerto ?? 0).toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (sessao.taxaAcerto ?? 0) >= 70
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
                                  'Parou na Pág: ${sessao.paginaParada ?? 0}${sessao.quantidadePaginasLidas != null && sessao.quantidadePaginasLidas! > 0 ? " • ${sessao.quantidadePaginasLidas} pág lidas" : ""}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0891B2),
                                  ),
                                ),
                              ),
                              if (sessao.tituloMaterial != null &&
                                  sessao.tituloMaterial!.isNotEmpty)
                                Text(
                                  '(${sessao.tituloMaterial})',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ],

                        if (sessao.anotacoes != null &&
                            sessao.anotacoes!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            sessao.anotacoes!,
                            style: TextStyle(
                              fontSize: 13,
                              color: ehModoEscuro
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // Rodapé: Data e Botão Excluir
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dataSessaoFormatada,
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
                              onPressed: () =>
                                  _confirmarExclusaoSessao(context, sessao),
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

  void _confirmarExclusaoSessao(
      BuildContext contexto, StudySession sessao) {
    showDialog(
      context: contexto,
      builder: (contextoDialogo) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir Registro'),
        content: const Text(
          'Deseja realmente remover esta sessão do seu histórico?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(contextoDialogo);
              final provedor = contexto.read<StudyProvider>();
              await provedor.excluirSessao(sessao.id);
              if (contexto.mounted) {
                ScaffoldMessenger.of(contexto).showSnackBar(
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
