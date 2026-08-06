# MathForge

> A native desktop mathematics visualizer that grows with the subjects I am studying.

**Working name:** Locus 
**Current target:** a useful Calculus II function plotter  
**Later targets:** multivariable calculus, linear algebra visualization, and mathematical modeling  
**Interface:** local desktop application only

---

## 1. Project vision

Locus is a gradual, open-source mathematics visualization project for students.

The first useful version will:

- read a mathematical function typed by the user;
- draw an interactive 2D graph;
- determine or estimate its domain and image;
- calculate roots, derivatives, critical points, and asymptotes;
- clearly distinguish exact symbolic results from numerical estimates.

Later versions will add:

- domains and level curves for functions of two variables;
- 3D surfaces and parametric curves;
- limits along multiple paths;
- vectors, matrices, bases, and linear transformations;
- eigenvectors, kernels, images, and geometric interpretations;
- regression, interpolation, optimization, differential equations, and phase portraits.

The project should be useful after the first few development sessions. It should not require implementing an entire computer algebra system or a 3D graphics engine before showing its first graph.

---

## 2. Main design decision

MathForge begins as a **Python desktop application with a C++ numerical extension**.

### Python owns

- the native desktop interface;
- expression parsing and validation;
- symbolic mathematics;
- coordination between modules;
- construction of plot data;
- explanations shown to the user;
- the initial reference implementation of every algorithm.

### C++ owns later

- adaptive sampling;
- discontinuity-aware subdivision;
- marching squares for implicit curves;
- geometry-heavy transformations;
- performance-critical numerical algorithms;
- algorithms that are useful to implement in C++ for learning.

### Why not begin with the entire application in C++?

A C++-first GUI plus an embedded Python interpreter would require learning all of these at once:

- Qt/C++ application architecture;
- CMake;
- Python embedding;
- object conversion between Python and C++;
- memory ownership across two languages;
- symbolic-library integration;
- graphics and plotting.

That complexity delays the first useful version.

The recommended order is:

```text
working Python desktop app
        ↓
well-tested numerical algorithm in Python
        ↓
equivalent C++ implementation
        ↓
pybind11 binding
        ↓
benchmark and choose the faster implementation
```

---

## 3. Technology stack

### Core dependencies

| Purpose | Library or tool | When introduced |
|---|---|---|
| Desktop window and controls | PySide6 / Qt Widgets | Immediately |
| Interactive 2D plotting | pyqtgraph | Immediately |
| Array calculations | NumPy | Immediately |
| Symbolic mathematics | SymPy | Immediately |
| Expression grammar | Lark | First plotting milestone |
| Unit testing | pytest | Immediately |
| Qt interface testing | pytest-qt | Immediately |
| Property-based testing | Hypothesis | After basic tests |
| Formatting and linting | Ruff | Immediately |
| Static type checking | mypy | Early |
| 3D viewport | pyqtgraph.opengl + PyOpenGL | Multivariable phase |
| Scientific algorithms | SciPy | Modeling phase |
| C++ build system | CMake | C++ phase |
| Python/C++ bindings | pybind11 | C++ phase |
| Mixed Python/C++ packaging | scikit-build-core | C++ phase |
| C++ linear algebra | Eigen | Linear algebra/C++ phase |
| C++ tests | Catch2 | C++ phase |
| Desktop executable | pyside6-deploy | Distribution phase |

### Optional later replacement for advanced 3D

If pyqtgraph's OpenGL layer becomes too limited for meshes, volumes, isosurfaces, or advanced streamlines, the 3D tab can later use **PyVistaQt**. Do not add it to the first versions.

---

## 4. Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                     PySide6 desktop UI                      │
│  input field · buttons · tabs · settings · result panels   │
└──────────────────────────────┬──────────────────────────────┘
                               │ FunctionRequest
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                         Services                            │
│ analyze_function · build_plot · analyze_matrix · save_file │
└───────────────┬───────────────────┬─────────────────────────┘
                │                   │
                ▼                   ▼
┌────────────────────────┐  ┌───────────────────────────────┐
│ Parsing and symbolic   │  │ Numerical computation         │
│ normalization          │  │ compile expression            │
│ grammar and AST        │  │ sample points and grids       │
│ domain and image       │  │ masks and discontinuities     │
│ derivatives and roots  │  │ Python fallback / C++ kernel  │
└───────────────┬────────┘  └───────────────┬───────────────┘
                │                           │
                └──────────────┬────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Plot adapters                          │
│  pyqtgraph 2D · pyqtgraph OpenGL 3D · future PyVistaQt     │
└─────────────────────────────────────────────────────────────┘
```

The interface must not perform mathematics directly.

A button click should call a service. The service calls the parser, symbolic analyzer, numerical sampler, and plot adapter.

---

## 5. Initial repository structure

Do not create fifty empty files on day one. Begin with this:

```text
mathforge/
├── README.md
├── pyproject.toml
├── src/
│   └── mathforge/
│       ├── __init__.py
│       ├── __main__.py
│       ├── app.py
│       ├── models.py
│       ├── parser.py
│       ├── analysis.py
│       ├── sampling.py
│       ├── plotting.py
│       └── main_window.py
└── tests/
    ├── test_parser.py
    ├── test_analysis.py
    └── test_sampling.py
