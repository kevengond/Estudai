import 'package:flutter/material.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:frontend/widgets/study_timer_widget.dart';
import 'package:provider/provider.dart';

class RecordStudyScreen extends StatefulWidget {
  final VoidCallback? aoSalvarSessao;

  const RecordStudyScreen({
    super.key,
    VoidCallback? aoSalvarSessao,
    VoidCallback? onSessionSaved,
  }) : aoSalvarSessao = aoSalvarSessao ?? onSessionSaved;

  VoidCallback? get onSessionSaved => aoSalvarSessao;

  @override
  State<RecordStudyScreen> createState() => _RecordStudyScreenState();
}

class _RecordStudyScreenState extends State<RecordStudyScreen> {
  final _chaveFormulario = GlobalKey<FormState>();

  late TextEditingController _controladorTopico;
  late TextEditingController _controladorAnotacoes;

  // Controladores do modo Questões
  late TextEditingController _controladorTotalQuestoes;
  late TextEditingController _controladorQuestoesCorretas;

  // Controladores do modo PDF
  late TextEditingController _controladorTituloMaterial;
  late TextEditingController _controladorPaginaParada;
  late TextEditingController _controladorQuantidadePaginasLidas;

  @override
  void initState() {
    super.initState();
    final provedor = context.read<StudyProvider>();
    _controladorTopico = TextEditingController(text: provedor.topico);
    _controladorAnotacoes = TextEditingController(text: provedor.anotacoes);
    _controladorTotalQuestoes = TextEditingController(
      text: provedor.totalQuestoes > 0 ? '${provedor.totalQuestoes}' : '',
    );
    _controladorQuestoesCorretas = TextEditingController(
      text: provedor.questoesCorretas > 0 ? '${provedor.questoesCorretas}' : '',
    );
    _controladorTituloMaterial =
        TextEditingController(text: provedor.tituloMaterial);
    _controladorPaginaParada = TextEditingController(
      text: provedor.paginaParada > 0 ? '${provedor.paginaParada}' : '',
    );
    _controladorQuantidadePaginasLidas = TextEditingController(
      text: provedor.quantidadePaginasLidas > 0
          ? '${provedor.quantidadePaginasLidas}'
          : '',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provedor = context.watch<StudyProvider>();
    if (_controladorTopico.text != provedor.topico) {
      _controladorTopico.text = provedor.topico;
    }
    if (_controladorAnotacoes.text != provedor.anotacoes) {
      _controladorAnotacoes.text = provedor.anotacoes;
    }
    if (provedor.tipoEstudoSelecionado == TipoEstudo.questoes) {
      if (provedor.totalQuestoes > 0 &&
          _controladorTotalQuestoes.text != '${provedor.totalQuestoes}') {
        _controladorTotalQuestoes.text = '${provedor.totalQuestoes}';
      }
      if (provedor.questoesCorretas > 0 &&
          _controladorQuestoesCorretas.text != '${provedor.questoesCorretas}') {
        _controladorQuestoesCorretas.text = '${provedor.questoesCorretas}';
      }
    } else {
      if (_controladorTituloMaterial.text != provedor.tituloMaterial) {
        _controladorTituloMaterial.text = provedor.tituloMaterial;
      }
      if (provedor.paginaParada > 0 &&
          _controladorPaginaParada.text != '${provedor.paginaParada}') {
        _controladorPaginaParada.text = '${provedor.paginaParada}';
      }
    }
  }

  @override
  void dispose() {
    _controladorTopico.dispose();
    _controladorAnotacoes.dispose();
    _controladorTotalQuestoes.dispose();
    _controladorQuestoesCorretas.dispose();
    _controladorTituloMaterial.dispose();
    _controladorPaginaParada.dispose();
    _controladorQuantidadePaginasLidas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provedorEstudo = context.watch<StudyProvider>();
    final tema = Theme.of(context);
    final ehModoEscuro = tema.brightness == Brightness.dark;

    final disciplinas = provedorEstudo.disciplinas;
    final ehQuestoes =
        provedorEstudo.tipoEstudoSelecionado == TipoEstudo.questoes;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _chaveFormulario,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar Sessão de Estudo 📚',
              style: tema.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cronometre seu tempo e registre seu progresso por questões ou PDF.',
              style: TextStyle(
                color: ehModoEscuro
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // 1. Cronômetro / Tempo de Estudo
            const StudyTimerWidget(),
            const SizedBox(height: 24),

            // 2. Seleção de Disciplina
            Text(
              'DISCIPLINA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: ehModoEscuro
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),

            if (disciplinas.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Você ainda não possui disciplinas cadastradas. Cadastre uma disciplina primeiro na aba "Disciplinas".',
                      ),
                    ),
                  ],
                ),
              )
            else
              Builder(
                builder: (contextoDropdown) {
                  final mapaDisciplinasUnicas = <int, Subject>{};
                  for (final item in disciplinas) {
                    mapaDisciplinasUnicas[item.id] = item;
                  }
                  final listaDisciplinasLimpa =
                      mapaDisciplinasUnicas.values.toList();
                  final idSelecionado = listaDisciplinasLimpa.any(
                    (item) => item.id == provedorEstudo.disciplinaSelecionada?.id,
                  )
                      ? provedorEstudo.disciplinaSelecionada?.id
                      : (listaDisciplinasLimpa.isNotEmpty
                          ? listaDisciplinasLimpa.first.id
                          : null);

                  return DropdownButtonFormField<int?>(
                    key: ValueKey(idSelecionado),
                    value: idSelecionado,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.school_outlined),
                      hintText: 'Selecione uma disciplina',
                    ),
                    items: listaDisciplinasLimpa.map((disciplinaItem) {
                      return DropdownMenuItem<int?>(
                        value: disciplinaItem.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: disciplinaItem.cor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                disciplinaItem.nome,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${disciplinaItem.ordemCiclo}º no ciclo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (novoId) {
                      if (novoId != null) {
                        final correspondente =
                            listaDisciplinasLimpa.firstWhere(
                          (item) => item.id == novoId,
                          orElse: () => listaDisciplinasLimpa.first,
                        );
                        provedorEstudo.definirDisciplinaSelecionada(
                            correspondente);
                      }
                    },
                    validator: (valor) =>
                        valor == null ? 'Selecione uma disciplina' : null,
                  );
                },
              ),
            const SizedBox(height: 24),

            // 3. Seletor: Questões vs PDF
            Text(
              'TIPO DE ESTUDO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: ehModoEscuro
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ehModoEscuro
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        provedorEstudo.definirTipoEstudoSelecionado(
                            TipoEstudo.questoes);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: ehQuestoes
                              ? tema.cardTheme.color
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: ehQuestoes
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.format_list_numbered_rounded,
                              size: 18,
                              color: ehQuestoes
                                  ? tema.colorScheme.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estudo por Questões',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ehQuestoes
                                    ? (ehModoEscuro
                                        ? Colors.white
                                        : Colors.black87)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        provedorEstudo
                            .definirTipoEstudoSelecionado(TipoEstudo.pdf);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !ehQuestoes
                              ? tema.cardTheme.color
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !ehQuestoes
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 18,
                              color: !ehQuestoes
                                  ? tema.colorScheme.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estudo por PDF',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !ehQuestoes
                                    ? (ehModoEscuro
                                        ? Colors.white
                                        : Colors.black87)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Campos Específicos por Modo
            if (ehQuestoes) ...[
              // MODO: QUESTÕES
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tema.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ehModoEscuro
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Métricas das Questões',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (provedorEstudo.totalQuestoes > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _obterCorTaxaAcerto(
                                      provedorEstudo.taxaAcertoAtual)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 14,
                                  color: _obterCorTaxaAcerto(
                                      provedorEstudo.taxaAcertoAtual),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${provedorEstudo.taxaAcertoAtual.toStringAsFixed(1)}% de Acerto',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _obterCorTaxaAcerto(
                                        provedorEstudo.taxaAcertoAtual),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controladorTotalQuestoes,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Total de Questões',
                              prefixIcon:
                                  Icon(Icons.format_list_numbered_rounded),
                              hintText: 'Ex: 25',
                            ),
                            onChanged: (valor) {
                              final numero = int.tryParse(valor) ?? 0;
                              provedorEstudo.definirTotalQuestoes(numero);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _controladorQuestoesCorretas,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Questões Corretas',
                              prefixIcon:
                                  Icon(Icons.check_circle_outline_rounded),
                              hintText: 'Ex: 22',
                            ),
                            onChanged: (valor) {
                              final numero = int.tryParse(valor) ?? 0;
                              provedorEstudo.definirQuestoesCorretas(numero);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // MODO: PDF
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tema.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ehModoEscuro
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalhes da Leitura do Material',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controladorTituloMaterial,
                      decoration: const InputDecoration(
                        labelText: 'Título do Material / PDF / Livro',
                        prefixIcon: Icon(Icons.picture_as_pdf_outlined),
                        hintText: 'Ex: Direito Administrativo Simplificado.pdf',
                      ),
                      onChanged: (valor) =>
                          provedorEstudo.definirTituloMaterial(valor),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controladorPaginaParada,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Página onde parou (Checkpoint)',
                              prefixIcon:
                                  Icon(Icons.bookmark_border_rounded),
                              hintText: 'Ex: 48',
                            ),
                            onChanged: (valor) {
                              final numero = int.tryParse(valor) ?? 0;
                              provedorEstudo.definirPaginaParada(numero);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _controladorQuantidadePaginasLidas,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Páginas lidas nesta sessão',
                              prefixIcon: Icon(Icons.auto_stories_outlined),
                              hintText: 'Ex: 15',
                            ),
                            onChanged: (valor) {
                              final numero = int.tryParse(valor) ?? 0;
                              provedorEstudo
                                  .definirQuantidadePaginasLidas(numero);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 5. Assunto / Tópico Geral
            TextFormField(
              controller: _controladorTopico,
              decoration: const InputDecoration(
                labelText: 'Assunto / Tópico Estudado',
                prefixIcon: Icon(Icons.tag_rounded),
                hintText: 'Ex: Controle de Constitucionalidade / Atos',
              ),
              onChanged: (valor) => provedorEstudo.definirTopico(valor),
            ),
            const SizedBox(height: 14),

            // 6. Observações / Anotações
            TextFormField(
              controller: _controladorAnotacoes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Anotações e Observações',
                prefixIcon: Icon(Icons.notes_rounded),
                hintText: 'Escreva pontos importantes ou lembretes...',
              ),
              onChanged: (valor) => provedorEstudo.definirAnotacoes(valor),
            ),
            const SizedBox(height: 32),

            // Faixa de Mensagem de Erro
            if (provedorEstudo.mensagemErro != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provedorEstudo.mensagemErro!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // 7. Botão Salvar Estudo
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: provedorEstudo.estaCarregando
                    ? null
                    : () async {
                        if (!_chaveFormulario.currentState!.validate()) return;
                        final mensageiro = ScaffoldMessenger.of(context);
                        final sucesso =
                            await provedorEstudo.salvarSessaoAtual();
                        if (sucesso && mounted) {
                          mensageiro.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '🎉 Sessão de estudos salva com sucesso! O ciclo foi atualizado.'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                          _controladorTopico.clear();
                          _controladorAnotacoes.clear();
                          _controladorTotalQuestoes.clear();
                          _controladorQuestoesCorretas.clear();
                          _controladorTituloMaterial.clear();
                          _controladorPaginaParada.clear();
                          _controladorQuantidadePaginasLidas.clear();
                          widget.aoSalvarSessao?.call();
                        }
                      },
                icon: provedorEstudo.estaCarregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(
                  provedorEstudo.estaCarregando
                      ? 'Salvando...'
                      : 'Finalizar e Salvar Estudo',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _obterCorTaxaAcerto(double taxa) {
    if (taxa >= 80) return const Color(0xFF10B981);
    if (taxa >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
