class PixGenerator {
  final String pixKey;
  final String? merchantName;
  final String? merchantCity;
  final String? txid;
  final double? amount;

  PixGenerator({
    required this.pixKey,
    this.merchantName,
    this.merchantCity,
    this.txid,
    this.amount,
  });

  String getPayload() {
    final payload = StringBuffer();

    payload.write(_getValue('00', '01'));
    payload.write(_getValue('26', _getMerchantAccountInformation()));
    payload.write(_getValue('52', '0000'));
    payload.write(_getValue('53', '986'));
    if (amount != null && amount! > 0) {
      payload.write(_getValue('54', amount!.toStringAsFixed(2)));
    }
    payload.write(_getValue('58', 'BR'));
    payload.write(_getValue('59', _formatString(merchantName ?? 'Nao Informado', 25)));
    payload.write(_getValue('60', _formatString(merchantCity ?? 'SAO PAULO', 15)));
    payload.write(_getValue('62', _getAdditionalDataFieldTemplate()));
    payload.write('6304');
    final crc = _getCRC16(payload.toString());
    return '${payload.toString()}$crc';
  }

  String _getMerchantAccountInformation() {
    final gui = _getValue('00', 'br.gov.bcb.pix');
    final key = _getValue('01', pixKey);
    return '$gui$key';
  }

  String _getAdditionalDataFieldTemplate() {
    final txidVal = txid ?? '***';
    return _getValue('05', txidVal);
  }

  String _getValue(String id, String value) {
    final len = value.length.toString().padLeft(2, '0');
    return '$id$len$value';
  }

  String _formatString(String value, int maxLength) {
    // Remove acentos e caracteres especiais básicos
    var normalized = value
        .replaceAll(RegExp(r'[ÁÀÂÃ]'), 'A')
        .replaceAll(RegExp(r'[áàâã]'), 'a')
        .replaceAll(RegExp(r'[ÉÈÊ]'), 'E')
        .replaceAll(RegExp(r'[éèê]'), 'e')
        .replaceAll(RegExp(r'[ÍÌÎ]'), 'I')
        .replaceAll(RegExp(r'[íìî]'), 'i')
        .replaceAll(RegExp(r'[ÓÒÔÕ]'), 'O')
        .replaceAll(RegExp(r'[óòôõ]'), 'o')
        .replaceAll(RegExp(r'[ÚÙÛ]'), 'U')
        .replaceAll(RegExp(r'[úùû]'), 'u')
        .replaceAll('Ç', 'C')
        .replaceAll('ç', 'c');

    if (normalized.length > maxLength) {
      return normalized.substring(0, maxLength);
    }
    return normalized;
  }

  String _getCRC16(String payload) {
    // Polinômio do CRC16-CCITT (0x1021)
    int crc = 0xFFFF;
    final bytes = payload.codeUnits;

    for (var byte in bytes) {
      crc ^= (byte << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ 0x1021;
        } else {
          crc = crc << 1;
        }
      }
    }
    return (crc & 0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}