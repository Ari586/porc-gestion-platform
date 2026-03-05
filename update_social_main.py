import codecs
import re

with codecs.open('lib/main.dart', 'r', 'utf-8') as f:
    content = f.read()

# 1. Update Post Model
new_post_model = """class Post {
  final String id;
  final String authorId;
  final String role;
  
  // Identité
  final String code;
  final String nom;
  final String contact;
  
  // Animal
  final String race;
  final String age;
  final String origine;
  final String ascendance;
  
  // Labo / Sperme
  final String typeSperme;
  final String collecte;
  final String quantite;
  final String qualite;
  final String frequence;
  final String lot;
  final String arrivee;
  final String conditionnement;
  
  // IA / Élevage
  final String localisation;
  final String truie;
  final String dose1;
  final String dose2;
  final String retour;
  final String miseBas;
  final String porcelets;
  final String iaStats;
  
  // Messages fixes
  final String suivi;
  final String message;
  
  // Meta
  final String createdAt;
  final int likes;
  final int comments;

  Post({
    required this.id,
    required this.authorId,
    required this.role,
    this.code = '',
    this.nom = '',
    this.contact = '',
    this.race = '',
    this.age = '',
    this.origine = '',
    this.ascendance = '',
    this.typeSperme = '',
    this.collecte = '',
    this.quantite = '',
    this.qualite = '',
    this.frequence = '',
    this.lot = '',
    this.arrivee = '',
    this.conditionnement = '',
    this.localisation = '',
    this.truie = '',
    this.dose1 = '',
    this.dose2 = '',
    this.retour = '',
    this.miseBas = '',
    this.porcelets = '',
    this.iaStats = '',
    this.suivi = '',
    this.message = '',
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });
}
"""
content = re.sub(r'class Post \{.*?\}\n', new_post_model, content, flags=re.DOTALL)

# 2. Update initialPosts
new_initial_posts = """final List<Post> initialPosts = [
  Post(
    id: 'P1',
    authorId: 'U3',
    role: 'Inséminateur',
    nom: 'Paul Insem',
    localisation: 'Ambohimanarina',
    truie: 'T-88',
    lot: 'LOT-2024-A',
    iaStats: '32 IA, 85%',
    message: 'Super matinée d\\'insémination à Ambohimanarina. La qualité de la semence du lot LOT-2024-A (Thor) est excellente ! 🧬🐷',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    likes: 12,
    comments: 3,
  ),
  Post(
    id: 'P2',
    authorId: 'U2',
    role: 'Éleveur',
    nom: 'Marc Éleveur',
    message: 'Quelqu\\'un sait si le Dr. Rivo est disponible ce weekend pour une échographie de gestation ?',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    likes: 2,
    comments: 5,
  ),
  Post(
    id: 'P3',
    authorId: 'U1',
    role: 'Responsable',
    nom: 'Jean Responsable',
    message: '📢 Annonce : Nouvelle arrivée de verrat Landrace prévue pour le mois prochain. Préparez vos plannings !',
    createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    likes: 24,
    comments: 8,
  ),
];"""
content = re.sub(r'final List<Post> initialPosts = \[.*?\];', new_initial_posts, content, flags=re.DOTALL)

