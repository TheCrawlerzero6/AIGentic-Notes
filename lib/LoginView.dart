import 'package:flutter/material.dart';
import 'package:mi_agenda/HomeView.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Figma Flutter Generator LoginView - FRAME - VERTICAL
    return Container(
      decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 1)),
      padding: EdgeInsets.symmetric(horizontal: 34, vertical: 77),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: <Widget>[
          SizedBox(height: 48),
          Container(
            width: 293.5,
            height: 157,

            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(),
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: <Widget>[
                        Text(
                          'Correo',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color.fromRGBO(30, 30, 30, 1),
                            fontFamily: 'Inter',
                            fontSize: 16,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.normal,
                            height: 1.5 /*PERCENT not supported*/,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Description',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color.fromRGBO(117, 117, 117, 1),
                            fontFamily: 'Inter',
                            fontSize: 16,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.normal,
                            height: 1.5 /*PERCENT not supported*/,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            color: Color.fromRGBO(255, 255, 255, 1),
                            border: Border.all(
                              color: Color.fromRGBO(217, 217, 217, 1),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: <Widget>[
                              Text(
                                'user@email.com',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Color.fromRGBO(30, 30, 30, 1),
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.normal,
                                  height: 1.5 /*PERCENT not supported*/,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Error',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color.fromRGBO(30, 30, 30, 1),
                            fontFamily: 'Inter',
                            fontSize: 16,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.normal,
                            height: 1.5 /*PERCENT not supported*/,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 87,
                  left: 0.5,
                  child: Container(
                    decoration: BoxDecoration(),
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: <Widget>[
                        Text(
                          'Contraseña',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color.fromRGBO(30, 30, 30, 1),
                            fontFamily: 'Inter',
                            fontSize: 16,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.normal,
                            height: 1.5 /*PERCENT not supported*/,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Description',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color.fromRGBO(117, 117, 117, 1),
                            fontFamily: 'Inter',
                            fontSize: 16,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.normal,
                            height: 1.5 /*PERCENT not supported*/,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            color: Color.fromRGBO(255, 255, 255, 1),
                            border: Border.all(
                              color: Color.fromRGBO(217, 217, 217, 1),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: <Widget>[
                              Text(
                                '******',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Color.fromRGBO(30, 30, 30, 1),
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.normal,
                                  height: 1.5 /*PERCENT not supported*/,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Error',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color.fromRGBO(30, 30, 30, 1),
                            fontFamily: 'Inter',
                            fontSize: 16,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.normal,
                            height: 1.5 /*PERCENT not supported*/,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48),
          Container(
            decoration: BoxDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(125),
                      topRight: Radius.circular(125),
                      bottomLeft: Radius.circular(125),
                      bottomRight: Radius.circular(125),
                    ),
                    color: Color.fromRGBO(103, 80, 164, 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12.5,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeView(),
                              ),
                            );
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 10),
                              Text(
                                'Iniciar Sesión',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontFamily: 'Roboto',
                                  fontSize: 17.5,
                                  letterSpacing: 0.125,
                                  fontWeight: FontWeight.normal,
                                  height: 1.4285714285714286,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
