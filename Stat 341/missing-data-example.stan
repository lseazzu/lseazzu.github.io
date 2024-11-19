functions{
  vector merge_missing( int[] miss_indexes , vector x_obs , vector x_miss ) {
    int N = dims(x_obs)[1];
    int N_miss = dims(x_miss)[1];
    vector[N] merged;
    merged = x_obs;
    for ( i in 1:N_miss )
      merged[ miss_indexes[i] ] = x_miss[i];
    return merged;
  }
}
data {
  int<lower=0> n;
  array[n] int BedsDisinfected; // response. (why must it be int type?)
  vector[n] Occupancy; // predictor (with missing values to impute)
  array[n] int Location_ix; // A. Can't impute missings. Why?
  array[79] int Occupancy_missidx; // B. why 79?
}
parameters {
  real mu_Occupancy;
  real b0;
  real b1;
  vector[2] b2; // C. Why 2?
  real<lower=0> phi_inverse; // 1/phi is easier to think about: overdisp is more if 1/phi is bigger, usually starts at 1
  real<lower=0> sigma_Occupancy;
  vector[79] Occupancy_impute;
}
transformed parameters {
  real phi = inv(phi_inverse); // the neg_binom2() stan function takes parameter phi = 1/phi_inverse as input
}
model {
  vector[n] mu;
  vector[n] Occupancy_merge; // D. what is this (once it's constructed?)
  // E. (the line below)
  Occupancy_merge = merge_missing(Occupancy_missidx, to_vector(Occupancy), Occupancy_impute);
  b0 ~ normal(0, 1);
  b1 ~ cauchy(0, 2.5);
  b2 ~ cauchy(0, 2.5);
  phi_inverse ~ lognormal(0,1);
  mu_Occupancy ~ normal(0, 1); // F. Why does this prior make sense?
  sigma_Occupancy ~ lognormal(0,1);
  Occupancy_merge ~ normal(mu_Occupancy, sigma_Occupancy); // G.
  for ( i in 1:n ) {
    mu[i] = exp(b0 + b1 * Occupancy_merge[i] + b2[Location_ix[i]]); // H. Why exp()?
  }
  BedsDisinfected ~ neg_binomial_2(mu, phi); // I.
}
// A. Because this is a categorical predictor, and Stan can't manage imputation for discrete parameters
// B. There are 79 missing values in the occupancy data. (It would be better to not hard code this but following *Rethinking* we are here...
// C. Because there are 2 locations (so this is a categorical predictor; we need one parameter per category)
// D. This is the Occupancy variable, with the missing values filled-in with their imputed values
// E. This applied the function defined above to merge together the imputed missing values and the observed actual Occupancy values into one vector with no missing values
// F. If Occupancy is scaled, it's somewhat reasonable to expect it to have a mean of 0 and a sd of 1.
// G. This is the prior for the missing Occupancy values. They should be Normal(mu_Occupancy, sigma_Occupancy)
// H. This is a negative binomial model with log link function. SO the model says that log(mu) = b0 + b1*x1... Therefore mu = exp(b0 + b1*x1...) That's nothing to do with the imputation - just part of the negative binomial GLM.
// I. This is nothing to do with the imputation; it's just specifying that we are  using the neg binom distribution to model the BedsDisinfected data (since it is a count response variable). So, if you ignore the missinga data stuf, this example shows you how to set up the code if you want to ever fit a negative binomial GLM.