// import 'package:dzero/config/config.dart';
import 'package:dzero/config/config.dart';
import 'package:dzero/models/models.dart';
import 'package:dzero/screens/screens.dart';
import 'package:dzero/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class VLoginScreen extends StatelessWidget {
  static const String name = 'login_screen';

  const VLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                SizedBox(height: 100),
                SizedBox(
                  width: double.infinity,
                  child: LoginForm(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends ConsumerState<LoginForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    String email = '';
    String password = '';
    final loader = ref.watch(loadingProvider);
    final formReporte = ref.watch(formularioReporteProvider);

    return Form(
      // key: ref.read(formularioReporteProvider).formKey,
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text('Iniciar Sesión', style: textStyles.titleLarge),
          const SizedBox(height: 90),
          CustomTextFormField(
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value,
            validator: (value) {
              if (value!.isEmpty) {
                return 'El campo no puede estar vacío';
              }
              if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value) == false) {
                return 'El correo no es válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          CustomTextFormField(
            label: 'Contraseña',
            validator: (value) {
              if (value!.isEmpty) {
                return 'El campo no puede estar vacío';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
            obscureText: true,
            onChanged: (value) => password = value,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
              text: 'Ingresar',
              buttonColor: colorTerceary,
              onPressed: () {
                if (!formReporte.esValido()) return;
                formReporte.esValido();
              },
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
              icon: FontAwesomeIcons.google,
              text: 'Iniciar Sesion con Google',
              buttonColor: colorSecondary,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Aun no tienes cuenta en DZero?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),
              ),
              TextButton(
                onPressed: () => context.pushNamed(VRegistroScreen.name),
                child: const Text(
                  'Registrese',
                  style: TextStyle(color: colorTerceary, fontSize: 14),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
