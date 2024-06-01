import 'package:flutter/material.dart';
import 'package:paycar/service/usuario_service.dart';
import 'package:fl_chart/fl_chart.dart';

class EstadisticasScreen extends StatefulWidget {
  @override
  _EstadisticasScreenState createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final UsuarioService usuarioService = UsuarioService();
  Future<Map<String, dynamic>?>? estadisticasFuture;

  @override
  void initState() {
    super.initState();
    estadisticasFuture = usuarioService.verEstadisticas();
  }

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color(0xFF2F3640),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: estadisticasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron estadísticas.', style: TextStyle(color: Colors.white)));
          } else {
            final estadisticas = snapshot.data!;
            final int numeroGrupos = estadisticas['numeroGrupos'];
            final int vecesConductor = estadisticas['vecesConductor'];
            final int vecesPasajero = estadisticas['vecesPasajero'];
            final double totalCostePagado = estadisticas['totalCostePagado'];
            final double totalCosteTotal = estadisticas['totalCosteTotal'];
            final double debes = totalCosteTotal - totalCostePagado;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    SizedBox(
                      height: 300, // Ajusta la altura según sea necesario
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: numeroGrupos.toDouble(),
                          barTouchData: BarTouchData(
                            
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  );
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 0:
                                      text = Text('Conductor', style: style);
                                      break;
                                    case 1:
                                      text = Text('Pasajero', style: style);
                                      break;
                                    default:
                                      text = Text('', style: style);
                                      break;
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 16,
                                    child: text,
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                                interval: 1,
                                reservedSize: 28,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: vecesConductor.toDouble(),
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: vecesPasajero.toDouble(),
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        LegendItem(color: Colors.green, text: 'Conductor'),
                        LegendItem(color: Colors.blue, text: 'Pasajero'),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('Coste Total vs Coste Pagado', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: totalCostePagado,
                              title: '',
                              radius: 50,
                              titleStyle: TextStyle(color: Colors.white, fontSize: 14),
                              badgeWidget: touchedIndex == 0 ? Text('$totalCostePagado', style: TextStyle(color: Colors.white)) : null,
                              badgePositionPercentageOffset: 1.2,
                            ),
                            PieChartSectionData(
                              color: Colors.red,
                              value: debes,
                              title: '',
                              radius: 50,
                              titleStyle: TextStyle(color: Colors.white, fontSize: 14),
                              badgeWidget: touchedIndex == 1 ? Text('$debes', style: TextStyle(color: Colors.white)) : null,
                              badgePositionPercentageOffset: 1.2,
                            ),
                          ],
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        LegendItem(color: Colors.green, text: 'Pagado'),
                        LegendItem(color: Colors.red, text: 'Debes'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
