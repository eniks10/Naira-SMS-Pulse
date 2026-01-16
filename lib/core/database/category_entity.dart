import 'package:isar/isar.dart';
part 'category_entity.g.dart';

@Collection()
class CategoryEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name; // e.g. "Food & Groceries" or "Books"

  late String iconData; // The JSON string for the icon
}
