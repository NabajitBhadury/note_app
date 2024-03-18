// here a extension is used to filter out the list of items from the stream based on the type defined in the stream.

extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
