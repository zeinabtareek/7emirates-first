import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:pay/pay.dart';
import 'package:sevenemirates/utils/app_settings.dart';

class ApplePayButtonWidget extends StatefulWidget {
  const ApplePayButtonWidget({
    Key? key,
    required this.amount,
    required this.onSuccess,
    required this.onFailed,
  });
  final String amount;
  final void Function() onSuccess, onFailed;
  @override
  State<ApplePayButtonWidget> createState() => _ApplePayButtonWidgetState();
}

class _ApplePayButtonWidgetState extends State<ApplePayButtonWidget> {
  final applePayJson = '''{
    "provider": "apple_pay",
    "data": {
      "merchantIdentifier": "merchant.sevenemirates.ebtasm.com",
      "displayName": "7 Emirate",
      "merchantCapabilities": ["3DS", "debit", "credit"],
      "supportedNetworks": ["amex", "visa", "discover", "masterCard"],
      "countryCode": "AE",
      "currencyCode": "AED",
      "requiredBillingContactFields": null,
      "requiredShippingContactFields": null
    }
  }''';

  // late List<PaymentItem> _paymentItems;

  @override
  void initState() {
    // log('initialize apple button', name: 'apple_pay_button');
    // _paymentItems = [
    //   PaymentItem(
    //     label: Lang('Total', 'الإجمالي'),
    //     amount: widget.amount,
    //     status: PaymentItemStatus.final_price,
    //   )
    // ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();

    /*Visibility(
      visible: Platform.isIOS,
      child: Padding(
        padding: EdgeInsets.zero,
        child: ApplePayButton(
          // paymentConfiguration:
              // PaymentConfiguration.fromJsonString(applePayJson),
          paymentConfigurationAsset: 'applepay.json',
          paymentItems: _paymentItems,
          style: ApplePayButtonStyle.black,
          type: ApplePayButtonType.buy,
          width: double.infinity,
          height: 35,
          // margin: const EdgeInsets.only(top: 15.0),
          onPaymentResult: (value) {
            widget.onSuccess();
            log('$value', name: 'result_success');
            log('afterinvoke');
          },
          onError: (error) {
            log('$error', name: 'result_error');
            widget.onFailed();
          },
          loadingIndicator: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
 */
  }
}
