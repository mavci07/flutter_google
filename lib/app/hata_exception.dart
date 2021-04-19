class Hatalar {
  static String goster(String hataKodu) {
    switch (hataKodu) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return "Bu mail adresi zaten kullanılıyor.";

      case 'ERROR_USER_NOT_FOUND':
        return "Bu Kullanıcı Kayıtlı Değil.";

      default:
        return "Bir hata oluştu";
    }
  }
}
