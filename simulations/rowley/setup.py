from distutils.core import setup 
from distutils.extension import Extension 
from Cython.Distutils import build_ext
import numpy

ext_modules = [Extension("rowley_midpoint",
                         ["rowley_midpoint.pyx"], 
                         include_dirs=[numpy.get_include()])]

setup( 
    name = "Rowley's midpoint algorithm for point vortices", 
    cmdclass = {'build_ext': build_ext}, 
    ext_modules = ext_modules
)