import codecs

dart_code = r"""import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const GeneticApp());
}

class GeneticApp extends StatelessWidget {
  const GeneticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GENETIC-NETWORK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: const Color(0xFFF1F5F9), // Fond type social network (gris clair)
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 1,
          shadowColor: Color(0x1A000000),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// --- Modèles de Données ---

class Roles {
  static const String admin = 'responsable';
  static const String breeder = 'eleveur';
  static const String inseminator = 'inseminateur';
  static const String labTech = 'technicien_labo';
  static const String vet = 'veterinaire';
}

class UserProfile {
  final String id;
  final String code;
  final String name;
  final String role;
  final String avatarUrl; // Pour le côté social
  final String description;
  final String contact;
  final String email;
  final String fokontany;
  final String commune;
  final String district;
  final int nbIaEffectue;
  final double tauxReussite;

  UserProfile({
    required this.id,
    this.code = '',
    required this.name,
    required this.role,
    this.avatarUrl = '',
    this.description = '',
    this.contact = '',
    this.email = '',
    this.fokontany = '',
    this.commune = '',
    this.district = '',
    this.nbIaEffectue = 0,
    this.tauxReussite = 0.0,
  });
}

class Verrat {
  final String id;
  final String code;
  final String nom;
  final String race;
  final int age; // en mois
  final String origine;
  final String pere;
  final String mere;
  String statut;

  Verrat({
    required this.id,
    required this.code,
    required this.nom,
    required this.race,
    required this.age,
    required this.origine,
    required this.pere,
    required this.mere,
    required this.statut,
  });
}

class SemenceConditionnee {
  final String numLot;
  final String verratCode;
  final String dateHeureConditionnement;
  final String estimSpzMl;
  final String technicienLaboId;

  SemenceConditionnee({
    required this.numLot,
    required this.verratCode,
    required this.dateHeureConditionnement,
    required this.estimSpzMl,
    required this.technicienLaboId,
  });
}

class Truie {
  final String code;
  final String nom;
  final int age;
  final String race;
  final String origine;
  final String pere;
  final String mere;
  final String eleveurId;

  Truie({
    required this.code,
    required this.nom,
    required this.age,
    required this.race,
    required this.origine,
    required this.pere,
    required this.mere,
    required this.eleveurId,
  });
}

class Insemination {
  final String id;
  final String truieCode;
  final String semenceLot;
  final String inseminateurId;
  final String date1ereDose;
  final String date2emeDose;
  final String observation;
  String statut;
  String resultat;
  final String dateProbableRetourChaleur;
  final String dateMiseBas;
  final int nombrePorcelets;

  Insemination({
    required this.id,
    required this.truieCode,
    required this.semenceLot,
    required this.inseminateurId,
    required this.date1ereDose,
    this.date2emeDose = '',
    this.observation = '',
    required this.statut,
    required this.resultat,
    this.dateProbableRetourChaleur = '',
    this.dateMiseBas = '',
    this.nombrePorcelets = 0,
  });
}

// --- Nouveaux Modèles Sociaux & Suivi ---

class Post {
  final String id;
  final String authorId;
  final String content;
  final String date;
  final int likes;
  final int comments;

  Post({
    required this.id,
    required this.authorId,
    required this.content,
    required this.date,
    this.likes = 0,
    this.comments = 0,
  });
}

class VetVisit {
  final String id;
  final String animalCode; // Truie ou Verrat
  final String vetId;
  final String date;
  final String diagnostic;
  final String traitement;
  final String prochainRdv;

  VetVisit({
    required this.id,
    required this.animalCode,
    required this.vetId,
    required this.date,
    required this.diagnostic,
    required this.traitement,
    this.prochainRdv = '',
  });
}

class CalendarEvent {
  final String id;
  final String date;
  final String title;
  final String description;
  final String type; // 'chaleur', 'ia', 'mise_bas', 'rdv_vet'

  CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.type,
  });
}

// --- Mock Data ---

final List<UserProfile> initialUsers = [
  UserProfile(id: 'U1', code: 'ADM-01', name: 'Jean Responsable', role: Roles.admin, avatarUrl: 'J'),
  UserProfile(
    id: 'U2',
    code: 'ELV-01',
    name: 'Marc Éleveur',
    role: Roles.breeder,
    avatarUrl: 'M',
    description: 'Passionné par la génétique porcine depuis 10 ans.',
    contact: '0340000000',
    fokontany: 'Ambohimanarina',
    commune: 'Antananarivo',
    district: 'Tana VI',
  ),
  UserProfile(
    id: 'U3',
    code: 'INS-01',
    name: 'Paul Insem',
    role: Roles.inseminator,
    avatarUrl: 'P',
    description: 'Technicien expérimenté. Trajet couvrant tout le Vakinankaratra.',
    contact: '0330000000',
    email: 'paul@insem.mg',
    nbIaEffectue: 145,
    tauxReussite: 88.5,
  ),
  UserProfile(
    id: 'U4',
    code: 'LAB-01',
    name: 'Lucie Labo',
    role: Roles.labTech,
    avatarUrl: 'L',
    description: 'Analyse et conditionnement des semences.',
  ),
  UserProfile(
    id: 'U5',
    code: 'VET-01',
    name: 'Dr. Rivo',
    role: Roles.vet,
    avatarUrl: 'R',
    description: 'Vétérinaire spécialisé en élevage porcin.',
    contact: '0320000000',
  ),
];

final List<Verrat> initialVerrats = [
  Verrat(id: 'V1', code: 'VR-1001', nom: 'Thor', race: 'Large White', age: 24, origine: 'Ferme Alpha', pere: 'VR-050', mere: 'TR-090', statut: 'Disponible'),
  Verrat(id: 'V2', code: 'VR-1002', nom: 'Zeus', race: 'Landrace', age: 18, origine: 'Import', pere: 'Inconnu', mere: 'Inconnu', statut: 'Indisponible'),
];

final List<Truie> initialTruies = [
  Truie(code: 'T-12', nom: 'Bella', age: 20, race: 'Duroc', origine: 'Ferme Soleil', pere: 'Inconnu', mere: 'Inconnu', eleveurId: 'U2'),
  Truie(code: 'T-88', nom: 'Nina', age: 12, race: 'Large White', origine: 'Ferme Alpha', pere: 'Inconnu', mere: 'Inconnu', eleveurId: 'U2'),
];

final List<SemenceConditionnee> initialSemences = [
  SemenceConditionnee(numLot: 'LOT-2024-A', verratCode: 'VR-1001', dateHeureConditionnement: '2024-05-14 08:00', estimSpzMl: '3 M/ml', technicienLaboId: 'U4'),
];

final List<Insemination> initialInseminations = [
  Insemination(
    id: 'I1', truieCode: 'T-88', semenceLot: 'LOT-2024-A', inseminateurId: 'U3', date1ereDose: '2024-02-15 09:00', date2emeDose: '2024-02-15 18:00',
    observation: 'RAS', statut: 'Terminé', resultat: 'Réussi', dateProbableRetourChaleur: '2024-03-08', dateMiseBas: '2024-06-10', nombrePorcelets: 12,
  ),
];

final List<Post> initialPosts = [
  Post(id: 'P1', authorId: 'U3', content: 'Super matinée d\'insémination à Ambohimanarina. La qualité de la semence du lot LOT-2024-A (Thor) est excellente ! 🧬🐷', date: 'Il y a 2 heures', likes: 12, comments: 3),
  Post(id: 'P2', authorId: 'U2', content: 'Quelqu\'un sait si le Dr. Rivo est disponible ce weekend pour une échographie de gestation ?', date: 'Il y a 5 heures', likes: 2, comments: 5),
  Post(id: 'P3', authorId: 'U1', content: '📢 Annonce : Nouvelle arrivée de verrat Landrace prévue pour le mois prochain. Préparez vos plannings !', date: 'Hier', likes: 24, comments: 8),
];

final List<VetVisit> initialVetVisits = [
  VetVisit(id: 'VV1', animalCode: 'T-12', vetId: 'U5', date: '2024-02-10', diagnostic: 'Boiterie légère patte arrière droite', traitement: 'Anti-inflammatoire 3j', prochainRdv: '2024-02-17'),
  VetVisit(id: 'VV2', animalCode: 'VR-1002', vetId: 'U5', date: '2024-02-05', diagnostic: 'Check-up qualité de sperme suite à baisse de mobilité', traitement: 'Cure vitamines', prochainRdv: ''),
];

final List<CalendarEvent> initialEvents = [
  CalendarEvent(id: 'E1', date: '2024-02-28', title: 'Retour de Chaleur T-12', description: 'Surveiller T-12 si échec IA précédente.', type: 'chaleur'),
  CalendarEvent(id: 'E2', date: '2024-03-05', title: 'RDV Vétérinaire (Thor)', description: 'Vaccination annuelle.', type: 'rdv_vet'),
  CalendarEvent(id: 'E3', date: '2024-06-10', title: 'Mise bas attendue (Nina T-88)', description: 'Préparer la maternité. Estimation 12 porcelets.', type: 'mise_bas'),
];

// --- Main Application UI ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  UserProfile _currentUser = initialUsers[0];
  int _selectedIndex = 0; // Bottom/Side Nav indexing
  
  final List<Post> _posts = List.from(initialPosts);
  final List<Insemination> _inseminations = List.from(initialInseminations);
  final List<VetVisit> _vetVisits = List.from(initialVetVisits);
  final List<CalendarEvent> _events = List.from(initialEvents);

  // Layout handling
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF1F5F9), // Social neutral bg
      appBar: isDesktop ? null : AppBar(
        title: Row(
          children: [
            const Icon(LucideIcons.piggyBank, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Text('GENETIC NET', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: const Color(0xFF2563EB))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF2563EB),
              child: Text(_currentUser.avatarUrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildTopBar(),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Centre : Contenu principal (Fil, ou Vue spécifique)
                      Expanded(
                        flex: 5,
                        child: _buildMainContent(),
                      ),
                      // Droite : Suggestions / Raccourcis (uniquement sur Desktop large)
                      if (MediaQuery.of(context).size.width > 1200)
                        Expanded(
                          flex: 2,
                          child: _buildRightPanel(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
             children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                      SizedBox(width: 8),
                      Text("Rechercher un éleveur, verrat...", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ],
                  ),
                ),
             ],
          ),
          Row(
            children: [
              IconButton(icon: const Icon(LucideIcons.bell, color: Color(0xFF64748B)), onPressed: () {}),
              IconButton(icon: const Icon(LucideIcons.messageSquare, color: Color(0xFF64748B)), onPressed: () {}),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  // Switch user cycler for demo
                  setState(() {
                    int nextIdx = (initialUsers.indexOf(_currentUser) + 1) % initialUsers.length;
                    _currentUser = initialUsers[nextIdx];
                  });
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2563EB),
                      radius: 16,
                      child: Text(_currentUser.avatarUrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_currentUser.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                        Text(_currentUser.role.toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          if (MediaQuery.of(context).size.width > 900)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  const Icon(LucideIcons.piggyBank, color: Color(0xFF2563EB), size: 28),
                  const SizedBox(width: 12),
                  Text('GENETIC NET', style: GoogleFonts.inter(color: const Color(0xFF2563EB), fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _buildNavItem(0, LucideIcons.home, 'Fil d\'actualité'),
          _buildNavItem(1, LucideIcons.calendar, 'Calendrier d\'élevage'),
          _buildNavItem(2, LucideIcons.users, 'Réseau Professionnel'),
          _buildNavItem(3, LucideIcons.activity, 'Suivi Vétérinaire'),
          _buildNavItem(4, LucideIcons.clipboardList, 'Dossier Inséminations'),
          _buildNavItem(5, LucideIcons.dna, 'Registre Verraterie'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final active = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B), size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: active ? const Color(0xFF2563EB) : const Color(0xFF475569),
                  fontSize: 14,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Prochains Événements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ..._events.take(3).map((e) => _buildMiniEventTile(e)).toList(),
          const SizedBox(height: 32),
          const Text('Actifs Récemment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...initialUsers.where((u) => u.id != _currentUser.id).take(4).map((u) => _buildContactTile(u)).toList(),
        ],
      ),
    );
  }

  Widget _buildMiniEventTile(CalendarEvent event) {
    IconData icon;
    Color color;
    if (event.type == 'chaleur') { icon = LucideIcons.flame; color = Colors.orange; }
    else if (event.type == 'mise_bas') { icon = LucideIcons.baby; color = Colors.pink; }
    else { icon = LucideIcons.stethoscope; color = Colors.blue; }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(event.date, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(UserProfile user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE2E8F0),
            radius: 16,
            child: Text(user.avatarUrl, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(user.role, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ),
          IconButton(icon: const Icon(LucideIcons.messageCircle, size: 16, color: Color(0xFF94A3B8)), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0: return _buildFeed();
      case 1: return _buildCalendarTimeline();
      case 2: return _buildNetworkDirectory();
      case 3: return _buildVetTracking();
      case 4: return _buildInseminationList();
      default: return const Center(child: Text("Page en construction"));
    }
  }

  // --- TAB 0: FEED SOCIAL ---
  Widget _buildFeed() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildCreatePostBox(),
        const SizedBox(height: 24),
        ..._posts.map((p) => _buildPostCard(p)).toList(),
      ],
    );
  }

  final _postCtrl = TextEditingController();
  Widget _buildCreatePostBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: const Color(0xFF2563EB), child: Text(_currentUser.avatarUrl, style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _postCtrl,
                  decoration: const InputDecoration(
                    hintText: "Partagez une nouvelle, une annonce...",
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextButton.icon(onPressed: (){}, icon: const Icon(LucideIcons.image, size: 18), label: const Text("Photo")),
                  TextButton.icon(onPressed: (){}, icon: const Icon(LucideIcons.calendar, size: 18), label: const Text("Évènement")),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_postCtrl.text.isNotEmpty) {
                    setState(() {
                      _posts.insert(0, Post(
                        id: DateTime.now().toString(),
                        authorId: _currentUser.id,
                        content: _postCtrl.text,
                        date: "À l'instant",
                      ));
                    });
                    _postCtrl.clear();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                child: const Text("Publier", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    final author = initialUsers.firstWhere((u) => u.id == post.authorId);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: const Color(0xFFE2E8F0), child: Text(author.avatarUrl, style: const TextStyle(color: Color(0xFF475569)))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(author.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${author.role.toUpperCase()} • ${post.date}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ],
              ),
              const Spacer(),
              IconButton(icon: const Icon(LucideIcons.moreHorizontal, color: Color(0xFF94A3B8)), onPressed: (){})
            ],
          ),
          const SizedBox(height: 16),
          Text(post.content, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5)),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9)),
          Row(
            children: [
              TextButton.icon(onPressed: (){}, icon: const Icon(LucideIcons.thumbsUp, size: 18, color: Color(0xFF64748B)), label: Text('${post.likes} J\'aime', style: const TextStyle(color: Color(0xFF64748B)))),
              const SizedBox(width: 16),
              TextButton.icon(onPressed: (){}, icon: const Icon(LucideIcons.messageCircle, size: 18, color: Color(0xFF64748B)), label: Text('${post.comments} Commentaires', style: const TextStyle(color: Color(0xFF64748B)))),
              const Spacer(),
              TextButton.icon(onPressed: (){}, icon: const Icon(LucideIcons.share, size: 18, color: Color(0xFF64748B)), label: const Text('Partager', style: TextStyle(color: Color(0xFF64748B)))),
            ],
          )
        ],
      ),
    );
  }

  // --- TAB 1: CALENDAR TIMELINE ---
  Widget _buildCalendarTimeline() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Calendrier d'Élevage & Gestation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text("Ajouter"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: _events.length,
                separatorBuilder: (ctx, idx) => const Padding(padding: EdgeInsets.only(left: 32), child: Divider()),
                itemBuilder: (ctx, idx) {
                  final e = _events[idx];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const CircleAvatar(radius: 5, backgroundColor: Color(0xFF2563EB)),
                          Container(width: 2, height: 60, color: const Color(0xFFE2E8F0)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.date, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(e.description, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- TAB 2: NETWORK DIRECTORY ---
  Widget _buildNetworkDirectory() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        childAspectRatio: 1.0,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: initialUsers.length,
      itemBuilder: (ctx, idx) {
        final u = initialUsers[idx];
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 32, backgroundColor: const Color(0xFFEFF6FF), child: Text(u.avatarUrl, style: const TextStyle(fontSize: 24, color: Color(0xFF2563EB), fontWeight: FontWeight.bold))),
              const SizedBox(height: 16),
              Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(u.role.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(u.description.isNotEmpty ? u.description : 'Membre du réseau', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("Contacter"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: VET TRACKING ---
  Widget _buildVetTracking() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Carnet de Santé & Visites Vétérinaires", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.filePlus, size: 16),
                label: const Text("Nouveau Bilan"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _vetVisits.length,
              itemBuilder: (ctx, idx) {
                final v = _vetVisits[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.stethoscope, color: Color(0xFF0D9488))),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Animal Code: ${v.animalCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(v.date, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Diagnostic: ${v.diagnostic}', style: const TextStyle(color: Color(0xFF334155), fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('Traitement: ${v.traitement}', style: const TextStyle(color: Color(0xFF334155), fontSize: 14)),
                            if (v.prochainRdv.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                                child: Text('Prochain RDV : ${v.prochainRdv}', style: const TextStyle(color: Color(0xFFD97706), fontSize: 11, fontWeight: FontWeight.bold)),
                              )
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // --- TAB 4: INSEMINATION LIST ---
  Widget _buildInseminationList() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text("Dossier des Inséminations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
           const SizedBox(height: 24),
           Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('DATE 1ère DOSE')),
                    DataColumn(label: Text('TRUIE')),
                    DataColumn(label: Text('LOT SEMENCE')),
                    DataColumn(label: Text('STATUT')),
                  ],
                  rows: _inseminations.map((ins) => DataRow(
                    cells: [
                      DataCell(Text(ins.date1ereDose.split(' ').first, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(ins.truieCode)),
                      DataCell(Text(ins.semenceLot, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: ins.statut == 'Terminé' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(ins.statut, style: TextStyle(color: ins.statut == 'Terminé' ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                      )),
                    ]
                  )).toList(),
                )
              ),
           )
        ]
      )
    );
  }
}
"""

with codecs.open('lib/main.dart', 'w', 'utf-8') as f:
    f.write(dart_code)

print("Social network UI successfully generated in main.dart")
