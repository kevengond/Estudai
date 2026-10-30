import 'package:flutter/material.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:provider/provider.dart';

class StudyTimerWidget extends StatelessWidget {
  const StudyTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provedorEstudo = context.watch<StudyProvider>();
    final estaExecutando = provedorEstudo.cronometroEmExecucao;
    final estaPausado = provedorEstudo.cronometroPausado;
    final tema = Theme.of(context);
    final ehModoEscuro = tema.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tema.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: estaExecutando
              ? tema.colorScheme.primary.withOpacity(0.5)
              : (ehModoEscuro
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0)),
          width: estaExecutando ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: estaExecutando ? tema.colorScheme.primary : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TEMPO DE SESSÃO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: estaExecutando
                          ? tema.colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              if (provedorEstudo.segundosCronometro > 0)
                TextButton.icon(
                  onPressed: provedorEstudo.redefinirCronometro,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Zerar', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Visor digital grande do cronômetro
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: ehModoEscuro
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              provedorEstudo.cronometroFormatado,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                fontFamily: 'Courier',
                color: estaExecutando
                    ? tema.colorScheme.primary
                    : (ehModoEscuro
                        ? Colors.white
                        : const Color(0xFF1E293B)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Botões de ação do cronômetro
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!estaExecutando) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provedorEstudo.iniciarCronometro,
                    icon: Icon(
                      estaPausado
                          ? Icons.play_arrow_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      estaPausado ? 'Retomar' : 'Iniciar Cronômetro',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Esmeralda
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provedorEstudo.pausarCronometro,
                    icon: const Icon(Icons.pause_rounded),
                    label: const Text('Pausar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B), // Âmbar
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Atalhos rápidos de tempo (+15m, +30m, +45m, +60m)
          Wrap(
            spacing: 8,
            children: [
              _construirBotaoPredefinicao(context, '+15m', 15 * 60),
              _construirBotaoPredefinicao(context, '+30m', 30 * 60),
              _construirBotaoPredefinicao(context, '+45m', 45 * 60),
              _construirBotaoPredefinicao(context, '+60m', 60 * 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirBotaoPredefinicao(
    BuildContext contexto,
    String rotulo,
    int segundosAdicionais,
  ) {
    final provedorEstudo = contexto.read<StudyProvider>();
    return OutlinedButton(
      onPressed: () {
        provedorEstudo.definirDuracaoManual(
          provedorEstudo.segundosCronometro + segundosAdicionais,
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(rotulo, style: const TextStyle(fontSize: 12)),
    );
  }
}
