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
                    fontSize: 18,
                  ),
                ),
                Text(
                  '5th Ave. New York, NY',
                  style: TextStyle(
                    fontSize: 13,
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
                child: const Center(
                    child: Text(
                  'Select',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                )),
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

class DateItemButton extends StatelessWidget {
  const DateItemButton({
    super.key,
    required this.selected,
    required this.title,
    required this.date,
  });

  final bool selected;
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black54, fontSize: 17),
          ),
          Text(
            date,
            style: TextStyle(color: selected ? Colors.white60 : Colors.black54),
          ),
        ],
      ),
    );
  }
}

class MassTimeButton extends StatelessWidget {
  const MassTimeButton({
    super.key,
    required this.time,
    required this.mass,
  });

  final String time;
  final String mass;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(FontAwesomeIcons.clock),
            const Gap(5),
            Text(
              time,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            Text(
              mass,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
