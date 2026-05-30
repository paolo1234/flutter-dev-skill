# Database Reference — Drift (SQLite)

## Setup

```yaml
dependencies:
  drift: ^2.22.1
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  path: ^1.9.1

dev_dependencies:
  drift_dev: ^2.22.1
  build_runner: ^2.4.13
```

## Table Definition

```dart
import 'package:drift/drift.dart';

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  // Foreign key
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get color => text().withDefault(const Constant('#2196F3'))();
}
```

## Database Class

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DriftDatabase(tables: [Items, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(items, items.updatedAt);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

## DAO Pattern

```dart
part 'items_dao.g.dart';

@DriftAccessor(tables: [Items, Categories])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  Future<List<Item>> getAllItems() => select(items).get();

  Stream<List<Item>> watchAllItems() => select(items).watch();

  Future<List<Item>> getItemsByCategory(int categoryId) {
    return (select(items)..where((t) => t.categoryId.equals(categoryId))).get();
  }

  Future<Item?> getItemById(int id) {
    return (select(items)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertItem(ItemsCompanion entry) {
    return into(items).insert(entry);
  }

  Future<bool> updateItem(ItemsCompanion entry) {
    return update(items).replace(entry);
  }

  Future<int> deleteItem(int id) {
    return (delete(items)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Item>> searchItems(String query) {
    return (select(items)..where((t) => t.title.like('%$query%'))).get();
  }

  // Join query
  Future<List<ItemWithCategory>> getItemsWithCategories() {
    final query = select(items).join([
      leftOuterJoin(categories, categories.id.equalsExp(items.categoryId)),
    ]);
    return query.map((row) {
      return ItemWithCategory(
        item: row.readTable(items),
        category: row.readTableOrNull(categories),
      );
    }).get();
  }
}
```

## Testing with In-Memory Database

```dart
void main() {
  late AppDatabase db;
  late ItemsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = ItemsDao(db);
  });

  tearDown(() => db.close());

  test('insert and retrieve item', () async {
    await dao.insertItem(ItemsCompanion.insert(title: 'Test Item'));
    final items = await dao.getAllItems();
    expect(items, hasLength(1));
    expect(items.first.title, 'Test Item');
  });

  test('delete removes item', () async {
    final id = await dao.insertItem(ItemsCompanion.insert(title: 'To Delete'));
    await dao.deleteItem(id);
    final items = await dao.getAllItems();
    expect(items, isEmpty);
  });
}
```

## Best Practices

1. **Use DAOs** to organize queries by domain
2. **Companion objects** for inserts (type-safe, handles defaults)
3. **`getSingleOrNull`** for queries that might return nothing
4. **Transactions** for multiple related operations
5. **Stream queries** (`watch()`) for reactive UI updates
6. **Index columns** used in WHERE clauses frequently
7. **Migration strategy** — always backward-compatible
8. **In-memory database** for tests (fast, isolated)
