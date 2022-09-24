import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/todo_app/atchtive_task/atchtive_task.dart';
import 'package:todo_app/modules/todo_app/done_task/done_screen.dart';
import 'package:todo_app/modules/todo_app/new_task/task_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:todo_app/shared/network/local/ccch_helper.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  Database? database;
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  List<Map> newtasks = [];
  List<Map> donetasks = [];
  List<Map> archivedtasks = [];

  List<Widget> screens = [
    NewTaskScreen(),
    DoneTaskScreen(),
    ArchivedTaskScreen()
  ];
  List<String> titles = [
    'NEW TASKS',
    'DONE TASKS',
    'ARCHIVED TASK',
  ];
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNabBarState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        // ignore: avoid_print
        print('create');
        database
            .execute(
                'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, title TEXT, data TEXT, time TEXT,status TEXT)')
            .then((value) {
          // ignore: avoid_print
          print('table created');
        }).catchError((error) {
          // ignore: avoid_print
          print('Error ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDatebase(database);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String data,
  }) async {
    await database?.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO Tasks(title, data, time,status) VALUES("$title", "$data","$time","new" )')
          .then((value) {
        // ignore: avoid_print, unnecessary_brace_in_string_interps
        print('${value} succesflly');
        emit(AppInsertDatabaseState());

        getDatebase(database);
        emit(AppGetDatabaseState());
      }).catchError((error) {
        // ignore: avoid_print
        print('Error ${error.toString()}');
      });
    });
  }

  void getDatebase(database) {
    newtasks = [];
    donetasks = [];
    archivedtasks = [];

    emit(AppGetDatabaseLoadingState());
    database!.rawQuery('SELECT * FROM Tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newtasks.add(element);
        } else if (element['status'] == 'done') {
          donetasks.add(element);
        } else {
          archivedtasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void changeBottomSheetState({required IconData icon, required bool isShow}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  void updataDatabase({required String status, required int id}) async {
    database!.rawUpdate('UPDATE Tasks SET status = ? WHERE id = ?',
        // ignore: unnecessary_string_interpolations, unnecessary_brace_in_string_interps
        ['${status}', id]).then((value) {
      getDatebase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deletDatabase({required int id}) async {
    database!.rawDelete('DELETE FROM Tasks WHERE id = ?', [id]).then((value) {
      getDatebase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  bool isDark = false;
  ThemeMode appMode = ThemeMode.dark;
  void changeAppMode({bool? fromIsDark}) {
    if (fromIsDark != null) {
      isDark = fromIsDark;
      emit(AppChangeModeState());
    } else {
      isDark = !isDark;
      CacheHelper.putData(key: 'isDark', value: isDark).then((value) {
        emit(AppChangeModeState());
      });
    }
  }
}
