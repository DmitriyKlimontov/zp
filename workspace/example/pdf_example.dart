// example/pdf_example.dart
// Пример использования генератора PDF с Syncfusion

import 'package:zp/services/documents/pdf_generator.dart';
import 'package:zp/services/documents/doc_models.dart';

void main() async {
  print('=== Пример генерации PDF с syncfusion_flutter_pdf ===\n');

  final generator = PdfGenerator();

  // Создаём тестовые данные для трудового договора
  final testData = TrudovoyDogovorData(
    orgNazvanie: 'ООО "Технологии Будущего"',
    orgKratkoeNazvanie: 'ООО "ТБ"',
    orgInn: '7701234567',
    orgKpp: '770101001',
    orgOgrn: '1157746123456',
    orgYuridicheskiyAdres: '123456, г. Москва, ул. Тверская, д. 1, офис 100',
    orgFakticheskiyAdres: 'г. Москва, ул. Тверская, д. 1, офис 100',
    orgTelefon: '+7 (495) 123-45-67',
    orgElPochta: 'info@techfuture.ru',
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
    dolzhnostNazvanie: 'Старший разработчик',
    podrazdelenie: 'Департамент разработки ПО',
    okladMin: 150000.0,
    okladMax: 200000.0,
    uslTrudaNazvanie: 'Офисное',
    uslKlassUslTruda: '2 класс (допустимые)',
    uslGraficRaboty: 'Пятидневная рабочая неделя',
    uslChasovVSmene: 8,
    uslVrNachalaRaboty: '09:00',
    uslVrOkonchaniyaRaboty: '18:00',
    uslKolObedennyhPereryv: 1,
    uslProdObedennyhPereryv: 60,
    uslNormirovannoye: true,
    uslChasovVechernih: 2,
    uslChasovNochnykh: 0,
    nomerDogovora: '45-ТД',
    dateSostavleniya: '25.01.2024',
  );

  print('Генерация трудового договора для: ${testData.sotFio}');
  print('Должность: ${testData.dolzhnostNazvanie}');
  print('Оклад: ${testData.okladMin} - ${testData.okladMax} руб.\n');

  try {
    final result = await generator.generateTrudovoyDogovor(testData);

    if (result.success) {
      print('✓ SUCCESS!');
      print('  Файл создан: ${result.filePath}');
      print('  Размер: ${(await result.filePath.length).toString()} байт\n');
    } else {
      print('✗ ERROR: ${result.error}');
    }
  } catch (e) {
    print('✗ EXCEPTION: $e');
  }

  print('\n=== Пример завершён ===');
}
