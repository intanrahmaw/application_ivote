import 'package:application_ivote/screens/home/kandidat_form_screen.dart';
import 'package:application_ivote/screens/home/kandidat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:application_ivote/utilis/constants.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi GetStorage
  await GetStorage.init();

  // Inisialisasi Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
  
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return (GetMaterialApp(
      title: 'iVote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: KandidatListScreen(),
    ));
  }
}