```

Expand only when the files become difficult to understand:

```text
mathforge/
├── README.md
├── ROADMAP.md
├── pyproject.toml
├── assets/
│   ├── icons/
│   └── examples/
├── presets/
│   ├── calculus_ii.json
│   ├── linear_algebra.json
│   └── modeling.json
├── src/
│   └── mathforge/
│       ├── __init__.py
│       ├── __main__.py
│       ├── app.py
│       │
│       ├── core/
│       │   ├── models.py
│       │   ├── errors.py
│       │   ├── certainty.py
│       │   └── settings.py
│       │
│       ├── parsing/
│       │   ├── normalization.py
│       │   ├── grammar.lark
│       │   ├── ast_nodes.py
│       │   ├── parser.py
│       │   └── sympy_builder.py
│       │
│       ├── symbolic/
│       │   ├── domain.py
│       │   ├── image.py
│       │   ├── roots.py
│       │   ├── derivatives.py
│       │   ├── critical_points.py
│       │   ├── asymptotes.py
│       │   ├── limits.py
│       │   └── linear_algebra.py
│       │
│       ├── numeric/
│       │   ├── compiler.py
│       │   ├── sampling_1d.py
│       │   ├── grids.py
│       │   ├── masks.py
│       │   ├── discontinuities.py
│       │   └── fallback.py
│       │
│       ├── visualization/
│       │   ├── plot_1d.py
│       │   ├── domains_2d.py
│       │   ├── contours.py
│       │   ├── surfaces.py
│       │   ├── parametric.py
│       │   ├── vectors.py
│       │   └── transformations.py
│       │
│       ├── services/
│       │   ├── analyze_function.py
│       │   ├── build_plot.py
│       │   ├── analyze_matrix.py
│       │   └── project_files.py
│       │
│       └── ui/
│           ├── main_window.py
│           ├── function_tab.py
│           ├── linear_algebra_tab.py
│           ├── modeling_tab.py
│           ├── result_panel.py
│           └── controllers.py
│
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── regression/
│   └── fixtures/
│
└── cpp/
    ├── CMakeLists.txt
    ├── include/
    │   └── mathforge_core/
    │       ├── adaptive_sampler.hpp
    │       └── marching_squares.hpp
    ├── src/
    │   ├── adaptive_sampler.cpp
    │   └── marching_squares.cpp
    ├── bindings/
    │   └── module.cpp
    └── tests/
        ├── test_adaptive_sampler.cpp
        └── test_marching_squares.cpp
```

---

## 6. Responsibilities by module

| Module | Contains | Must not contain |
|---|---|---|
| `ui` | Windows, widgets, layouts, signals, slots, displayed text | SymPy rules or numerical algorithms |
| `services` | Complete user operations and module coordination | Widget-specific code |
| `parsing` | Text normalization, grammar, AST, validated expression construction | Plotting |
| `symbolic` | Exact mathematical analysis | Qt widgets or large numerical grids |
| `numeric` | Compiled callables, samples, masks, approximations | User-interface layouts |
| `visualization` | Conversion from mathematical data to graphical items | Parsing or domain rules |
| `core` | Dataclasses, enums, shared errors, settings | Heavy algorithms |
| `cpp` | Isolated measured kernels | Desktop interface or symbolic mathematics |

---

# 7. Exact development sequence

Each step should end with something visible, testable, or reusable.

---

## Step 0 — Install the tools

### Study

- basic Python modules and virtual environments;
- Git basics;
- very basic CMake terminology, but do not write C++ bindings yet.

### Install

- Python 3.11 or newer;
- Git;
- `uv`;
- a C++20 compiler;
- CMake;
- Ninja, if available.

### Create the project

```bash
uv init --package mathforge
cd mathforge

uv add pyside6 pyqtgraph numpy sympy lark
uv add --dev pytest pytest-qt hypothesis ruff mypy
```

### Done when

```bash
uv run python -c "import PySide6, pyqtgraph, numpy, sympy, lark"
uv run pytest
```

both run successfully.

---

## Step 1 — Create the native desktop shell

This is not the function parser yet. It proves that the desktop application opens correctly.

### Libraries

- PySide6

### Files

```text
src/mathforge/__main__.py
src/mathforge/app.py
src/mathforge/main_window.py
```

### Implement

A `QApplication`, one `QMainWindow`, and a layout containing:

```text
Function: [__________________________] [Plot]
x minimum: [ -10 ]   x maximum: [ 10 ]

┌─────────────────────────────────────────────┐
│               empty plot area               │
└─────────────────────────────────────────────┘

