import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ayoayo/widgets/diagnosis/image_upload_placeholder.dart';

class DevicePassportForm extends StatefulWidget {
  final Function(String, String, int, List<File>) onSubmit;

  const DevicePassportForm({super.key, required this.onSubmit});

  @override
  State<DevicePassportForm> createState() => DevicePassportFormState();
}

class DevicePassportFormState extends State<DevicePassportForm> {
  final _formKey = GlobalKey<FormState>();
  final _deviceModelController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _yearOfReleaseController = TextEditingController();
  List<File> _imagePaths = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _deviceModelController,
            decoration: const InputDecoration(labelText: 'Device Model'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a device model';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _manufacturerController,
            decoration: const InputDecoration(labelText: 'Manufacturer'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a manufacturer';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _yearOfReleaseController,
            decoration: const InputDecoration(labelText: 'Year of Release'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a year of release';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid year';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          ImageUploadPlaceholder(
            label: 'Device Images',
            onImagesSelected: (imagePaths) {
              setState(() {
                _imagePaths = imagePaths;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  _deviceModelController.text,
                  _manufacturerController.text,
                  int.parse(_yearOfReleaseController.text),
                  _imagePaths,
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
