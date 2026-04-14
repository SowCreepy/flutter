import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_client.dart';
import '../models/player.dart';

String eloToRank(int elo) {
  if (elo >= 25000) return 'Global Elite';
  if (elo >= 20000) return 'Supreme';
  if (elo >= 17500) return 'LEM';
  if (elo >= 15000) return 'LE';
  if (elo >= 13000) return 'DMG';
  if (elo >= 11000) return 'MG2';
  if (elo >= 9000) return 'MG1';
  if (elo >= 7500) return 'GN Master';
  if (elo >= 6000) return 'GN3';
  if (elo >= 4500) return 'GN2';
  if (elo >= 3000) return 'GN1';
  if (elo >= 2000) return 'Silver Elite M.';
  if (elo >= 1500) return 'Silver Elite';
  if (elo >= 1000) return 'Silver IV';
  if (elo >= 750) return 'Silver III';
  if (elo >= 500) return 'Silver II';
  return 'Silver I';
}

Color eloToColor(int elo) {
  if (elo >= 25000) return const Color(0xFFFFD700);
  if (elo >= 20000) return const Color(0xFFFF4444);
  if (elo >= 15000) return const Color(0xFFFF6B6B);
  if (elo >= 10000) return const Color(0xFF7C6FFF);
  if (elo >= 5000) return const Color(0xFF4ECDC4);
  if (elo >= 2000) return const Color(0xFF95E1D3);
  return const Color(0xFFA0A0A0);
}

class EditProfilePage extends StatefulWidget {
  final Player player;
  const EditProfilePage({super.key, required this.player});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _eloController;
  late TextEditingController _steamUrlController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.player.username);
    _eloController = TextEditingController(
      text: widget.player.elo > 0 ? widget.player.elo.toString() : '',
    );
    _steamUrlController = TextEditingController(
      text: widget.player.steamUrl ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _eloController.dispose();
    _steamUrlController.dispose();
    super.dispose();
  }

  int get _elo => int.tryParse(_eloController.text) ?? 0;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final elo = _elo.clamp(0, 30000);
      final rank = eloToRank(elo);

      final body = <String, dynamic>{
        'username': _usernameController.text.trim(),
        'elo': elo,
        'rank': rank,
      };

      final steamUrl = _steamUrlController.text.trim();
      if (steamUrl.isNotEmpty) {
        if (!steamUrl.startsWith('https://steamcommunity.com/')) {
          setState(() {
            _error =
                'URL Steam invalide (doit commencer par https://steamcommunity.com/)';
            _saving = false;
          });
          return;
        }
        body['steamUrl'] = steamUrl;
      } else {
        body['steamUrl'] = null;
      }

      await ApiClient.instance.patch('/players/me', body);
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Erreur de sauvegarde');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewElo = _elo.clamp(0, 30000);
    final previewRank = eloToRank(previewElo);
    final previewColor = eloToColor(previewElo);

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
          'Modifier le profil',
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
                  border: Border.all(
                    color: const Color(0xFFFF5252).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFFF5252),
                    fontSize: 14,
                  ),
                ),
              ),

            _label('PSEUDO'),
            const SizedBox(height: 8),
            _textField(
              controller: _usernameController,
              hint: 'Votre pseudo',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 28),

            _label('ELO PREMIER CS2'),
            const SizedBox(height: 8),
            _textField(
              controller: _eloController,
              hint: '0 - 30000',
              icon: Icons.military_tech_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: previewColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: previewColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: previewColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    previewRank,
                    style: TextStyle(
                      color: previewColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$previewElo pts',
                    style: TextStyle(
                      color: previewColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _label('PROFIL STEAM'),
            const SizedBox(height: 8),
            _textField(
              controller: _steamUrlController,
              hint: 'https://steamcommunity.com/id/...',
              icon: Icons.link,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 6),
            Text(
              'Collez l\'URL de votre profil Steam pour le lier à votre compte.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
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
                        'Enregistrer',
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

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
