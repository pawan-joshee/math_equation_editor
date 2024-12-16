// lib/utils/constants.dart
class Constants {
  static const List<String> symbolCategories = [
    'Basic',
    'Letters',
    'Relations',
    'Sets & Logic',
    'Operators',
    'Greek',
    'Functions',
    'Probability',
    'Formulas',
  ];

  static const Map<String, List<String>> symbols = {
    'Basic': [
      // Arithmetic Operators
      '+', '-', '=', r'\neq',

      // Parentheses and Brackets
      '(', ')', '[', ']', r'\{', r'\}',
      r'\langle', r'\rangle',
      r'\lceil', r'\rceil',
      r'\lfloor', r'\rfloor',

      // Spacing and Punctuation
      r'\space', r'\quad',
      ',', '.', ':', r'\%',

      // Multiplication Dots
      r'\cdot', r'\cdots', r'\vdots', r'\ddots',

      // Special Characters
      r'\&', r'\ldots', r'| |', r'\|',

      // Diacritical Marks
      r'\hat{}', r'\check{}', r'\breve{}',
      r'\acute{}', r'\grave{}', r'\tilde{}',
      r'\bar{}', r'\vec{}', r'\dot{}', r'\ddot{}',
    ],
    'Letters': [
      // Latin Letters
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
      'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
      'u', 'v', 'w', 'x', 'y', 'z',

      // Capital Latin Letters
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
      'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
      'U', 'V', 'W', 'X', 'Y', 'Z',

      //  Cursive Handwriting Letters
      r'\mathcal{A}', r'\mathcal{B}', r'\mathcal{C}', r'\mathcal{D}',
      r'\mathcal{E}', r'\mathcal{F}', r'\mathcal{G}', r'\mathcal{H}',
      r'\mathcal{I}', r'\mathcal{J}', r'\mathcal{K}', r'\mathcal{L}',
      r'\mathcal{M}', r'\mathcal{N}', r'\mathcal{O}', r'\mathcal{P}',
      r'\mathcal{Q}', r'\mathcal{R}', r'\mathcal{S}', r'\mathcal{T}',
      r'\mathcal{U}', r'\mathcal{V}', r'\mathcal{W}', r'\mathcal{X}',
      r'\mathcal{Y}', r'\mathcal{Z}',

      //  Fraktur Letters
      r'\mathfrak{A}', r'\mathfrak{B}', r'\mathfrak{C}', r'\mathfrak{D}',
      r'\mathfrak{E}', r'\mathfrak{F}', r'\mathfrak{G}', r'\mathfrak{H}',
      r'\mathfrak{I}', r'\mathfrak{J}', r'\mathfrak{K}', r'\mathfrak{L}',
      r'\mathfrak{M}', r'\mathfrak{N}', r'\mathfrak{O}', r'\mathfrak{P}',
      r'\mathfrak{Q}', r'\mathfrak{R}', r'\mathfrak{S}', r'\mathfrak{T}',
      r'\mathfrak{U}', r'\mathfrak{V}', r'\mathfrak{W}', r'\mathfrak{X}',
      r'\mathfrak{Y}', r'\mathfrak{Z}',

      //  Blackboard Bold Letters
      r'\mathbb{A}', r'\mathbb{B}', r'\mathbb{C}', r'\mathbb{D}',
      r'\mathbb{E}', r'\mathbb{F}', r'\mathbb{G}', r'\mathbb{H}',
      r'\mathbb{I}', r'\mathbb{J}', r'\mathbb{K}', r'\mathbb{L}',
      r'\mathbb{M}', r'\mathbb{N}', r'\mathbb{O}', r'\mathbb{P}',
      r'\mathbb{Q}', r'\mathbb{R}', r'\mathbb{S}', r'\mathbb{T}',
      r'\mathbb{U}', r'\mathbb{V}', r'\mathbb{W}', r'\mathbb{X}',
      r'\mathbb{Y}', r'\mathbb{Z}',

      //  Sans-Serif Letters
      r'\mathsf{A}', r'\mathsf{B}', r'\mathsf{C}', r'\mathsf{D}',
      r'\mathsf{E}', r'\mathsf{F}', r'\mathsf{G}', r'\mathsf{H}',
      r'\mathsf{I}', r'\mathsf{J}', r'\mathsf{K}', r'\mathsf{L}',
      r'\mathsf{M}', r'\mathsf{N}', r'\mathsf{O}', r'\mathsf{P}',
      r'\mathsf{Q}', r'\mathsf{R}', r'\mathsf{S}', r'\mathsf{T}',
      r'\mathsf{U}', r'\mathsf{V}', r'\mathsf{W}', r'\mathsf{X}',
      r'\mathsf{Y}', r'\mathsf{Z}',

      //  Monospace Letters
      r'\mathtt{A}', r'\mathtt{B}', r'\mathtt{C}', r'\mathtt{D}',
      r'\mathtt{E}', r'\mathtt{F}', r'\mathtt{G}', r'\mathtt{H}',
      r'\mathtt{I}', r'\mathtt{J}', r'\mathtt{K}', r'\mathtt{L}',
      r'\mathtt{M}', r'\mathtt{N}', r'\mathtt{O}', r'\mathtt{P}',
      r'\mathtt{Q}', r'\mathtt{R}', r'\mathtt{S}', r'\mathtt{T}',
      r'\mathtt{U}', r'\mathtt{V}', r'\mathtt{W}', r'\mathtt{X}',
      r'\mathtt{Y}', r'\mathtt{Z}',

      // Italic Script or Fancy Script Letters
      r'\mathscr{A}', r'\mathscr{B}', r'\mathscr{C}', r'\mathscr{D}',
      r'\mathscr{E}', r'\mathscr{F}', r'\mathscr{G}', r'\mathscr{H}',
      r'\mathscr{I}', r'\mathscr{J}', r'\mathscr{K}', r'\mathscr{L}',
      r'\mathscr{M}', r'\mathscr{N}', r'\mathscr{O}', r'\mathscr{P}',
      r'\mathscr{Q}', r'\mathscr{R}', r'\mathscr{S}', r'\mathscr{T}',
      r'\mathscr{U}', r'\mathscr{V}', r'\mathscr{W}', r'\mathscr{X}',
      r'\mathscr{Y}', r'\mathscr{Z}',

      //Calligraphy
      r'\mathcal{A}', r'\mathcal{B}', r'\mathcal{C}', r'\mathcal{D}',
      r'\mathcal{E}', r'\mathcal{F}', r'\mathcal{G}', r'\mathcal{H}',
      r'\mathcal{I}', r'\mathcal{J}', r'\mathcal{K}', r'\mathcal{L}',
      r'\mathcal{M}', r'\mathcal{N}', r'\mathcal{O}', r'\mathcal{P}',
      r'\mathcal{Q}', r'\mathcal{R}', r'\mathcal{S}', r'\mathcal{T}',
      r'\mathcal{U}', r'\mathcal{V}', r'\mathcal{W}', r'\mathcal{X}',
      r'\mathcal{Y}', r'\mathcal{Z}',

      //  Bold Letters
      r'\mathbf{A}', r'\mathbf{B}', r'\mathbf{C}', r'\mathbf{D}',
      r'\mathbf{E}', r'\mathbf{F}', r'\mathbf{G}', r'\mathbf{H}',
      r'\mathbf{I}', r'\mathbf{J}', r'\mathbf{K}', r'\mathbf{L}',
      r'\mathbf{M}', r'\mathbf{N}', r'\mathbf{O}', r'\mathbf{P}',
      r'\mathbf{Q}', r'\mathbf{R}', r'\mathbf{S}', r'\mathbf{T}',
      r'\mathbf{U}', r'\mathbf{V}', r'\mathbf{W}', r'\mathbf{X}',
      r'\mathbf{Y}', r'\mathbf{Z}',
    ],
    'Relations': [
      // Basic Comparisons
      '<', '>', r'\leq', r'\geq', r'\ll', r'\gg',

      // Equivalence Relations
      r'\sim', r'\simeq', r'\approx', r'\equiv', r'\cong',
      r'\not\equiv', r'\doteq', r'\propto',

      // Geometric Relations
      r'\parallel', r'\perp', r'\mid', r'\nmid',

      // Order Relations
      r'\prec', r'\succ', r'\preceq', r'\succeq',

      // Set Relations
      r'\subset', r'\supset', r'\subseteq', r'\supseteq',
      r'\subsetneq', r'\supsetneq',

      // Other Relations
      r'\asymp', r'\bowtie', r'\frown', r'\smile',
      r'\vdash', r'\dashv', r'\models',
    ],
    'Sets & Logic': [
      // Set Membership
      r'\in', r'\notin', r'\ni',

      // Set Operations
      r'\subset', r'\supset', r'\subseteq', r'\supseteq',
      r'\emptyset', r'\varnothing', r'\complement',

      // Logic Quantifiers
      r'\forall', r'\exists', r'\nexists',

      // Logic Operators
      r'\neg', r'\lor', r'\land', r'\implies', r'\iff',

      // Arrows and Implications
      r'\to', r'\mapsto', r'\therefore', r'\because',

      // Number Sets
      r'\N', r'\Z', r'\R',

      // Special Sets
      r'\infty', r'\aleph', r'\wp',
    ],
    'Operators': [
      // Basic Operations
      r'\times', r'\div', r'\pm', r'\mp',

      // Special Operators
      r'\ast', r'\star', r'\circ', r'\bullet',

      // Set Operations
      r'\cap', r'\cup', r'\setminus',

      // Calculus Operators
      r'\partial', r'\nabla',

      // Integrals
      r'\int', r'\iint', r'\iiint', r'\oint',

      // Big Operators
      r'\sum', r'\prod', r'\coprod',
      r'\bigoplus', r'\bigotimes', r'\bigcap', r'\bigcup',

      // Arrows
      r'\rightarrow', r'\leftarrow',
      r'\Rightarrow', r'\Leftarrow', r'\Leftrightarrow',
    ],
    'Greek': [
      // Lowercase Common
      r'\alpha', r'\beta', r'\gamma', r'\delta',
      r'\epsilon', r'\varepsilon', r'\theta',
      r'\lambda', r'\mu', r'\nu', r'\pi',
      r'\sigma', r'\tau', r'\phi', r'\psi', r'\omega',

      // Uppercase Common
      r'\Gamma', r'\Delta', r'\Theta', r'\Lambda',
      r'\Pi', r'\Sigma', r'\Phi', r'\Psi', r'\Omega',

      // Additional Letters
      r'\zeta', r'\eta', r'\xi', r'\kappa',
      r'\rho', r'\varrho', r'\chi',
      r'\upsilon', r'\Upsilon',

      //  Bold Greek Letters
      r'\boldsymbol{\alpha}', r'\boldsymbol{\beta}', r'\boldsymbol{\gamma}',
      r'\boldsymbol{\delta}', r'\boldsymbol{\epsilon}',
      r'\boldsymbol{\varepsilon}',
      r'\boldsymbol{\zeta}', r'\boldsymbol{\eta}', r'\boldsymbol{\theta}',
      r'\boldsymbol{\iota}', r'\boldsymbol{\kappa}', r'\boldsymbol{\lambda}',
      r'\boldsymbol{\mu}', r'\boldsymbol{\nu}', r'\boldsymbol{\xi}',
      r'\boldsymbol{\pi}', r'\boldsymbol{\rho}', r'\boldsymbol{\sigma}',
      r'\boldsymbol{\tau}', r'\boldsymbol{\upsilon}', r'\boldsymbol{\phi}',
      r'\boldsymbol{\chi}', r'\boldsymbol{\psi}', r'\boldsymbol{\omega}',
      r'\boldsymbol{\Gamma}', r'\boldsymbol{\Delta}', r'\boldsymbol{\Theta}',
      r'\boldsymbol{\Lambda}', r'\boldsymbol{\Xi}', r'\boldsymbol{\Pi}',
      r'\boldsymbol{\Sigma}', r'\boldsymbol{\Upsilon}', r'\boldsymbol{\Phi}',
      r'\boldsymbol{\Psi}', r'\boldsymbol{\Omega}',
    ],
    'Functions': [
      // Trigonometric
      r'\sin', r'\cos', r'\tan',
      r'\csc', r'\sec', r'\cot',

      // Inverse Trigonometric
      r'\arcsin', r'\arccos', r'\arctan',

      // Hyperbolic
      r'\sinh', r'\cosh', r'\tanh',

      // Logarithmic and Exponential
      r'\ln', r'\log', r'\exp',

      // Limits and Bounds
      r'\lim_{n \to \infty}', r'\max', r'\min',
      r'\sup', r'\inf',

      // Linear Algebra
      r'\det', r'\deg', r'\dim', r'\ker',

      // Other Functions
      r'\Pr', r'\gcd', r'\forall', r'\exists',
      r'\nabla', r'\partial',
    ],
    'Probability': [
      // Basic Probability
      r'\mathbb{P}', r'\mathbb{E}',

      // Statistical Measures
      r'\mathrm{Var}', r'\mathrm{Cov}', r'\mathrm{Corr}',

      // Common Distributions
      r'\mathrm{Normal}', r'\mathrm{Binomial}', r'\mathrm{Poisson}',
      r'\mathrm{Beta}', r'\mathrm{Gamma}', r'\mathrm{Exponential}',

      // Advanced Distributions
      r'\mathrm{Chi-Squared}', r'\mathrm{F}',
      r'\mathrm{Student}', r'\mathrm{Uniform}',
      r'\mathrm{Geometric}', r'\mathrm{Hypergeometric}',
      r'\mathrm{Logistic}', r'\mathrm{Lognormal}',
      r'\mathrm{Negative Binomial}',
      r'\mathrm{Weibull}', r'\mathrm{Zipf}',
    ],
    'Formulas': [
      // Classical Physics
      r'F = ma', // Newton's second law
      r'F = G \frac{m_1 m_2}{r^2}', // Newton's law of gravitation
      r'W = \int \vec{F} \cdot d\vec{r}', // Work done by force
      r'KE = \frac{1}{2} m v^2', // Kinetic energy
      r'PE = m g h', // Gravitational potential energy

      // Modern Physics
      r'E = mc^2', // Einstein's mass-energy equivalence
      r'E = h \nu', // Planck's energy-frequency relation
      r'p = \frac{h}{2\pi}', // De Broglie wavelength

      // Thermodynamics
      r'PV = nRT', // Ideal gas law
      r'\Delta S \geq 0', // Second law of thermodynamics

      // Kinematics
      r'v = v_0 + at', // Velocity-time equation
      r's = ut + \frac{1}{2}at^2', // Position-time equation

      // Calculus Fundamentals
      r'\int e^x dx = e^x + C', // Exponential integral
      r'\frac{d}{dx}(e^x) = e^x', // Exponential derivative
      r'\int \frac{1}{x} dx = \ln|x| + C', // Natural log integral

      // Algebra
      r'x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}', // Quadratic formula
      r'\sum_{i=1}^{n} i = \frac{n(n+1)}{2}', // Sum of first n natural numbers
      r'e^{i\pi} + 1 = 0', // Euler's identity

      // Geometry - 2D
      r'A = \pi r^2', // Circle area
      r'C = 2 \pi r', // Circle circumference
      r'A = \frac{1}{2} b h', // Triangle area
      r'A_{triangle} = \frac{1}{2}bc\sin(A)', // Triangle area using sine

      // Geometry - 3D
      r'V = l w h', // Rectangular prism volume
      r'SA = 4 \pi r^2', // Sphere surface area
      r'V = \frac{4}{3} \pi r^3', // Sphere volume

      // Trigonometry
      r'\cos(C) = \frac{a^2 + b^2 - c^2}{2ab}', // Law of cosines

      // Common Mathematical Templates
      r'\frac{a}{b}', // Basic fraction
      r'\sqrt{x}', // Square root
      r'\sqrt[n]{x}', // nth root
      r'\sqrt[n]{\frac{a}{b}}', // Complex fraction with root

      // Operation Templates
      r'\frac{a}{b} \pm \frac{c}{d}', // Fraction operations
      r'\sqrt[n]{a} \pm \sqrt[n]{b}', // Root operations
      r'\sqrt[n]{a^2} \pm \sqrt[n]{b^2}' // Power-root operations
    ]
  };

  static const Map<String, String> symbolDescriptions = {
    '+': 'Addition',
    '-': 'Subtraction',
    '=': 'Equals',
    r'\neq': 'Not Equal',
    r'\alpha': 'Alpha',
    r'\beta': 'Beta',
    r'\gamma': 'Gamma',
    r'\delta': 'Delta',
    r'\pi': 'Pi',
    r'\sum': 'Summation',
    r'\int': 'Integral',
    r'\infty': 'Infinity',
    r'\rightarrow': 'Right Arrow',
    r'\Rightarrow': 'Implies',
    r'\sin': 'Sine Function',
    r'\cos': 'Cosine Function',
    r'\tan': 'Tangent Function',
    // Add more descriptions as needed
  };
}