Results:
No function analyzed yet.
```

Use Qt Widgets, not QML, for the first version.

### Done when

```bash
uv run python -m mathforge
```

opens a real desktop window.

---

## Step 2 — Define the application's data models

Before reading expressions, decide how data moves through the application.

### Libraries

- Python standard library: `dataclasses`, `enum`, and typing

### File

```text
src/mathforge/models.py
```

### Implement

```python
@dataclass(frozen=True)
class Viewport1D:
    x_min: float
    x_max: float
    sample_count: int = 2000


@dataclass(frozen=True)
class FunctionRequest:
    source: str
    variables: tuple[str, ...]
    viewport: Viewport1D


class Certainty(Enum):
    EXACT = "exact"
    NUMERIC_ESTIMATE = "numeric_estimate"
    UNKNOWN = "unknown"


@dataclass(frozen=True)
class AnalysisResult:
    normalized_expression: str
    domain_text: str
    image_text: str
    certainty: Certainty
    warnings: tuple[str, ...]
```

### Done when

The UI can create a `FunctionRequest` without performing any mathematics.

---

## Step 3 — Implement the function reader

The **function reader** reads the complete request from the interface.

It does not yet understand mathematical syntax.

### Libraries

- PySide6
- standard library

### Files

```text
src/mathforge/ui/controllers.py
src/mathforge/services/analyze_function.py
```

### Implement

Read:

- expression text;
- variable selection;
- viewport bounds;
- sample count.

Validate simple interface rules:

- expression is not empty;
- minimum is less than maximum;
- sample count is within a safe limit;
- expression length is below a chosen maximum.

### Output

```python
FunctionRequest(
    source="sin(x) / x",
    variables=("x",),
    viewport=Viewport1D(-10.0, 10.0, 2000),
)
```

### Done when

Pressing **Plot** prints or logs a valid `FunctionRequest`.

---

## Step 4 — Normalize mathematical input

Normalization makes common classroom notation consistent.

### Libraries

- standard library only

### File

```text
src/mathforge/parsing/normalization.py
```

### Initially support

```text
^       → **
sen     → sin
tg      → tan
ln      → log
π       → pi
√(...)  → sqrt(...)
```

Do not try to normalize every possible notation.

### Important rule

Normalization is not validation. It only rewrites known forms.

### Tests

```text
x^2          -> x**2
sen(x)       -> sin(x)
ln(x)        -> log(x)
2π           -> either reject clearly or normalize intentionally
```

Choose and document whether implicit multiplication is supported. It is acceptable to reject `2x` in the first version and require `2*x`.

---

## Step 5 — Implement the expression parser

The parser converts text into a syntax tree. It must not execute the text as Python.

### Libraries

- Lark

### Files

```text
src/mathforge/parsing/grammar.lark
src/mathforge/parsing/ast_nodes.py
src/mathforge/parsing/parser.py
```

### First grammar

Support only:

```text
numbers
variables: x
constants: pi, e
operators: +, -, *, /, **
parentheses
functions: sin, cos, tan, exp, log, sqrt, abs
```

### Example AST

```text
sin(x) / x
```

becomes conceptually:

```text
Divide(
    FunctionCall("sin", Variable("x")),
    Variable("x"),
)
```

### Reject

- assignments;
- attribute access;
- indexing;
- imports;
- arbitrary function names;
- strings;
- Python statements;
- excessively deep expressions.

### Done when

The parser accepts:

```text
x**2
sin(x)
sqrt(x - 1)
x / (x - 2)
```

and returns readable errors for malformed expressions.

---

## Step 6 — Convert the AST into a SymPy expression

The parser's AST is your trusted representation. Now create SymPy objects manually.

### Libraries

- SymPy

### File

```text
src/mathforge/parsing/sympy_builder.py
```

### Implement mappings

```text
Variable("x")       -> sympy.Symbol("x", real=True)
FunctionCall("sin") -> sympy.sin
FunctionCall("log") -> sympy.log
Power(a, b)         -> a ** b
```

Use an explicit allowlist.

Do not send raw user text directly to an unrestricted SymPy parser.

### Done when

```text
"x^2 + sin(x)"
```

becomes a valid SymPy expression equivalent to:

```python
x**2 + sin(x)
```

---

## Step 7 — Compile the symbolic expression for numerical evaluation

A symbolic expression is excellent for analysis but too slow to evaluate one point at a time for plotting.

### Libraries

- SymPy
- NumPy

### File

```text
src/mathforge/numeric/compiler.py
```

### Implement

After the expression has been validated and constructed safely:

```python
numeric_function = sympy.lambdify(
    [x],
    expression,
    modules="numpy",
)
```

Wrap it in your own class:

```python
@dataclass
class CompiledFunction:
    variables: tuple[str, ...]
    callable: Callable[..., np.ndarray]
