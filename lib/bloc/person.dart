import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

@JsonSerializable()
class Person {
  final id;
  final name;
  final age;

  Person(this.id, this.name, this.age);

  factory Person.fromJson(String id, Map<String, dynamic> json) => _$PersonFromJson(json)..id;
  factory Person.fromFire(DocumentSnapshot doc) => Person.fromJson(doc.id, doc.data() as Map<String, dynamic>);

  Map<String, dynamic> toJson() => _$PersonToJson(this);

}