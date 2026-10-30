import 'package:flutter/material.dart';
import 'package:frontend/models/cycle_suggestion.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:provider/provider.dart';

class CycleScreen extends StatefulWidget {
  final Function(int) aoNavegarParaAba;

  const CycleScreen({
    super.key,
    Function(int)? aoNavegarParaAba,
    Function(int)? onNavigateToTab,
  }) : aoNavegarParaAba = aoNavegarParaAba ?? onNavigateToTab ?? _funcaoVazia;

  static void _funcaoVazia(int _) {}

  // Getter de compatibilidade
  Function(int) get onNavigateToTab => aoNavegarParaAba;

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  List<Subject> _listaReordenada = [];
  bool _salvandoOrdem = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_salvandoOrdem) {
      final provedorEstudo = context.watch<StudyProvider>();
      _listaReordenada = List.from(provedorEstudo.disciplinasAtivas);
    }
  }

  Future<void> _moverDisciplina(int indiceAntigo, int indiceNovo) async {
    if (_salvandoOrdem) return;
    if (indiceNovo < 0 || indiceNovo >= _listaReordenada.length) return;

    setState(() {
      _salvandoOrdem = true;
      final itemRemovido = _listaReordenada.removeAt(indiceAntigo);
      _listaReordenada.insert(indiceNovo, itemRemovido);
    });

    try {
      final provedorEstudo = context.read<StudyProvider>();
      final idsDisciplinas = _listaReordenada.map((item) => item.id).toList();
      await provedorEstudo.reordenarCiclo(idsDisciplinas);
    } finally {
      if (mounted) {
        setState(() {
          _salvandoOrdem = false;
          _listaReordenada =
              List.from(context.read<StudyProvider>().disciplinasAtivas);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provedorEstudo = context.watch<StudyProvider>();
    final sugestao = provedorEstudo.sugestao;
    final tema = Theme.of(context);
    final disciplinaSugerida = sugestao?.disciplinaSugerida;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ciclo de Estudos 🔄',
                      style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Use as setas ↑ ↓ ou arraste para definir a ordem do ciclo.',
                      style: TextStyle(
                        color: tema.brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_salvandoOrdem)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),

          if (provedorEstudo.grupoSelecionado != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: provedorEstudo.grupoSelecionado!.cor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.layers_rounded,
                      size: 14, color: provedorEstudo.grupoSelecionado!.cor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Ciclo: ${provedorEstudo.grupoSelecionado!.nome}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: provedorEstudo.grupoSelecionado!.cor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Banner da Próxima Matéria Sugerida
          if (disciplinaSugerida != null && _listaReordenada.isNotEmpty) ...[
            _construirDestaqueProximaSugestao(context, sugestao!, tema),
            const SizedBox(height: 20),
          ],

          // Lista de disciplinas do ciclo
          if (_listaReordenada.isEmpty)
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
                          widget.aoNavegarParaAba(3), // Aba Matérias
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
              itemCount: _listaReordenada.length,
              onReorder: (indiceAntigo, indiceNovo) {
                if (indiceNovo > indiceAntigo) {
                  indiceNovo -= 1;
                }
                _moverDisciplina(indiceAntigo, indiceNovo);
              },
              itemBuilder: (contextoItem, indice) {
                final disciplina = _listaReordenada[indice];
                final ehProximaSugerida =
                    disciplinaSugerida?.id == disciplina.id;

                final ehPrimeira = indice == 0;
                final ehUltima = indice == _listaReordenada.length - 1;

                return Material(
                  key: ValueKey(disciplina.id),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      provedorEstudo.prepararAPartirDeDisciplina(disciplina);
                      widget.aoNavegarParaAba(1); // Aba Registro
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: tema.cardTheme.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ehProximaSugerida
                              ? tema.colorScheme.primary
                              : (tema.brightness == Brightness.dark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                          width: ehProximaSugerida ? 2 : 1,
                        ),
                        boxShadow: ehProximaSugerida
                            ? [
                                BoxShadow(
                                  color: tema.colorScheme.primary
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
                            backgroundColor: disciplina.cor,
                            radius: 15,
                            child: Text(
                              '${indice + 1}',
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
                                        disciplina.nome,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (ehProximaSugerida) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: tema.colorScheme.primary
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'PRÓXIMA',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: tema.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Meta: ${disciplina.metaMinutos} min • Total: ${(disciplina.totalSegundosEstudo / 3600).toStringAsFixed(1)}h',
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
                              color: ehProximaSugerida
                                  ? tema.colorScheme.primary
                                  : Colors.grey.shade400,
                            ),
                            tooltip: 'Estudar agora',
                            onPressed: () {
                              if (ehProximaSugerida && sugestao != null) {
                                provedorEstudo.prepararAPartirDeSugestao(sugestao);
                              } else {
                                provedorEstudo.prepararAPartirDeDisciplina(disciplina);
                              }
                              widget.aoNavegarParaAba(1);
                            },
                          ),

                          // Seta para Cima (↑)
                          IconButton(
                            icon: Icon(
                              Icons.arrow_upward_rounded,
                              size: 19,
                              color: ehPrimeira || _salvandoOrdem
                                  ? Colors.grey.withOpacity(0.3)
                                  : tema.colorScheme.primary,
                            ),
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(),
                            tooltip:
                                ehPrimeira ? null : 'Mover para cima no ciclo',
                            onPressed: (ehPrimeira || _salvandoOrdem)
                                ? null
                                : () => _moverDisciplina(indice, indice - 1),
                          ),
                          const SizedBox(width: 2),

                          // Seta para Baixo (↓)
                          IconButton(
                            icon: Icon(
                              Icons.arrow_downward_rounded,
                              size: 19,
                              color: ehUltima || _salvandoOrdem
                                  ? Colors.grey.withOpacity(0.3)
                                  : tema.colorScheme.primary,
                            ),
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(),
                            tooltip:
                                ehUltima ? null : 'Mover para baixo no ciclo',
                            onPressed: (ehUltima || _salvandoOrdem)
                                ? null
                                : () => _moverDisciplina(indice, indice + 1),
                          ),
                          const SizedBox(width: 2),

                          // Ícone Amarelo: Olho (Ocultar do Ciclo)
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_off_outlined,
                              size: 19,
                              color: Color(0xFFF59E0B),
                            ),
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(),
                            tooltip:
                                'Deixar invisível no ciclo (mantém histórico)',
                            onPressed: () =>
                                _confirmarOcultarDoCiclo(context, disciplina),
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
                                _confirmarExcluirDisciplina(context, disciplina),
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

  Widget _construirDestaqueProximaSugestao(
    BuildContext contexto,
    NextStudySuggestion sugestao,
    ThemeData tema,
  ) {
    final disciplina = sugestao.disciplinaSugerida;
    if (disciplina == null) return const SizedBox.shrink();

    final provedorEstudo = contexto.read<StudyProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tema.brightness == Brightness.dark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tema.colorScheme.primary.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tema.colorScheme.primary.withOpacity(0.1),
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
                  color: tema.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.autorenew_rounded,
                        size: 13, color: tema.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'PRÓXIMA NO CICLO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: tema.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (sugestao.statusCiclo.isNotEmpty)
                Text(
                  sugestao.statusCiclo,
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
                  color: disciplina.cor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  disciplina.nome,
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sugestao.detalhePontoParada.isNotEmpty
                ? sugestao.detalhePontoParada
                : 'Pronto para iniciar a sessão',
            style: TextStyle(
              fontSize: 12,
              color: tema.brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: tema.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                provedorEstudo.prepararAPartirDeSugestao(sugestao);
                widget.aoNavegarParaAba(1); // Aba Registro
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

  void _confirmarOcultarDoCiclo(BuildContext contexto, Subject disciplina) {
    showDialog(
      context: contexto,
      builder: (contextoDialogo) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.visibility_off_outlined, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Text('Ocultar do Ciclo'),
          ],
        ),
        content: Text(
          'Deseja ocultar "${disciplina.nome}" do ciclo de estudos ativo? O histórico e o tempo estudado continuarão salvos e você poderá reativá-la a qualquer momento na aba "Matérias".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(contextoDialogo);
              final provedorEstudo = contexto.read<StudyProvider>();
              await provedorEstudo.alternarDisciplinaAtivaNoCiclo(disciplina);
              if (mounted) {
                setState(() {
                  _listaReordenada =
                      List.from(provedorEstudo.disciplinasAtivas);
                });
              }
            },
            child: const Text('Ocultar do Ciclo'),
          ),
        ],
      ),
    );
  }

  void _confirmarExcluirDisciplina(
      BuildContext contexto, Subject disciplina) {
    showDialog(
      context: contexto,
      builder: (contextoDialogo) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Excluir Disciplina'),
          ],
        ),
        content: Text(
          'Deseja excluir "${disciplina.nome}" definitivamente? Isso removerá a matéria do ciclo e apagará o histórico associado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(contextoDialogo);
              final provedorEstudo = contexto.read<StudyProvider>();
              await provedorEstudo.excluirDisciplina(disciplina.id);
              if (mounted) {
                setState(() {
                  _listaReordenada =
                      List.from(provedorEstudo.disciplinasAtivas);
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
