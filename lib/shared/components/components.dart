import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color backgrount = Colors.blue,
  bool isUpperCase = true,
  double radius = 0.0,
  required Function function,
  required String text,
}) =>
    Container(
      width: width,
      child: MaterialButton(
        onPressed: () {
          function();
        },
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgrount,
      ),
    );

Widget defaultFormField({
  required TextEditingController controller,
  TextInputType type = TextInputType.visiblePassword,
  Function(dynamic text)? onSubmit,
  // Function? onChange,
  Function()? onTap,
  required Function validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  bool ispassword = false,
  Function? suffixPressed,
  Function(dynamic text)? onChange,
}) {
  return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: ispassword,
      onChanged: onChange,
      // onTap: onTap ,
      // onFieldSubmitted: onSubmit,
      validator: (value) {
        return validate(value);
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 20),
        prefixIcon: Icon(prefix),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixPressed!(),
                icon: Icon(suffix),
              )
            : null,

        // suffixIcon: suffix != null
        //     ? IconButton(
        //         onPressed: suffixPressed!(),
        //         icon: Icon(suffix),
        //       )
        //     : null,
        border: const OutlineInputBorder(),
      ));
}

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deletDatabase(id: model['id']);
      },
      child: Container(
        color: Colors.white70,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,

                child: Text('${model['time']}'),

                // child: Text('${model['time']}'),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${model['title']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${model['data']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () {
                  AppCubit.get(context).updataDatabase(
                    status: 'done',
                    id: model['id'],
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                color: Colors.green,
              ),
              IconButton(
                onPressed: () {
                  AppCubit.get(context).updataDatabase(
                    status: 'archive',
                    id: model['id'],
                  );
                },
                icon: const Icon(Icons.archive_outlined),
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
Widget tasksBuilder({
  required List<Map> tasks,
}) =>
    ConditionalBuilder(
      // ignore: prefer_is_empty
      condition: tasks.length > 0,
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.menu,
              size: 100,
              color: Colors.grey,
            ),
            Text(
              'No Tasks Yet , Please Add Some Tasks',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ],
        ),
      ),
      builder: (context) => ListView.separated(
          itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
          separatorBuilder: (context, index) => myDivider(),
          itemCount: tasks.length),
    );
Widget myDivider() => Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: double.infinity,
        height: 1,
        color: Colors.grey[200],
      ),
    );
void navigateTO(context, widget) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
