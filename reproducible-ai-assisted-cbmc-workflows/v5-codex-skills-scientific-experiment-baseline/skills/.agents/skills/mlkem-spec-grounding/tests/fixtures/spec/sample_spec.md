# Synthetic ML-KEM Specification Fixture

This fixture is not FIPS 203. It exists only to test deterministic retrieval.

## 1 Parameters

The fixed polynomial degree is 256 and the coefficient modulus is 3329.

## 2 Polynomial operations

Polynomial subtraction computes a result coefficient from corresponding input coefficients.
The operation is interpreted coefficient-wise before any representation-specific reduction.

## 3 Encoding

An encoded polynomial occupies a fixed number of bytes under the selected parameter set.
