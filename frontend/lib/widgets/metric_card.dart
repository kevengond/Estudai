import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String? subtitulo;
  final IconData icone;
  final Color corIcone;
  final Color? corFundo;

  const MetricCard({
    super.key,
    String? titulo,
    String? title,
    String? valor,
    String? value,
    String? subtitulo,
    String? subtitle,
    IconData? icone,
    IconData? icon,
    Color? corIcone,
    Color? iconColor,
    Color? corFundo,
    Color? backgroundColor,
  })  : titulo = titulo ?? title ?? '',
        valor = valor ?? value ?? '',
        subtitulo = subtitulo ?? subtitle,
        icone = icone ?? icon ?? Icons.info_outline,
        corIcone = corIcone ?? iconColor ?? Colors.blue,
        corFundo = corFundo ?? backgroundColor;
    return MetricCard(
      key: key,
      titulo: title,
      valor: value,
      subtitulo: subtitle,
      icone: icon,
      corIcone: iconColor,
      corFundo: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ehModoEscuro = tema.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: corFundo ?? tema.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ehModoEscuro
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: ehModoEscuro
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: corIcone.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: corIcone, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitulo!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                color: ehModoEscuro
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
