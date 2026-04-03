class Roles {
  Roles._();

  static const String admin = 'Responsable';
  static const String breeder = 'Éleveur';
  static const String inseminator = 'Inséminateur';
  static const String labTechnician = 'Technicien labo';
  static const String vet = 'Vétérinaire';

  static const List<String> all = [
    admin,
    breeder,
    inseminator,
    labTechnician,
    vet,
  ];
}

class AppTabs {
  AppTabs._();

  static const String dashboard = 'dashboard';
  static const String profile = 'profile';
  static const String actualites = 'actualites';
  static const String administration = 'administration';
  static const String messenger = 'messenger';
  static const String services = 'services';
  static const String elevage = 'elevage';
  static const String inseminations = 'inseminations';
  static const String boars = 'boars';
  static const String sows = 'sows';
  static const String pedigree = 'pedigree';
  static const String health = 'health';
  static const String commercial = 'commercial';
  static const String logiciel = 'logiciel';
  static const String users = 'users';
}
