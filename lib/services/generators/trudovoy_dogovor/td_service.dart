// Фасад генерации трудового договора.
// UI работает только с этим классом.

import 'dart:developer' as dev;
import 'package:zp/services/generators/generator_models.dart';
import 'td_data.dart';
import 'td_repository.dart';
import 'td_pdf_generator.dart';

class TdService {
  final TdRepository _repo;
  final TdPdfGenerator _pdf;

  TdService({TdRepository? repo, TdPdfGenerator? pdf})
    : _repo = repo ?? TdRepository(),
      _pdf = pdf ?? TdPdfGenerator();

  Future<TrudovoyDogovorData?> loadData({
    required int sotrudnikId,
    required int organizaciyaId,
    String? nomerDogovora,
    bool estIspSrok = false,
    int ispSrokKolichestvo = 3,
    IspSrokUnit ispSrokUnit = IspSrokUnit.mesyacy,
  }) {
    dev.log(
      '[TdService] loadData sotrudnik=$sotrudnikId org=$organizaciyaId',
      name: 'DocGen',
    );
    return _repo.load(
      sotrudnikId: sotrudnikId,
      organizaciyaId: organizaciyaId,
      nomerDogovora: nomerDogovora,
      estIspSrok: estIspSrok,
      ispSrokKolichestvo: ispSrokKolichestvo,
      ispSrokUnit: ispSrokUnit,
    );
  }

  Future<List<Map<String, dynamic>>> getOrganizacii() => _repo.getOrganizacii();

  Future<GeneratorResult> generatePdf(TrudovoyDogovorData data) {
    dev.log('[TdService] generatePdf', name: 'DocGen');
    return _pdf.generate(data);
  }
}
