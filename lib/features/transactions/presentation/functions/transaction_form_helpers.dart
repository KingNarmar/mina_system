import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';

String buildWorkerOptionLabel(WorkerModel worker) {
  return '${worker.hrCode} - ${worker.name}';
}

String buildToolOptionLabel(ToolModel tool) {
  return '${tool.toolCode} - ${tool.toolName}';
}

WorkerModel findWorkerByOptionLabel({
  required List<WorkerModel> workers,
  required String label,
}) {
  return workers.firstWhere((worker) {
    return buildWorkerOptionLabel(worker) == label;
  });
}

ToolModel findToolByOptionLabel({
  required List<ToolModel> tools,
  required String label,
}) {
  return tools.firstWhere((tool) {
    return buildToolOptionLabel(tool) == label;
  });
}
