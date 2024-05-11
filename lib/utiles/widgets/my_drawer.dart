import 'package:electech/controller/firebase_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key, });

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    final theme=Theme.of(context).colorScheme;
    return Drawer(child: ListView(
      children: [
        Container(
          color: theme.secondary,
          height: size.height*0.3,
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SingleChildScrollView(
                child: CircleAvatar(
                
                  backgroundImage: AssetImage('assets/Images/person.jpg'),
                
                  radius: 50,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child:  Text(
                  FirebaseDataController.instance.user.value.name,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              Text(
                FirebaseDataController.instance.user.value.email,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),


            ],
          ),
        ),
        Padding(
          padding: const  EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            onTap: () {
              Get.back();
              FirebaseDataController.instance.setIndex=0;

            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child:  Icon(Icons.home_outlined,size: size.height*0.035,),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Text('Home',style: TextStyle(fontSize: size.height*0.025),),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            onTap: () {
              Get.back();
              FirebaseDataController.instance.setIndex=1;

            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child:  Icon(Icons.settings_outlined,size: size.height*0.035,),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Text('Setting',style: TextStyle(fontSize: size.height*0.025),),
                )
              ],
            ),
          ),
        )
      ],
    ),
    );
  }
}
