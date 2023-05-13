import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:go_sell_sdk_flutter/go_sell_sdk_flutter.dart';
import 'package:go_sell_sdk_flutter/model/models.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';

class TapPaymentHelper {
  TapPaymentHelper._();

  static final instance = TapPaymentHelper._();

  void initPayment() {
    GoSellSdkFlutter.configureApp(
        bundleId: "com.ebtasm.sevenemirates",
        productionSecreteKey: "",
        sandBoxsecretKey: "sk_live_lhRSMLy2k5KwsubQjco731BI",
        // sandBoxsecretKey: "sk_test_mSylL72AET9vaOi0KekFVfMt",
        lang: Const.AppLanguage == 1 ? 'ar' : 'en');
  }

  // Map<dynamic, dynamic>? tapSDKResult;

  Future<void> setupSDKSession({
    required double amount,
    required AppSetting settings,
    required void Function(String) onSuccess,
    required void Function() onFailed,
  }) async {
    initPayment();

    try {
      GoSellSdkFlutter.sessionConfigurations(
        trxMode: TransactionMode.PURCHASE,
        transactionCurrency: "AED",
        amount: '$amount',
        customer: Customer(
          customerId: "",
          // customer id is important to retrieve cards saved for this customer
          email: "${settings.email}",
          isdNumber: "971",
          number: "${settings.phone}",
          firstName: "${settings.name}",
          middleName: "",
          lastName: "",
          metaData: null,
        ),
        paymentItems: <PaymentItem>[
          // PaymentItem(
          //     name: "item1",
          //     amountPerUnit: 1,
          //     quantity: Quantity(value: 1),
          //     discount: {
          //       "type": "F",
          //       "value": 10,
          //       "maximum_fee": 10,
          //       "minimum_fee": 1
          //     },
          //     description: "Item 1 Apple",
          //     taxes: [
          //       Tax(
          //           amount: Amount(
          //               type: "F", value: 10, minimumFee: 1, maximumFee: 10),
          //           name: "tax1",
          //           description: "tax describtion")
          //     ],
          //     totalAmount: 100),
        ],
        // List of taxes
        taxes: [
          // Tax(
          //     amount:
          //         Amount(type: "F", value: 10, minimumFee: 1, maximumFee: 10),
          //     name: "tax1",
          //     description: "tax describtion"),
          // Tax(
          //     amount:
          //         Amount(type: "F", value: 10, minimumFee: 1, maximumFee: 10),
          //     name: "tax1",
          //     description: "tax describtion")
        ],
        // List of shippnig
        shippings: [
          // Shipping(
          //     name: "shipping 1",
          //     amount: 100,
          //     description: "shiping description 1"),
          // Shipping(
          //     name: "shipping 2",
          //     amount: 150,
          //     description: "shiping description 2")
        ],
        // Post URL
        postURL: "https://tap.company",
        // Payment description
        paymentDescription: "paymentDescription",
        // Payment Metadata
        paymentMetaData: {
          "a": "a meta",
          "b": "b meta",
        },
        // Payment Reference
        paymentReference: Reference(
          acquirer: "acquirer",
          gateway: "gateway",
          payment: "payment",
          track: "track",
          transaction: "trans_910101",
          order: "order_262625",
        ),
        // payment Descriptor
        paymentStatementDescriptor: "paymentStatementDescriptor",
        // Save Card Switch
        isUserAllowedToSaveCard: true,
        // Enable/Disable 3DSecure
        isRequires3DSecure: true,
        // Receipt SMS/Email
        receipt: Receipt(true, false),
        // Authorize Action [Capture - Void]
        authorizeAction:
            AuthorizeAction(type: AuthorizeActionType.CAPTURE, timeInHours: 10),
        // Destinations
        destinations: null,
        // merchant id
        merchantID: "",
        // merchantID: "2136043",
        // Allowed cards
        allowedCadTypes: CardType.ALL,
        allowsToSaveSameCardMoreThanOnce: false,
        applePayMerchantID: 'merchant.sevenemirates.ebtasm.com',
        // pass the card holder name to the SDK
        cardHolderName: "",
        // disable changing the card holder name by the user
        allowsToEditCardHolderName: true,
        // select payments you need to show [Default is all, and you can choose between WEB-CARD-APPLEPAY ]
        paymentType: PaymentType.ALL,
        // Transaction mode
        sdkMode: SDKMode.Sandbox,
      );
      Map<dynamic, dynamic>? tapSDKResult =
          await GoSellSdkFlutter.startPaymentSDK;
      if (tapSDKResult?['sdk_result'] == 'SUCCESS') {
        onSuccess(tapSDKResult?['charge_id'].toString() ?? '');
      } else {
        onFailed();
      }

      log('$tapSDKResult', name: 'result_payment');
    } on PlatformException {
      onFailed();
      // platformVersion = 'Failed to get platform version.';
    } catch (e) {
      onFailed();
    }

    // if (!mounted) return;

    // setState(() {
    //   tapSDKResult = {};
    // });
  }
}
