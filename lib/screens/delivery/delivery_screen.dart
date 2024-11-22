import 'package:flutter/material.dart';
import 'package:maria_store/models/delivery/delivery_manager.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:provider/provider.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKeyDelivery = GlobalKey<FormState>();
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Entrega',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<DeliveryManager>(
        builder: (_, deliveryManager, __) {
          return ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: Form(
                        key: formKeyDelivery,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    enabled: !deliveryManager.loading,
                                    initialValue: deliveryManager.base?.toStringAsFixed(2),
                                    decoration: const InputDecoration(labelText: 'Valor Base'),
                                    keyboardType: TextInputType.number,
                                    validator: (base) {
                                      if (base == null || base.isEmpty) {
                                        return 'Campo obrigatorio...';
                                      }
                                      return null;
                                    },
                                    onSaved: (base) => deliveryManager.base = num.tryParse(base!) ?? 0.0,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    enabled: !deliveryManager.loading,
                                    initialValue: deliveryManager.km?.toStringAsFixed(2),
                                    decoration: const InputDecoration(labelText: 'Valor do KM'),
                                    keyboardType: TextInputType.number,
                                    validator: (km) {
                                      if (km == null || km.isEmpty) {
                                        return 'Campo obrigatorio...';
                                      }
                                      return null;
                                    },
                                    onSaved: (km) => deliveryManager.km = num.tryParse(km!) ?? 0.0,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                            TextFormField(
                              enabled: !deliveryManager.loading,
                              initialValue: deliveryManager.maxkm?.toString(),
                              decoration: const InputDecoration(labelText: 'Raio de entrega (KM)'),
                              keyboardType: TextInputType.number,
                              validator: (maxkm) {
                                if (maxkm == null || maxkm.isEmpty) {
                                  return 'Campo obrigatorio...';
                                }
                                return null;
                              },
                              onSaved: (maxkm) => deliveryManager.maxkm = int.tryParse(maxkm!) ?? 0,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    enabled: !deliveryManager.loading,
                                    initialValue: deliveryManager.lat?.toString(),
                                    decoration: const InputDecoration(labelText: 'Latitude'),
                                    keyboardType: TextInputType.number,
                                    validator: (lat) {
                                      if (lat == null || lat.isEmpty) {
                                        return 'Campo obrigatorio...';
                                      }
                                      return null;
                                    },
                                    onSaved: (lat) => deliveryManager.lat = num.tryParse(lat!) ?? 0.0,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    enabled: !deliveryManager.loading,
                                    initialValue: deliveryManager.long?.toString(),
                                    decoration: const InputDecoration(labelText: 'Longitude'),
                                    keyboardType: TextInputType.number,
                                    validator: (long) {
                                      if (long == null || long.isEmpty) {
                                        return 'Campo obrigatorio...';
                                      }
                                      return null;
                                    },
                                    onSaved: (long) => deliveryManager.long = num.tryParse(long!) ?? 0.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
                              ),
                              onPressed: !deliveryManager.loading
                                  ? () async {
                                      if (formKeyDelivery.currentState!.validate()) {
                                        formKeyDelivery.currentState!.save();

                                        await deliveryManager.save();

                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil('/base', (Route<dynamic> route) => false);
                                      }
                                    }
                                  : null,
                              child: deliveryManager.loading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    )
                                  : const Text('Salvar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
