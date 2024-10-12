import 'package:flutter/material.dart';
import 'package:simplex/components/button_assistant.dart';
import 'package:simplex/welcome_page.dart';

void main() {
  runApp(SimplexApp());
}

class SimplexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}

class SimplexScreen extends StatefulWidget {  
  @override
  _SimplexScreenState createState() => _SimplexScreenState();
}

class _SimplexScreenState extends State<SimplexScreen> {
  final _formKey = GlobalKey<FormState>();
  String _operation = 'Maximizar';
  List<double> _objectiveFunction = [];
  List<List<double>> _restrictions = [];
  List<double> _rhs = [];
  int _numVars = 0;

  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _restrictionController = TextEditingController();
  final TextEditingController _rhsController = TextEditingController();
  String _solution = '';

  void _addRestriction() {
    setState(() {
      List<double> restriction = _restrictionController.text
          .split(',')
          .map((e) => double.parse(e))
          .toList();
      _restrictions.add(restriction);
      _rhs.add(double.parse(_rhsController.text));
      _restrictionController.clear();
      _rhsController.clear();
    });
  }

  void _solveSimplex() {
    setState(() {
      _objectiveFunction = _objectiveController.text
          .split(',')
          .map((e) => double.parse(e))
          .toList();
      _numVars = _objectiveFunction.length;

      Simplex simplex = Simplex(
          _objectiveFunction, _restrictions, _rhs, _operation == 'Maximizar');
      _solution = simplex.solve();
      
      List<String> steps = simplex.getSteps();
      _solution += '\n\nPasos:\n' + steps.join('\n');
    });
  }

