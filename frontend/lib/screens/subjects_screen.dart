import 'package:flutter/material.dart';
import 'package:frontend/models/study_group.dart';
import 'package:frontend/models/subject.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:frontend/widgets/group_selector_widget.dart';
import 'package:provider/provider.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  static const List<String> coresDisponiveis = [
    '#4F46E5', // Índigo
    '#0891B2', // Ciano
    '#059669', // Esmeralda
    '#D97706', // Âmbar
    '#DC2626', // Vermelho
    '#9333EA', // Roxo
    '#DB2777', // Rosa
    '#2563EB', // Azul
    '#475569', // Ardósia
  ];

  static List<String> get availableColors => coresDisponiveis;

  @override
  Widget build(BuildContext context) {
    final provedorEstudo = context.watch<StudyProvider>();
    final disciplinas = provedorEstudo.disciplinas;
    final grupoSelecionado = provedorEstudo.grupoSelecionado;
    final tema = Theme.of(context);
    final ehModoEscuro = tema.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _exibirDialogoAdicionarEditarDisciplina(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Disciplina'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disciplinas 📚',
                        style: tema.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ative/desative no ciclo ou edite metas.',
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
                OutlinedButton.icon(
                  onPressed: () => _exibirDialogoGerenciarGrupos(context),
                  icon: const Icon(Icons.folder_special_rounded, size: 16),
                  label: const Text('Subgrupos', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Banner do Subgrupo Ativo
            if (grupoSelecionado != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: grupoSelecionado.cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: grupoSelecionado.cor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.layers_rounded,
                        color: grupoSelecionado.cor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subgrupo: ${grupoSelecionado.nome}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: grupoSelecionado.cor,
                            ),
                          ),
                          if (grupoSelecionado.descricao != null &&
                              grupoSelecionado.descricao!.isNotEmpty)
                            Text(
                              grupoSelecionado.descricao!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            if (disciplinas.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: tema.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.school_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Nenhuma matéria cadastrada neste subgrupo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Clique no botão abaixo para adicionar matérias.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: disciplinas.length,
                separatorBuilder: (contextoSeparador, indice) =>
                    const SizedBox(height: 10),
                itemBuilder: (contextoItem, indice) {
                  final disciplina = disciplinas[indice];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tema.cardTheme.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: disciplina.ativo
                            ? (ehModoEscuro
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0))
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: disciplina.ativo
                                  ? disciplina.cor
                                  : Colors.grey.shade400,
                              radius: 16,
                              child: Text(
                                disciplina.nome.isNotEmpty
                                    ? disciplina.nome[0].toUpperCase()
                                    : 'D',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
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
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: disciplina.ativo
                                          ? null
                                          : TextDecoration.lineThrough,
                                      color: disciplina.ativo
                                          ? null
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ordem #${disciplina.ordemCiclo} • Meta: ${disciplina.metaMinutos}m • Total: ${(disciplina.totalSegundosEstudo / 3600).toStringAsFixed(1)}h',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              onPressed: () => _exibirDialogoAdicionarEditarDisciplina(
                                  context,
                                  disciplina: disciplina),
                              tooltip: 'Editar',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.red),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  _confirmarExcluirDisciplina(context, disciplina),
                              tooltip: 'Excluir definitivamente',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              disciplina.ativo
                                  ? '🟢 Ativa no Ciclo'
                                  : '⚪ Fora do Ciclo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: disciplina.ativo
                                    ? const Color(0xFF10B981)
                                    : Colors.grey.shade500,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: disciplina.ativo,
                                activeThumbColor: const Color(0xFF10B981),
                                onChanged: (_) async {
                                  await provedorEstudo
                                      .alternarDisciplinaAtivaNoCiclo(disciplina);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _exibirDialogoAdicionarEditarDisciplina(BuildContext contexto,
      {Subject? disciplina}) {
    final estaEditando = disciplina != null;
    final provedorEstudo = contexto.read<StudyProvider>();
    final grupos = provedorEstudo.grupos;

    final controladorNome =
        TextEditingController(text: disciplina?.nome ?? '');
    final controladorMinutos =
        TextEditingController(text: '${disciplina?.metaMinutos ?? 60}');
    String corSelecionada = disciplina?.corHex ?? coresDisponiveis.first;
    bool ativaNoCiclo = disciplina?.ativo ?? true;
    int? idGrupoSelecionado =
        disciplina?.idGrupo ?? provedorEstudo.grupoSelecionado?.id;

    showDialog(
      context: contexto,
      builder: (contextoDialogo) {
        return StatefulBuilder(
          builder: (contextoEstado, definirEstadoInterno) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                estaEditando ? 'Editar Disciplina' : 'Nova Disciplina',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controladorNome,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Matéria',
                        hintText: 'Ex: Direito Constitucional',
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (grupos.isNotEmpty) ...[
                      DropdownButtonFormField<int?>(
                        value: idGrupoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Subgrupo / Concurso',
                          prefixIcon: Icon(Icons.folder_outlined),
                        ),
                        items: grupos.map((grupoItem) {
                          return DropdownMenuItem<int?>(
                            value: grupoItem.id,
                            child: Text(grupoItem.nome),
                          );
                        }).toList(),
                        onChanged: (novoValor) {
                          definirEstadoInterno(() {
                            idGrupoSelecionado = novoValor;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: controladorMinutos,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Meta de Estudo (minutos)',
                        hintText: 'Ex: 60',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cor da Disciplina:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: coresDisponiveis.map((codigoHex) {
                        final cor = Color(int.parse(
                            'FF${codigoHex.replaceAll('#', '')}',
                            radix: 16));
                        final estaSelecionada = corSelecionada == codigoHex;

                        return GestureDetector(
                          onTap: () {
                            definirEstadoInterno(() {
                              corSelecionada = codigoHex;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: cor,
                              shape: BoxShape.circle,
                              border: estaSelecionada
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                            child: estaSelecionada
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Ativa no Ciclo de Estudos'),
                      value: ativaNoCiclo,
                      onChanged: (novoValor) {
                        definirEstadoInterno(() {
                          ativaNoCiclo = novoValor;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(contextoDialogo),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nome = controladorNome.text.trim();
                    final minutosMeta =
                        int.tryParse(controladorMinutos.text.trim()) ?? 60;

                    if (nome.isEmpty) return;

                    if (estaEditando) {
                      await provedorEstudo.atualizarDisciplina(
                        disciplina.id,
                        nome,
                        corSelecionada,
                        ativaNoCiclo,
                        minutosMeta,
                        idGrupo: idGrupoSelecionado,
                      );
                    } else {
                      await provedorEstudo.adicionarDisciplina(
                        nome,
                        corSelecionada,
                        minutosMeta,
                        idGrupo: idGrupoSelecionado,
                      );
                    }

                    if (contexto.mounted) {
                      Navigator.pop(contextoDialogo);
                      ScaffoldMessenger.of(contexto).showSnackBar(
                        SnackBar(
                          content: Text(estaEditando
                              ? 'Disciplina atualizada!'
                              : 'Disciplina cadastrada com sucesso!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  child: Text(estaEditando ? 'Salvar' : 'Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarExcluirDisciplina(BuildContext contexto, Subject disciplina) {
    showDialog(
      context: contexto,
      builder: (contextoDialogo) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir Disciplina'),
        content: Text(
          'Deseja realmente excluir "${disciplina.nome}"? Todas as sessões desta disciplina serão removidas permanentemente.',
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
              final provedorEstudo = contexto.read<StudyProvider>();
              await provedorEstudo.excluirDisciplina(disciplina.id);
              if (contexto.mounted) {
                ScaffoldMessenger.of(contexto).showSnackBar(
                  const SnackBar(
                    content: Text('Disciplina excluída com sucesso.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excluir Definitivamente'),
          ),
        ],
      ),
    );
  }

  void _exibirDialogoGerenciarGrupos(BuildContext contexto) {
    showDialog(
      context: contexto,
      builder: (contextoDialogo) {
        return Consumer<StudyProvider>(
          builder: (contextoConsumer, provedorEstudo, _) {
            final grupos = provedorEstudo.grupos;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subgrupos / Concursos',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Color(0xFF6366F1)),
                    tooltip: 'Novo Subgrupo',
                    onPressed: () {
                      GroupSelectorWidget.exibirDialogoAdicionarEditarGrupo(
                          contexto);
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: grupos.isEmpty
                    ? const Text('Nenhum subgrupo cadastrado.')
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: grupos.length,
                        separatorBuilder: (contextoSep, indice) =>
                            const Divider(),
                        itemBuilder: (contextoItem, indice) {
                          final grupo = grupos[indice];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: grupo.cor,
                              radius: 14,
                            ),
                            title: Text(grupo.nome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            subtitle:
                                Text('${grupo.totalDisciplinas} disciplinas'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18),
                                  onPressed: () {
                                    GroupSelectorWidget
                                        .exibirDialogoAdicionarEditarGrupo(
                                      contexto,
                                      grupo: grupo,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  tooltip: 'Excluir em cascata',
                                  onPressed: () {
                                    _confirmarExcluirGrupo(contexto, grupo);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(contextoDialogo),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarExcluirGrupo(BuildContext contexto, StudyGroup grupo) {
    showDialog(
      context: contexto,
      builder: (contextoDialogo) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Excluir Subgrupo em Cascata',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja excluir o subgrupo "${grupo.nome}"?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: Text(
                '⚠️ ATENÇÃO: Esta ação é irreversível. Todas as ${grupo.totalDisciplinas} matérias vinculadas a este subgrupo e todo o histórico de sessões/estudos serão apagados em cascata permanentemente.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: const Text('Excluir Tudo em Cascata'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(contextoDialogo);
              final provedorEstudo = contexto.read<StudyProvider>();
              await provedorEstudo.excluirGrupo(grupo.id);
              if (contexto.mounted) {
                ScaffoldMessenger.of(contexto).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Subgrupo "${grupo.nome}" e seus dados foram excluídos com sucesso.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
