// test/pdf_generator_test.dart
// Тест для генератора PDF на базе Syncfusion

import 'package:flutter_test/flutter_test.dart';
import 'package:zp/services/documents/pdf_generator.dart';
import 'package:zp/services/documents/doc_models.dart';

void main() {
  group('PdfGenerator с syncfusion_flutter_pdf', () {
    late PdfGenerator generator;

    setUp(() {
      generator = PdfGenerator();
    });

    test('генерация трудового договора с тестовыми данными', () async {
      // Создаём тестовые данные
      final testData = TrudovoyDogovorData(
        orgNazvanie: 'ООО "Рога и Копыта"',
        orgKratkoeNazvanie: 'ООО "РиК"',
        orgInn: '7701234567',
        orgKpp: '770101001',
        orgOgrn: '1157746123456',
        orgYuridicheskiyAdres: '123456, г. Москва, ул. Ленина, д. 10, офис 5',
        orgFakticheskiyAdres: 'г. Москва, ул. Ленина, д. 10, офис 5',
        orgTelefon: '+7 (495) 123-45-67',
        orgElPochta: 'info@example.ru',
        orgBankRS: '40702810123456789012',
        orgBankKS: '30101810100000000225',
        orgBankBIK: '044525225',
        orgBankName: 'ПАО Сбербанк',
        orgDirektorFio: 'Иванов Иван Иванович',
        orgBuhgalterFio: 'Петрова Мария Сергеевна',
        sotFamiliya: 'Сидоров',
        sotName: 'Пётр',
        sotOtchestvo: 'Александрович',
        sotDateBirth: '15.05.1990',
        sotMestoBirth: 'г. Москва',
        sotAdresRegistr: '123456, г. Москва, ул. Пушкина, д. 5, кв. 10',
        sotAdresGitelstva: '123456, г. Москва, ул. Пушкина, д. 5, кв. 10',
        sotTelefon: '+7 (903) 987-65-43',
        sotElPochta: 'sidorov@example.ru',
        sotInn: '770198765432',
        sotSnils: '123-456-789 01',
        sotPasportSeria: '4501',
        sotPasportNomer: '123456',
        sotPasportVidan: 'ОВД района Арбат',
        sotPasportVidanDateTime: '20.10.2015',
        sotPasportKodPodrazdeleniya: '770-001',
        sotBankRS: '40817810123456789012',
        sotBankKS: '30101810100000000225',
        sotBankBIK: '044525225',
        sotBankName: 'ПАО Сбербанк',
        sotDatePriema: '01.02.2024',
        dolzhnostNazvanie: 'Менеджер по продажам',
        podrazdelenie: 'Отдел продаж',
        okladMin: 50000.0,
        okladMax: 80000.0,
        uslTrudaNazvanie: 'Офисное',
        uslKlassUslTruda: '2 класс',
        uslGraficRaboty: 'Пятидневка',
        uslChasovVSmene: 8,
        uslVrNachalaRaboty: '09:00',
        uslVrOkonchaniyaRaboty: '18:00',
        uslKolObedennyhPereryv: 1,
        uslProdObedennyhPereryv: 60,
        uslNormirovannoye: true,
        uslChasovVechernih: 0,
        uslChasovNochnykh: 0,
        nomerDogovora: '123-ТД',
        dateSostavleniya: '25.01.2024',
      );

      // Генерируем PDF
      final result = await generator.generateTrudovoyDogovor(testData);

      // Проверяем результат
      expect(
        result.success,
        true,
        reason: 'Генерация должна завершиться успешно',
      );
      expect(
        result.filePath.isNotEmpty,
        true,
        reason: 'Путь к файлу должен быть указан',
      );
      expect(result.error, isNull, reason: 'Ошибок быть не должно');

      print('✓ PDF успешно создан: ${result.filePath}');
    });

    test('генерация с минимальными данными', () async {
      final testData = TrudovoyDogovorData(
        orgNazvanie: 'ООО "Тест"',
        orgKratkoeNazvanie: 'ООО "Тест"',
        orgInn: '7701000001',
        orgKpp: '770101001',
        orgOgrn: '1157746000001',
        orgYuridicheskiyAdres: 'г. Москва',
        orgFakticheskiyAdres: 'г. Москва',
        orgTelefon: '',
        orgElPochta: '',
        orgBankRS: '',
        orgBankKS: '',
        orgBankBIK: '',
        orgBankName: '',
        orgDirektorFio: 'Директоров Д.Д.',
        orgBuhgalterFio: '',
        sotFamiliya: 'Тестов',
        sotName: 'Тест',
        sotOtchestvo: 'Тестович',
        sotDateBirth: '01.01.2000',
        sotMestoBirth: 'г. Москва',
        sotAdresRegistr: 'г. Москва',
        sotAdresGitelstva: 'г. Москва',
        sotTelefon: '',
        sotElPochta: '',
        sotInn: '',
        sotSnils: '',
        sotPasportSeria: '0000',
        sotPasportNomer: '000000',
        sotPasportVidan: '',
        sotPasportVidanDateTime: '',
        sotPasportKodPodrazdeleniya: '',
        sotBankRS: '',
        sotBankKS: '',
        sotBankBIK: '',
        sotBankName: '',
        sotDatePriema: '01.01.2024',
        dolzhnostNazvanie: 'Специалист',
        podrazdelenie: 'Общий отдел',
        okladMin: 30000.0,
        okladMax: 30000.0,
        uslTrudaNazvanie: 'Нормальное',
        uslKlassUslTruda: '1',
        uslGraficRaboty: 'Стандартный',
        uslChasovVSmene: 8,
        uslVrNachalaRaboty: '09:00',
        uslVrOkonchaniyaRaboty: '18:00',
        uslKolObedennyhPereryv: 1,
        uslProdObedennyhPereryv: 60,
        uslNormirovannoye: true,
        uslChasovVechernih: 0,
        uslChasovNochnykh: 0,
        nomerDogovora: '',
        dateSostavleniya: '01.01.2024',
      );

      final result = await generator.generateTrudovoyDogovor(testData);

      expect(result.success, true);
      expect(result.filePath.isNotEmpty, true);
      print('✓ PDF с минимальными данными создан: ${result.filePath}');
    });
  });
}
