class Formats{

  static String formatPriceNumber(int number) {
    // Convertir el número a una cadena
    String formattedNumber = number.toString();

    // Insertar separadores de miles (en este caso, usaremos comas)
    String numberWithCommas = formattedNumber.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '\'');

    // Agregar comillas al inicio y al final
    String result = numberWithCommas;

    return result;
  }

}