import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:provider/provider.dart';

class PhoneField extends StatelessWidget {
  const PhoneField({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManager>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Telefone:',
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            TextFormField(
              initialValue: userManager.userApp?.phone,
              decoration: const InputDecoration(hintText: '(99) 99123-4567', isDense: true),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TelefoneInputFormatter(),
              ],
              validator: (phone) {
                if (phone!.isEmpty) {
                  return 'Campo Obrigatório';
                } else if (phone.length != 15) {
                  return 'Telefone Inválido';
                }
                return null;
              },
              onSaved: userManager.userApp?.setPhone,
            ),
          ],
        ),
      ),
    );
  }
}
