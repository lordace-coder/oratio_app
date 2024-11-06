import 'package:flutter/material.dart';

class CustomBannerAd extends StatelessWidget {
  const CustomBannerAd(
      {super.key,
      required this.buttonColor,
      required this.onTap,
      required this.label});
  final Color buttonColor;
  final VoidCallback onTap;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.red,
          image: DecorationImage(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3), // Adjust opacity here
                BlendMode.darken, // Choose how to blend the color
              ),
              fit: BoxFit.cover,
              image: Image.asset(
                'assets/images/wallet_bg.jpeg',
                fit: BoxFit.cover,
              ).image)),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: buttonColor)),
              child: Text(
                label,
                style: TextStyle(color: buttonColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}

