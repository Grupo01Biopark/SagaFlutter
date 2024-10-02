import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiDashboardService {
  final String apiPorte = "http://127.0.0.1:8080/dashboard/porte";
  final String apiSetor = "http://127.0.0.1:8080/dashboard/setor";
  final String apiTotal = "http://127.0.0.1:8080/dashboard/total";
  final String apiChecklist = "http://127.0.0.1:8080/dashboard/checklist";
  final String apiEmpresasMes =
      "http://127.0.0.1:8080/dashboard/mes"; // Nova rota

  Future<Map<String, dynamic>> fetchPorteData() async {
    final response = await http.get(Uri.parse(apiPorte));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Falha ao carregar dados de porte');
    }
  }

  Future<Map<String, dynamic>> fetchSetorData() async {
    final response = await http.get(Uri.parse(apiSetor));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Falha ao carregar dados de setor');
    }
  }

  Future<int> fetchTotalEmpresas() async {
    final response = await http.get(Uri.parse(apiTotal));

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Falha ao carregar total de empresas');
    }
  }

  Future<int> fetchTotalChecklists() async {
    final response = await http.get(Uri.parse(apiChecklist));

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Falha ao carregar total de checklists');
    }
  }

  Future<List<EmpresasMesData>> fetchEmpresasMes() async {
    final response = await http.get(Uri.parse(apiEmpresasMes));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Mapeia os dados para a classe EmpresasMesData
      return (data as List).map((item) {
        return EmpresasMesData(item[0], item[1], item[2]);
      }).toList();
    } else {
      throw Exception('Falha ao carregar dados de empresas por mês');
    }
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardPageState(title: 'Dashboard de Portes e Setores'),
    );
  }
}

class DashboardPageState extends StatefulWidget {
  DashboardPageState({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPageState> {
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
    _porteDataFuture =
        fetchPorteData(); // Inicializa a busca dos dados de porte
    _setorDataFuture =
        fetchSetorData(); // Inicializa a busca dos dados de setor
    _totalEmpresasFuture =
        _apiService.fetchTotalEmpresas(); // Busca total de empresas
    _totalChecklistsFuture =
        _apiService.fetchTotalChecklists(); // Busca total de checklists
    _empresasMesFuture =
        _apiService.fetchEmpresasMes(); // Busca empresas por mês
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
    return SafeArea(
        child: Scaffold(
            body: Column(
      children: [
        // Gráfico de Porte
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
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
                        return Center(child: Text('Nenhum dado de porte disponível'));
                      }

                      return SfCircularChart(
                        title: ChartTitle(text: 'Distribuição de Portes'),
                        legend: Legend(
                            position: LegendPosition.bottom,
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap),
                        tooltipBehavior: _tooltipBehaviorPorte,
                        series: <CircularSeries>[
                          PieSeries<PorteData, String>(
                            dataSource: snapshot.data,
                            xValueMapper: (PorteData data, _) => data.porte,
                            yValueMapper: (PorteData data, _) => data.quantidade,
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                            enableTooltip: true,
                          ),
                        ],
                      );
                    }),
              ),
              SizedBox(width: 10), // Espaçamento entre os gráficos
              Expanded(
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
                        return Center(child: Text('Nenhum dado de setor disponível'));
                      }

                      return SfCircularChart(
                        title: ChartTitle(text: 'Distribuição de Setores'),
                        legend: Legend(
                            position: LegendPosition.bottom,
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap),
                        tooltipBehavior: _tooltipBehaviorSetor,
                        series: <CircularSeries>[
                          PieSeries<SetorData, String>(
                            dataSource: snapshot.data,
                            xValueMapper: (SetorData data, _) => data.setor,
                            yValueMapper: (SetorData data, _) => data.quantidade,
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                            enableTooltip: true,
                          ),
                        ],
                      );
                    }),
              ),
            ],
          ),
          SizedBox(height: 20), // Espaçamento extra
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Card Total de Empresas
            FutureBuilder<int>(
                future: _totalEmpresasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }
                }),
            // Card Total de Checklists
            FutureBuilder<int>(
                future: _totalChecklistsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }
                }),
          ],
        ),
        SizedBox(height: 20), // Espaçamento extra
        Expanded(
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
                      child:
                          Text('Nenhum dado de empresas por mês disponível'));
                }

                return SfCartesianChart(
                  title: ChartTitle(text: 'Empresas Cadastradas por Mês'),
                  legend: Legend(
                      position: LegendPosition.bottom, // Posiciona a legenda abaixo do gráfico
                      isVisible: true
                    ),
                  tooltipBehavior: _tooltipBehaviorEmpresasMes,
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    ColumnSeries<EmpresasMesData, String>(
                      // Corrigido para ColumnSeries
                      dataSource: snapshot.data!,
                      xValueMapper: (EmpresasMesData data, _) =>
                          '${data.mes}/${data.ano}',
                      yValueMapper: (EmpresasMesData data, _) =>
                          data.quantidade,
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                  ],
                );
              }),
        ),
        SizedBox(height: 20), // Espaçamento extra
      ],
    )));
  }
}

// Modelo de dados para o gráfico de Porte
class PorteData {
  PorteData(this.porte, this.quantidade);
  final String porte;
  final int quantidade;
}

// Modelo de dados para o gráfico de Setor
class SetorData {
  SetorData(this.setor, this.quantidade);
  final String setor;
  final int quantidade;
}

// Modelo de dados para o gráfico de Empresas por Mês
class EmpresasMesData {
  EmpresasMesData(this.ano, this.mes, this.quantidade);
  final int ano;
  final int mes;
  final int quantidade;
}
