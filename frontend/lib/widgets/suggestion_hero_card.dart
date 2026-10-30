import 'package:flutter/material.dart';
import 'package:frontend/models/cycle_suggestion.dart';
import 'package:frontend/models/study_session.dart';

class SuggestionHeroCard extends StatelessWidget {
  final NextStudySuggestion? sugestao;
  final VoidCallback aoIniciarEstudo;

  const SuggestionHeroCard({
    super.key,
    NextStudySuggestion? sugestao,
    NextStudySuggestion? suggestion,
    VoidCallback? aoIniciarEstudo,
    VoidCallback? onStartStudy,
  })  : sugestao = sugestao ?? suggestion,
        aoIniciarEstudo = aoIniciarEstudo ?? onStartStudy ?? _funcaoVazia;

  static void _funcaoVazia() {}

  @override
  Widget build(BuildContext context) {
    final disciplina = sugestao?.disciplinaSugerida;
    final ehQuestoes = sugestao?.tipoEstudoSugerido == TipoEstudo.questoes;
    final ehRetomada = sugestao?.ehRetomadaUltimoConteudo ?? false;

    // Se nenhuma matéria ativa no ciclo
    if (disciplina == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF6366F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'CICLO DE ESTUDOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Comece a organizar seus estudos! 📖',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cadastre ou ative disciplinas no seu ciclo para receber sugestões automáticas e continuar exatamente de onde parou.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: aoIniciarEstudo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4F46E5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Registrar Estudo / Cadastrar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4F46E5), // Índigo
            Color(0xFF7C3AED), // Violeta
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Distintivo superior
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ehRetomada
                            ? Icons.bookmark_added_rounded
                            : Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ehRetomada
                            ? 'PRÓXIMA NO CICLO • DE ONDE PAROU'
                            : 'SUGESTÃO DO CICLO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                if (sugestao != null && sugestao!.statusCiclo.isNotEmpty)
                  Text(
                    sugestao!.statusCiclo,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              sugestao?.mensagemRetomada.isNotEmpty == true
                  ? sugestao!.mensagemRetomada
                  : disciplina.nome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sugestao?.detalhePontoParada ?? 'Pronto para iniciar a sessão',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ehQuestoes
                            ? Icons.format_list_numbered_rounded
                            : Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ehQuestoes ? 'Questões' : 'Leitura PDF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: aoIniciarEstudo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F46E5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text(
                    'Estudar Agora',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
