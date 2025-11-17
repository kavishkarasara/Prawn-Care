import 'package:flutter/material.dart';

class ConditionIcons {
  static Widget buildWaterLevelIcon() {
    return Stack(
      children: [
        SizedBox(
          width: 40,
          height: 50,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  width: 15,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.yellow[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Positioned(
                right: 5,
                bottom: 35,
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildOxygenIcon() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          const Icon(
            Icons.water_drop,
            size: 30,
            color: Colors.blue,
          ),
          const Positioned(
            right: 8,
            top: 8,
            child: Text(
              'O₂',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 5,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 5,
            bottom: 5,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildAmmoniaIcon() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'N',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 5,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'H',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 5,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'H',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'H',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPhIcon() {
    return const SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          Icon(
            Icons.water_drop,
            size: 30,
            color: Colors.blue,
          ),
          Positioned(
            right: 6,
            top: 8,
            child: Text(
              'PH',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 5,
            top: 0,
            child: Icon(
              Icons.arrow_upward,
              size: 12,
              color: Colors.blue,
            ),
          ),
          Positioned(
            right: 2,
            top: 0,
            child: Icon(
              Icons.arrow_upward,
              size: 12,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildTemperatureIcon() {
    return const SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          Icon(
            Icons.thermostat,
            size: 30,
            color: Colors.red,
          ),
          Positioned(
            right: 5,
            top: 8,
            child: Text(
              '°C',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
