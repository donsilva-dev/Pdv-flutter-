import 'package:flutter/material.dart';

class PdvNumericKeyboard extends StatelessWidget {
  final void Function(String value) onKeyPressed;

  final double width;
  final double buttonHeight;
  final double spacing;

  const PdvNumericKeyboard({
    super.key,
    required this.onKeyPressed,
    this.width = 600,
    this.buttonHeight = 70,
    this.spacing = 5,
  });

  @override
  Widget build(BuildContext context) {
    final normalHeight = buttonHeight;

    // Voltar e Entrar ocupam duas linhas
    final largeHeight = (buttonHeight * 2) + spacing;

    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COLUNA 1
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: normalHeight,
                  child: _actionButton(
                    value: 'Limpar',
                    cor: Colors.red,
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  height: normalHeight,
                  child: _actionButton(
                    value: 'Total',
                    cor: Colors.deepPurple,
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  height: normalHeight,
                  child: _actionButton(
                    value: 'Função',
                    cor: const Color.fromARGB(255, 5, 36, 129),
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  height: normalHeight,
                  child: _actionButton(
                    value: 'X',
                    cor: Colors.white,
                    textColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: spacing),

          // COLUNA 2
          Expanded(
            child: Column(
              children: [
                SizedBox(height: normalHeight, child: _numberButton('1')),
                SizedBox(height: spacing),
                SizedBox(height: normalHeight, child: _numberButton('4')),
                SizedBox(height: spacing),
                SizedBox(height: normalHeight, child: _numberButton('7')),
                SizedBox(height: spacing),
                SizedBox(height: normalHeight, child: _numberButton('.')),
              ],
            ),
          ),

          SizedBox(width: spacing),

          // COLUNA 3
          Expanded(
            child: Column(
              children: [
                SizedBox(height: normalHeight, child: _numberButton('2')),
                SizedBox(height: spacing),
                SizedBox(height: normalHeight, child: _numberButton('5')),
                SizedBox(height: spacing),
                SizedBox(height: normalHeight, child: _numberButton('8')),
                SizedBox(height: spacing),
                SizedBox(height: normalHeight, child: _numberButton('0')),
              ],
            ),
          ),

          SizedBox(width: spacing),

          // COLUNA 4
          Expanded(
            child: Column(
              children: [
                SizedBox(height: normalHeight, child: _numberButton('3')),
                SizedBox(height: spacing),
                SizedBox(height: normalHeight, child: _numberButton('6')),
                SizedBox(height: spacing),
                SizedBox(height: normalHeight, child: _numberButton('9')),
                SizedBox(height: spacing),
                SizedBox(height: normalHeight, child: _numberButton('00')),
              ],
            ),
          ),

          SizedBox(width: spacing),

          // COLUNA 5
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: largeHeight,
                  child: _largeActionButton(
                    cor: Color.fromARGB(255, 255, 160, 26),
                    value: 'Voltar',
                    icon: Icons.arrow_back,
                  ),
                ),

                SizedBox(height: spacing),

                SizedBox(
                  height: largeHeight,
                  child: _largeActionButton(
                    value: 'Entrar',
                    cor: Color(0xff00C853),

                    icon: Icons.keyboard_return,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _largeActionButton({
    required String value,
    IconData? icon,
    required Color cor,
  }) {
    return Material(
      color: cor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => onKeyPressed(value),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(height: 8),
              ],

              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberButton(String number) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => onKeyPressed(number),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    IconData? icon,
    required String value,
    Color? cor,
    Color? textColor,
  }) {
    return Material(
      color: cor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => onKeyPressed(value),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, size: 28)
              : Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
