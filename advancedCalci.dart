import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const CalculatorApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advanced Calculator',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF03DAC6),
        ),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _currentInput = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operation = "";
  bool _isCalculating = false;
  bool _isScientificMode = false;
  double _memoryValue = 0;
  String _lastOperation = "";

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _resetCalculator();
      } else if (buttonText == "⌫") {
        _handleBackspace();
      } else if (buttonText == "=") {
        _calculateResult();
      } else if (buttonText == "+/-") {
        _toggleSign();
      } else if (buttonText == "%") {
        _calculatePercentage();
      } else if (["sin", "cos", "tan", "asin", "acos", "atan", "log", "ln", "√", "x²", "x³", "x^y", "π", "e", "1/x", "10^x", "e^x", "n!", "Rand"].contains(buttonText)) {
        _handleScientificFunction(buttonText);
      } else if (buttonText == "M+") {
        _memoryAdd();
      } else if (buttonText == "M-") {
        _memorySubtract();
      } else if (buttonText == "MR") {
        _memoryRecall();
      } else if (buttonText == "MC") {
        _memoryClear();
      } else if (buttonText == "SCI") {
        _toggleScientificMode();
      } else if (["+", "-", "×", "÷", "x^y"].contains(buttonText)) {
        _handleOperation(buttonText);
      } else if (buttonText == ".") {
        _handleDecimalPoint();
      } else {
        _handleNumberInput(buttonText);
      }
    });
  }

  void _resetCalculator() {
    _output = "0";
    _currentInput = "";
    _num1 = 0;
    _num2 = 0;
    _operation = "";
    _isCalculating = false;
    _lastOperation = "";
  }

  void _handleBackspace() {
    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      if (_currentInput.isEmpty) _currentInput = "0";
      _updateOutput();
    }
  }

  void _calculateResult() {
    if (_operation.isNotEmpty && _currentInput.isNotEmpty) {
      _num2 = double.parse(_currentInput);
      double result = 0;
      
      switch (_operation) {
        case "+":
          result = _num1 + _num2;
          break;
        case "-":
          result = _num1 - _num2;
          break;
        case "×":
          result = _num1 * _num2;
          break;
        case "÷":
          result = _num1 / _num2;
          break;
        case "x^y":
          result = math.pow(_num1, _num2).toDouble();
          break;
      }
      
      _currentInput = result.toString();
      _lastOperation = "$_num1 $_operation $_num2 = $result";
      _num1 = result;
      _operation = "";
      _output = _currentInput;
      _isCalculating = false;
    }
  }

  void _toggleSign() {
    if (_currentInput.isNotEmpty && _currentInput != "0") {
      _currentInput = _currentInput.startsWith("-") 
          ? _currentInput.substring(1) 
          : "-$_currentInput";
      _updateOutput();
    }
  }

  void _calculatePercentage() {
    if (_currentInput.isNotEmpty) {
      double value = double.parse(_currentInput);
      _currentInput = (value / 100).toString();
      _updateOutput();
    }
  }

  void _handleScientificFunction(String function) {
    if (_currentInput.isEmpty && !["π", "e", "Rand"].contains(function)) return;
    
    double value = function == "π" ? math.pi 
                 : function == "e" ? math.e 
                 : function == "Rand" ? math.Random().nextDouble()
                 : double.parse(_currentInput);
    
    double result = 0;
    
    switch (function) {
      case "sin":
        result = math.sin(value * math.pi / 180);
        break;
      case "cos":
        result = math.cos(value * math.pi / 180);
        break;
      case "tan":
        result = math.tan(value * math.pi / 180);
        break;
      case "asin":
        result = math.asin(value) * 180 / math.pi;
        break;
      case "acos":
        result = math.acos(value) * 180 / math.pi;
        break;
      case "atan":
        result = math.atan(value) * 180 / math.pi;
        break;
      case "log":
        result = math.log(value) / math.log(10);
        break;
      case "ln":
        result = math.log(value);
        break;
      case "√":
        result = math.sqrt(value);
        break;
      case "x²":
        result = math.pow(value, 2).toDouble();
        break;
      case "x³":
        result = math.pow(value, 3).toDouble();
        break;
      case "1/x":
        result = 1 / value;
        break;
      case "10^x":
        result = math.pow(10, value).toDouble();
        break;
      case "e^x":
        result = math.exp(value);
        break;
      case "n!":
        result = _factorial(value.toInt()).toDouble();
        break;
      case "π":
      case "e":
      case "Rand":
        _currentInput = value.toString();
        _updateOutput();
        return;
    }
    
    _currentInput = result.toString();
    _lastOperation = "$function($value) = $result";
    _updateOutput();
  }

  int _factorial(int n) {
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  void _memoryAdd() {
    if (_currentInput.isNotEmpty) {
      _memoryValue += double.parse(_currentInput);
    }
  }

  void _memorySubtract() {
    if (_currentInput.isNotEmpty) {
      _memoryValue -= double.parse(_currentInput);
    }
  }

  void _memoryRecall() {
    _currentInput = _memoryValue.toString();
    _updateOutput();
  }

  void _memoryClear() {
    _memoryValue = 0;
  }

  void _toggleScientificMode() {
    setState(() {
      _isScientificMode = !_isScientificMode;
    });
  }

  void _handleOperation(String buttonText) {
    if (_currentInput.isNotEmpty) {
      _num1 = double.parse(_currentInput);
      _isCalculating = true;
      _operation = buttonText;
      _output = "$_num1 $_operation";
      _currentInput = "";
    }
  }

  void _handleDecimalPoint() {
    if (!_currentInput.contains(".")) {
      _currentInput += _currentInput.isEmpty ? "0." : ".";
      _updateOutput();
    }
  }

  void _handleNumberInput(String buttonText) {
    if (_currentInput == "0") {
      _currentInput = buttonText;
    } else {
      _currentInput += buttonText;
    }
    _updateOutput();
  }

  void _updateOutput() {
    if (!_isCalculating) {
      _output = _currentInput;
    } else {
      _output = "$_num1 $_operation $_currentInput";
    }
  }

  Widget _buildButton(String buttonText, {Color? color, double? fontSize, bool isScientific = false}) {
    final buttonColor = color ?? (isScientific ? Colors.blueGrey[800] : Colors.grey[900]);
    final textColor = color != null ? Colors.white : Colors.white;
    
    return Container(
      margin: const EdgeInsets.all(2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          minimumSize: Size.zero,
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: fontSize ?? 16,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Display Area
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_lastOperation.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _lastOperation,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      Text(
                        _output,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _isScientificMode ? "SCIENTIFIC MODE" : "STANDARD MODE",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Buttons Area
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      if (_isScientificMode) ...[
                        // Scientific Functions Row 1
                        Expanded(
                          child: Row(
                            children: [
                              _buildButton("sin", isScientific: true, fontSize: 14),
                              _buildButton("cos", isScientific: true, fontSize: 14),
                              _buildButton("tan", isScientific: true, fontSize: 14),
                              _buildButton("π", isScientific: true, fontSize: 14),
                              _buildButton("e", isScientific: true, fontSize: 14),
                            ],
                          ),
                        ),
                        // Scientific Functions Row 2
                        Expanded(
                          child: Row(
                            children: [
                              _buildButton("asin", isScientific: true, fontSize: 14),
                              _buildButton("acos", isScientific: true, fontSize: 14),
                              _buildButton("atan", isScientific: true, fontSize: 14),
                              _buildButton("x^y", isScientific: true, fontSize: 14),
                              _buildButton("n!", isScientific: true, fontSize: 14),
                            ],
                          ),
                        ),
                        // Scientific Functions Row 3
                        Expanded(
                          child: Row(
                            children: [
                              _buildButton("log", isScientific: true, fontSize: 14),
                              _buildButton("ln", isScientific: true, fontSize: 14),
                              _buildButton("10^x", isScientific: true, fontSize: 14),
                              _buildButton("e^x", isScientific: true, fontSize: 14),
                              _buildButton("Rand", isScientific: true, fontSize: 14),
                            ],
                          ),
                        ),
                        // Memory Functions Row
                        Expanded(
                          child: Row(
                            children: [
                              _buildButton("MC", isScientific: true),
                              _buildButton("MR", isScientific: true),
                              _buildButton("M+", isScientific: true),
                              _buildButton("M-", isScientific: true),
                              _buildButton("SCI", color: const Color(0xFF6C63FF)),
                            ],
                          ),
                        ),
                      ],
                      // Standard Calculator Rows
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton("C", color: const Color(0xFF6C63FF)),
                            _buildButton("⌫", color: const Color(0xFF6C63FF)),
                            _buildButton("%", color: const Color(0xFF6C63FF)),
                            _buildButton("÷", color: const Color(0xFF6C63FF)),
                            if (!_isScientificMode) _buildButton("SCI", color: const Color(0xFF6C63FF)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton("7"),
                            _buildButton("8"),
                            _buildButton("9"),
                            _buildButton("×", color: const Color(0xFF6C63FF)),
                            if (_isScientificMode) _buildButton("√", isScientific: true),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton("4"),
                            _buildButton("5"),
                            _buildButton("6"),
                            _buildButton("-", color: const Color(0xFF6C63FF)),
                            if (_isScientificMode) _buildButton("x²", isScientific: true),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton("1"),
                            _buildButton("2"),
                            _buildButton("3"),
                            _buildButton("+", color: const Color(0xFF6C63FF)),
                            if (_isScientificMode) _buildButton("x³", isScientific: true),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton("+/-"),
                            _buildButton("0"),
                            _buildButton("."),
                            _buildButton("=", color: const Color(0xFF6C63FF)),
                            if (_isScientificMode) _buildButton("1/x", isScientific: true),
                          ],
                        ),
                      ),
                    ],
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