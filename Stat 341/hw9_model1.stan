data {
  int<lower=0> n;
  vector[n] MRSA_SIR;
  vector[n] Recommend;
  vector[n] Clean_Star_Rating;
  array[n] int State_Num;  
}
parameters {
  real b0;
  real b1;
  real b2;
  vector[56] b3; // there are some territories and DC included
  real<lower=0> sigma;
}
model {
  vector[n] mu;
  vector[n] alpha;
  vector[n] lambda;
  for ( i in 1:n ) {
    mu[i] = exp(b0 + b1 * Recommend[i] + b2 * Clean_Star_Rating[i] + b3[State_Num[i]]);
    alpha[i] = mu[i]^2 / sigma^2;
    lambda[i] = mu[i] / sigma^2;
  }
  b0 ~ normal(0, 1);
  b1 ~ cauchy(0, 2.5);
  b2 ~ cauchy(0, 2.5);
  b3 ~ cauchy(0, 0.5);
  sigma ~ lognormal(0,1);
  MRSA_SIR ~ gamma(alpha, lambda); 
}
generated quantities{
  vector[n] mu;
  vector[n] alpha;
  vector[n] lambda;
  for (i in 1:n) {
    mu[i] = exp(b0 + b1 * Recommend[i] + b2 * Clean_Star_Rating[i] + b3[State_Num[i]]);
    alpha[i] = mu[i]^2 / sigma^2; 
    lambda[i] = mu[i] / sigma^2;
  }
}
