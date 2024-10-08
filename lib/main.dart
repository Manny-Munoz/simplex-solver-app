import 'package:flutter/material.dart';

void main() {
  runApp(SimplexApp());
}

class SimplexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SimplexScreen(),
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

  // Controladores de los campos de texto
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
    });
  }

  // Método para construir la tabla basada en las restricciones y la función objetivo
  Widget _buildSimplexTable() {
    List<TableRow> rows = [];

    // Agregar fila para la función objetivo
    List<Widget> objectiveRow = _objectiveFunction
        .map((coef) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(coef.toString()),
            ))
        .toList();
    objectiveRow.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("Función Objetivo"),
    ));

    rows.add(TableRow(children: objectiveRow));

    // Agregar restricciones
    for (int i = 0; i < _restrictions.length; i++) {
      List<Widget> restrictionRow = _restrictions[i]
          .map((coef) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(coef.toString()),
              ))
          .toList();
      restrictionRow.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('<= ${_rhs[i]}'),
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
      appBar: AppBar(
        title: Text('Método Simplex'),
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
                decoration: InputDecoration(labelText: 'Operación'),
              ),
              TextFormField(
                controller: _objectiveController,
                decoration: InputDecoration(
                    labelText: 'Función Objetivo (ej: 3,5 para 3x + 5y)'),
              ),
              TextFormField(
                controller: _restrictionController,
                decoration: InputDecoration(
                    labelText:
                        'Agregar Restricción (ej: 2,3 para 2x + 3y <= rhs)'),
              ),
              TextFormField(
                controller: _rhsController,
                decoration:
                    InputDecoration(labelText: 'Valor RHS de la restricción'),
              ),
              ElevatedButton(
                onPressed: _addRestriction,
                child: Text('Agregar Restricción'),
              ),
              SizedBox(height: 16),
              Text('Restricciones agregadas:'),
              ..._restrictions
                  .asMap()
                  .entries
                  .map((entry) => Text(
                      '${entry.value.toString()} <= ${_rhs[entry.key]}'))
                  .toList(),
              SizedBox(height: 16),
              Text('Tabla Simplex:'),
              if (_objectiveFunction.isNotEmpty && _restrictions.isNotEmpty)
                _buildSimplexTable(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _solveSimplex,
                child: Text('Resolver'),
              ),
              SizedBox(height: 16),
              if (_solution.isNotEmpty) Text('Solución: $_solution'),
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

  Simplex(this.objectiveFunction, this.restrictions, this.rhs,
      this.isMaximization);

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

    // Rellenar la fila de la función objetivo
    for (int j = 0; j < numVars; j++) {
      tableau[numConstraints][j] = isMaximization
          ? -objectiveFunction[j]
          : objectiveFunction[j];
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
        break;
      }

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
        return 'No hay solución';
      }

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
    }

    // Leer la solución
    List<double> solution = List.filled(numVars, 0);
    for (int i = 0; i < numConstraints; i++) {
      for (int j = 0; j < numVars; j++) {
        if (tableau[i][j] == 1.0) {
          solution[j] = tableau[i][tableau[i].length - 1];
          break;
        }
      }
    }

    double optimalValue = tableau[numConstraints][tableau[0].length - 1];
    return 'Valor óptimo: $optimalValue, Variables: ${solution.toString()}';
  }
}
