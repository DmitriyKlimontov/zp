/*Что делать по порядку:

Добавьте библиотеки из pubspec_additions.yaml и выполните flutter pub get
Создайте шаблон DOCX — откройте Word, напишите текст договора и вставьте переменные в двойных фигурных скобках: {{sot_fio}}, {{org_nazvanie}}, {{dolzhnost}} и т.д. Полный список переменных есть в docx_generator.dart в методе _fillContent. Сохраните в assets/templates/trudovoy_dogovor.docx
В sotrudnikiitem.dart добавьте фрагменты из sotrudnikiitem_patch.dart*/