# We need to completely rewrite the _buildFeed, _buildCreatePostBox and _buildPostCard functions.
# Since it's a massive change, let's inject a new file 'feed_ui.dart' and import it, or just replace the chunks carefully.
# Given the size, let's replace the whole _buildFeed section down to _buildCalendarTimeline
new_feed_code = """
  // --- STATE FOR FEED ---
  String _roleFiltre = 'Tous';
  String _selectedRoleForm = 'Verrat';

  final _codeCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _raceCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _origineCtrl = TextEditingController();
  final _ascendanceCtrl = TextEditingController();
  String _typeSpermeForm = 'Fraiche';
  final _collecteCtrl = TextEditingController();
  final _quantiteCtrl = TextEditingController();
  final _qualiteCtrl = TextEditingController();
  final _frequenceCtrl = TextEditingController();
  final _lotCtrl = TextEditingController();
  final _arriveeCtrl = TextEditingController();
  final _conditionnementCtrl = TextEditingController();
  final _localisationCtrl = TextEditingController();
  final _truieCtrl = TextEditingController();
  final _dose1Ctrl = TextEditingController();
  final _dose2Ctrl = TextEditingController();
  final _retourCtrl = TextEditingController();
  final _miseBasCtrl = TextEditingController();
  final _porceletsCtrl = TextEditingController();
  final _iaStatsCtrl = TextEditingController();
  final _suiviCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  void _clearForm() {
    _codeCtrl.clear(); _nomCtrl.clear(); _contactCtrl.clear(); _raceCtrl.clear();
    _ageCtrl.clear(); _origineCtrl.clear(); _ascendanceCtrl.clear(); _collecteCtrl.clear();
    _quantiteCtrl.clear(); _qualiteCtrl.clear(); _frequenceCtrl.clear(); _lotCtrl.clear();
    _arriveeCtrl.clear(); _conditionnementCtrl.clear(); _localisationCtrl.clear();
    _truieCtrl.clear(); _dose1Ctrl.clear(); _dose2Ctrl.clear(); _retourCtrl.clear();
    _miseBasCtrl.clear(); _porceletsCtrl.clear(); _iaStatsCtrl.clear(); _suiviCtrl.clear();
    _messageCtrl.clear();
  }

  // --- TAB 0: FEED SOCIAL ---
  Widget _buildFeed() {
    final visibles = _roleFiltre == 'Tous' ? _posts : _posts.where((p) => p.role == _roleFiltre).toList();
    
    int iaTotal = 0;
    int porcelets = 0;
    for (var p in _posts) {
       final match = RegExp(r'\\d+').firstMatch(p.iaStats);
       if (match != null) iaTotal += int.tryParse(match.group(0) ?? '0') ?? 0;
       porcelets += int.tryParse(p.porcelets) ?? 0;
    }
    final verratsCount = _posts.where((p) => p.role == 'Verrat').length;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildCreatePostBox(),
        const SizedBox(height: 24),
        
        // KPIs
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _buildSmallKpi('${_posts.length}', 'Publications'),
            _buildSmallKpi('$verratsCount', 'Suivis verrat'),
            _buildSmallKpi('$iaTotal', 'IA déclarées'),
            _buildSmallKpi('$porcelets', 'Porcelets nés'),
          ]
        ),
        const SizedBox(height: 16),
        
        // Filters
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Tous', 'Verrat', 'Technicien labo', 'Éleveur', 'Inséminateur', 'Responsable'].map((r) {
            final active = _roleFiltre == r;
            return ChoiceChip(
              label: Text(r),
              selected: active,
              selectedColor: const Color(0xFF059669),
              labelStyle: TextStyle(color: active ? Colors.white : const Color(0xFF1D4ED8)),
              onSelected: (val) {
                if (val) setState(() => _roleFiltre = r);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        ...visibles.map((p) => _buildPostCard(p)).toList(),
      ],
    );
  }

  Widget _buildSmallKpi(String val, String label) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FBFF), border: Border.all(color: const Color(0xFFD9E2F1)), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF667085))),
        ]
      )
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFC9D4EA))),
            ),
          )
        ],
      )
    );
  }

  Widget _buildCreatePostBox() {
    List<Widget> activeFields = [];
    
    // Logic from HTML mapRoleClasses
    bool showCommon = true;
    bool showVerrat = _selectedRoleForm == 'Verrat' || _selectedRoleForm == 'Technicien labo';
    bool showLabo = _selectedRoleForm == 'Technicien labo';
    bool showEleveur = _selectedRoleForm == 'Éleveur' || _selectedRoleForm == 'Inséminateur';
    bool showInsem = _selectedRoleForm == 'Inséminateur';
    bool showResp = _selectedRoleForm == 'Responsable';

    activeFields.add(_buildField('Code / Référence', _codeCtrl));
    activeFields.add(_buildField('Nom / Prénoms', _nomCtrl));
    activeFields.add(_buildField('Contact / Email', _contactCtrl));
    
    if (showCommon) {
      activeFields.add(_buildField('Race', _raceCtrl));
      activeFields.add(_buildField('Âge', _ageCtrl));
    }
    if (showVerrat) {
      activeFields.add(_buildField('Origine verrat', _origineCtrl));
      activeFields.add(_buildField('Père / Mère', _ascendanceCtrl));
      activeFields.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sperme (Fraiche/Congelé)', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC9D4EA)), borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _typeSpermeForm,
                  isExpanded: true,
                  items: ['Fraiche', 'Congelé'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _typeSpermeForm = v!),
                )
              )
            )
          ]
        )
      ));
    }
    if (showVerrat || showLabo) {
      activeFields.add(_buildField('Date/heure collecte', _collecteCtrl));
      activeFields.add(_buildField('Quantité (ml)', _quantiteCtrl));
      activeFields.add(_buildField('Mobilité / force / spz/ml', _qualiteCtrl));
      activeFields.add(_buildField('Fréquence collecte', _frequenceCtrl));
      activeFields.add(_buildField('Lot semence', _lotCtrl));
    }
    if (showLabo) {
      activeFields.add(_buildField('Date/heure arrivée labo', _arriveeCtrl));
      activeFields.add(_buildField('Date/heure conditionnement', _conditionnementCtrl));
    }
    if (showEleveur) {
      activeFields.add(_buildField('Localisation', _localisationCtrl));
      activeFields.add(_buildField('Truie (code, nom...)', _truieCtrl));
      activeFields.add(_buildField('Date IA 1ère dose', _dose1Ctrl));
      activeFields.add(_buildField('Date IA 2ème dose', _dose2Ctrl));
    }
    if (_selectedRoleForm == 'Éleveur') {
      activeFields.add(_buildField('Date probable retour chaleur', _retourCtrl));
      activeFields.add(_buildField('Date mise bas', _miseBasCtrl));
      activeFields.add(_buildField('Nombre de porcelets', _porceletsCtrl));
    }
    if (showInsem) {
      activeFields.add(_buildField('Nombre IA/mois + taux réussite', _iaStatsCtrl));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2F1)),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 10, offset: Offset(0, 4))]
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nouvelle publication", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
               const Text('Acteur : ', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
               const SizedBox(width: 8),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10),
                 decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC9D4EA)), borderRadius: BorderRadius.circular(8)),
                 child: DropdownButtonHideUnderline(
                   child: DropdownButton<String>(
                     value: _selectedRoleForm,
                     items: ['Verrat', 'Technicien labo', 'Éleveur', 'Inséminateur', 'Responsable'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                     onChanged: (v) => setState(() => _selectedRoleForm = v!),
                   )
                 )
               )
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
             crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             childAspectRatio: 5,
             crossAxisSpacing: 10,
             mainAxisSpacing: 0,
             children: activeFields,
          ),
          if (showResp) _buildField('Suivi responsable', _suiviCtrl, maxLines: 3),
          _buildField('Message de publication', _messageCtrl, maxLines: 3),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_messageCtrl.text.isEmpty && _nomCtrl.text.isEmpty && _codeCtrl.text.isEmpty) return;
                  setState(() {
                    _posts.insert(0, Post(
                      id: DateTime.now().toString(),
                      authorId: _currentUser.id,
                      role: _selectedRoleForm,
                      code: _codeCtrl.text,
                      nom: _nomCtrl.text,
                      contact: _contactCtrl.text,
                      race: _raceCtrl.text,
                      age: _ageCtrl.text,
                      origine: _origineCtrl.text,
                      ascendance: _ascendanceCtrl.text,
                      typeSperme: _typeSpermeForm,
                      collecte: _collecteCtrl.text,
                      quantite: _quantiteCtrl.text,
                      qualite: _qualiteCtrl.text,
                      frequence: _frequenceCtrl.text,
                      lot: _lotCtrl.text,
                      arrivee: _arriveeCtrl.text,
                      conditionnement: _conditionnementCtrl.text,
                      localisation: _localisationCtrl.text,
                      truie: _truieCtrl.text,
                      dose1: _dose1Ctrl.text,
                      dose2: _dose2Ctrl.text,
                      retour: _retourCtrl.text,
                      miseBas: _miseBasCtrl.text,
                      porcelets: _porceletsCtrl.text,
                      iaStats: _iaStatsCtrl.text,
                      suivi: _suiviCtrl.text,
                      message: _messageCtrl.text,
                      createdAt: DateTime.now().toIso8601String(),
                    ));
                  });
                  _clearForm();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D4ED8), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text("Publier"),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                   setState((){
                      _posts.clear();
                   });
                },
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1D4ED8), side: const BorderSide(color: Color(0xFFBFD1FB)), backgroundColor: const Color(0xFFEEF4FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text("Vider fil"),
              )
            ],
          )
        ],
      )
    );
  }

  Widget _buildPostRow(String label, String value) {
     if (value.isEmpty || value.trim() == '' || value.replaceAll(' - ', '').trim().isEmpty || value.replaceAll(' · ', '').trim().isEmpty || value.replaceAll(' → ', '').trim().isEmpty) return const SizedBox.shrink();
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 3),
       child: RichText(
         text: TextSpan(
           style: const TextStyle(fontSize: 13, color: Color(0xFF1F2A44)),
           children: [
             TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
             TextSpan(text: value),
           ]
         )
       )
     );
  }

  Widget _buildPostCard(Post post) {
    String initials = post.nom.isNotEmpty ? post.nom.substring(0, 1).toUpperCase() : post.role.substring(0, 1).toUpperCase();
    
    DateTime dt;
    try { dt = DateTime.parse(post.createdAt); } catch(e) { dt = DateTime.now(); }
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(dt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2F1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: const Color(0xFF059669), radius: 16, child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(post.nom.isNotEmpty ? post.nom : 'Sans nom', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), border: Border.all(color: const Color(0xFFBFDBFE)), borderRadius: BorderRadius.circular(99)),
                        child: Text(post.role, style: const TextStyle(fontSize: 10, color: Color(0xFF1E3A8A))),
                      )
                    ],
                  ),
                  Text('${post.code.isNotEmpty ? post.code : "Sans code"} · $formattedDate', style: const TextStyle(color: Color(0xFF667085), fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPostRow('Message', post.message),
          _buildPostRow('Race / âge', [post.race, post.age].where((e) => e.isNotEmpty).join(' - ')),
          _buildPostRow('Origine', post.origine),
          _buildPostRow('Ascendance', post.ascendance),
          _buildPostRow('Sperme', [post.typeSperme, post.quantite.isNotEmpty ? '${post.quantite} ml' : '', post.qualite].where((e) => e.isNotEmpty).join(' · ')),
          _buildPostRow('Collecte / conditionnement', [post.collecte, post.conditionnement].where((e) => e.isNotEmpty).join(' → ')),
          _buildPostRow('Lot / arrivée labo', [post.lot, post.arrivee].where((e) => e.isNotEmpty).join(' · ')),
          _buildPostRow('Éleveur/Truie', [post.localisation, post.truie].where((e) => e.isNotEmpty).join(' · ')),
          _buildPostRow('IA', [post.dose1, post.dose2, post.iaStats].where((e) => e.isNotEmpty).join(' | ')),
          _buildPostRow('Retour chaleur / mise bas / porcelets', [post.retour, post.miseBas, post.porcelets].where((e) => e.isNotEmpty).join(' · ')),
          _buildPostRow('Suivi responsable', post.suivi),
          _buildPostRow('Contact', post.contact),
        ],
      ),
    );
  }

  // --- TAB 1: CALENDAR TIMELINE ---
"""
content = re.sub(r'  // --- TAB 0: FEED SOCIAL ---.*// --- TAB 1: CALENDAR TIMELINE ---', new_feed_code, content, flags=re.DOTALL)

with codecs.open('lib/main.dart', 'w', 'utf-8') as f:
    f.write(content)

print("Main.dart successfully updated with custom HTML structure.")
