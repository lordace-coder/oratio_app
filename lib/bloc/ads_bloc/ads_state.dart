import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// State
class AdsState extends Equatable {
  final List<Ad> ads;
  final String? error;
  final bool isLoading;

  const AdsState({
    this.ads = const [],
    this.error,
    this.isLoading = false,
  });

  AdsState copyWith({
    List<Ad>? ads,
    String? error,
    bool? isLoading,
  }) {
    return AdsState(
      ads: ads ?? this.ads,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [ads, error, isLoading];
}

// Model
class Ad extends Equatable {
  final String id;
  final String location;
  final int? clicks;
  final int? views;
  final String? image;
  final String title;
  final String description;
  final String? callToAction;
  final DateTime created;
  final DateTime updated;

  const Ad({
    required this.id,
    required this.location,
    this.clicks,
    this.views,
    this.image,
    required this.title,
    required this.description,
    this.callToAction,
    required this.created,
    required this.updated,
  });


  @override
  List<Object?> get props => [
        id,
        location,
        clicks,
        views,
        image,
        title,
        description,
        callToAction,
        created,
        updated
      ];
}