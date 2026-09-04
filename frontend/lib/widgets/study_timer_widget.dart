import 'package:flutter/material.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:provider/provider.dart';

class StudyTimerWidget extends StatelessWidget {
  const StudyTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final isRunning = studyProvider.isTimerRunning;
    final isPaused = studyProvider.isTimerPaused;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRunning
              ? theme.colorScheme.primary.withOpacity(0.5)
              : (theme.brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0)),
          width: isRunning ? 2 : 1,
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
                    color: isRunning ? theme.colorScheme.primary : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TEMPO DE SESSÃO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isRunning
                          ? theme.colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              if (studyProvider.timerSeconds > 0)
                TextButton.icon(
                  onPressed: studyProvider.resetTimer,
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
          // Large digital stopwatch display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              studyProvider.formattedTimer,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                fontFamily: 'Courier',
                color: isRunning
                    ? theme.colorScheme.primary
                    : (theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1E293B)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Timer Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isRunning) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: studyProvider.startTimer,
                    icon: Icon(
                      isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      isPaused ? 'Retomar' : 'Iniciar Cronômetro',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Emerald
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: studyProvider.pauseTimer,
                    icon: const Icon(Icons.pause_rounded),
                    label: const Text('Pausar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B), // Amber
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Quick time presets (+15m, +30m, +45m, +60m)
          Wrap(
            spacing: 8,
            children: [
              _buildPresetButton(context, '+15m', 15 * 60),
              _buildPresetButton(context, '+30m', 30 * 60),
              _buildPresetButton(context, '+45m', 45 * 60),
              _buildPresetButton(context, '+60m', 60 * 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(BuildContext context, String label, int seconds) {
    final studyProvider = context.read<StudyProvider>();
    return OutlinedButton(
      onPressed: () {
        studyProvider.setManualDuration(studyProvider.timerSeconds + seconds);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
