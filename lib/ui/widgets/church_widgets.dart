import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/ui/themes.dart';


class ChurchListTile extends StatelessWidget {
  const ChurchListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.black45),
          ),
          const Gap(15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'St. Patrick ',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Text(
                  '5th Ave. New York, NY',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textDarkDim,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.gray),
                child: const Center(child: Text('Select')),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: AppColors.dimGray, borderRadius: BorderRadius.circular(5)),
      child: TextField(
        keyboardType: TextInputType.name,
        style: TextStyle(
          color: AppColors.gray,
        ),
        controller: controller,
        decoration: const InputDecoration(
            hintStyle:
                TextStyle(color: Colors.black45, fontWeight: FontWeight.normal),
            border: InputBorder.none,
            hintText: 'Search for a church or Mass center',
            prefixIcon: Icon(
              FontAwesomeIcons.magnifyingGlass,
              color: Colors.black45,
              size: 17,
            )),
      ),
    );
  }
}
