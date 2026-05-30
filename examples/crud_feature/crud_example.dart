// Esempio completo di una CRUD feature con Riverpod
// Include: Gestione lista, creazione elemento, eliminazione con undo

// Questo file serve solo come riferimento visivo. Per lo sviluppo reale,
// usa i template in templates/feature/ e mantieni i file separati
// (page.dart, provider.dart, repository.dart, model.dart).

/*
// 1. Il Provider (AsyncNotifier)
@riverpod
class Items extends _$Items {
  @override
  FutureOr<List<ItemModel>> build() async {
    return ref.watch(itemsRepositoryProvider).fetchAll();
  }

  Future<void> create(String title) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemsRepositoryProvider);
      final newItem = await repo.create({'title': title});
      return [...?state.valueOrNull, newItem];
    });
  }

  Future<void> delete(String id) async {
    final currentList = state.valueOrNull ?? [];
    
    // Aggiornamento ottimistico
    state = AsyncData(currentList.where((item) => item.id != id).toList());

    try {
      await ref.read(itemsRepositoryProvider).delete(id);
    } catch (e) {
      // Rollback in caso di errore
      state = AsyncData(currentList);
      rethrow;
    }
  }
}

// 2. La Page (UI)
class ItemsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(itemsProvider);
    
    return Scaffold(
      body: state.when(
        data: (items) => ListView.builder(...),
        loading: () => const SkeletonList(),
        error: (e, _) => ErrorWidget(e),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(itemsProvider.notifier).create('Nuovo'),
      ),
    );
  }
}
*/
