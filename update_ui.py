import codecs
with codecs.open('lib/main.dart', 'r', 'utf-8') as f:
    text = f.read()

# 1. State vars
text = text.replace(
    "  final List<Verrat> _verrats = List.from(initialVerrats);\n  final List<Insemination> _inseminations = List.from(initialInseminations);",
    "  final List<Verrat> _verrats = List.from(initialVerrats);\n  final List<Truie> _truies = List.from(initialTruies);\n  final List<SemenceConditionnee> _semences = List.from(initialSemences);\n  final List<Insemination> _inseminations = List.from(initialInseminations);"
)

# 2. _addVerrat
text = text.replace(
    """  void _addVerrat(String code, String race, String pedigree) {
    setState(() {
      _verrats.add(
        Verrat(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          code: code,
          race: race,
          pedigree: pedigree,
          statut: 'Disponible',
        ),
      );
    });
  }""",
    """  void _addVerrat(String code, String nom, String race, String origine) {
    setState(() {
      _verrats.add(
        Verrat(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          code: code,
          nom: nom,
          race: race,
          age: 12,
          origine: origine,
          pere: 'N/A',
          mere: 'N/A',
          statut: 'Disponible',
        ),
      );
    });
  }"""
)

# 3. _addInsemination
text = text.replace(
    """  void _addInsemination(
    String date,
    String verratId,
    String truie,
    String lot,
  ) {
    setState(() {
      _inseminations.add(
        Insemination(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: date,
          eleveurId: _currentUser.id,
          verratId: verratId,
          truieCode: truie,
          lotCode: lot,
          inseminateurId: 'U3',
          statut: 'En cours',
          resultat: 'En attente',
        ),
      );
    });
  }""",
    """  void _addInsemination(
    String truie,
    String lot,
    String date1ere,
  ) {
    setState(() {
      _inseminations.add(
        Insemination(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          truieCode: truie,
          semenceLot: lot,
          inseminateurId: _currentUser.role == Roles.inseminator ? _currentUser.id : 'U3',
          date1ereDose: date1ere,
          statut: 'En cours',
          resultat: 'En attente',
        ),
      );
    });
  }"""
)

# 4. _buildPerformanceByBreeder
text = text.replace(
    """      initialUsers.where((u) => u.role == Roles.breeder).map((eleveur) {
        final iCount = _inseminations
            .where((i) => i.eleveurId == eleveur.id)
            .length;
        return _buildPerformanceTile(eleveur.name, eleveur.farm, iCount);
      }).toList(),""",
    """      initialUsers.where((u) => u.role == Roles.breeder).map((eleveur) {
        final eleveurTruies = _truies.where((t) => t.eleveurId == eleveur.id).map((t) => t.code).toList();
        final iCount = _inseminations
            .where((i) => eleveurTruies.contains(i.truieCode))
            .length;
        return _buildPerformanceTile(eleveur.name, eleveur.fokontany, iCount);
      }).toList(),"""
)

# 5. _buildInterventionTile
text = text.replace(
    """                Text(
                  '${ins.date} • Lot: ${ins.lotCode}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),""",
    """                Text(
                  '${ins.date1ereDose} • Lot: ${ins.semenceLot}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),"""
)

# 6. _buildInseminationList filtered
text = text.replace(
    """    final filtered = _inseminations.where((i) {
      if (_currentUser.role == Roles.breeder && i.eleveurId != _currentUser.id)
        return false;
      if (_currentUser.role == Roles.inseminator &&
          i.inseminateurId != _currentUser.id)
        return false;
      final term = _searchTerm.toLowerCase();
      final verrat = _verrats.firstWhere((v) => v.id == i.verratId);
      return i.truieCode.toLowerCase().contains(term) ||
          i.lotCode.toLowerCase().contains(term) ||
          verrat.code.toLowerCase().contains(term);
    }).toList();""",
    """    final filtered = _inseminations.where((i) {
      final truie = _truies.firstWhere((t) => t.code == i.truieCode, orElse: () => Truie(code: '', nom: '', age: 0, race: '', origine: '', pere: '', mere: '', eleveurId: ''));
      if (_currentUser.role == Roles.breeder && truie.eleveurId != _currentUser.id)
        return false;
      if (_currentUser.role == Roles.inseminator &&
          i.inseminateurId != _currentUser.id)
        return false;
      final term = _searchTerm.toLowerCase();
      final sem = _semences.firstWhere((s) => s.numLot == i.semenceLot, orElse: () => SemenceConditionnee(numLot: '', verratCode: '', dateHeureConditionnement: '', estimSpzMl: '', technicienLaboId: ''));
      return i.truieCode.toLowerCase().contains(term) ||
          i.semenceLot.toLowerCase().contains(term) ||
          sem.verratCode.toLowerCase().contains(term);
    }).toList();"""
)

