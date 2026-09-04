import 'package:flutter/material.dart';
import 'package:frontend/models/study_group.dart';
import 'package:frontend/models/subject.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:frontend/widgets/group_selector_widget.dart';
import 'package:provider/provider.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  static const List<String> availableColors = [
    '#4F46E5', // Indigo
    '#0891B2', // Cyan
    '#059669', // Emerald
    '#D97706', // Amber
    '#DC2626', // Red
    '#9333EA', // Purple
    '#DB2777', // Pink
    '#2563EB', // Blue
    '#475569', // Slate
  ];

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final subjects = studyProvider.subjects;
    final selectedGroup = studyProvider.selectedGroup;
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSubjectDialog(context),
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ative/desative no ciclo ou edite metas.',
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
                OutlinedButton.icon(
                  onPressed: () => _showManageGroupsDialog(context),
                  icon: const Icon(Icons.folder_special_rounded, size: 16),
                  label: const Text('Subgrupos', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Active Group Banner
            if (selectedGroup != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedGroup.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: selectedGroup.color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.layers_rounded,
                        color: selectedGroup.color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subgrupo: ${selectedGroup.name}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: selectedGroup.color,
                            ),
                          ),
                          if (selectedGroup.description != null &&
                              selectedGroup.description!.isNotEmpty)
                            Text(
                              selectedGroup.description!,
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

            if (subjects.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
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
                itemCount: subjects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final sub = subjects[index];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sub.active
                            ? (theme.brightness == Brightness.dark
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
                              backgroundColor: sub.active
                                  ? sub.color
                                  : Colors.grey.shade400,
                              radius: 16,
                              child: Text(
                                sub.name.isNotEmpty
                                    ? sub.name[0].toUpperCase()
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
                                    sub.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: sub.active
                                          ? null
                                          : TextDecoration.lineThrough,
                                      color: sub.active
                                          ? null
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ordem #${sub.cycleOrder} • Meta: ${sub.targetMinutes}m • Total: ${(sub.totalStudySeconds / 3600).toStringAsFixed(1)}h',
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
                              onPressed: () => _showAddEditSubjectDialog(context,
                                  subject: sub),
                              tooltip: 'Editar',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.red),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  _confirmDeleteSubject(context, sub),
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
                              sub.active ? '🟢 Ativa no Ciclo' : '⚪ Fora do Ciclo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sub.active
                                    ? const Color(0xFF10B981)
                                    : Colors.grey.shade500,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: sub.active,
                                activeThumbColor: const Color(0xFF10B981),
                                onChanged: (_) async {
                                  await studyProvider
                                      .toggleSubjectActiveInCycle(sub);
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

  void _showAddEditSubjectDialog(BuildContext context, {Subject? subject}) {
    final isEditing = subject != null;
    final studyProvider = context.read<StudyProvider>();
    final groups = studyProvider.groups;

    final nameController = TextEditingController(text: subject?.name ?? '');
    final minutesController =
        TextEditingController(text: '${subject?.targetMinutes ?? 60}');
    String selectedColor = subject?.colorHex ?? availableColors.first;
    bool active = subject?.active ?? true;
    int? selectedGroupId = subject?.groupId ?? studyProvider.selectedGroup?.id;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                isEditing ? 'Editar Disciplina' : 'Nova Disciplina',
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
                        labelText: 'Nome da Matéria',
                        hintText: 'Ex: Direito Constitucional',
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (groups.isNotEmpty) ...[
                      DropdownButtonFormField<int?>(
                        value: selectedGroupId,
                        decoration: const InputDecoration(
                          labelText: 'Subgrupo / Concurso',
                          prefixIcon: Icon(Icons.folder_outlined),
                        ),
                        items: groups.map((g) {
                          return DropdownMenuItem<int?>(
                            value: g.id,
                            child: Text(g.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedGroupId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: minutesController,
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
                            width: 30,
                            height: 30,
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
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Ativa no Ciclo de Estudos'),
                      value: active,
                      onChanged: (val) {
                        setState(() {
                          active = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
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
                    final minutes =
                        int.tryParse(minutesController.text.trim()) ?? 60;

                    if (name.isEmpty) return;

                    if (isEditing) {
                      await studyProvider.updateSubject(
                        subject.id,
                        name,
                        selectedColor,
                        active,
                        minutes,
                        groupId: selectedGroupId,
                      );
                    } else {
                      await studyProvider.addSubject(
                        name,
                        selectedColor,
                        minutes,
                        groupId: selectedGroupId,
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing
                              ? 'Disciplina atualizada!'
                              : 'Disciplina cadastrada com sucesso!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Salvar' : 'Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteSubject(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir Disciplina'),
        content: Text(
          'Deseja realmente excluir "${subject.name}"? Todas as sessões desta disciplina serão removidas permanentemente.',
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
              final studyProvider = context.read<StudyProvider>();
              await studyProvider.deleteSubject(subject.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
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

  void _showManageGroupsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer<StudyProvider>(
          builder: (context, studyProvider, _) {
            final groups = studyProvider.groups;
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
                      GroupSelectorWidget.showAddEditGroupDialog(context);
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: groups.isEmpty
                    ? const Text('Nenhum subgrupo cadastrado.')
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: groups.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final g = groups[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: g.color,
                              radius: 14,
                            ),
                            title: Text(g.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            subtitle: Text('${g.totalSubjects} disciplinas'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18),
                                  onPressed: () {
                                    GroupSelectorWidget.showAddEditGroupDialog(
                                        context,
                                        group: g);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  tooltip: 'Excluir em cascata',
                                  onPressed: () {
                                    _confirmDeleteGroup(context, g);
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
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteGroup(BuildContext context, StudyGroup group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
              'Tem certeza que deseja excluir o subgrupo "${group.name}"?',
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
                '⚠️ ATENÇÃO: Esta ação é irreversível. Todas as ${group.totalSubjects} matérias vinculadas a este subgrupo e todo o histórico de sessões/estudos serão apagados em cascata permanentemente.',
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
            onPressed: () => Navigator.pop(ctx),
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
              Navigator.pop(ctx);
              final studyProvider = context.read<StudyProvider>();
              await studyProvider.deleteGroup(group.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Subgrupo "${group.name}" e seus dados foram excluídos com sucesso.'),
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
