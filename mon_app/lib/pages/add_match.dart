import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_client.dart';

const _cs2Maps = [
  'Dust 2',
  'Mirage',
  'Inferno',
  'Nuke',
  'Overpass',
  'Ancient',
  'Vertigo',
  'Anubis',
  'Train',
];

class AddMatchPage extends StatefulWidget {
  const AddMatchPage({super.key});

  @override
  State<AddMatchPage> createState() => _AddMatchPageState();
}

class _AddMatchPageState extends State<AddMatchPage> {
  String _selectedMap = _cs2Maps.first;
  bool _isWin = true;
  final _killsController = TextEditingController();
  final _deathsController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _killsController.dispose();
    _deathsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final kills = int.tryParse(_killsController.text) ?? 0;
    final deaths = int.tryParse(_deathsController.text) ?? 0;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ApiClient.instance.post('/matches', {
        'isWin': _isWin,
        'map': _selectedMap,
        'kills': kills,
        'deaths': deaths,
      });
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Erreur');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ajouter une partie',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFFF5252)),
                ),
              ),

            _label('RÉSULTAT'),
            const SizedBox(height: 12),
            Row(
              children: [
                _resultButton('Victoire', true, const Color(0xFF4CAF50)),
                const SizedBox(width: 12),
                _resultButton('Défaite', false, const Color(0xFFFF5252)),
              ],
            ),

            const SizedBox(height: 28),

            _label('MAP'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cs2Maps.map((map) {
                final selected = _selectedMap == map;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMap = map),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF7C6FFF)
                          : const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF7C6FFF)
                            : const Color(0xFF2A2A3E),
                      ),
                    ),
                    child: Text(
                      map,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white60,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            _label('STATISTIQUES'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    controller: _killsController,
                    label: 'Kills',
                    icon: Icons.gps_fixed,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _numberField(
                    controller: _deathsController,
                    label: 'Deaths',
                    icon: Icons.close,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6FFF),
                  disabledBackgroundColor: const Color(
                    0xFF7C6FFF,
                  ).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Ajouter la partie',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      color: Colors.white.withOpacity(0.4),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    ),
  );

  Widget _resultButton(String label, bool value, Color color) {
    final selected = _isWin == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isWin = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.2) : const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : const Color(0xFF2A2A3E),
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? color : Colors.white60,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C6FFF), width: 1),
        ),
      ),
    );
  }
}
