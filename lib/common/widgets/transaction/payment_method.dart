import 'package:flutter/material.dart';
import '../../../data/models/payments/payment_methods_model.dart';
import '../../../config/theme/colors/app_colors.dart';

Widget buildContactCard(PaymentMethods method) {
  return Padding(
   padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: ElevatedButton(
      onPressed: () {
        //  action here
      },
      
      style: ElevatedButton.styleFrom(
        elevation: 0.0,
        backgroundColor: AppColors.softGrey, // Button background color
        fixedSize: const Size(400, 65), // Button size (width, height)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Button corner radius
        ),
        
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softGrey,
              image: method.assetImage != null
                  ? DecorationImage(
                      image: AssetImage(method.assetImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: Border.all(
                color: AppColors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: method.icon != null
                ? Icon(
                    method.icon,
                    color: Colors.black,
                    size: 24,
                  )
                : null,
          ),
          const SizedBox(width: 18),
          Text(
            method.name,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
  
}
