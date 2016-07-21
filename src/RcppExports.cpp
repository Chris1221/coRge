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
Rcpp::List returnLD(arma::vec cIndex, arma::mat gen);
RcppExport SEXP coRge_returnLD(SEXP cIndexSEXP, SEXP genSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< arma::vec >::type cIndex(cIndexSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type gen(genSEXP);
    __result = Rcpp::wrap(returnLD(cIndex, gen));
    return __result;
END_RCPP
}
// test
Rcpp::List test(arma::vec cIndex, arma::mat gen);
RcppExport SEXP coRge_test(SEXP cIndexSEXP, SEXP genSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< arma::vec >::type cIndex(cIndexSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type gen(genSEXP);
    __result = Rcpp::wrap(test(cIndex, gen));
    return __result;
END_RCPP
}
