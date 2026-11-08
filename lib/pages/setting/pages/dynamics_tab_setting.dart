import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynamicsTabSettingPage extends StatefulWidget {
  const DynamicsTabSettingPage({super.key});

  @override
  State<DynamicsTabSettingPage> createState() => _DynamicsTabSettingPageState();
}

class _DynamicsTabSettingPageState extends State<DynamicsTabSettingPage> {
  late List<DynamicsTabType> _tabs;
  late Set<DynamicsTabType> _selected;

  @override
  void initState() {
    super.initState();
    _tabs = List.from(DynamicsTabType.values);
    _selected = Set.from(Pref.dynamicsTabs);
  }

  void _save() {
    if (_selected.isEmpty) {
      Get.snackbar('提示', '至少需要保留一个标签页');
      return;
    }
    final saveList = _tabs
        .where((e) => _selected.contains(e))
        .map((e) => e.index)
        .toList();
    GStorage.setting.put(SettingBoxKey.dynamicsTabs, saveList);
    Get.back();
    Get.snackbar('提示', '保存成功，返回动态页刷新即可生效');
  }

  void _reset() {
    setState(() {
      _tabs = List.from(DynamicsTabType.values);
      _selected = Set.from(DynamicsTabType.values);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态标签页编辑'),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text('重置'),
          ),
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _tabs.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = _tabs.removeAt(oldIndex);
            _tabs.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selected.contains(tab);
          return ListTile(
            key: ValueKey(tab),
            leading: Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selected.add(tab);
                  } else {
                    _selected.remove(tab);
                  }
                });
              },
            ),
            title: Text(tab.label),
            trailing: const Icon(Icons.drag_handle),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selected.remove(tab);
                } else {
                  _selected.add(tab);
                }
              });
            },
          );
        },
      ),
    );
  }
}
