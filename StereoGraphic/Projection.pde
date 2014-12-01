public class Projection {

  private float phi_prime, lambda_prime, R;
  public Projection() {
    this(HALF_PI, 0.0, 1);
  }
  
  public Projection(float phi, float lambda, float R) {
    this.phi_prime = phi;
    this.lambda_prime = lambda;
    this.R = R;
  }

  public void setPhiPrime(float phi){
   this.phi_prime = phi;
  }
 
  public void setLambdaPrime(float lambda){
   this.lambda_prime = lambda;
  }
   public void setR(float R){
   this.R = R;
  }

  private float _k(float phi, float lambda) {
    return (2.0 * this.R)/(1.0+sin(this.phi_prime)*sin(phi)+cos(this.phi_prime)*cos(phi)*cos(lambda - this.lambda_prime));
  }  

  public float x(float phi, float lambda) {
    float k = this._k(phi, lambda);
    return k * cos(phi)*sin(lambda - this.lambda_prime);
  }

  public float y(float phi, float lambda) {
    float k = this._k(phi, lambda);
    return k * (cos(this.phi_prime)*sin(phi) - sin(this.phi_prime)*cos(phi)*cos(lambda - this.lambda_prime));
  }


  private float _rho(float x, float y) {
    return sqrt(x*x + y*y);
  }

  private float _c(float x, float y) {
    return 2.0*atan2(this._rho(x, y), (2*this.R));
  }

  public float phi(float x, float y) {
    float rho = this._rho(x, y);
    float c = this._c(x, y); 
    float partial = ((y*sin(c)*cos(this.phi_prime))/rho);
    if(Float.isNaN(partial)){
      return asin(cos(c) * sin(this.phi_prime));
    } else {
      return asin(cos(c) * sin(this.phi_prime) + partial);
    }
  }

  public float lambda(float x, float y) {
    float rho = this._rho(x, y);
    float c = this._c(x, y);
    return this.lambda_prime + atan2((x*sin(c)),(rho*cos(phi_prime)*cos(c)-y*sin(phi_prime)*sin(c)));
  }
}

