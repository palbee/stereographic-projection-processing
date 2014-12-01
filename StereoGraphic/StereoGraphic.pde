PImage img;
Projection proj = new Projection(0, 0, 80);
float phi_input;
float lambda_input;
float auto_phi;
float auto_lambda;
boolean mouse_driven = true;
boolean grid = true;
float map_data[][] = null;
boolean dirty = true;
final int GRID = 0;
final int MAP = 1;
final int SMOOTH_RANGE = 2;
final int FAST_RANGE = 3;
final int SPIRAL = 4;
int projection_mode = GRID;

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
    projection_mode = GRID;
    break;

  case 'M':
  case 'm':
    projection_mode = MAP;
    break;

  case 'R':
  case 'r':
    projection_mode = FAST_RANGE;
    break;

  case 'S':
  case 's':
    projection_mode = SMOOTH_RANGE;
    break;
  case 'C':
  case 'c':
    projection_mode = SPIRAL;
    break;
  }

  dirty = true;
}

void setup() {
  size(1024, 768);
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
    int delta_x = pmouseX - mouseX;
    int delta_y = pmouseY - mouseY;
    if (delta_x != 0 || delta_y != 0) {
      phi_input += map(delta_y, 0, height -1, 0, HALF_PI);
      lambda_input += map(delta_x, 0, width -1, 0, HALF_PI);
      phi_input = clean_angle_radians(phi_input); 
      lambda_input = clean_angle_radians(lambda_input);
      dirty = true;
    }
  }
}

void draw() {
  String phi_label;
  String lambda_label;
  float phi;
  float lambda;
  if (mouse_driven) {
  } else {
    dirty = true;
    auto_phi = auto_phi + 5;
    if (auto_phi >= height) {
      auto_phi %= height;
      auto_lambda = (auto_lambda + 5) % width;
    }
    phi_input = map(auto_phi, 0, height -1, 0, TWO_PI);
    lambda_input = map(auto_lambda, 0, width -1, 0, TWO_PI);
  }

  if (dirty) {
    background(0);
    noFill();
    proj.setPhiPrime(phi_input);
    proj.setLambdaPrime(lambda_input);
    switch(projection_mode) {
    case GRID:
      render_grid();
      break;
    case MAP:
      render_map();
      break;
    case SMOOTH_RANGE:
      render_range_smooth();
      break;
    case FAST_RANGE:
      render_range_fast();
      break;
    case SPIRAL:
      render_spiral();
      break;
    default:
      render_grid();
    }
    phi_label = String.format("Phi = %.3f", phi_input);
    lambda_label = String.format("Lambda = %.3f", lambda_input);
    textAlign(LEFT);
    text(phi_label, 10, 20);
    text(lambda_label, 10, 40);
    dirty = false;
  }
}

