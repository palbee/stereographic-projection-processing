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
float clean_angle_radians(float angle) {
  while (angle < 0) {
    angle += TWO_PI;
  };
  while (angle >= TWO_PI) {
    angle -= TWO_PI;
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
void mouseDragged() 
{  
  if (mouse_driven) {
    phi_input += map(pmouseY - mouseY, 0, height -1, 0, TWO_PI);
    lambda_input += map(mouseX - pmouseX, 0, width -1, 0, TWO_PI);
    phi_input = clean_angle_radians(phi_input); 
    lambda_input = clean_angle_radians(lambda_input);
  }
}

void draw() {
  String phi_label;
  String lambda_label;
  float phi;
  float lambda;
  background(0);
  noFill();
  if (mouse_driven) {
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
  phi_label = String.format("Phi = %.3f", phi_input);
  lambda_label = String.format("Lambda = %.3f", lambda_input);
  textAlign(LEFT);
  text(phi_label, 10,20);
  text(lambda_label, 10,40);
  
}