```

### Done when

The compiled function accepts a NumPy array and returns values for:

```text
x**2
sin(x)
sqrt(x - 1)
1 / x
```

---

## Step 8 — Implement uniform 1D sampling

### Libraries

- NumPy

### File

```text
src/mathforge/numeric/sampling_1d.py
```

### Implement

1. Generate x-values with `numpy.linspace`.
2. Evaluate the compiled function.
3. Convert output to a NumPy array.
4. Replace complex, infinite, or invalid values with `NaN`.
5. Return a structured result.

```python
@dataclass(frozen=True)
class SampledCurve:
    x: np.ndarray
    y: np.ndarray
    valid: np.ndarray
```

Use:

```python
with np.errstate(all="ignore"):
    y = function(x)

valid = np.isfinite(y) & np.isreal(y)
```

### Done when

Sampling never crashes the application for ordinary invalid points.

---

## Step 9 — Split curves at discontinuities

A naive plotter draws a vertical line across the asymptote of `1/x`. Fix that before adding advanced mathematics.

### Libraries

- NumPy

### File

```text
src/mathforge/numeric/discontinuities.py
```

### First rules

Break the line when:

- either endpoint is invalid;
- the difference in y-values is much larger than the visible y-scale;
- a symbolic singularity lies between two samples;
- the function changes from a very large positive value to a very large negative value.

Insert `NaN` between disconnected segments.

### Test functions

```text
1/x
tan(x)
1/(x - 2)
sin(x)/x
```

### Done when

The graph does not connect opposite sides of a singularity.

---

## Step 10 — Draw the first real graph

### Libraries

- pyqtgraph
- PySide6

### Files

```text
src/mathforge/visualization/plot_1d.py
src/mathforge/main_window.py
```

### Implement

Use `pyqtgraph.PlotWidget`.

Add:

- x and y axes;
- grid;
- mouse zoom;
- mouse pan;
- auto-range;
- curve label;
- reset-view button.

### Done when

Typing:

```text
sin(x) / x
```

and clicking **Plot** displays an interactive desktop graph.

This is the first real MVP.

---

## Step 11 — Connect the complete request pipeline

### Libraries

No new library.

### Files

```text
src/mathforge/services/analyze_function.py
src/mathforge/ui/controllers.py
```

### Pipeline

```text
button click
→ FunctionRequest
→ normalize
→ parse
→ build SymPy expression
→ compile
→ sample
→ split discontinuities
→ build plot
→ update results panel
```

Catch your own exception types:

```text
InputError
NormalizationError
ParseError
UnsupportedExpressionError
AnalysisError
SamplingError
```

Never show a Python traceback to normal users.

---

## Step 12 — Add regression tests for the first MVP

### Libraries

- pytest
- pytest-qt
- Hypothesis later

### Tests

| Expression | Expected behavior |
|---|---|
| `x**2` | valid everywhere in the selected interval |
| `1/x` | invalid at zero and visually split |
| `sqrt(x-1)` | invalid for `x < 1` |
| `sin(x)/x` | hole at zero |
| `log(x)` | invalid for `x <= 0` |
| `tan(x)` | split near odd multiples of `pi/2` |

### Done when

A bug fix can be protected by a test before changing the code.

---

# 8. Calculus I and II analysis sequence

Do not implement every analysis feature at once. Add them in this order.

---

## Step 13 — Determine the 1D domain

### Libraries

- SymPy
- your own restriction walker

### File

```text
src/mathforge/symbolic/domain.py
```

### Strategy

First accumulate obvious restrictions yourself:

| Expression | Restriction |
|---|---|
| `a / b` | `b != 0` |
| `sqrt(a)` | `a >= 0` |
| `1 / sqrt(a)` | `a > 0` |
| `log(a)` | `a > 0` |
| `asin(a)` | `-1 <= a <= 1` |
| `acos(a)` | `-1 <= a <= 1` |

Then attempt SymPy's continuity/domain tools.

Return a structured result:

```python
DomainResult(
    exact_set=...,
    predicate=...,
    certainty=Certainty.EXACT,
    warnings=(),
)
```

### Display examples

```text
Domain: ℝ
Domain: ℝ \ {0}
Domain: [1, ∞)
Domain: could not be determined exactly
```

---

## Step 14 — Add roots and intercepts

### Libraries

- SymPy

### File

```text
src/mathforge/symbolic/roots.py
```

### Implement

- x-axis intersections;
- y-axis intersection;
- exact roots when possible;
- numerical roots in the visible interval as fallback.

Label exact and numerical roots differently.

---

## Step 15 — Add derivatives and tangent lines

### Libraries

- SymPy
- NumPy
- pyqtgraph

### File

```text
src/mathforge/symbolic/derivatives.py
```

### Implement

- symbolic first derivative;
- optional second derivative;
- tangent line at a selected x-value;
- derivative curve toggle.

The user should be able to click or type a point and see:

```text
f(a)
f'(a)
tangent equation
```

---

## Step 16 — Add critical points and monotonicity

### Libraries

- SymPy

### File

```text
src/mathforge/symbolic/critical_points.py
```

### Implement

- solve `f'(x) = 0`;
- include derivative undefined points;
- classify local maxima/minima when possible;
- determine increasing/decreasing intervals when possible.

