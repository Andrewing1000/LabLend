import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/models/Session.dart';
import 'package:palette_generator/palette_generator.dart';

class ItemInfoWidget extends StatefulWidget {
  final Item item;

  const ItemInfoWidget({Key? key, required this.item}) : super(key: key);

  @override
  _ItemInfoWidgetState createState() => _ItemInfoWidgetState();
}

class _ItemInfoWidgetState extends State<ItemInfoWidget> {
  int cartItemCount = 0;
  List<Item> cartItems = [];
  Color dominantColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _updatePalette();
  }

  Future<void> _updatePalette() async {
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      NetworkImage("/assets/images/place_holder.png"),
    );
    setState(() {
      dominantColor = generator.dominantColor?.color ?? Colors.black;
    });
  }

  void _addToCart() {
    setState(() {
      cartItemCount++;
      cartItems.add(widget.item);
    });
  }

  void _showCartItems() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
          ),
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Card(
                color: Colors.grey[900],
                child: ListTile(
                  leading: Image.network("/assets/images/place_holder.png"),
                  title:
                      Text(item.nombre, style: TextStyle(color: Colors.white)),
                  subtitle: Text(item.description ?? 'Sin descripción',
                      style: TextStyle(color: Colors.white70)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen y título del ítem como banner
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [dominantColor, dominantColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Opacity(
                  opacity: 0.3,
                  child: Image.network(
                    "/assets/images/place_holder.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.nombre,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Recuadro gris detrás de la información del ítem
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información adicional del ítem con subtítulos en bold
                _buildInfoRow('Marca', widget.item.marca.marca),
                _buildInfoRow('Cantidad', widget.item.quantity.toString()),
                _buildInfoRow('Número de serie',
                    widget.item.serialNumber ?? 'No disponible'),
                _buildInfoRow('Categorías',
                    widget.item.categories.map((c) => c.nombre).join(', ')),
                SizedBox(height: 20),
                // Botón para agregar a la lista de compras
                ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    //primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text('Prestar',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          // Ícono del carrito de compras
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _showCartItems,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white, size: 30),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$cartItemCount',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
