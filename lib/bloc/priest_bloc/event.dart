// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class PriestEvent {}

class FetchTransactionsEvent extends PriestEvent {
  BuildContext ctx;
  FetchTransactionsEvent({
    required this.ctx,
  });
}