Do not claim a numerical sample proves global behavior.

---

## Step 17 — Add discontinuities and asymptotes

### Libraries

- SymPy
- NumPy

### File

```text
src/mathforge/symbolic/asymptotes.py
```

### Implement gradually

1. vertical asymptotes from singularities and one-sided limits;
2. horizontal asymptotes from limits at infinity;
3. oblique asymptotes;
4. removable discontinuities.

Show a dashed line for confirmed asymptotes.

---

## Step 18 — Add image/range analysis

### Libraries

- SymPy
- NumPy

### File

```text
src/mathforge/symbolic/image.py
```

### Result levels

1. exact symbolic image;
2. exact result under documented assumptions;
3. numerical values observed in the visible interval;
4. unknown.

### Display correctly

Good:

```text
Image: [0, ∞) — exact
```

Good:

```text
Image not determined symbolically.
Observed values in x ∈ [-10, 10]: approximately [-0.217, 1.000].
```

Bad:

```text
Image: [-0.217, 1.000]
```

when that interval is only from the current viewport.

---

## Step 19 — Support multiple functions

### Libraries

No new library.

### Implement

A function list:

```text
☑ f(x) = sin(x)
☑ g(x) = cos(x)
☐ h(x) = tan(x)
```

Each function stores:

- expression;
- visibility;
- line style;
- viewport-independent analysis;
- cached samples for the current viewport.

---

## Step 20 — Save, load, and export

### Libraries

- standard library `json`
- PySide6 file dialogs
- pyqtgraph exporters

### Implement

- save project as JSON;
- load project;
- export PNG;
- export sampled points as CSV;
- copy analysis text.

Do not use pickle for files shared with classmates.

---

# 9. Multivariable Calculus II sequence

The uploaded Calculus II material makes functions of two variables, domains, level curves, surfaces, parametrized curves, limits, and continuity high-priority features.

---

## Step 21 — Generalize the parser to multiple variables

### Libraries

- Lark
- SymPy

### Support

```text
x, y
u, v
x, y, z
t
```

A `FunctionRequest` must explicitly declare its variables.

Reject unknown identifiers instead of silently creating new symbols.

---

## Step 22 — Build a multivariable domain predicate

### Libraries

- SymPy

### File

```text
src/mathforge/symbolic/domain.py
```

### Examples

```text
f(x,y) = x*y/(x - 2*y)
domain predicate:
x - 2*y != 0
```

```text
f(x,y) = log(2*x**2 + y**2 - 1)
domain predicate:
2*x**2 + y**2 - 1 > 0
```

The first goal is a correct predicate, not a beautiful closed-form set.

---

## Step 23 — Build 2D numerical grids and masks

### Libraries

- NumPy

### Files

```text
src/mathforge/numeric/grids.py
src/mathforge/numeric/masks.py
```

### Implement

```python
x = np.linspace(x_min, x_max, resolution)
y = np.linspace(y_min, y_max, resolution)
X, Y = np.meshgrid(x, y)

valid = domain_function(X, Y)
Z = function(X, Y)
Z = np.where(valid & np.isfinite(Z), Z, np.nan)
```

Limit the initial resolution to keep the interface responsive.

---

## Step 24 — Visualize 2D domains

### Libraries

- pyqtgraph

### File

```text
src/mathforge/visualization/domains_2d.py
```

### Implement

- shaded valid region;
- invalid region;
- boundary curves;
- axes and equal aspect ratio;
- cursor coordinates.

This directly helps with multivariable-domain exercises.

---

## Step 25 — Add level curves

### Libraries

- pyqtgraph
- NumPy

### File

```text
src/mathforge/visualization/contours.py
```

Use image data plus isocurve items.

Allow:

- automatic levels;
- user-entered level `k`;
- multiple level curves;
- optional labels;
- cross-section lines.

---

## Step 26 — Add 3D surfaces

### Libraries

- `pyqtgraph.opengl`
- PyOpenGL
- NumPy

### File

```text
src/mathforge/visualization/surfaces.py
```

Install when this step begins:

```bash
uv add pyopengl
```

Use:

- `GLViewWidget`;
- axis and grid items;
- surface plot item;
- mouse rotation and zoom.

Begin only with explicit surfaces:

```text
z = f(x, y)
```

Do not begin with arbitrary implicit 3D surfaces.

---

## Step 27 — Add parametrized curves

### Libraries

- SymPy
- NumPy
- pyqtgraph
- pyqtgraph.opengl

### File

```text
src/mathforge/visualization/parametric.py
```

Support:

