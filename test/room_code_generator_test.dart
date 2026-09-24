import 'package:flutter_test/flutter_test.dart';
import 'package:skribbl_io/utils/room_code_generator.dart';

void main() {
  group('RoomCodeGenerator', () {
    test('generates valid 6-character alphanumeric code with letters and numbers', () {
      for (int i = 0; i < 20; i++) {
        final code = RoomCodeGenerator.generate();
        expect(code.length, 6);
        expect(RegExp(r'[A-Z]').hasMatch(code), isTrue, reason: 'Must contain uppercase letter');
        expect(RegExp(r'[0-9]').hasMatch(code), isTrue, reason: 'Must contain number');
      }
    });

    test('cleanCode handles plain codes and converts to uppercase', () {
      expect(RoomCodeGenerator.cleanCode('k9x2b7'), 'K9X2B7');
      expect(RoomCodeGenerator.cleanCode('  pink42  '), 'PINK42');
    });

    test('cleanCode extracts code from full invite URLs', () {
      expect(
        RoomCodeGenerator.cleanCode('http://192.168.1.3:3000/?room=K9X2B7'),
        'K9X2B7',
      );
      expect(
        RoomCodeGenerator.cleanCode('https://cute-game.onrender.com/?server=https://...&room=STAR88'),
        'STAR88',
      );
    });

    test('cleanCode extracts code from text messages', () {
      expect(
        RoomCodeGenerator.cleanCode('Join my Skribbl game! Code: K9X2B7'),
        'K9X2B7',
      );
      expect(
        RoomCodeGenerator.cleanCode('Room code: BUNNY7 let\'s play!'),
        'BUNNY7',
      );
    });
  });
}
