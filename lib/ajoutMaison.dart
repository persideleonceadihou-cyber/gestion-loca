import 'package:flutter/material.dart';

class AjoutMaison extends StatefulWidget {
  const AjoutMaison({super.key});

  @override
  State<AjoutMaison> createState() => _AjoutMaisonState();
}

class _AjoutMaisonState extends State<AjoutMaison> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _price;
  String? _address;
  String? _etat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un bien")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Titre (Maison, Villa...)"),
                onSaved: (val) => _title = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Montant (FCFA)"),
                keyboardType: TextInputType.number,
                onSaved: (val) => _price = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Adresse"),
                onSaved: (val) => _address = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "État (Disponible, Loué...)"),
                onSaved: (val) => _etat = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  // Ici tu peux sauvegarder dans ta base ou liste
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bien ajouté avec succès")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

