import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/session_record.dart';

enum ExportMode { all, single, range }

class CsvExportService {
  /// Shows export options dialog and exports selected sessions to a CSV file.
  static Future<void> showExportDialog(
      BuildContext context, List<SessionRecord> allSessions) async {
    if (allSessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dışa aktarılacak veri yok.')),
      );
      return;
    }

    final result = await showDialog<_ExportSelection>(
      context: context,
      builder: (ctx) => _ExportOptionsDialog(sessions: allSessions),
    );

    if (result == null) return;

    final sessionsToExport = result.sessions;
    if (sessionsToExport.isEmpty) return;

    // Generate CSV content
    final csvData = _generateCsv(sessionsToExport);

    // Let user pick save location
    final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final fileName = 'muzik_terapi_$dateStr.csv';

    String? outputPath;
    try {
      outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'CSV Dosyasını Kaydet',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
    } catch (_) {
      // FilePicker saveFile not supported on some platforms — fallback
      outputPath = null;
    }

    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsString(csvData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${sessionsToExport.length} seans dışa aktarıldı:\n$outputPath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      // Fallback: save to Documents folder
      final dir = await getApplicationDocumentsDirectory();
      final fallbackPath = '${dir.path}/$fileName';
      final file = File(fallbackPath);
      await file.writeAsString(csvData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${sessionsToExport.length} seans dışa aktarıldı:\n$fallbackPath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  static String _generateCsv(List<SessionRecord> sessions) {
    final List<List<dynamic>> rows = [];
    rows.add([
      'timestamp',
      'group',
      'mood',
      'selectedTrackId',
      'completed',
      'stressBefore',
      'stressAfter',
      'deltaStress',
      'surveyRelax',
      'surveyFeelGood',
      'surveyRepeat',
      'durationPlannedSeconds',
      'durationListenedSeconds',
    ]);
    for (final s in sessions) {
      rows.add([
        s.timestamp.toIso8601String(),
        s.group,
        s.mood,
        s.selectedTrackId,
        s.completed,
        s.stressBefore,
        s.stressAfter,
        s.deltaStress,
        s.surveyRelax,
        s.surveyFeelGood,
        s.surveyRepeat,
        s.durationPlannedSeconds,
        s.durationListenedSeconds,
      ]);
    }
    return const ListToCsvConverter().convert(rows);
  }
}

class _ExportSelection {
  final List<SessionRecord> sessions;
  _ExportSelection(this.sessions);
}

class _ExportOptionsDialog extends StatefulWidget {
  final List<SessionRecord> sessions;
  const _ExportOptionsDialog({required this.sessions});
  @override
  State<_ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<_ExportOptionsDialog> {
  ExportMode _mode = ExportMode.all;
  final Set<int> _selectedIndices = {};
  final DateFormat _df = DateFormat('dd.MM.yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Dışa Aktarma Seçenekleri'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selection
            RadioListTile<ExportMode>(
              title: const Text('Tümünü dışa aktar'),
              subtitle: Text('${widget.sessions.length} seans'),
              value: ExportMode.all,
              groupValue: _mode,
              onChanged: (v) => setState(() {
                _mode = v!;
                _selectedIndices.clear();
              }),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<ExportMode>(
              title: const Text('Seçili seansları dışa aktar'),
              value: ExportMode.range,
              groupValue: _mode,
              onChanged: (v) => setState(() {
                _mode = v!;
                _selectedIndices.clear();
              }),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            // Session selection list (only for range mode)
            if (_mode == ExportMode.range) ...[
              const Divider(),
              Text('Seansları seçin:',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.sessions.length,
                  itemBuilder: (ctx, i) {
                    final s = widget.sessions[i];
                    return CheckboxListTile(
                      value: _selectedIndices.contains(i),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _selectedIndices.add(i);
                        } else {
                          _selectedIndices.remove(i);
                        }
                      }),
                      title: Text(s.mood,
                          style: const TextStyle(fontSize: 14)),
                      subtitle: Text(
                        '${_df.format(s.timestamp)} • Stres: ${s.stressBefore}→${s.stressAfter}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
              if (_selectedIndices.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${_selectedIndices.length} seans seçildi',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton.icon(
          onPressed: () {
            List<SessionRecord> selected;
            if (_mode == ExportMode.all) {
              selected = widget.sessions;
            } else {
              selected = _selectedIndices
                  .map((i) => widget.sessions[i])
                  .toList();
              if (selected.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lütfen en az bir seans seçin.')),
                );
                return;
              }
            }
            Navigator.pop(context, _ExportSelection(selected));
          },
          icon: const Icon(Icons.save_alt),
          label: const Text('Dışa Aktar'),
        ),
      ],
    );
  }
}
