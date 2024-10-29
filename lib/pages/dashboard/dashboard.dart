import 'package:flutter/material.dart';
import 'package:saga_flutter_app/theme/theme_notifier.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class ApiDashboardService {
  final String apiPorte = "http://127.0.0.1:8080/dashboard/porte";
  final String apiSetor = "http://127.0.0.1:8080/dashboard/setor";
  final String apiTotal = "http://127.0.0.1:8080/dashboard/total";
  final String apiChecklist = "http://127.0.0.1:8080/dashboard/checklist";
  final String apiEmpresasMes = "http://127.0.0.1:8080/dashboard/mes";

  Future<Map<String, dynamic>> fetchPorteData() async {
    final response = await http.get(Uri.parse(apiPorte));
    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      return json.decode(utf8Response);
    } else {
      throw Exception('Falha ao carregar dados de porte');
    }
  }

  Future<Map<String, dynamic>> fetchSetorData() async {
    final response = await http.get(Uri.parse(apiSetor));
    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      return json.decode(utf8Response);
    } else {
      throw Exception('Falha ao carregar dados de setor');
    }
  }

  Future<int> fetchTotalEmpresas() async {
    final response = await http.get(Uri.parse(apiTotal));
    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      return int.parse(utf8Response);
    } else {
      throw Exception('Falha ao carregar total de empresas');
    }
  }

  Future<int> fetchTotalChecklists() async {
    final response = await http.get(Uri.parse(apiChecklist));
    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      return int.parse(utf8Response);
    } else {
      throw Exception('Falha ao carregar total de checklists');
    }
  }

  Future<List<EmpresasMesData>> fetchEmpresasMes() async {
    final response = await http.get(Uri.parse(apiEmpresasMes));
    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      final data = json.decode(utf8Response);
      return (data as List).map((item) {
        return EmpresasMesData(item[0], item[1], item[2]);
      }).toList();
    } else {
      throw Exception('Falha ao carregar dados de empresas por mês');
    }
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late TooltipBehavior _tooltipBehaviorPorte;
  late TooltipBehavior _tooltipBehaviorSetor;
  late TooltipBehavior _tooltipBehaviorEmpresasMes;
  late ApiDashboardService _apiService;
  Future<List<PorteData>>? _porteDataFuture;
  Future<List<SetorData>>? _setorDataFuture;
  Future<int>? _totalEmpresasFuture;
  Future<int>? _totalChecklistsFuture;
  Future<List<EmpresasMesData>>? _empresasMesFuture;

  @override
  void initState() {
    super.initState();
    _tooltipBehaviorPorte = TooltipBehavior(enable: true);
    _tooltipBehaviorSetor = TooltipBehavior(enable: true);
    _tooltipBehaviorEmpresasMes = TooltipBehavior(enable: true);
    _apiService = ApiDashboardService();
    _porteDataFuture = fetchPorteData();
    _setorDataFuture = fetchSetorData();
    _totalEmpresasFuture = _apiService.fetchTotalEmpresas();
    _totalChecklistsFuture = _apiService.fetchTotalChecklists();
    _empresasMesFuture = _apiService.fetchEmpresasMes();
  }

  Future<List<PorteData>> fetchPorteData() async {
    final apiData = await _apiService.fetchPorteData();
    return apiData.entries.map((entry) {
      return PorteData(entry.key, entry.value);
    }).toList();
  }

  Future<List<SetorData>> fetchSetorData() async {
    final apiData = await _apiService.fetchSetorData();
    return apiData.entries.map((entry) {
      return SetorData(entry.key, entry.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<List<PorteData>>(
                    future: _porteDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Erro ao carregar dados de porte: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text('Nenhum dado de porte disponível'));
                      }

                      return SfCircularChart(
                        title: ChartTitle(text: 'Distribuição de Portes'),
                        legend: Legend(
                          position: LegendPosition.right,
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                          shouldAlwaysShowScrollbar: true,
                        ),
                        tooltipBehavior: _tooltipBehaviorPorte,
                        series: <CircularSeries>[
                          PieSeries<PorteData, String>(
                            dataSource: snapshot.data,
                            xValueMapper: (PorteData data, _) => data.porte,
                            yValueMapper: (PorteData data, _) =>
                                data.quantidade,
                            dataLabelSettings:
                                DataLabelSettings(isVisible: true),
                            enableTooltip: true,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<List<SetorData>>(
                    future: _setorDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Erro ao carregar dados de setor: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text('Nenhum dado de setor disponível'));
                      }

                      return SfCircularChart(
                        title: ChartTitle(text: 'Distribuição de Setores'),
                        legend: Legend(
                          position: LegendPosition.right,
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                          shouldAlwaysShowScrollbar: true,
                        ),
                        tooltipBehavior: _tooltipBehaviorSetor,
                        series: <CircularSeries>[
                          PieSeries<SetorData, String>(
                            dataSource: snapshot.data,
                            xValueMapper: (SetorData data, _) => data.setor,
                            yValueMapper: (SetorData data, _) =>
                                data.quantidade,
                            dataLabelSettings:
                                DataLabelSettings(isVisible: true),
                            enableTooltip: true,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0), // Margem lateral
                    child: Container(
                      width: 300, // Ajuste a largura conforme necessário
                      child: FutureBuilder<int>(
                        future: _totalEmpresasFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Erro ao carregar total de empresas');
                          } else {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Total de Empresas',
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 8),
                                    Text(snapshot.data.toString(),
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0), // Margem lateral
                    child: Container(
                      width: 300, // Ajuste a largura conforme necessário
                      child: FutureBuilder<int>(
                        future: _totalChecklistsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Erro ao carregar total de checklists');
                          } else {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Total de Checklists',
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 8),
                                    Text(snapshot.data.toString(),
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<List<EmpresasMesData>>(
                    future: _empresasMesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Erro ao carregar dados de empresas por mês: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text(
                                'Nenhum dado de empresas por mês disponível'));
                      }

                      return SfCartesianChart(
                        title: ChartTitle(text: 'Empresas cadastradas por Mês'),
                        legend: Legend(isVisible: true),
                        tooltipBehavior: _tooltipBehaviorEmpresasMes,
                        series: <CartesianSeries>[
                          ColumnSeries<EmpresasMesData, String>(
                            dataSource: snapshot.data!,
                            xValueMapper: (EmpresasMesData data, _) =>
                                '${data.ano}-${data.mes}',
                            yValueMapper: (EmpresasMesData data, _) =>
                                data.quantidade,
                            dataLabelSettings:
                                DataLabelSettings(isVisible: true),
                          ),
                        ],
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PorteData {
  final String porte;
  final int quantidade;
  PorteData(this.porte, this.quantidade);
}

class SetorData {
  final String setor;
  final int quantidade;
  SetorData(this.setor, this.quantidade);
}

class EmpresasMesData {
  final int ano;
  final int mes;
  final int quantidade;
  EmpresasMesData(this.ano, this.mes, this.quantidade);
}
