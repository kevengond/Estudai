import 'package:flutter/material.dart';
import 'package:frontend/models/study_group.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:provider/provider.dart';

class GroupSelectorWidget extends StatelessWidget {
  const GroupSelectorWidget({super.key});

  static const List<String> availableColors = [
    '#6366F1', // Indigo
    '#059669', // Emerald
    '#0891B2', // Cyan
    '#D97706', // Amber
    '#DC2626', // Red
    '#9333EA', // Purple
    '#DB2777', // Pink
  ];

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final groups = studyProvider.groups;
    final selectedGroup = studyProvider.selectedGroup;
    final theme = Theme.of(context);

    if (groups.isEmpty) {
      return TextButton.icon(
        onPressed: () => showAddEditGroupDialog(context),
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('Criar Subgrupo', style: TextStyle(fontSize: 12)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: PopupMenuButton<StudyGroup?>(
        tooltip: 'Trocar Subgrupo / Concurso',
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (context) {
          return [
            ...groups.map(
              (g) => PopupMenuItem<StudyGroup?>(
                value: g,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: g.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        g.name,
                        style: TextStyle(
                          fontWeight: selectedGroup?.id == g.id
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (selectedGroup?.id == g.id)
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
        onSelected: (group) {
          if (group == null) {
            showAddEditGroupDialog(context);
          } else {
            studyProvider.selectGroup(group);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: selectedGroup?.color ?? const Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                selectedGroup?.name ?? 'Subgrupo',
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

  static void showAddEditGroupDialog(BuildContext context,
      {StudyGroup? group}) {
    final isEditing = group != null;
    final nameController = TextEditingController(text: group?.name ?? '');
    final descController =
        TextEditingController(text: group?.description ?? '');
    String selectedColor = group?.colorHex ?? availableColors.first;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                isEditing
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
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Subgrupo / Concurso',
                        hintText: 'Ex: Concurso Polícia Federal, OAB, etc.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descController,
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
                      children: availableColors.map((hex) {
                        final color = Color(int.parse(
                            'FF${hex.replaceAll('#', '')}',
                            radix: 16));
                        final isSelected = selectedColor == hex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = hex;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                            child: isSelected
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
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final desc = descController.text.trim();
                    if (name.isEmpty) return;

                    final studyProvider = context.read<StudyProvider>();
                    if (isEditing) {
                      await studyProvider.updateGroup(
                          group.id, name, desc, selectedColor, true);
                    } else {
                      await studyProvider.addGroup(name, desc, selectedColor);
                    }

                    if (context.mounted) {
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing
                              ? 'Subgrupo atualizado!'
                              : 'Subgrupo criado com sucesso!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Salvar' : 'Criar Subgrupo'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
