class HisseModel {
  final String kurumAdi;
  final String hisseKodu;
  final String hisseAdi;
  final String sonFiyat;
  final String hedefFiyat;
  final String potansiyelGetiri;
  final String tavsiye;
  final String tarih;
  // Kurumun logosunu da ekleyebiliriz, şimdilik dursun
  // final String kurumLogoUrl;

  HisseModel({
    required this.kurumAdi,
    required this.hisseKodu,
    required this.hisseAdi,
    required this.sonFiyat,
    required this.hedefFiyat,
    required this.potansiyelGetiri,
    required this.tavsiye,
    required this.tarih,
  });
}