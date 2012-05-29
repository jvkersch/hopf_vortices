"""
Functions dealing with continuous-time vortex systems.

"""


import numpy as np
cimport numpy as np
cimport cython 

# Build with 
# 
# python setup.py build_ext --inplace


DTYPE=np.double
ctypedef np.double_t DTYPE_t

from math import pi
cdef double PI = pi

cdef extern from "math.h":
    double log(double)


@cython.boundscheck(False) 
@cython.wraparound(False)
cpdef np.ndarray[DTYPE_t, ndim=2] scaled_gradient_hamiltonian(
    np.ndarray[DTYPE_t, ndim=1] gamma, 
    np.ndarray[DTYPE_t, ndim=2] X, 
    DTYPE_t sigma):

    # NOTE/TODO: This is gradient of the hamiltonian UP TO A FACTOR 
    # of gamma, so the name of this function is not that accurate.
    # Better would be to make this a wrapper around J * vortex_rhs

    cdef int N = X.shape[0]
    cdef int ndim = X.shape[1]
    cdef np.ndarray[DTYPE_t, ndim=2] res = np.zeros([N, ndim], dtype=DTYPE)
    cdef np.ndarray[DTYPE_t, ndim=1] vec 
    cdef int i, j

    for i from 0 <= i < N:
        for j from i+1 <= j < N:
            vec = X[i, :] - X[j, :]
            vec /= np.dot(vec, vec) + 2*sigma**2
            res[i, :] += gamma[j]*vec
            res[j, :] -= gamma[i]*vec
        res[i, :] *= -1/(2.*PI)

    return res


@cython.boundscheck(False) 
@cython.wraparound(False)
cpdef np.ndarray[DTYPE_t, ndim=2] vortex_rhs(
    np.ndarray[DTYPE_t, ndim=1] gamma, 
    np.ndarray[DTYPE_t, ndim=2] X,
    DTYPE_t sigma):
    # Agrees with Matlab

    cdef np.ndarray[DTYPE_t, ndim=2] res
    cdef int i

    res = scaled_gradient_hamiltonian(gamma, X, sigma)

    for i from 0 <= i < X.shape[0]:
        res[i, :] = np.cross(res[i, :], X[i, :])

    return res


@cython.boundscheck(False) 
@cython.wraparound(False)
def vortex_hamiltonian(np.ndarray[DTYPE_t, ndim=1] gamma, 
                       np.ndarray[DTYPE_t, ndim=2] X,
                       DTYPE_t sigma):
    """Value of the energy for a vortex configuration.

    INPUT:

      - ``gamma`` - Vector of vortex strengths.

      - ``X`` - Array of vortex locations in 3D.

      - ``sigma`` - Scalar value for regularization parameter.

    OUTPUT:

    Value of the energy as a scalar.

    """

    cdef int N = X.shape[0]
    cdef int ndim = X.shape[1]
    cdef np.ndarray[DTYPE_t, ndim=1] vec 
    cdef int i, j
    cdef DTYPE_t E = 0

    for i from 0 <= i < N:
        for j from i+1 <= j < N:
            vec = X[i, :] - X[j, :]
            E -= gamma[i]*gamma[j]/(4*PI)*log(2*sigma**2 + np.dot(vec, vec))
             
    return E


@cython.boundscheck(False) 
@cython.wraparound(False)
def vortex_moment(np.ndarray[DTYPE_t, ndim=1] gamma, 
                  np.ndarray[DTYPE_t, ndim=2] X):
    """Moment of a vortex configuration.

    INPUT:

      - ``gamma`` - Vector of vortex strengths.

      - ``X`` - Array of vortex locations in 3D.

    OUTPUT:

    Value of the vortex moment as a numpy three-vector.
      
    """

    cdef int i
    cdef np.ndarray[DTYPE_t, ndim=1] m = np.empty((3, ), dtype=DTYPE)

    for i from 0 <= i < 3:
        m[i] = np.sum(gamma*X[:, i])

    return m




