import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class HomeLayout extends StatelessWidget {
  // ignore: non_constant_identifier_names
  var ScaffoldKey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();

  var titileController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: ScaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
              backgroundColor: Colors.blueAccent,
            ),
            backgroundColor: const Color.fromARGB(255, 211, 223, 238),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: ((context) => cubit.screens[cubit.currentIndex]),
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formkey.currentState!.validate()) {
                    cubit.insertToDatabase(
                        title: titileController.text,
                        time: timeController.text,
                        data: dateController.text);
                  }
                } else {
                  ScaffoldKey.currentState
                      ?.showBottomSheet<void>((context) => Container(
                            color: Colors.grey[300],
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: formkey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultFormField(
                                        controller: titileController,
                                        type: TextInputType.text,
                                        validate: (String value) {
                                          if (value.isEmpty) {
                                            return 'title must not be empty';
                                          }
                                          return null;
                                        },
                                        label: 'Task Title',
                                        prefix: Icons.title),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    defaultFormField(
                                        controller: timeController,
                                        type: TextInputType.datetime,
                                        validate: (String value) {
                                          if (value.isEmpty) {
                                            return 'time must not be empty';
                                          }
                                          return null;
                                        },
                                        label: 'Task Time',
                                        prefix: Icons.timelapse),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    defaultFormField(
                                        controller: dateController,
                                        type: TextInputType.datetime,

                                        // onTap: () async {
                                        //   await showDatePicker(
                                        //     context: context,
                                        //     initialDate: DateTime.now(),
                                        //     firstDate: DateTime(2015),
                                        //     lastDate: DateTime(2025),
                                        //   ).then((selectedDate) {
                                        //     if (selectedDate != null) {
                                        //       dateController.text =
                                        //           DateFormat('yyyy-MM-dd')
                                        //               .format(selectedDate);
                                        //     }
                                        //   });
                                        // },
                                        validate: (String value) {
                                          if (value.isEmpty) {
                                            return 'date must not be empty';
                                          }
                                          return null;
                                        },
                                        label: 'Task date',
                                        prefix: Icons.calendar_today),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isShow: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                  // setState(() {
                  //   currentIndex = index;
                  // });
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu), label: 'Task'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_box), label: 'Done'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive_outlined), label: 'Archived'),
                ]),
          );
        },
      ),
    );
  }
}
