import "dart:developer";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:url_shortener/services/api_service.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;
  String _shortUrl = "";

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("URL Shortener")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _controller,
                  onSubmitted: _shorten,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: "Enter URL",
                    hintText: "Enter the URL you want to shorten",
                  ),
                ),

                const SizedBox(height: 16.0),

                ElevatedButton.icon(
                  onPressed: !_isLoading ? _shorten : null,
                  icon: const Icon(Icons.link),
                  label: const Text("Shorten URL"),
                ),

                const SizedBox(height: 16.0),

                if (_isLoading) const CircularProgressIndicator(),

                if (_shortUrl.isNotEmpty) ...<Widget>[
                  const Text("Shortened URL (Tap to copy)"),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: _shortUrl));

                      _showMessage("Copied to clipboard!");
                    },
                    child: Text(
                      _shortUrl,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shorten([String? search]) async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();

      final String input = search ?? _controller.text.trim();

      if (input.isEmpty) {
        _showMessage("Please enter a URL");
        return;
      }

      setState(() {
        _isLoading = true;
        _shortUrl = "";
      });

      final String result = await APIService().generate(url: input);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _shortUrl = result;
      });

      if (result.isEmpty) {
        _showMessage("Failed to shorten URL");
        return;
      }
    } on Exception catch (error, stackTrace) {
      log("Exception", error: error, stackTrace: stackTrace, name: "shorten");

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _shortUrl = "";
      });

      _showMessage("An error occurred: $error");
    }

    return;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
