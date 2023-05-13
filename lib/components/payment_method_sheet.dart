import 'package:flutter/material.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

import '../utils/app_settings.dart';

class PaymentMethodsSheet extends StatelessWidget {
  const PaymentMethodsSheet({
    Key? key,
    required this.paymentMethods,
    required this.onConfirm,
  }) : super(key: key);

  final List<PaymentMethods> paymentMethods;
  final void Function(int) onConfirm;

  @override
  Widget build(BuildContext context) {
    var paymentMethodId = -1;
    var isInit = true;
    void onRadioChanged(
      int? value, {
      required void Function(void Function()) setState,
    }) {
      if (value == null) {
        return;
      }
      setState(
        () {
          paymentMethodId = value;
        },
      );
    }

    return StatefulBuilder(builder: (context, setState) {
      // if
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(Lang('Choose Payment Method', 'اختر طريقة الدفع')),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                var method = paymentMethods[index];

                return InkWell(
                  onTap: () => onRadioChanged(
                    method.paymentMethodId,
                    setState: setState,
                  ),
                  child: Row(children: [
                    Radio<int?>(
                      fillColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                      value: method.paymentMethodId,
                      groupValue: paymentMethodId,
                      onChanged: (v) => onRadioChanged(
                        v,
                        setState: setState,
                      ),
                    ),
                    Image.network(
                      method.imageUrl ?? '',
                      height: 50,
                      width: 50,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Text(
                        Lang(
                          method.paymentMethodEn ?? '',
                          method.paymentMethodAr ?? '',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
          Visibility(
            visible: paymentMethodId > 0,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              width: 200,
              height: 35,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm(paymentMethodId);
                },
                child: Text(
                  Lang(
                    'Confirm',
                    'تأكيد',
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
