import 'transformer_interface.dart';

class TransformerRegistry {
  static final TransformerRegistry _instance = TransformerRegistry._internal();

  final List<Transformer> _transformers = [];

  factory TransformerRegistry() {
    return _instance;
  }

  TransformerRegistry._internal();

  void registerTransformer(Transformer transformer) {
    _transformers.add(transformer);
  }

  List<Transformer> get transformers => List.unmodifiable(_transformers);
}