```text
r(t) = (x(t), y(t))
r(t) = (x(t), y(t), z(t))
```

Add:

- t minimum and maximum;
- moving point slider;
- tangent vector;
- animation later.

---

## Step 28 — Build a path-based limit explorer

### Libraries

- SymPy
- NumPy
- pyqtgraph

### File

```text
src/mathforge/symbolic/limits.py
```

Test paths such as:

```text
y = m*x
y = x**2
y = k*x**2
x = r*cos(theta), y = r*sin(theta)
```

Correct messaging:

```text
Different tested paths produced different limits.
Therefore, the multivariable limit does not exist.
```

Also correct:

```text
All tested paths approached 0 numerically.
This is evidence, not a proof that the limit exists.
```

---

## Step 29 — Add gradient and directional derivatives

### Libraries

- SymPy
- NumPy
- pyqtgraph

### Implement

- partial derivatives;
- gradient vector;
- directional derivative;
- tangent plane;
- gradient field over a 2D region;
- relationship between gradient and level curves.

---

# 10. Linear algebra sequence

Keep the first linear algebra tools two-dimensional.

---

## Step 30 — Draw vectors in 2D

### Libraries

- NumPy
- pyqtgraph

### File

```text
src/mathforge/visualization/vectors.py
```

Support:

- vector coordinates;
- magnitude;
- direction;
- addition;
- subtraction;
- scalar multiplication;
- dot product;
- projection.

---

## Step 31 — Visualize linear combinations

### Libraries

- NumPy
- pyqtgraph

### Implement

Given vectors `v1` and `v2`, use sliders for:

```text
a*v1 + b*v2
```

Show the reachable line or plane and explain dependence/independence geometrically.

---

## Step 32 — Visualize 2×2 matrix transformations

### Libraries

- NumPy
- pyqtgraph

### File

```text
src/mathforge/visualization/transformations.py
```

Transform:

- the coordinate grid;
- basis vectors;
- the unit square;
- selected vectors.

Show:

- matrix;
- determinant;
- area scale;
- orientation preserved or reversed;
- singular/non-singular status.

---

## Step 33 — Add exact matrix analysis

### Libraries

- SymPy matrices
- NumPy for animation

### File

```text
src/mathforge/symbolic/linear_algebra.py
```

Support:

- row reduction;
- rank;
- determinant;
- inverse;
- null space;
- column space;
- solution sets;
- eigenvalues and eigenvectors.

Use SymPy for exact integer/rational work and NumPy for floating-point animation.

---

## Step 34 — Animate eigenvectors

### Libraries

- NumPy
- SymPy
- pyqtgraph

Show a general vector changing direction under repeated transformation, while an eigenvector keeps its line.

Only after this should you add 3D transformations.

---

# 11. C++ integration sequence

Do not add C++ merely to say the project uses C++.

Add it when a Python algorithm exists, is tested, and has a small interface.

---

## Step 35 — Select the first C++ kernel

Recommended first kernel:

```text
adaptive 1D function sampling
```

It has a clear input and output and directly improves graph quality.

### Python contract

```python
def adaptive_sample(
    function,
    x_min: float,
    x_max: float,
    tolerance: float,
    max_depth: int,
) -> np.ndarray:
    ...
```

### C++ contract

```cpp
std::vector<Point2D> adaptive_sample(
    const std::function<double(double)>& function,
    double x_min,
    double x_max,
    double tolerance,
    int max_depth
);
```

---

## Step 36 — Implement the Python reference version

### Libraries

- NumPy
- pytest

### File

```text
src/mathforge/numeric/adaptive_sampling.py
```

The Python version defines correct behavior and expected edge cases.

Test:

- straight line;
- parabola;
- high-curvature region;
- singularity;
- oscillatory function;
- maximum recursion depth.

---

## Step 37 — Create the C++ library

### Libraries

- C++20
- CMake
- Catch2

### Files

```text
cpp/CMakeLists.txt
cpp/include/mathforge_core/adaptive_sampler.hpp
cpp/src/adaptive_sampler.cpp
cpp/tests/test_adaptive_sampler.cpp
```

Learn:

- `std::vector`;
- structs;
- references;
- `std::function`;
- lambdas;
- RAII;
- CMake targets;
- header/source separation.

Do not use Eigen for this algorithm unless matrices are actually needed.

---

## Step 38 — Bind C++ to Python

### Libraries

- pybind11
- scikit-build-core
- CMake

### File

```text
cpp/bindings/module.cpp
```

Expose:

```python
from mathforge._core import adaptive_sample
```

Keep the public Python API unchanged:

```python
from mathforge.numeric import adaptive_sample
```

The wrapper decides whether to call C++ or the Python fallback.

---

## Step 39 — Compare Python and C++ implementations

### Libraries

- pytest
- NumPy
- a benchmark tool such as `pyperf` or `pytest-benchmark`

### Required checks

