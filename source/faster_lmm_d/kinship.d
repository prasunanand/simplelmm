/*
   This code is part of faster_lmm_d and published under the GPLv3
   License (see LICENSE.txt)

   Copyright © 2017 Prasun Anand & Pjotr Prins
*/

module faster_lmm_d.kinship;

import std.exception;
import std.experimental.logger;

import faster_lmm_d.dmatrix;
import faster_lmm_d.helpers;
import faster_lmm_d.optmatrix;

dmatrix kinship_full(const dmatrix G)
{
  info("Full kinship matrix used");
  int m = G.shape[0]; // snps
  int n = G.shape[1]; // inds
  log(m," SNPs");
  assert(m>n, "n should be larger than m");
  dmatrix temp = matrixTranspose(G);
  dmatrix mmT = matrixMult(temp, G);
  info("normalize K");
  dmatrix K = divideDmatrixNum(mmT, G.shape[0]);

  log("kinship_full K sized ",n," ",K.elements.length);
  log(K.elements[0],",",K.elements[1],",",K.elements[2],"...",K.elements[n-3],",",K.elements[n-2],",",K.elements[n-1]);
  ulong row = n;
  ulong lr = n*n-1;
  ulong ll = (n-1)*n;
  log(K.elements[ll],",",K.elements[ll+1],",",K.elements[ll+2],"...",K.elements[lr-2],",",K.elements[lr-1],",",K.elements[lr]);
  return K;
}

eighTuple kvakve(const dmatrix K)
{
  trace("Obtaining eigendecomposition for %dx%d matrix",K.shape[0],K.shape[1]);
  return eigh(K);
}