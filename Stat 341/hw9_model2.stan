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
  vector[n] MRSA_SIR;
  vector[n] Recommend;
  vector[n] Clean_Star_Rating;
  array[n] int State_Num; 
  array[115] int Clean_Star_missidx;
  array[115] int Recommend_missidx;
}
parameters {
  real mu_Clean_Star;
  real mu_Recommend;
  real b0;
  real b1;
  real b2;
  vector[56] b3; // there are some territories and DC included
  real<lower=0> sigma;
  real<lower=0> sigma_Clean_Star;
  real<lower=0> sigma_Recommend;
  vector[115] Clean_Star_impute;
  vector[115] Recommend_impute;
}
model {
  vector[n] mu;
  vector[n] alpha;
  vector[n] lambda;
  vector[n] Clean_Star_merge;
  vector[n] Recommend_merge;
  Clean_Star_merge = merge_missing(Clean_Star_missidx, to_vector(Clean_Star_Rating), Clean_Star_impute);
  Recommend_merge = merge_missing(Recommend_missidx, to_vector(Recommend), Recommend_impute);
  b0 ~ normal(0, 1);
  b1 ~ cauchy(0, 2.5);
  b2 ~ cauchy(0, 2.5);
  b3 ~ cauchy(0, 0.5);
  sigma ~ lognormal(0,1);
  mu_Clean_Star ~ normal(0, 1);
  mu_Recommend ~ normal(0, 1);
  sigma_Clean_Star ~ lognormal(0,1);
  sigma_Recommend ~ lognormal(0,1);
  Clean_Star_merge ~ normal(mu_Clean_Star, sigma_Clean_Star);
  Recommend_merge ~ normal(mu_Recommend, sigma_Recommend);
  for ( i in 1:n ) {
    mu[i] = exp(b0 + b1 * Recommend_merge[i] + b2 * Clean_Star_merge[i] + b3[State_Num[i]]);
    alpha[i] = mu[i]^2 / sigma^2;
    lambda[i] = mu[i] / sigma^2;
  }
  MRSA_SIR ~ gamma(alpha, lambda); 
}