- same valid regions;
- same discontinuity behavior;
- numerically close point sets;
- no crashes on invalid input;
- meaningful speed improvement.

Keep the Python implementation even after C++ works.

---

## Step 40 — Add a second C++ kernel only when justified

Good later candidates:

- marching squares;
- polyline simplification;
- large grid transformations;
- vector-field integration;
- geometric clipping;
- custom numerical integration.

Bad early candidates:

- symbolic differentiation;
- symbolic domain solving;
- button handling;
- JSON loading;
- simple matrix multiplication already handled efficiently by NumPy.

---

## Step 41 — Introduce Eigen

### Libraries

- Eigen

Use Eigen when the C++ kernel genuinely works with:

- vectors;
- matrices;
- decompositions;
- transformations;
- geometry.

Possible project:

```text
transform a large point cloud with a matrix
```

Compare it against NumPy before deciding which implementation to use.

---

# 12. Modeling sequence

Begin modeling only after the calculus and linear algebra foundation is reliable.

---

## Step 42 — Import datasets

### Libraries

- standard-library CSV first;
- pandas later if useful.

Support columns selected as:

```text
x data
y data
optional uncertainty
```

---

## Step 43 — Add regression and interpolation

### Libraries

- NumPy
- SciPy

Support:

- linear least squares;
- polynomial regression;
- nonlinear least squares;
- cubic splines;
- residual plot;
- goodness-of-fit metrics.

---

## Step 44 — Add numerical optimization

### Libraries

- SciPy

Visualize:

- objective function;
- current point;
- gradient direction;
- optimization path;
- local minima;
- effect of initial conditions.

---

## Step 45 — Add ordinary differential equations

### Libraries

- SciPy
- NumPy
- pyqtgraph

Support:

- first-order initial-value problems;
- systems of ODEs;
- solution curves;
- direction fields;
- phase portraits;
- parameter sliders.

---

## Step 46 — Add vector fields and trajectories

### Libraries

- NumPy
- SciPy
- pyqtgraph
- optional PyVistaQt later

Begin in 2D with arrows and particle trajectories. Add advanced 3D streamlines only when needed.

---

# 13. Distribution to classmates

## Step 47 — Create a desktop executable

### Library/tool

- `pyside6-deploy`

### Goal

A classmate should be able to open MathForge without:

- installing Python;
- opening a terminal;
- starting a server;
- opening a browser.

Build separately on each target operating system.

Example:

```bash
pyside6-deploy src/mathforge/__main__.py
```

Test the produced application on a clean machine or virtual machine.

---

# 14. First seven development sessions

This is the shortest path to a useful result.

## Session 1

- create the repository;
- install dependencies;
- open the native PySide6 window;
- embed an empty `PlotWidget`.

## Session 2

- define `FunctionRequest`;
- read the text and viewport from the UI;
- implement normalization.

## Session 3

- write the first Lark grammar;
- parse numbers, `x`, arithmetic, and parentheses;
- convert the AST to SymPy.

## Session 4

- add `sin`, `cos`, `tan`, `sqrt`, `log`, and `exp`;
- compile the expression with `lambdify`;
- sample with NumPy.

## Session 5

- draw the graph;
- show parse errors inside the UI;
- support zoom, pan, and reset.

## Session 6

- mask invalid values;
- split `1/x`, `tan(x)`, and `sin(x)/x` correctly;
- add regression tests.

## Session 7

- display domain;
- display derivative;
- display roots;
- package an early version for one classmate to test.

At the end of Session 5 the application is already useful.

---

# 15. Initial supported syntax

The first parser should support a small documented language.

```text
Variables:
x

Constants:
pi
e

Operators:
+
-
*
/
**
^

Functions:
sin
cos
tan
exp
log
ln
sqrt
abs
```

Examples:

```text
x^2
sin(x)
sin(x)/x
sqrt(x - 1)
log(x)
exp(-x^2)
1/(x - 2)
```

Initially rejected:

```text
2x
sin x
f(x) = x^2
x = 3
unknown_function(x)
import os
```

Later versions may intentionally support implicit multiplication and equation-style input.

---

# 16. Mathematical reliability rules

MathForge must clearly label what it knows.

## Exact

```text
Domain: [1, ∞) — exact
```

## Exact under assumptions

```text
Image: [0, ∞), assuming x is real
```

## Numerical estimate

```text
Observed values in the current viewport:
approximately [-2.1, 8.7]
```

## Unknown

```text
The image could not be determined symbolically.
```

Rules:

1. Never call viewport samples the complete image.
2. Never claim tested paths prove a multivariable limit exists.
3. Never connect graph segments across confirmed singularities.
4. Never execute raw expression input as Python.
5. Unknown is better than confidently wrong.
6. Preserve symbolic results when possible.
7. Display assumptions.
8. Add regression tests for every mathematical bug.

---

# 17. Performance rules

Do not optimize before measuring.

Initial limits:

