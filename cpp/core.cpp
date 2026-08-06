#include <pybind11/pybind11.h>

namespace py = pybind11;

PYBIND11_MODULE(_locus_core, m) {
    m.doc() = "Locus C++ numerical core";
    m.attr("__version__") = "0.1.0";
}