# 7. _buildInseminationList rows
text = text.replace(
    """              rows: filtered.map((ins) {
                final verrat = _verrats.firstWhere((v) => v.id == ins.verratId);
                final eleveur = initialUsers.firstWhere(
                  (u) => u.id == ins.eleveurId,
                );""",
    """              rows: filtered.map((ins) {
                final truie = _truies.firstWhere((t) => t.code == ins.truieCode, orElse: () => Truie(code: '', nom: '', age: 0, race: '', origine: '', pere: '', mere: '', eleveurId: ''));
                final eleveur = initialUsers.firstWhere((u) => u.id == truie.eleveurId, orElse: () => initialUsers[0]);
                final semence = _semences.firstWhere((s) => s.numLot == ins.semenceLot, orElse: () => SemenceConditionnee(numLot: '', verratCode: 'Inconnu', dateHeureConditionnement: '', estimSpzMl: '', technicienLaboId: ''));
                final verrat = _verrats.firstWhere((v) => v.code == semence.verratCode, orElse: () => Verrat(id: '', code: semence.verratCode, nom: 'Inconnu', race: '', age: 0, origine: '', pere: '', mere: '', statut: ''));"""
)

text = text.replace(
    """                          Text(
                            ins.date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            ins.lotCode,""",
    """                          Text(
                            ins.date1ereDose.split(' ').first,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            ins.semenceLot,"""
)


# 8. _buildVerratCard
text = text.replace(
    """                            const Text(
                              'PEDIGREE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              v.pedigree,
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF334155),
                              ),
                            ),""",
    """                            const Text(
                              'INFOS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              'Nom: ${v.nom}\\nOrigine: ${v.origine}\\nPère: ${v.pere} - Mère: ${v.mere}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF334155),
                              ),
                            ),"""
)

# 9. _showAddVerratDialog
text = text.replace(
    """  void _showAddVerratDialog() {
    final codeCtrl = TextEditingController();
    final raceCtrl = TextEditingController();
    final pedCtrl = TextEditingController();""",
    """  void _showAddVerratDialog() {
    final codeCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final raceCtrl = TextEditingController();
    final origineCtrl = TextEditingController();"""
)

text = text.replace(
    """              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Code Verrat'),
              ),
              TextField(
                controller: raceCtrl,
                decoration: const InputDecoration(labelText: 'Race'),
              ),
              TextField(
                controller: pedCtrl,
                decoration: const InputDecoration(labelText: 'Pedigree'),
              ),""",
    """              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Code Verrat'),
              ),
              TextField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: raceCtrl,
                decoration: const InputDecoration(labelText: 'Race'),
              ),
              TextField(
                controller: origineCtrl,
                decoration: const InputDecoration(labelText: 'Origine'),
              ),"""
)

text = text.replace(
    """              if (codeCtrl.text.isNotEmpty) {
                _addVerrat(codeCtrl.text, raceCtrl.text, pedCtrl.text);""",
    """              if (codeCtrl.text.isNotEmpty) {
                _addVerrat(codeCtrl.text, nomCtrl.text, raceCtrl.text, origineCtrl.text);"""
)

# 10. _showAddInseminationDialog
text = text.replace(
    """  void _showAddInseminationDialog() {
    final truieCtrl = TextEditingController();
    final lotCtrl = TextEditingController();
    final availableVerrats = _verrats
        .where((v) => v.statut == 'Disponible')
        .toList();
    String? selVerrat = availableVerrats.isNotEmpty
        ? availableVerrats.first.id
        : null;""",
    """  void _showAddInseminationDialog() {
    final truieCtrl = TextEditingController();
    final lotCtrl = TextEditingController();
    final availableSemences = _semences;
    String? selSemence = availableSemences.isNotEmpty
        ? availableSemences.first.numLot
        : null;"""
)

text = text.replace(
    """                if (availableVerrats.isEmpty)
                  const Text(
                    'Aucun verrat disponible',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: selVerrat,
                    decoration: const InputDecoration(labelText: 'Verrat'),
                    items: availableVerrats
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text(v.code),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setLocalState(() => selVerrat = val),
                  ),""",
    """                if (availableSemences.isEmpty)
                  const Text(
                    'Aucune semence disponible',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: selSemence,
                    decoration: const InputDecoration(labelText: 'Lot de Semence (Code Verrat)'),
                    items: availableSemences
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.numLot,
                            child: Text('${s.numLot} (${s.verratCode})'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setLocalState(() => selSemence = val),
                  ),"""
)

text = text.replace(
    """              onPressed: () {
                if (truieCtrl.text.isNotEmpty && selVerrat != null) {
                  _addInsemination(
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    selVerrat!,
                    truieCtrl.text,
                    lotCtrl.text,
                  );
                  Navigator.pop(ctx);
                }
              },""",
    """              onPressed: () {
                if (truieCtrl.text.isNotEmpty) {
                  final lot = selSemence ?? lotCtrl.text;
                  if (lot.isNotEmpty) {
                    _addInsemination(
                      truieCtrl.text,
                      lot,
                      DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                    );
                    Navigator.pop(ctx);
                  }
                }
              },"""
)

with codecs.open('lib/main.dart', 'w', 'utf-8') as f:
    f.write(text)
print("Done")