```text
maximum expression length: 500 characters
maximum AST depth: 100
maximum 1D samples: 100,000
default 1D samples: 2,000
default 2D grid: 250 × 250
maximum initial 2D grid: 600 × 600
maximum visible functions: 20
```

Later:

- cache parsed expressions;
- cache symbolic results;
- recompute samples only when the viewport changes;
- move expensive work to a Qt worker thread;
- add cancellation;
- add timeouts for symbolic analysis;
- use C++ only for measured bottlenecks.

Never freeze the Qt event loop with long calculations.

---

# 18. Testing strategy

## Unit tests

Test one module at a time:

- normalizer;
- parser;
- SymPy builder;
- domain rules;
- sampling;
- curve splitting.

## Integration tests

Test the pipeline:

```text
input text
→ parsed expression
→ analysis
→ samples
```

## UI tests

Use `pytest-qt` for:

- entering an expression;
- clicking Plot;
- displaying an error;
- switching tabs;
- saving a project.

## Property-based tests

Use Hypothesis for properties such as:

```text
x^2 is nonnegative for real x
A + 0 = A
identity matrix preserves vectors
sample arrays have matching shapes
valid square-root-domain points produce real values
```

## Regression tests

Every discovered bug gets a permanent test.

---

# 19. What to study and when

| Topic | Study before |
|---|---|
| Python functions, modules, dataclasses, exceptions | Steps 1–3 |
| Qt widgets, layouts, signals, and slots | Steps 1–3 |
| EBNF grammars and abstract syntax trees | Steps 4–6 |
| SymPy expression trees | Steps 6 and 13 |
| NumPy arrays, vectorization, masks, and `NaN` | Steps 7–9 |
| Numerical sampling and floating-point error | Steps 8–9 |
| Calculus domain rules and limits | Steps 13–18 |
| `meshgrid` and contour concepts | Steps 23–25 |
| Basic OpenGL concepts | Step 26, not earlier |
| Linear transformations and bases | Steps 30–34 |
| C++ RAII, vectors, lambdas, and testing | Steps 35–39 |
| CMake targets and linking | Steps 37–39 |
| Python extension modules | Step 38 |
| Numerical methods and ODEs | Steps 43–46 |

---

# 20. Features that should wait

Do not begin with:

- a custom OpenGL renderer;
- shaders;
- arbitrary implicit 3D surfaces;
- GPU computing;
- CUDA;
- a complete computer algebra system;
- a plugin marketplace;
- networking;
- user accounts;
- cloud synchronization;
- a browser frontend;
- mobile apps;
- fluid simulation;
- a complete LaTeX parser;
- collaborative editing.

These can consume months without improving today's exercise list.

---

# 21. Definition of the first public alpha

MathForge `0.1.0` is ready when it can:

- open as a native desktop application;
- plot several one-variable functions;
- zoom and pan;
- display clear syntax errors;
- avoid drawing across singularities;
- show domain;
- show roots;
- show first derivative;
- show critical points when supported;
- show exact image or clearly labeled viewport estimate;
- save and reopen a project;
- export a graph;
- run automated tests;
- open on a classmate's computer without a browser.

Required test expressions:

```text
x^2
1/x
sqrt(x - 1)
sin(x)/x
log(x)
tan(x)
exp(-x^2)
```

---

# 22. Later milestone definitions

## Version 0.2 — Calculus II

- two-variable parser;
- domain masks;
- level curves;
- 3D explicit surfaces;
- parametrized curves;
- path-based limit explorer;
- gradients and tangent planes.

## Version 0.3 — Linear algebra

- vectors;
- combinations;
- systems;
- row reduction;
- 2×2 transformations;
- determinant visualization;
- eigenvectors;
- kernel and image.

## Version 0.4 — C++ numerical core

- adaptive sampler in C++;
- Python fallback;
- benchmark suite;
- stable pybind11 build;
- marching squares if justified.

## Version 0.5 — Modeling

- data import;
- regression;
- interpolation;
- optimization;
- ODEs;
- direction fields;
- phase portraits.

---

# 23. Contribution philosophy

MathForge is a learning project.

A contribution should:

- solve one well-defined problem;
- include tests;
- preserve exact-versus-numerical labeling;
- keep UI and mathematics separated;
- avoid unnecessary dependencies;
- explain difficult algorithms;
- prefer a small finished feature over a large unfinished subsystem.

---

# 24. License

Choose a license before publishing the repository.

Possible options:

- MIT for a permissive project;
- GPLv3 if derivative desktop applications should remain open source.

Check the licenses and distribution obligations of all dependencies before releasing binaries.

---

# 25. Immediate next task

Implement Steps 0 through 3 only:

```text
1. create project and install dependencies;
2. open a PySide6 main window;
3. embed a pyqtgraph PlotWidget;
4. read expression and viewport into FunctionRequest;
5. add tests for request validation.
```

Do not begin symbolic analysis or C++ bindings until this shell works cleanly.
