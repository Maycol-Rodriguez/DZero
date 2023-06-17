import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dzero/config/config.dart';
import 'package:dzero/models/models.dart';
import 'package:dzero/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class GenerarReporteScreen extends ConsumerStatefulWidget {
  static const String name = 'generar-reporte';
  const GenerarReporteScreen({Key? key}) : super(key: key);

  @override
  GenerarReporteScreenState createState() => GenerarReporteScreenState();
}

class GenerarReporteScreenState extends ConsumerState<GenerarReporteScreen> {
  File? _image;
  String? path;

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      path = image.path;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _image = img;
        context.pop();
      });
    } on PlatformException {
      Navigator.of(context).pop();
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.28,
        maxChildSize: 0.4,
        minChildSize: 0.28,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: SelectPhotoOptionsScreen(
              onTap: _pickImage,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formReporte = ref.watch(formularioReporteProvider);
    Future<void> enviarDatos() async {
      const uuid = Uuid();
      Reporte reporte;

      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            path!,
            resourceType: CloudinaryResourceType.Image,
          ),
        );

        reporte = Reporte(
          id: '',
          picture: response.secureUrl,
          description: 'descripcion',
          location: '-12.04807041556919, -75.18945304764888',
          user: User(
            id: uuid.v1(),
            email: 'email@prueba.com',
            name: 'usuario de prueba',
          ),
        );

        ref.watch(subirReportesProvider(reporte));
      } on CloudinaryException catch (e) {
        throw Text(e.message ?? '');
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        _showSelectPhotoOptions(context);
                      },
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          height: 450,
                          width: double.infinity,
                          decoration: CustomDecoration.decoration(false, true, false, false, true),
                          child: Opacity(
                            opacity: .75,
                            child: ClipRRect(
                              borderRadius: CustomBorder.radiusTop,
                              child: _image == null
                                  ? const Image(
                                      image: AssetImage('assets/images/no-image.png'),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: 20,
                    child: IconButton(
                      onPressed: () => context.pushReplacementNamed(VHomeScreen.name),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const _FormularioReporte(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorTerceary,
        heroTag: 1,
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text('Publicar reporte', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          if (!formReporte.esValido()) return;
          formReporte.esValido();
          await enviarDatos();
          Future.delayed(
            const Duration(milliseconds: 300),
            () => context.pushReplacementNamed(VHomeScreen.name),
          );
          Future.delayed(
            const Duration(milliseconds: 500),
            () => ref.refresh(obtenerReportesProvider),
          );
        },
      ),
    );
  }
}

class _FormularioReporte extends ConsumerWidget {
  const _FormularioReporte();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = Theme.of(context).textTheme.titleSmall;
    String usuario;
    String descripcion;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: CustomDecoration.decoration(false),
        child: Form(
          key: ref.watch(formularioReporteProvider).formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                onChanged: (value) => usuario = value,
                keyboardType: TextInputType.text,
                decoration: InputDecorations.authInputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Nombre del usuario',
                  prefixIcon: Icons.person,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('^[a-zA-Z.,]+')),
                ],
                validator: (value) {
                  if (value!.isEmpty || value.length < 3) {
                    return 'La descripción es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              TextFormField(
                maxLines: 3,
                minLines: 1,
                keyboardType: TextInputType.text,
                onChanged: (value) => descripcion = value,
                decoration: InputDecorations.authInputDecoration(
                  labelText: 'Descripcion',
                  hintText: 'Descripcion del reporte ',
                  prefixIcon: Icons.description,
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 3) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
