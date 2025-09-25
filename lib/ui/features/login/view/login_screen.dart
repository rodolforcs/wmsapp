import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/ui/widgets/responsive_center_layout.dart';
import 'package:wmsapp/ui/features/login/viewmodel/login_view_model.dart';
import 'package:wmsapp/ui/features/login/widgets/exit_button.dart';
import 'package:wmsapp/ui/features/login/widgets/login_button.dart';

class LoginWms extends StatefulWidget {
  const LoginWms({super.key});

  @override
  State<LoginWms> createState() => _LoginWmsState();
}

class _LoginWmsState extends State<LoginWms> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dominioController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late FocusNode _userFocusNode;

  @override
  void initState() {
    super.initState();

    _dominioController = TextEditingController(text: dotenv.env['DOMAIN']);
    _userController = TextEditingController();
    _passwordController = TextEditingController();
    _userFocusNode = FocusNode();
    _userFocusNode.addListener(_onUserFieldFocusChange);
  }

  @override
  void dispose() {
    _userFocusNode.removeListener(_onUserFieldFocusChange);
    _userFocusNode.dispose();

    _dominioController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onUserFieldFocusChange() {
    if (!_userFocusNode.hasFocus) {
      // Usa context.read para chamar o método na ViewModel
      // O "Listen: false" é implicito no contex.read, evitando reconstruções desnecessárias
      context.read<LoginViewModel>().validateUserOnLeave(_userController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    //Escutando o LoginViewModel
    final viewModelLogin = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo da Empresa
            Flexible(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(
                  minHeight: 80,
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: ResponsiveCenterLayout(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Utilizar Domínio',
                              style: TextStyle(fontSize: 18),
                            ),
                            Switch(
                              value: viewModelLogin.utilizarDominio,
                              activeColor: Colors.indigo,
                              onChanged: viewModelLogin.toggleDominio,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        if (viewModelLogin.utilizarDominio)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              controller: _dominioController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Domínio',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                            ),
                          ),
                        TextFormField(
                          controller: _userController,
                          focusNode: _userFocusNode,
                          readOnly: false,
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                            suffixIcon: _buildUserValidationIcon(
                              viewModelLogin,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          readOnly: false,
                          obscureText: viewModelLogin.isPasswordObscured,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.lock,
                            ),
                            suffixIcon: IconButton(
                              onPressed:
                                  viewModelLogin.togglePasswordVisibility,
                              icon: Icon(
                                viewModelLogin.isPasswordObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        if (viewModelLogin.userValidationState ==
                                UserValidationState.success &&
                            viewModelLogin.estabelecimentos.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: DropdownButtonFormField<String>(
                              value: viewModelLogin.selectedEstabelecimento,
                              decoration: const InputDecoration(
                                labelText: 'Estabelecimento',
                                border: OutlineInputBorder(),
                              ),
                              items: viewModelLogin.estabelecimentos
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? newValue) {
                                // Lógica para selecionar o estabelecimento no ViewModel
                                viewModelLogin.selectEstabelecimento(newValue);
                              },
                              /*
                              validator: (value) {
                                if (viewModelLogin
                                        .selectedEstabelecimento
                                        .isNotEmpty &&
                                    value == null) {
                                  return 'Selecione um estabelecimento';
                                }
                                return null;
                                
                              },*/
                            ),
                          ),
                        const SizedBox(height: 8),
                        LoginButton(
                          isLoading: viewModelLogin.isLoggingIn,
                          onPressed: () {
                            // Validação do formulário (opcional, mas bom ter)
                            if (_formKey.currentState?.validate() ?? false) {
                              // Chama o método da ViewModel passando os dados dos controllers.
                              viewModelLogin.performLogin(
                                context: context,
                                domain: _dominioController.text,
                                username: _userController.text,
                                password: _passwordController.text,
                              );
                            }
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ExitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================================
  // == COLOQUE O MÉTODO HELPER AQUI, DENTRO DA CLASSE _LoginWmsState ==
  // =======================================================================
  Widget? _buildUserValidationIcon(LoginViewModel viewModel) {
    switch (viewModel.userValidationState) {
      case UserValidationState.loading:
        return const Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );
      case UserValidationState.error:
        return Tooltip(
          message: viewModel.validationErrorMessage,
          child: const Icon(Icons.error, color: Colors.red),
        );
      case UserValidationState.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case UserValidationState.idle:
        return null;
    }
  }

  // Fim do método helper
  // =======================================================================
}
