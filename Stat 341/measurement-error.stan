data{
    int n;
    vector[n] Divorce_sd_Z;
    vector[n] Divorce_obs_Z;
    real Marriage_Z[n];
    real MedianAgeMarriage_Z[n];
}
parameters{
    vector[n] D_true;
    real a;
    real bA;
    real bM;
    real<lower=0> sigma;
}
model{
    vector[n] mu;
    sigma ~ exponential( 1 );
    bM ~ normal( 0 , 0.5 );
    bA ~ normal( 0 , 0.5 );
    a ~ normal( 0 , 0.2 );
    for ( i in 1:n ) {
        mu[i] = a + bA * MedianAgeMarriage_Z[i] + bM * Marriage_Z[i];
    }
    D_true ~ normal( mu , sigma );
    Divorce_obs_Z ~ normal( D_true , Divorce_sd_Z );
}
