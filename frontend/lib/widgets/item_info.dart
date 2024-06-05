import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/Loan.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:frontend/screens/edit_item_screen.dart';

import '../models/User.dart'; // Asegúrate de importar la pantalla de edición

class ItemInfoWidget extends StatefulWidget {
  final Item item;

  const ItemInfoWidget({Key? key, required this.item}) : super(key: key);

  @override
  _ItemInfoWidgetState createState() => _ItemInfoWidgetState();
}

class _ItemInfoWidgetState extends State<ItemInfoWidget> {
  int cartItemCount = 0;
  List<PrestamoItem> cartItems = [];
  Color dominantColor = Colors.black;
  final sessionManager = SessionManager(); // Instancia de SessionManager

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
      cartItems.add(PrestamoItem(itemId: widget.item.id, cantidad: 1));
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      cartItemCount--;
      cartItems.removeAt(index);
    });
  }

  void _showCartItems() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.black,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    return Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        leading:
                            Image.network("/assets/images/place_holder.png"),
                        title: Text(widget.item.nombre,
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                            widget.item.description ?? 'Sin descripción',
                            style: TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeFromCart(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _createLoan,
                  style: ElevatedButton.styleFrom(
                    //primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text('Confirmar Préstamo',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createLoan() async {
    var session = sessionManager.session; // Acceso correcto a la sesión
    var user = session.user.email;

    Loan loan = Loan(
      id: 1,
      usuario: user,
      fechaPrestamo: DateTime.now(),
      fechaDevolucion: DateTime.now().add(Duration(days: 1)),
      devuelto: false,
      items: cartItems,
    );

    loan.create();

    // Vaciar el carrito después de crear el préstamo
    setState(() {
      cartItems.clear();
      cartItemCount = 0;
    });

    // Mostrar una notificación o mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Préstamo creado con éxito')),
    );

    // Cerrar el modal
    Navigator.of(context).pop();
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
                    // Icono de editar solo para administradores
                    if (sessionManager.session.user is AdminUser)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () {},
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
                  child: Text('Agregar a la lista de compras',
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
