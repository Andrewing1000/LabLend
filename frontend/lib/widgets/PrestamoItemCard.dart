import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Loan.dart';
import '../models/Session.dart';
import '../models/item.dart';
import '../services/Cart.dart';
import 'horizontal_card.dart';

class PrestamoItemCard extends StatefulWidget {
  final PrestamoItem prestamoItem;
  final CheckoutCart? cart;
  final bool editable;

  PrestamoItemCard({
    super.key,
    required this.prestamoItem,
    this.cart,
    this.editable = true});

  @override
  _PrestamoItemCardState createState() => _PrestamoItemCardState();
}

class _PrestamoItemCardState extends State<PrestamoItemCard> {
  bool isHovered = false;
  Item? item;
  int selectedQuantity = 1;
  bool isInCart = true;

  @override
  void initState() {
    super.initState();
    selectedQuantity = widget.prestamoItem.cantidad;
    _fetchItem();
  }

  Future<void> _fetchItem() async {
    final fetchedItem = await SessionManager.inventory.getItemById(widget.prestamoItem.itemId);
    setState(() {
      item = fetchedItem;
    });
  }

  void _onEnter(PointerEvent event) {
    setState(() {
      isHovered = true;
    });
  }

  void _onExit(PointerEvent event) {
    setState(() {
      isHovered = false;
    });
  }

  void _removeItem() {
    widget.cart?.removeItem(widget.prestamoItem.itemId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: widget.prestamoItem),
            ChangeNotifierProvider.value(value: widget.cart),
          ],
          child: Consumer2<PrestamoItem, CheckoutCart>(
            builder: (context, prestamoItem, cart, child) {
              if (item == null) {
                return Container();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  if (width > HorizontalCard.maxWidth) {
                    width = HorizontalCard.maxWidth;
                  } else if (width < HorizontalCard.minWidth) {
                    width = HorizontalCard.minWidth;
                  }

                  double height = (2 / 7.5) * width;
                  if (height > HorizontalCard.maxHeight) {
                    height = HorizontalCard.maxHeight;
                  } else if (height < HorizontalCard.minHeight) {
                    height = HorizontalCard.minHeight;
                  }

                  return Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: height,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                      decoration: BoxDecoration(
                        color: isHovered
                            ? Colors.grey[850]
                            : const Color.fromRGBO(255, 255, 255, 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (item != null)
                            AspectRatio(
                              aspectRatio: 1,
                              child: SizedBox(
                                height: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    item!.imagePath ??
                                        'assets/images/place_holder.png',
                                    fit: BoxFit.cover,
                                    isAntiAlias: true,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item!.nombre,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  item!.serialNumber ?? 'No serial number',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if(widget.editable)  Row(
                            children: [
                              ElevatedButton(
                                onPressed: selectedQuantity > 1
                                    ? () {
                                  setState(() {
                                    selectedQuantity--;
                                    if (isInCart) {
                                      widget.cart?.addItem(PrestamoItem(
                                          itemId: item!.id ?? 1,
                                          cantidad: selectedQuantity));
                                    }
                                  });
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInCart
                                      ? Colors.orange
                                      : Colors.white,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(5),
                                ),
                                child: Icon(
                                  size: 14,
                                  Icons.remove,
                                  color: isInCart
                                      ? Colors.white
                                      : Colors.black),
                              ),
                              Text(
                                selectedQuantity.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              ElevatedButton(
                                onPressed: selectedQuantity <
                                    (item!.quantity -
                                        item!.quantityOnLoan)
                                    ? () {
                                  setState(() {
                                    selectedQuantity++;
                                    if (isInCart) {
                                      widget.cart?.addItem(PrestamoItem(
                                          itemId: item!.id ?? 1,
                                          cantidad: selectedQuantity));
                                    }
                                  });
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInCart
                                      ? Colors.orange
                                      : Colors.white,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(5),
                                ),
                                child: Icon(Icons.add,
                                    size: 14,
                                    color: isInCart
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ],
                          ),
                          if(!widget.editable)
                            Text(
                              'Cantidad: ${selectedQuantity.toString()}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          SizedBox(width: 16),
                          if(widget.editable) IconButton(
                            onPressed: _removeItem,
                            icon: Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
