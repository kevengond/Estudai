import 'package:flutter/material.dart';
import 'package:frontend/models/study_group.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:provider/provider.dart';

class GroupSelectorWidget extends StatelessWidget {
  const GroupSelectorWidget({super.key});

  static const List<String> coresDisponiveis = [
    '#6366F1', // Índigo
    '#059669', // Esmeralda
    '#0891B2', // Ciano
    '#D97706', // Âmbar
    '#DC2626', // Vermelho
    '#9333EA', // Roxo
    '#DB2777', // Rosa
  ];

  static List<String> get availableColors => coresDisponiveis;

  @override
  Widget build(BuildContext context) {
    final provedorEstudo = context.watch<StudyProvider>();
    final grupos = provedorEstudo.grupos;
    final grupoSelecionado = provedorEstudo.grupoSelecionado;
    final tema = Theme.of(context);
    final ehModoEscuro = tema.brightness == Brightness.dark;

    if (grupos.isEmpty) {
      return TextButton.icon(
        onPressed: () => exibirDialogoAdicionarEditarGrupo(context),
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('Criar Subgrupo', style: TextStyle(fontSize: 12)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ehModoEscuro
            ? const Color(0xFF1E293B)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ehModoEscuro
              ? const Color(0xFF334155)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: PopupMenuButton<StudyGroup?>(
        tooltip: 'Trocar Subgrupo / Concurso',
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (contextoMenu) {
          return [
            ...grupos.map(
              (grupo) => PopupMenuItem<StudyGroup?>(
                value: grupo,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: grupo.cor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        grupo.nome,
                        style: TextStyle(
                          fontWeight: grupoSelecionado?.id == grupo.id
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (grupoSelecionado?.id == grupo.id)
                      const Icon(Icons.check_rounded,
                          size: 18, color: Color(0xFF10B981)),
                  ],
                ),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<StudyGroup?>(
              value: null,
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, size: 18),
                  SizedBox(width: 10),
                  Text('Novo Subgrupo / Concurso',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ];
        },
        onSelected: (grupoEscolhido) {
          if (grupoEscolhido == null) {
            exibirDialogoAdicionarEditarGrupo(context);
          } else {
            provedorEstudo.selecionarGrupo(grupoEscolhido);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: grupoSelecionado?.cor ?? const Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                grupoSelecionado?.nome ?? 'Subgrupo',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  static void exibirDialogoAdicionarEditarGrupo(
    BuildContext contexto, {
    StudyGroup? grupo,
  }) {
    final estaEditando = grupo != null;
    final controladorNome = TextEditingController(text: grupo?.nome ?? '');
    final controladorDescricao =
        TextEditingController(text: grupo?.descricao ?? '');
    String corSelecionada = grupo?.corHex ?? coresDisponiveis.first;

    showDialog(
      context: contexto,
      builder: (contextoDialogo) {
        return StatefulBuilder(
          builder: (contextoEstado, definirEstadoInterno) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                estaEditando
                    ? 'Editar Subgrupo / Concurso'
                    : 'Novo Subgrupo / Concurso',
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
                        labelText: 'Nome do Subgrupo / Concurso',
                        hintText: 'Ex: Concurso Polícia Federal, OAB, etc.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controladorDescricao,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descrição / Cargo (opcional)',
                        hintText: 'Ex: Foco no cargo de Agente...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cor de Destaque:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
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
                            width: 32,
                            height: 32,
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
                    final descricao = controladorDescricao.text.trim();
                    if (nome.isEmpty) return;

                    final provedorEstudo = contexto.read<StudyProvider>();
                    if (estaEditando) {
                      await provedorEstudo.atualizarGrupo(
                        grupo.id,
                        nome,
                        descricao,
                        corSelecionada,
                        true,
                      );
                    } else {
                      await provedorEstudo.adicionarGrupo(
                        nome,
                        descricao,
                        corSelecionada,
                      );
                    }

                    if (contexto.mounted) {
                      Navigator.pop(contextoDialogo);
                      ScaffoldMessenger.of(contexto).showSnackBar(
                        SnackBar(
                          content: Text(estaEditando
                              ? 'Subgrupo atualizado!'
                              : 'Subgrupo criado com sucesso!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  child: Text(estaEditando ? 'Salvar' : 'Criar Subgrupo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void showAddEditGroupDialog(BuildContext context,
          {StudyGroup? group}) =>
      exibirDialogoAdicionarEditarGrupo(context, grupo: group);
}
