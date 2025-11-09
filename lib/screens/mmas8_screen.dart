import 'package:flutter/material.dart';
import '../../db/crud_methods.dart';
import '../../models/mmas8_result.dart';

class MMAS8Screen extends StatefulWidget {
  const MMAS8Screen({super.key});

  @override
  State<MMAS8Screen> createState() => _MMAS8ScreenState();
}

class _MMAS8ScreenState extends State<MMAS8Screen> {
  final CrudMethods _crud = CrudMethods();

  // Respuestas
  Map<int, dynamic> answers = {};
  double? _likertValue;

  double _calculateScore() {
    double total = 0;
    for (int q = 1; q <= 7; q++) {
      final val = answers[q];
      if ([1, 2, 3, 4, 6, 7].contains(q) && val == true) total += 1;
      if (q == 5 && val == false) total += 1;
    }
    total += _likertValue ?? 0;
    return total;
  }

  String _getAdherenceLevel(double score) {
    if (score == 0) return "Alta adherencia";
    if (score < 2) return "Adherencia moderada";
    return "Baja adherencia";
  }

  Future<void> _saveResult() async {
    final score = _calculateScore();
    final level = _getAdherenceLevel(score);

    final result = MMAS8Result(
      score: score,
      adherenceLevel: level,
      dateTaken: DateTime.now().millisecondsSinceEpoch,
      notes: null,
    );
    await _crud.insertMMAS8Result(result);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Resultado"),
        content: Text(
          "Puntaje: ${score.toStringAsFixed(2)}\nNivel: $level",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cuestionario MMAS-8")),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("MediApp", style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Inicio"),
              onTap: () => Navigator.pushNamed(context, "/"),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("MMAS-8"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Responde las siguientes preguntas:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...List.generate(7, (i) {
            int q = i + 1;
            String text = [
              "¿A veces se le olvida tomar su medicación?",
              "En las últimas dos semanas, ¿hubo días en los que no tomó su medicación?",
              "¿Ha dejado de tomar o reducido su medicación sin avisar al médico?",
              "¿Cuando viaja o sale de casa, olvida llevar su medicación?",
              "¿Tomó su medicación la última vez que debía hacerlo?",
              "¿Cuando sus síntomas están controlados, deja de tomar su medicación?",
              "¿Se siente molesto por tener que tomar medicamentos todos los días?"
            ][i];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: const Text("Sí"),
                        value: true,
                        groupValue: answers[q],
                        onChanged: (val) =>
                            setState(() => answers[q] = val),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: const Text("No"),
                        value: false,
                        groupValue: answers[q],
                        onChanged: (val) =>
                            setState(() => answers[q] = val),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),

          const SizedBox(height: 20),
          const Text(
            "¿Con qué frecuencia tiene dificultad para recordar tomar todos sus medicamentos?",
            style: TextStyle(fontSize: 16),
          ),
          DropdownButton<double>(
            isExpanded: true,
            hint: const Text("Selecciona una opción"),
            value: _likertValue,
            items: const [
              DropdownMenuItem(value: 0, child: Text("Nunca")),
              DropdownMenuItem(value: 0.25, child: Text("Casi nunca")),
              DropdownMenuItem(value: 0.5, child: Text("Algunas veces")),
              DropdownMenuItem(value: 0.75, child: Text("Frecuentemente")),
              DropdownMenuItem(value: 1, child: Text("Siempre")),
            ],
            onChanged: (val) => setState(() => _likertValue = val),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveResult,
            child: const Text("Guardar resultado"),
          ),
        ],
      ),
    );
  }
}
