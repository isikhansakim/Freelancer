import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreelancerApp'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Freelance',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Find your job',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Giriş Yap'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  RegisterFormState createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  //final TextEditingController _ageController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();

  String? _educationLevel;
  String? _graduatedSchool;
  String? _graduatedDepartment;
  String? _selectedCity;

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Doğum tarihi doğrulaması
      final int? day = int.tryParse(_dayController.text);
      final int? month = int.tryParse(_monthController.text);
      final int? year = int.tryParse(_yearController.text);
      if (day == null ||
          month == null ||
          year == null ||
          day < 1 ||
          day > 31 ||
          month < 1 ||
          month > 12 ||
          year < 1950) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen geçerli bir doğum tarihi giriniz.'),
        ));
        return;
      }
      try {
        // Kullanıcıyı Firebase Authentication'a kaydetme
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);

        // Kullanıcı bilgilerinin Firestore'a kaydedilmesi
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'year': int.parse(_yearController.text),
          'occupation': _occupationController.text,
          'educationLevel': _educationLevel,
          'graduatedSchool': _graduatedSchool,
          'graduatedDepartment': _graduatedDepartment,
        });

        // Kayıt başarılı, pop-up gösterme ve ana sayfaya yönlendirme
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Kayıt Başarılı'),
              content: const Text(
                  'Kayıt işleminiz başarılı bir şekilde tamamlandı.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: const Text('Tamam'),
                ),
              ],
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        // Hata mesajı gösterme
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: ${e.message}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'İsim Soyisim'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan boş bırakılamaz';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Mail Adresi'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan boş bırakılamaz';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Şifre'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan boş bırakılamaz';
              }
              return null;
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dayController,
                  decoration: const InputDecoration(labelText: 'Gün'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _monthController,
                  decoration: const InputDecoration(labelText: 'Ay'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Yıl'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _occupationController,
            decoration: const InputDecoration(labelText: 'Meslek'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan boş bırakılamaz';
              }
              return null;
            },
          ),
          DropdownSearch<String>(
            items: const ["Ortaokul", "Lise", "Lisans"],
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: "Öğrenim Durumu",
              ),
            ),
            onChanged: (value) {
              setState(() {
                _educationLevel = value;
              });
            },
            selectedItem: _educationLevel,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan boş bırakılamaz';
              }
              return null;
            },
          ),
          if (_educationLevel == "Lise" || _educationLevel == "Lisans")
            DropdownSearch<String>(
              items: _educationLevel == "Lise"
                  ? const [
                      "Lise1",
                      "Lise2",
                      "Lise3"
                    ] // Türkiye'deki liselerin listesi
                  : const [
                      "Üniversite1",
                      "Üniversite2",
                      "Üniversite3"
                    ], // Türkiye'deki üniversitelerin listesi
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Mezun Olunan Okul",
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _graduatedSchool = value;
                });
              },
              selectedItem: _graduatedSchool,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bu alan boş bırakılamaz';
                }
                return null;
              },
            ),
          if (_educationLevel == "Lisans")
            DropdownSearch<String>(
              items: const [
                "Bölüm1",
                "Bölüm2",
                "Bölüm3"
              ], // Türkiye'deki üniversite bölümleri
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Mezun Olunan Bölüm",
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _graduatedDepartment = value;
                });
              },
              selectedItem: _graduatedDepartment,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bu alan boş bırakılamaz';
                }
                return null;
              },
            ),
          DropdownSearch<String>(
            items: const [
              'İstanbul',
              'Ankara',
              'İzmir',
              'Bursa',
              'Antalya',
              // Diğer şehirleri buraya ekleyebilirsiniz
            ],
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: "Yaşadığınız şehir",
              ),
            ),
            onChanged: (value) {
              setState(() {
                _graduatedDepartment = value;
              });
            },
            selectedItem: _selectedCity,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan boş bırakılamaz';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _register,
            child: const Text('Kaydol'),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Kullanıcıyı Firebase Authentication ile doğrulama
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Giriş başarılı, bir sonraki sayfaya yönlendirme
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const NextPage()),
        );
      } on FirebaseAuthException catch (e) {
        // Hata mesajı gösterme
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: ${e.message}')));
      }
    }
  }

  // Yeni metod: Şifremi Unuttum butonuna basıldığında yapılacak işlem
  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Mail Adresi'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan boş bırakılamaz';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Şifre'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan boş bırakılamaz';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _login,
            child: const Text('Giriş Yap'),
          ),
          // Şifremi Unuttum butonu
          TextButton(
            onPressed: _forgotPassword,
            child: const Text('Şifremi Unuttum'),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifremi Unuttum'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ForgotPasswordForm(),
      ),
    );
  }
}

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  ForgotPasswordFormState createState() => ForgotPasswordFormState();
}

class ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final TextEditingController _emailController = TextEditingController();

  void _sendPasswordResetEmail() {
    if (_emailController.text.isNotEmpty) {
      FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Şifre sıfırlama bağlantısı e-postanıza gönderildi. Lütfen e-postanızı kontrol edin.')));
        Navigator.of(context).pop(); // Ana sayfaya geri dön
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Şifre sıfırlama bağlantısı gönderilirken bir hata oluştu.')));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir e-posta adresi girin.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'E-posta Adresi'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'E-posta adresi boş bırakılamaz';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: _sendPasswordResetEmail,
            child: const Text('Şifremi Sıfırla'),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profil Sayfası',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İlan Filtrele'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                items: ['İzmir', 'İstanbul', 'Ankara'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'İl'),
                onChanged: (String? value) {},
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                items: [
                  'Bilgisayar Mühendisliği',
                  'Makine Mühendisliği',
                  'Elektrik-Elektronik Mühendisliği'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Bölüm'),
                onChanged: (String? value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () {
                // Seçilen filtrelere göre işlemler yapabilirsiniz
                Navigator.of(context).pop();
              },
              child: const Text('Uygula'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İş İlanları'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('job_postings').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz ilan yok.'));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Veriler alınamadı.'));
          }
          return ListView(
            shrinkWrap: true,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(
                  data['advert_title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  data['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.home),
            label: 'Ana Ekran',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.add),
            label: 'İlan Ekle',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.filter_list),
            label: 'İlan Filtrele',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.list),
            label: 'İlanlarım',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NextPage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddJobPage()),
              );
              break;
            case 2:
              _showFilterDialog(context);
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyJobsPage()),
              );
              break;
          }
        },
      ),
    );
  }
}

class AddJobPage extends StatefulWidget {
  const AddJobPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddJobPageState createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  String? _advertTitle;
  String? _description;
  String? _selectedCity;
  bool _isOnline = false;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imagesRef = storageRef
          .child('job_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = imagesRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveJobPostingToDatabase() async {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      _formKey.currentState!.save();

      String? downloadUrl = await _uploadImageToFirebase(_selectedImage!);

      if (downloadUrl != null) {
        await FirebaseFirestore.instance.collection('job_postings').add({
          'advert_title': _advertTitle,
          'description': _description,
          'city': _isOnline ? 'Online' : _selectedCity,
          'image_url': downloadUrl,
          'created_at': Timestamp.now(),
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlan başarıyla eklendi')),
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resim yüklenirken bir hata oluştu')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Lütfen tüm alanları doldurun ve bir fotoğraf seçin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Online Çalışma: '),
                    Checkbox(
                      value: _isOnline,
                      onChanged: (bool? value) {
                        setState(() {
                          _isOnline = value!;
                          if (_isOnline) {
                            _selectedCity = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!_isOnline)
                  DropdownButtonFormField<String>(
                    items: ['İzmir', 'İstanbul', 'Ankara'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'İl'),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    validator: (value) {
                      if (value == null && !_isOnline) {
                        return 'Lütfen bir il seçin';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'İlan Başlığı'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen ilan başlığı girin';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _advertTitle = value;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  maxLines: 4,
                  decoration:
                      const InputDecoration(labelText: 'İlan Açıklaması'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen ilan açıklaması girin';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Fotoğraf Seç'),
                ),
                const SizedBox(height: 20),
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 150,
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveJobPostingToDatabase,
                  child: const Text('İlanı Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyJobsPage extends StatelessWidget {
  const MyJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlanlarım'),
      ),
      body: const Center(
        child: Text('İlanlarım ekranı burada olacak.'),
      ),
    );
  }
}
