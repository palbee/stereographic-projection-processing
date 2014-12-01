PImage img;
Projection proj = new Projection(0, 0, 50);
float phi_input;
float lambda_input;
float auto_phi;
float auto_lambda;
boolean mouse_driven = true;
boolean grid = true;

float map_data[][] = null;

void keyPressed() {
  switch(key) {
  case 'A':
  case 'a':
    mouse_driven = !mouse_driven;
    if (!mouse_driven) {
      auto_phi = mouseY;
      auto_lambda = mouseX;
    }
    break;
  case 'G':
  case 'g':
    grid = !grid;
    break;
  }
}
void setup() {
  size(721, 721);
  phi_input = height/2.0;
  lambda_input = width/2.0;
  img = loadImage("range_image.png");
  map_data = load_map_data();
}

color angle_color(float phi, float lambda) {
  float red = map(phi, -PI, PI, 0, 255);
  float green = map(lambda, -PI, PI, 0, 255);
  float blue = map(phi-lambda, -TWO_PI, TWO_PI, 0, 255);
  return color(red, green, blue);
}

float clean_angle(float angle) {
  while (angle < 0) {
    angle += 360;
  };
  while (angle > 359) {
    angle -= 360;
  };
  return angle;
}

int clean_angle(int angle) {
  while (angle < 0) {
    angle += 360;
  }
  while (angle > 359) {
    angle -= 360;
  }
  return angle;
}


void draw() {
  float phi;
  float lambda;
  background(0);
  noFill();
  if (mouse_driven) {
    phi_input = map(mouseY, 0, height -1, 0, TWO_PI);
    lambda_input = map(mouseX, 0, width -1, 0, TWO_PI);
  } else {
    auto_phi = auto_phi + 5;
    if (auto_phi >= height) {
      auto_phi %= height;
      auto_lambda = (auto_lambda + 5) % width;
    }
    phi_input = map(auto_phi, 0, height -1, 0, TWO_PI);
    lambda_input = map(auto_lambda, 0, width -1, 0, TWO_PI);
  }

  proj.setPhiPrime(phi_input);
  proj.setLambdaPrime(lambda_input);
  if (grid) {
    render_grid();
  } else {
    render_range();
  }
}

void render_grid() {
  for (float phi = 0; phi < TWO_PI; phi += (TWO_PI / 360.0)) {
    //    beginShape(POINTS);
    for (float lambda = 0; lambda < TWO_PI; lambda += (TWO_PI / 18.0)) {
      stroke(angle_color(phi, lambda));
      point(proj.x(phi, lambda)+width/2, proj.y(phi, lambda)+height/2);
    }
    //    endShape();
  }
  for (float phi = 0; phi < TWO_PI; phi += TWO_PI / 18.0) {
    //    beginShape(POINTS);
    for (float lambda = 0; lambda < TWO_PI; lambda += TWO_PI / 360.0) {
      stroke(angle_color(phi, lambda));
      point(proj.x(phi, lambda)+width/2, proj.y(phi, lambda)+height/2);
    }
    //    endShape();
  }
}

void render_range() {
  float phi, lambda;
  for (float x = -width/2; x < width/2; x++) {
    for (float y = -height/2; y < height/2; y++) {
      phi = clean_angle(degrees(proj.phi(x, y)));
      lambda = clean_angle(degrees(proj.lambda(x, y)));

      int lx = clean_angle(floor(lambda));
      int ux = clean_angle(ceil(lambda));
      int ly = clean_angle(floor(phi));
      int uy = clean_angle(ceil(phi));
      float xprime = clean_angle(lambda - lx);
      float yprime = clean_angle(phi - ly);
      color f00 = img.get(lx, ly);
      color f01 = img.get(lx, uy);
      color f10 = img.get(ux, ly);
      color f11 = img.get(ux, uy);
      color result = color(
      red(f00)  *(1-xprime)*(1-yprime)+  red(f10)*xprime*(1-yprime)+  red(f01)*(1-xprime)*yprime+  red(f11)*xprime*yprime, 
      green(f00)*(1-xprime)*(1-yprime)+green(f10)*xprime*(1-yprime)+green(f01)*(1-xprime)*yprime+green(f11)*xprime*yprime, 
      blue(f00) *(1-xprime)*(1-yprime)+ blue(f10)*xprime*(1-yprime)+ blue(f01)*(1-xprime)*yprime+ blue(f11)*xprime*yprime);
      if(result == color(0,0,0)){
        println(x,y,hex(f00),hex(f01),hex(f10),hex(f11),hex(result),phi,lambda);
      }
      stroke(result);
      point(x + width/2, y + height/2);
    }
  }
}

void render_spiral() {
  float phi = 0;
  float lambda = 0;
  stroke(255);  
  //  beginShape();
  while (lambda < TWO_PI) {
    stroke(angle_color(phi, lambda));
    point(proj.x(phi, lambda)+width/2, proj.y(phi, lambda)+height/2);
    phi += 0.01;
    lambda += 0.01;
  }
  //  endShape(OPEN);
}
void render_map() {
  float phi = 0;
  float lambda = 0;
  //  stroke(255,255,255);
  for (int i=0; i < map_data.length; i++) {
    beginShape();
    for (int j=0; j < map_data[i].length/2; j+= 2) {
      lambda = radians(map_data[i][j]);
      phi = radians(map_data[i][j+1]);
      stroke(angle_color(phi, lambda));
      vertex(proj.x(phi, lambda)+width/2, proj.y(phi, lambda)+height/2);
      //      vertex(map(phi, -PI, PI, 0, height-1), map(lambda, -PI, PI, 0, width-1));
    }
    endShape(CLOSE);
  }
}