  Widget _buildSimplexTable() {
    List<TableRow> rows = [];

    List<Widget> objectiveRow = _objectiveFunction
        .map((coef) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(coef.toString()),
            ))
        .toList();
    objectiveRow.add(const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text("Función Objetivo"),
    ));

    rows.add(TableRow(children: objectiveRow));

    for (int i = 0; i < _restrictions.length; i++) {
      List<Widget> restrictionRow = _restrictions[i]
          .map((coef) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(coef.toString()),
              ))
          .toList();
      String sign = _operation == 'Minimizar' ? '>=' : '<=';
      restrictionRow.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('$sign ${_rhs[i]}'),
      ));
      rows.add(TableRow(children: restrictionRow));
    }

    return Table(
      border: TableBorder.all(),
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255,189, 174, 147),
      appBar: AppBar(
        title: const Text('Método Simplex', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 58, 49, 42),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _operation,
                onChanged: (String? newValue) {
                  setState(() {
                    _operation = newValue!;
                  });
                },
                items: <String>['Maximizar', 'Minimizar']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Operación', labelStyle: TextStyle(color: Colors.black)),
              ),
              TextFormField(
                controller: _objectiveController,
                decoration: const InputDecoration(
                    labelText: 'Función Objetivo (ej: 3,5 para 3x + 5y)'),
              ),
              TextFormField(
                controller: _restrictionController,
                decoration: const InputDecoration(
                    labelText:
                        'Agregar Restricción (ej: 2,3 para 2x + 3y <= rhs)'),
              ),
              TextFormField(
                controller: _rhsController,
                decoration:
                    const InputDecoration(labelText: 'Valor RHS de la restricción'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addRestriction,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 215, 155, 38)),
                ),
                child: const Text('Agregar Restricción', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 16),
              const Text('Restricciones agregadas:'),
              const SizedBox(height: 8),
              ..._restrictions
                  .asMap()
                  .entries
                  .map((entry) => Text(
                      '${entry.value.toString()} ${_operation == 'Minimizar' ? '>=' : '<='} ${_rhs[entry.key]}'))
                  .toList(),
              const SizedBox(height: 16),
              const Text('Tabla Simplex:'),
              const SizedBox(height: 8),
              if (_objectiveFunction.isNotEmpty && _restrictions.isNotEmpty)
                _buildSimplexTable(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _solveSimplex,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 215, 155, 38)),
                ),
                child: const Text('Resolver', style: TextStyle(color: Colors.black),),
              ),
              const SizedBox(height: 16),
              if (_solution.isNotEmpty) Text('Solución: $_solution'),
              const SizedBox(height: 16),
              ButtonAssistant(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class Simplex {
  final List<double> objectiveFunction;
  final List<List<double>> restrictions;
  final List<double> rhs;
  final bool isMaximization;
  List<String> steps = [];

  Simplex(this.objectiveFunction, this.restrictions, this.rhs, this.isMaximization);

  String solve() {
    int numVars = objectiveFunction.length;
    int numConstraints = restrictions.length;

    // Crear la tabla inicial del simplex
    List<List<double>> tableau = List.generate(
        numConstraints + 1, (i) => List.filled(numVars + numConstraints + 1, 0));

    // Rellenar las restricciones en la tabla
    for (int i = 0; i < numConstraints; i++) {
      for (int j = 0; j < numVars; j++) {
        tableau[i][j] = restrictions[i][j];
      }
      tableau[i][numVars + i] = 1; // Variables de holgura
      tableau[i][tableau[i].length - 1] = rhs[i];
    }

    // Registrar tabla inicial
    steps.add('Tabla inicial:\n' + _tableauToString(tableau));

    // Rellenar la fila de la función objetivo
    for (int j = 0; j < numVars; j++) {
      tableau[numConstraints][j] = isMaximization
          ? -objectiveFunction[j] // Para maximizar, invierte el signo
          : objectiveFunction[j];  // Para minimizar, no cambies el signo
    }

    // Método simplex
    while (true) {
      // Encontrar la columna pivote (entra en la base)
      int pivotCol = 0;
      for (int j = 1; j < tableau[0].length - 1; j++) {
        if (tableau[numConstraints][j] < tableau[numConstraints][pivotCol]) {
          pivotCol = j;
        }
      }
      if (tableau[numConstraints][pivotCol] >= 0) {
        // Solución óptima encontrada
        steps.add('Solución óptima encontrada.');
        break;
      }

      steps.add('Columna pivote: $pivotCol');

      // Encontrar la fila pivote (sale de la base)
      int pivotRow = -1;
      double minRatio = double.infinity;
      for (int i = 0; i < numConstraints; i++) {
        if (tableau[i][pivotCol] > 0) {
          double ratio = tableau[i][tableau[i].length - 1] / tableau[i][pivotCol];
          if (ratio < minRatio) {
            minRatio = ratio;
            pivotRow = i;
          }
        }
      }
      if (pivotRow == -1) {
        steps.add('No hay solución factible.');
        return 'No hay solución';
      }

      steps.add('Fila pivote: $pivotRow');

      // Realizar pivotación
      double pivotValue = tableau[pivotRow][pivotCol];
      for (int j = 0; j < tableau[0].length; j++) {
        tableau[pivotRow][j] /= pivotValue;
      }
      for (int i = 0; i <= numConstraints; i++) {
        if (i != pivotRow) {
          double factor = tableau[i][pivotCol];
          for (int j = 0; j < tableau[0].length; j++) {
            tableau[i][j] -= factor * tableau[pivotRow][j];
          }
        }
      }

      steps.add('Tabla después de pivotar:\n' + _tableauToString(tableau));
    }

    // Leer la solución
    List<double> solution = List.filled(numVars, 0);
    for (int j = 0; j < numVars; j++) {
      bool isBasic = false;
      double val = 0.0;
      
      // Verifica si la columna es básica (solo 1 en una fila y ceros en otras)
      for (int i = 0; i < numConstraints; i++) {
        if (tableau[i][j] == 1.0 && !isBasic) {
          isBasic = true;
          val = tableau[i][tableau[i].length - 1];
        } else if (tableau[i][j] != 0) {
          isBasic = false;
          break;
        }
      }

      // Asignar valor solo si la columna es básica
      if (isBasic) {
        solution[j] = val;
      }
    }

    double optimalValue = tableau[numConstraints][tableau[0].length - 1];
    steps.add('Valor óptimo: $optimalValue, Variables: ${solution.toString()}');
    return 'Valor óptimo: $optimalValue, Variables: ${solution.toString()}';
  }

  String _tableauToString(List<List<double>> tableau) {
    return tableau.map((row) => row.map((val) => val.toStringAsFixed(2)).join('  ')).join('\n');
  }

  List<String> getSteps() {
    return steps;
  }
}
