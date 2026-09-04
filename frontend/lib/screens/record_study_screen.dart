import 'package:flutter/material.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:frontend/widgets/study_timer_widget.dart';
import 'package:provider/provider.dart';

class RecordStudyScreen extends StatefulWidget {
  final VoidCallback? onSessionSaved;

  const RecordStudyScreen({super.key, this.onSessionSaved});

  @override
  State<RecordStudyScreen> createState() => _RecordStudyScreenState();
}

class _RecordStudyScreenState extends State<RecordStudyScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _topicController;
  late TextEditingController _notesController;

  // Questions controllers
  late TextEditingController _totalQuestionsController;
  late TextEditingController _correctQuestionsController;

  // PDF controllers
  late TextEditingController _materialTitleController;
  late TextEditingController _pageStoppedController;
  late TextEditingController _pagesReadCountController;

  @override
  void initState() {
    super.initState();
    final p = context.read<StudyProvider>();
    _topicController = TextEditingController(text: p.topic);
    _notesController = TextEditingController(text: p.notes);
    _totalQuestionsController =
        TextEditingController(text: p.totalQuestions > 0 ? '${p.totalQuestions}' : '');
    _correctQuestionsController =
        TextEditingController(text: p.correctQuestions > 0 ? '${p.correctQuestions}' : '');
    _materialTitleController = TextEditingController(text: p.materialTitle);
    _pageStoppedController =
        TextEditingController(text: p.pageStopped > 0 ? '${p.pageStopped}' : '');
    _pagesReadCountController =
        TextEditingController(text: p.pagesReadCount > 0 ? '${p.pagesReadCount}' : '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.watch<StudyProvider>();
    if (_topicController.text != p.topic) {
      _topicController.text = p.topic;
    }
    if (_notesController.text != p.notes) {
      _notesController.text = p.notes;
    }
    if (p.selectedStudyType == StudyType.questions) {
      if (p.totalQuestions > 0 &&
          _totalQuestionsController.text != '${p.totalQuestions}') {
        _totalQuestionsController.text = '${p.totalQuestions}';
      }
      if (p.correctQuestions > 0 &&
          _correctQuestionsController.text != '${p.correctQuestions}') {
        _correctQuestionsController.text = '${p.correctQuestions}';
      }
    } else {
      if (_materialTitleController.text != p.materialTitle) {
        _materialTitleController.text = p.materialTitle;
      }
      if (p.pageStopped > 0 &&
          _pageStoppedController.text != '${p.pageStopped}') {
        _pageStoppedController.text = '${p.pageStopped}';
      }
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    _totalQuestionsController.dispose();
    _correctQuestionsController.dispose();
    _materialTitleController.dispose();
    _pageStoppedController.dispose();
    _pagesReadCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final theme = Theme.of(context);

    final subjects = studyProvider.subjects;
    final isQuestions = studyProvider.selectedStudyType == StudyType.questions;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar Sessão de Estudo 📚',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cronometre seu tempo e registre seu progresso por questões ou PDF.',
              style: TextStyle(
                color: theme.brightness == Brightness.dark
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
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),

            if (subjects.isEmpty)
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
                builder: (context) {
                  final uniqueMap = <int, Subject>{};
                  for (final s in subjects) {
                    uniqueMap[s.id] = s;
                  }
                  final cleanList = uniqueMap.values.toList();
                  final selectedId = cleanList.any((s) => s.id == studyProvider.selectedSubject?.id)
                      ? studyProvider.selectedSubject?.id
                      : (cleanList.isNotEmpty ? cleanList.first.id : null);

                  return DropdownButtonFormField<int?>(
                    key: ValueKey(selectedId),
                    value: selectedId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.school_outlined),
                      hintText: 'Selecione uma disciplina',
                    ),
                    items: cleanList.map((sub) {
                      return DropdownMenuItem<int?>(
                        value: sub.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: sub.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                sub.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${sub.cycleOrder}º no ciclo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newId) {
                      if (newId != null) {
                        final match = cleanList.firstWhere((s) => s.id == newId,
                            orElse: () => cleanList.first);
                        studyProvider.setSelectedSubject(match);
                      }
                    },
                    validator: (val) =>
                        val == null ? 'Selecione uma disciplina' : null,
                  );
                },
              ),
            const SizedBox(height: 24),

            // 3. Segmented Switch: Questões vs PDF
            Text(
              'TIPO DE ESTUDO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        studyProvider
                            .setSelectedStudyType(StudyType.questions);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isQuestions
                              ? theme.cardTheme.color
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isQuestions
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
                              color: isQuestions
                                  ? theme.colorScheme.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estudo por Questões',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isQuestions
                                    ? (theme.brightness == Brightness.dark
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
                        studyProvider.setSelectedStudyType(StudyType.pdf);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isQuestions
                              ? theme.cardTheme.color
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !isQuestions
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
                              color: !isQuestions
                                  ? theme.colorScheme.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estudo por PDF',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !isQuestions
                                    ? (theme.brightness == Brightness.dark
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

            // 4. Specific Inputs according to Mode
            if (isQuestions) ...[
              // MODE: QUESTIONS
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
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
                        // Live accuracy badge
                        if (studyProvider.totalQuestions > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getAccuracyColor(
                                      studyProvider.currentAccuracyRate)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 14,
                                  color: _getAccuracyColor(
                                      studyProvider.currentAccuracyRate),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${studyProvider.currentAccuracyRate.toStringAsFixed(1)}% de Acerto',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _getAccuracyColor(
                                        studyProvider.currentAccuracyRate),
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
                            controller: _totalQuestionsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Total de Questões',
                              prefixIcon:
                                  Icon(Icons.format_list_numbered_rounded),
                              hintText: 'Ex: 25',
                            ),
                            onChanged: (val) {
                              final num = int.tryParse(val) ?? 0;
                              studyProvider.setTotalQuestions(num);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _correctQuestionsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Questões Corretas',
                              prefixIcon:
                                  Icon(Icons.check_circle_outline_rounded),
                              hintText: 'Ex: 22',
                            ),
                            onChanged: (val) {
                              final num = int.tryParse(val) ?? 0;
                              studyProvider.setCorrectQuestions(num);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // MODE: PDF
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
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
                      controller: _materialTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Título do Material / PDF / Livro',
                        prefixIcon: Icon(Icons.picture_as_pdf_outlined),
                        hintText: 'Ex: Direito Administrativo Simplificado.pdf',
                      ),
                      onChanged: (val) => studyProvider.setMaterialTitle(val),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pageStoppedController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Página onde parou (Checkpoint)',
                              prefixIcon: Icon(Icons.bookmark_border_rounded),
                              hintText: 'Ex: 48',
                            ),
                            onChanged: (val) {
                              final num = int.tryParse(val) ?? 0;
                              studyProvider.setPageStopped(num);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _pagesReadCountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Páginas lidas nesta sessão',
                              prefixIcon: Icon(Icons.auto_stories_outlined),
                              hintText: 'Ex: 15',
                            ),
                            onChanged: (val) {
                              final num = int.tryParse(val) ?? 0;
                              studyProvider.setPagesReadCount(num);
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
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Assunto / Tópico Estudado',
                prefixIcon: Icon(Icons.tag_rounded),
                hintText: 'Ex: Controle de Constitucionalidade / Atos',
              ),
              onChanged: (val) => studyProvider.setTopic(val),
            ),
            const SizedBox(height: 14),

            // 6. Observações / Anotações
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Anotações e Observações',
                prefixIcon: Icon(Icons.notes_rounded),
                hintText: 'Escreva pontos importantes ou lembretes...',
              ),
              onChanged: (val) => studyProvider.setNotes(val),
            ),
            const SizedBox(height: 32),

            // Error Message Banner if any
            if (studyProvider.errorMessage != null)
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
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        studyProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // 7. Save Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: studyProvider.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        final messenger = ScaffoldMessenger.of(context);
                        final success =
                            await studyProvider.saveCurrentSession();
                        if (success && mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '🎉 Sessão de estudos salva com sucesso! O ciclo foi atualizado.'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                          _topicController.clear();
                          _notesController.clear();
                          _totalQuestionsController.clear();
                          _correctQuestionsController.clear();
                          _materialTitleController.clear();
                          _pageStoppedController.clear();
                          _pagesReadCountController.clear();
                          widget.onSessionSaved?.call();
                        }
                      },
                icon: studyProvider.isLoading
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
                  studyProvider.isLoading
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

  Color _getAccuracyColor(double rate) {
    if (rate >= 80) return const Color(0xFF10B981);
    if (rate >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
