data {
  int<lower=0> n;
  int<lower=0> n_County_Data;
  vector[n] MRSA_SIR;
  vector[n] Recommend;
  vector[n] Clean_Star_Rating;
  array[n] int State_Num;
  array[n] int County_Num;
}
parameters {
  real b0;
  real b1;
  real b2;
  vector[56] b3; // there are some territories and DC included
  real mu_County; 
  vector[n_County_Data] z0; 
  real<lower=0> sigma; 
  real<lower=0> sigma_County; 
}
model {
  vector[n] mu;
  vector[n] alpha;
  vector[n] lambda;
  for ( i in 1:n ) {
    mu[i] = exp(b0 + mu_County + z0[County_Num[i]] * sigma_County + b1 * Recommend[i] + b2 * Clean_Star_Rating[i] + b3[State_Num[i]]);
    alpha[i] = mu[i]^2 / sigma^2;
    lambda[i] = mu[i] / sigma^2;
  }
  b0 ~ normal(0, 1);
  mu_County ~ normal(0,1);
  z0 ~ normal(0,1);
  b1 ~ cauchy(0, 2.5);
  b2 ~ cauchy(0, 2.5);
  b3 ~ cauchy(0, 0.5);
  sigma ~ lognormal(0,1);
  sigma_County ~ lognormal(0,1);
  MRSA_SIR ~ gamma(alpha, lambda); 
}
generated quantities{
  vector[n] mu;
  vector[n] alpha;
  vector[n] lambda;
  vector[n_County_Data] a0;
  a0 =  mu_County + z0 * sigma_County; 
  for (i in 1:n) {
    mu[i] = exp(b0 + b1 * Recommend[i] + b2 * Clean_Star_Rating[i] + b3[State_Num[i]]);
    alpha[i] = mu[i]^2 / sigma^2; 
    lambda[i] = mu[i] / sigma^2;
  }
}
