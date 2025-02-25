class FiltersConstants {
  static final Map<String, List<double>> filters = {
    'Normal': [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0
    ],
    'Pro Contrast': [
      1.1,
      0,
      0,
      0,
      0,
      0,
      1.1,
      0,
      0,
      0,
      0,
      0,
      1.1,
      0,
      -0.1,
      0,
      0,
      0,
      1,
      0
    ],
    'Cinematic': [
      1.1,
      -0.1,
      0.1,
      0,
      0,
      0.1,
      1.1,
      -0.1,
      0,
      0,
      0.05,
      -0.1,
      1.1,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ],
    'Cross Process': [
      1,
      0.2,
      0.1,
      0,
      0,
      0.2,
      1.1,
      0,
      0,
      -0.1,
      0.1,
      0.2,
      1,
      0,
      0.1,
      0,
      0,
      0,
      1,
      0
    ],
    'Bleached': [
      1.4,
      -0.1,
      -0.1,
      0,
      0,
      -0.1,
      1.3,
      -0.1,
      0,
      0,
      -0.1,
      -0.1,
      1.2,
      0,
      0.2,
      0,
      0,
      0,
      1,
      0
    ],
    'B&W': [
      0.33,
      0.33,
      0.33,
      0,
      0,
      0.33,
      0.33,
      0.33,
      0,
      0,
      0.33,
      0.33,
      0.33,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ],
    'Vintage': [
      0.9, 0.5, 0.1, 0, 0, //
      0.3, 0.8, 0.1, 0, 0, //
      0.2, 0.3, 0.5, 0, 0, //
      0, 0, 0, 1, 0
    ],
    'Dramatic': [
      1.2, -0.1, -0.1, 0, 0, //
      -0.1, 1.2, -0.1, 0, 0, //
      -0.1, -0.1, 1.2, 0, 0, //
      0, 0, 0, 1, 0
    ],
    'Cool': [
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0.2,
      0,
      0,
      0,
      0,
      1.2,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
    'Warm': [
      1.2,
      0,
      0,
      0,
      0,
      0,
      1.1,
      0,
      0,
      0,
      0,
      0,
      0.9,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
    // Add more filters...
  };
}
