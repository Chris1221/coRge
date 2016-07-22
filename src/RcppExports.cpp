// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// gen_cor
arma::mat gen_cor(arma::vec causal, arma::mat all);
RcppExport SEXP coRge_gen_cor(SEXP causalSEXP, SEXP allSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< arma::vec >::type causal(causalSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type all(allSEXP);
    __result = Rcpp::wrap(gen_cor(causal, all));
    return __result;
END_RCPP
}
// returnLD
Rcpp::List returnLD(arma::uvec cIndex, arma::mat gen, arma::vec bpVec);
RcppExport SEXP coRge_returnLD(SEXP cIndexSEXP, SEXP genSEXP, SEXP bpVecSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< arma::uvec >::type cIndex(cIndexSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type gen(genSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type bpVec(bpVecSEXP);
    __result = Rcpp::wrap(returnLD(cIndex, gen, bpVec));
    return __result;
END_RCPP
}
// assoc
arma::vec assoc(arma::mat gen, arma::colvec y);
RcppExport SEXP coRge_assoc(SEXP genSEXP, SEXP ySEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< arma::mat >::type gen(genSEXP);
    Rcpp::traits::input_parameter< arma::colvec >::type y(ySEXP);
    __result = Rcpp::wrap(assoc(gen, y));
    return __result;
END_RCPP
}
// test
bool test(arma::vec geno);
RcppExport SEXP coRge_test(SEXP genoSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< arma::vec >::type geno(genoSEXP);
    __result = Rcpp::wrap(test(geno));
    return __result;
END_RCPP
}
