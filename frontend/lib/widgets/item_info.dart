import 'package:flutter/material.dart';
import 'package:frontend/models/Loan.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/services/Cart.dart';
import 'package:frontend/services/PageManager.dart';
import 'package:frontend/services/SelectedItemContext.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class ItemInfoWidget extends StatefulWidget {
  final SelectedItemContext itemContext;
  final PageManager pageManager;
  final CheckoutCart cart;

  const ItemInfoWidget({
    super.key,
    required this.itemContext,
    required this.pageManager,
    required this.cart,
  });

  @override
  _ItemInfoWidgetState createState() => _ItemInfoWidgetState();
}

class _ItemInfoWidgetState extends State<ItemInfoWidget> {
  Color dominantColor = Colors.black;
  Item? item;
  int selectedQuantity = 1;
  bool isInCart = false;

  @override
  void initState() {
    super.initState();
    item = widget.itemContext.item;
    _updatePalette();
    _checkIfInCart();
  }

  Future<void> _updatePalette() async {
    var imagePath = "/assets/images/place_holder.png";
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      NetworkImage(item?.imagePath ?? imagePath),
    );
    setState(() {
      dominantColor = generator.dominantColor?.color ?? Colors.black;
    });
  }

  void _checkIfInCart() {

    var existingItem;

    for(PrestamoItem item in widget.cart.items){
      if(item.itemId == this.item?.id){
        existingItem = item;
        break;
      }
    }

    if (existingItem != null) {
        selectedQuantity = existingItem.cantidad;
        isInCart = true;
    } else {
        selectedQuantity = 1;
        isInCart = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.itemContext),
        ChangeNotifierProvider.value(value: widget.cart),
        ChangeNotifierProvider.value(value: SessionManager()),
      ],
      child: Consumer3<SelectedItemContext, CheckoutCart, SessionManager>(
        builder: (context, itemContext, cart, sessionManager, child) {
          if (!itemContext.isSet()) {
            return Container();
          }
          item = itemContext.item!;
          _checkIfInCart();
          return Container(
            width: MediaQuery.of(context).size.width * 0.25,
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen y título del ítem como banner
                ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 330,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [dominantColor, dominantColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Opacity(
                          opacity: 0.7,
                          child: Image.network(
                            item?.imagePath != null ? item!.imagePath! : "assets/images/place_holder.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, -1),
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.fromLTRB(20, 250, 20, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item!.nombre,
                                style: TextStyle(
                                  color: dominantColor.computeLuminance() < 0.5 ? Colors.black : Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  overflow: TextOverflow.ellipsis,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4.0,
                                      color: dominantColor.computeLuminance() > 0.5 ?
                                      Colors.black.withAlpha(100) :
                                      Colors.white.withAlpha(100),
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(1, 0),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: IconButton(
                            onPressed: () {
                              itemContext.unsetItem();
                            },
                            color: dominantColor.computeLuminance() < 0.5 ? Colors.black : Colors.white,
                            icon: const Icon(
                              Icons.clear,
                              size: 30,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Recuadro gris detrás de la información del ítem
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información adicional del ítem con subtítulos en bold
                      _buildInfoRow('Marca', item!.marca.marca),
                      _buildInfoRow('Cantidad disponible', (item!.quantity - item!.quantityOnLoan).toString()),
                      _buildInfoRow('Número de serie', item!.serialNumber ?? 'No disponible'),
                      _buildInfoRow('Categorías', item!.categories.map((c) => c.nombre).join(', ')),
                      SizedBox(height: 20),
                      // Selector de cantidad y botón para agregar a la lista de compras
                      if(sessionManager.session.user is! VisitorUser)
                        Row(
                        children: [
                          ElevatedButton(
                            onPressed: selectedQuantity > 1
                                ? () {
                              setState(() {
                                selectedQuantity--;
                                if (isInCart) {
                                  widget.cart.addItem(PrestamoItem(itemId: item!.id ?? 1, cantidad: selectedQuantity));
                                }
                              });
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInCart ? Colors.orange : Colors.white,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(10),
                            ),
                            child: Icon(Icons.remove, color: isInCart ? Colors.white : Colors.black),
                          ),
                          Text(
                            selectedQuantity.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          ElevatedButton(
                            onPressed: selectedQuantity < (item!.quantity - item!.quantityOnLoan)
                                ? () {
                              setState(() {
                                selectedQuantity++;
                                if (isInCart) {
                                  widget.cart.addItem(PrestamoItem(itemId: item!.id ?? 1, cantidad: selectedQuantity));
                                }
                              });
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInCart ? Colors.orange : Colors.white,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(10),
                            ),
                            child: Icon(Icons.add, color: isInCart ? Colors.white : Colors.black),
                          ),
                          if (isInCart) Icon(Icons.check_circle, color: Colors.white, size: 30),
                        ],
                      ),
                      SizedBox(height: 20),
                      if(sessionManager.session.user is! VisitorUser)
                        ElevatedButton(
                        onPressed: () {
                          if(isInCart){
                            cart.removeItem(item!.id ?? 1);
                            return;
                          }
                          if(selectedQuantity <= (item!.quantity - item!.quantityOnLoan)){
                            cart.addItem(PrestamoItem(itemId: item!.id ?? 1, cantidad: selectedQuantity));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          backgroundColor: isInCart? Colors.white: Colors.orange,
                        ),
                        child: Text( isInCart? 'Quitar':'Agregar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(color: Colors.white, fontSize: 16, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }

}