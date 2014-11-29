PImage img;
Projection proj = new Projection(0, 0, 80);
float phi_input;
float lambda_input;
float auto_phi;
float auto_lambda;
boolean mouse_driven = true;
boolean grid = true;


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
}

color angle_color(float phi, float lambda) {
  float red = map(phi, -PI, PI, 0, 255);
  float green = map(lambda, -PI, PI, 0, 255);
  float blue = map(phi-lambda, -TWO_PI, TWO_PI, 0, 255);
  return color(red, green, blue);
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
      phi = degrees(proj.phi(x, y));
      lambda = degrees(proj.lambda(x, y));
      while (phi < 0) {
        phi += 360;
      }
      while (lambda < 0) {
        lambda += 360;
      }

      while(lambda > 359){
        lambda = lambda - 360;
      }
      while(phi > 359){
        phi = phi - 360;
      }
      
      int lx = floor(lambda);
      if (lx < 0) {
        lx += 360;
      }
      int ux = ceil(lambda);
      if (ux > 359) {
        ux = 360 - ux;
      }
      int ly = floor(phi);
      if (ly < 0) {
        ly += 360;
      }
      int uy = ceil(phi);
      if (ux > 359) {
        ux = 360 - ux;
      }
      float xprime = lambda - lx;
      float yprime = phi - ly;
      if (lx < 0) {
        lx += 360;
      }
      if (ly < 0) {
        ly += 360;
      }

      if (ux > 359) {
        ux = 360 - 359;
      }
      if (uy> 359) {
        uy = 360 - 359;
      }

      //      if(ux == lx){
      //        xprime = 0;
      //      }
      //      if (uy == ly) {
      //        yprime = 0;
      //      }
      color f00 = img.get(lx, ly);
      color f01 = img.get(lx, uy);
      color f10 = img.get(ux, ly);
      color f11 = img.get(ux, uy);
      color result = color(
      red(f00)  *(1-xprime)*(1-yprime)+  red(f10)*xprime*(1-yprime)+  red(f01)*(1-xprime)*yprime+  red(f11)*xprime*yprime, 
      green(f00)*(1-xprime)*(1-yprime)+green(f10)*xprime*(1-yprime)+green(f01)*(1-xprime)*yprime+green(f11)*xprime*yprime, 
      blue(f00) *(1-xprime)*(1-yprime)+ blue(f10)*xprime*(1-yprime)+ blue(f01)*(1-xprime)*yprime+ blue(f11)*xprime*yprime);
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

float map_data[][] = {
  { 
    -92.32, 48.24, 
    -88.13, 48.92, 
    -83.11, 46.27, 
    -81.66, 44.76, 
    -82.09, 42.29, 
    -77.10, 44.00, 
    -69.95, 46.92, 
    -65.92, 45.32, 
    -66.37, 44.25, 
    -61.22, 45.43, 
    -64.94, 47.34, 
    -64.12, 48.52, 
    -70.68, 47.02, 
    -67.24, 49.33, 
    -59.82, 50.48, 
    -56.14, 52.46, 
    -59.07, 53.58, 
    -58.26, 54.21, 
    -60.69, 55.33, 
    -61.97, 57.41, 
    -64.35, 59.49, 
    -67.29, 58.15, 
    -69.89, 59.91, 
    -71.31, 61.45, 
    -78.22, 61.97, 
    -77.28, 59.53, 
    -77.09, 55.88, 
    -79.06, 51.68, 
    -82.23, 52.70, 
    -86.75, 55.72, 
    -92.17, 56.86, 
    -95.61, 58.82, 
    -92.66, 62.02, 
    -90.65, 63.24, 
    -95.96, 64.12, 
    -89.88, 63.98, 
    -89.30, 65.22, 
    -86.86, 66.12, 
    -84.54, 66.88, 
    -82.30, 67.76, 
    -83.10, 69.68, 
    -86.05, 67.98, 
    -88.18, 68.20, 
    -91.00, 68.82, 
    -91.72, 69.69, 
    -93.15, 71.09, 
    -96.58, 71.05, 
    -93.35, 69.52, 
    -94.23, 68.25, 
    -95.96, 66.73, 
    -98.83, 68.27, 
    -102.45, 67.69, 
    -108.34, 68.43, 
    -105.83, 68.05, 
    -108.15, 66.60, 
    -111.15, 67.63, 
    -114.10, 68.23, 
    -120.92, 69.44, 
    -124.32, 69.26, 
    -128.76, 70.50, 
    -131.86, 69.19, 
    -131.15, 69.79, 
    -135.81, 69.13, 
    -140.19, 69.37, 
    -141.20, 69.58, 
    -141.21, 69.56, 
    -142.49, 69.83, 
    -148.09, 70.26, 
    -154.37, 70.96, 
    -159.53, 70.38, 
    -166.64, 68.25, 
    -161.56, 66.55, 
    -162.99, 65.97, 
    -168.23, 65.49, 
    -161.12, 64.49, 
    -165.29, 62.57, 
    -164.58, 60.06, 
    -162.06, 58.36, 
    -157.85, 58.12, 
    -162.34, 55.06, 
    -156.52, 57.11, 
    -153.53, 59.32, 
    -149.18, 60.81, 
    -149.90, 59.50, 
    -146.54, 60.36, 
    -139.98, 59.73, 
    -137.12, 58.28, 
    -136.01, 59.12, 
    -133.84, 57.12, 
    -131.46, 55.98, 
    -132.08, 57.20, 
    -140.37, 60.25, 
    -141.21, 60.16, 
    -133.38, 58.93, 
    -130.88, 54.83, 
    -128.86, 53.90, 
    -126.58, 52.12, 
    -127.08, 50.80, 
    -124.42, 49.66, 
    -122.56, 48.91, 
    -122.44, 48.92, 
    -124.42, 47.18, 
    -124.52, 42.48, 
    -123.09, 38.45, 
    -121.73, 36.62, 
    -117.60, 33.34, 
    -117.28, 32.64, 
    -117.29, 32.48, 
    -114.75, 27.80, 
    -112.53, 24.80, 
    -110.55, 24.07, 
    -114.23, 29.59, 
    -112.58, 29.99, 
    -109.57, 25.94, 
    -105.61, 21.94, 
    -102.09, 17.87, 
    -95.75, 15.94, 
    -92.21, 14.97, 
    -92.22, 14.71, 
    -86.74, 12.06, 
    -83.03, 8.65, 
    -79.93, 8.74, 
    -77.00, 7.82, 
    -81.99, 8.97, 
    -83.92, 12.70, 
    -86.33, 15.80, 
    -88.40, 15.92, 
    -88.45, 17.42, 
    -87.01, 21.33, 
    -91.65, 18.72, 
    -96.96, 20.37, 
    -97.65, 25.67, 
    -97.62, 25.82, 
    -95.62, 28.84, 
    -90.77, 29.03, 
    -87.33, 30.22, 
    -82.69, 28.15, 
    -80.16, 26.66, 
    -80.74, 32.31, 
    -76.89, 35.43, 
    -76.47, 38.21, 
    -75.66, 37.67, 
    -71.31, 41.76, 
    -69.44, 44.17, 
    -67.69, 47.03, 
    -73.18, 45.14, 
    -79.26, 43.28, 
    -82.84, 42.59, 
    -83.49, 45.32, 
    -86.36, 43.65, 
    -87.75, 43.42, 
    -86.01, 45.96, 
    -87.00, 46.59, 
    -91.39, 46.79, 
    -90.05, 47.96
  }
  , {
    -152.62, 58.41, 
    -152.60, 58.40
  }
  , {
    -153.30, 57.80, 
    -152.40, 57.48, 
    -153.32, 57.79
  }
  , {
    -166.96, 53.96, 
    -167.01, 53.95
  }
  , {
    -168.36, 53.50, 
    -168.19, 53.36
  }
  , {
    -170.73, 52.68, 
    -170.60, 52.55
  }
  , {
    -174.47, 51.94, 
    -174.47, 51.92
  }
  , {
    -176.58, 51.71, 
    -176.64, 51.73
  }
  , {
    -177.55, 51.76, 
    -177.41, 51.63
  }
  , {
    -178.27, 51.75
  }
  , {
    177.35, 51.80, 
    177.33, 51.76
  }
  , {
    172.44, 53.00, 
    172.55, 53.03
  }
  , {
    -123.40, 48.33, 
    -128.00, 50.84, 
    -123.50, 48.34
  }
  , {
    -132.49, 52.88, 
    -132.44, 52.91
  }
  , {
    -132.64, 53.02, 
    -131.97, 53.71, 
    -132.63, 53.02
  }
  , {
    -55.36, 51.56, 
    -54.66, 49.52, 
    -53.65, 47.48, 
    -52.98, 46.31, 
    -56.12, 46.84, 
    -58.47, 47.57, 
    -57.61, 50.38, 
    -55.39, 51.53
  }
  , {
    -61.37, 49.01, 
    -61.80, 49.29, 
    -61.38, 49.03
  }
  , {
    -63.01, 46.71, 
    -64.42, 46.61, 
    -63.04, 46.68
  }
  , {
    -60.14, 46.48, 
    -60.14, 46.50
  }
  , {
    -71.97, 41.11, 
    -71.97, 41.15
  }
  , {
    -80.79, 27.03, 
    -81.01, 26.99
  }
  , {
    -113.01, 42.09, 
    -113.10, 42.01
  }
  , {
    -155.74, 20.02, 
    -155.73, 19.98
  }
  , {
    -156.51, 20.78, 
    -156.51, 20.78
  }
  , {
    -157.12, 21.21, 
    -157.08, 20.95
  }
  , {
    -157.87, 21.42
  }
  , {
    -159.53, 22.07
  }
  , {
    -117.44, 66.46, 
    -119.59, 65.24, 
    -123.95, 65.03, 
    -123.69, 66.44, 
    -119.21, 66.22, 
    -117.44, 66.44
  }
  , {
    -120.71, 64.03, 
    -114.91, 62.30, 
    -109.07, 62.72, 
    -112.62, 61.19, 
    -118.68, 61.19, 
    -117.01, 61.17, 
    -115.97, 62.56, 
    -119.46, 64.00, 
    -120.59, 63.94
  }
  , {
    -112.31, 58.46, 
    -108.90, 59.44, 
    -104.14, 58.90, 
    -102.56, 56.72, 
    -101.82, 58.73, 
    -104.65, 58.91, 
    -111.00, 58.51, 
    -112.35, 58.62
  }
  , {
    -98.74, 50.09, 
    -99.75, 52.24, 
    -99.62, 51.47, 
    -98.82, 50.39
  }
  , {
    -97.02, 50.21, 
    -97.50, 54.02, 
    -98.69, 52.93, 
    -97.19, 51.09, 
    -96.98, 50.20
  }
  , {
    -95.34, 49.04, 
    -92.32, 50.34, 
    -94.14, 49.47, 
    -95.36, 48.82
  }
  , {
    -80.39, 56.16, 
    -79.22, 55.94, 
    -80.34, 56.08
  }
  , {
    -103.56, 58.60, 
    -103.60, 58.58
  }
  , {
    -101.82, 58.03, 
    -102.33, 58.10, 
    -101.77, 58.06
  }
  , {
    -101.88, 55.79, 
    -97.92, 57.15, 
    -101.22, 55.85, 
    -101.88, 55.74
  }
  , {
    -77.61, 6.80, 
    -78.70, 0.97, 
    -80.75, -4.47, 
    -76.19, -14.57, 
    -70.44, -18.75, 
    -70.68, -26.15, 
    -71.44, -32.03, 
    -73.38, -37.27, 
    -73.06, -42.11, 
    -73.17, -46.09, 
    -73.52, -48.05, 
    -73.67, -51.56, 
    -71.06, -53.88, 
    -69.14, -50.77, 
    -67.51, -46.59, 
    -63.49, -42.80, 
    -62.14, -40.16, 
    -57.12, -36.71, 
    -53.17, -34.15, 
    -51.26, -32.02, 
    -48.16, -25.48, 
    -40.73, -22.32, 
    -38.88, -15.24, 
    -34.60, -7.81, 
    -41.95, -3.42, 
    -48.02, -1.84, 
    -48.44, -1.57, 
    -50.81, 0.00, 
    -54.47, 5.39, 
    -60.59, 8.32, 
    -64.19, 9.88, 
    -70.78, 10.64, 
    -70.97, 11.89, 
    -76.26, 8.76, 
    -77.61, 6.80
  }
  , {
    -69.14, -52.79, 
    -66.16, -55.08, 
    -70.01, -54.88, 
    -70.55, -53.85, 
    -69.31, -52.81
  }
  , {
    -59.29, -51.58, 
    -59.35, -51.54
  }
  , {
    -58.65, -51.55, 
    -58.55, -51.56
  }
  , {
    -84.39, 21.44, 
    -73.90, 19.73, 
    -79.27, 21.18, 
    -83.74, 21.80, 
    -84.32, 21.42
  }
  , {
    -66.96, 17.95, 
    -67.05, 17.89
  }
  , {
    -77.88, 17.22, 
    -78.06, 16.98
  }
  , {
    -74.47, 18.08, 
    -69.88, 18.99, 
    -71.10, 17.76, 
    -74.45, 17.86
  }
  , {
    -85.28, 73.74, 
    -85.79, 70.96, 
    -85.13, 71.94, 
    -84.74, 72.96, 
    -80.61, 73.10, 
    -78.45, 72.20, 
    -75.44, 72.55, 
    -73.89, 71.98, 
    -72.56, 71.04, 
    -71.49, 70.57, 
    -69.78, 70.29, 
    -68.12, 69.71, 
    -65.91, 69.19, 
    -66.92, 68.39, 
    -64.08, 67.68, 
    -62.50, 66.68, 
    -63.07, 65.33, 
    -66.11, 66.08, 
    -67.48, 65.41, 
    -64.05, 63.15, 
    -66.58, 63.26, 
    -69.04, 62.33, 
    -72.22, 63.77, 
    -76.88, 64.17, 
    -73.25, 65.54, 
    -70.09, 66.64, 
    -72.05, 67.44, 
    -76.32, 68.36, 
    -78.34, 70.17, 
    -82.12, 69.71, 
    -87.64, 70.12, 
    -89.68, 71.43, 
    -85.28, 73.74
  }
  , {
    -80.90, 76.10, 
    -84.21, 76.28, 
    -88.94, 76.38, 
    -85.47, 77.40, 
    -85.43, 77.93, 
    -87.01, 78.54, 
    -83.17, 78.94, 
    -84.87, 79.93, 
    -81.33, 79.82, 
    -76.27, 80.92, 
    -82.88, 80.62, 
    -82.58, 81.16, 
    -86.51, 81.05, 
    -89.36, 81.21, 
    -90.45, 81.38, 
    -89.28, 81.86, 
    -87.21, 82.30, 
    -80.51, 82.05, 
    -80.16, 82.55, 
    -77.83, 82.86, 
    -75.51, 83.05, 
    -71.18, 82.90, 
    -65.10, 82.78, 
    -63.34, 81.80, 
    -68.26, 81.26, 
    -69.46, 80.34, 
    -71.05, 79.82, 
    -74.40, 79.46, 
    -75.42, 79.03, 
    -75.48, 78.92, 
    -76.01, 78.20, 
    -80.66, 77.28, 
    -78.07, 76.98, 
    -80.90, 76.13
  }
  , {
    -92.86, 74.13, 
    -92.50, 72.70, 
    -94.89, 73.16, 
    -92.96, 74.14
  }
  , {
    -94.80, 76.95, 
    -89.68, 76.04, 
    -88.52, 75.40, 
    -82.36, 75.67, 
    -79.39, 74.65, 
    -86.15, 74.22, 
    -91.70, 74.94, 
    -95.60, 76.91, 
    -94.87, 76.96
  }
  , {
    -99.96, 73.74, 
    -97.89, 72.90, 
    -98.28, 71.13, 
    -102.04, 72.92, 
    -101.34, 73.14, 
    -99.69, 73.59
  }
  , {
    -107.58, 73.25, 
    -104.59, 71.02, 
    -101.71, 69.56, 
    -104.07, 68.62, 
    -106.61, 69.12, 
    -114.09, 69.05, 
    -113.89, 70.12, 
    -115.88, 70.32, 
    -116.10, 71.32, 
    -117.45, 72.48, 
    -113.53, 72.44, 
    -109.84, 72.24, 
    -106.62, 71.71, 
    -107.43, 73.04
  }
  , {
    -120.96, 74.29, 
    -118.37, 72.53, 
    -123.06, 71.18, 
    -123.40, 73.77, 
    -120.93, 74.27
  }
  , {
    -108.83, 76.74, 
    -106.25, 75.54, 
    -107.08, 74.78, 
    -112.99, 74.16, 
    -112.28, 74.99, 
    -116.04, 75.33, 
    -115.27, 76.20, 
    -110.95, 75.56, 
    -109.77, 76.31, 
    -108.82, 76.70
  }
  , {
    -115.70, 77.46, 
    -118.10, 76.30, 
    -121.13, 76.37, 
    -116.04, 77.28
  }
  , {
    -110.01, 77.86, 
    -112.36, 77.68, 
    -109.96, 77.86
  }
  , {
    -109.60, 78.48, 
    -112.20, 78.01, 
    -109.60, 78.48
  }
  , {
    -97.87, 76.61, 
    -99.21, 75.31, 
    -100.86, 75.60, 
    -99.40, 76.26, 
    -97.79, 76.60
  }
  , {
    -94.72, 75.53, 
    -94.66, 75.52
  }
  , {
    -104.10, 79.01, 
    -99.19, 77.54, 
    -103.22, 78.08, 
    -104.30, 78.95
  }
  , {
    -93.74, 77.52, 
    -93.74, 77.52
  }
  , {
    -96.88, 78.50, 
    -96.91, 77.77, 
    -96.94, 78.48
  }
  , {
    -84.69, 65.84, 
    -81.58, 63.87, 
    -85.00, 62.96, 
    -84.63, 65.71
  }
  , {
    -81.84, 62.75, 
    -82.01, 62.63
  }
  , {
    -79.88, 62.12, 
    -79.88, 62.12
  }
  , {
    -43.53, 59.89, 
    -45.29, 60.67, 
    -47.91, 60.83, 
    -49.90, 62.41, 
    -50.71, 64.42, 
    -51.39, 64.94, 
    -52.96, 66.09, 
    -53.62, 67.19, 
    -53.51, 67.51, 
    -51.84, 68.65, 
    -52.19, 70.00, 
    -51.85, 71.03, 
    -55.41, 71.41, 
    -54.63, 72.97, 
    -56.98, 74.70, 
    -61.95, 76.09, 
    -66.38, 75.83, 
    -71.13, 77.00, 
    -66.81, 77.60, 
    -70.78, 77.78, 
    -64.96, 79.70, 
    -63.38, 81.16, 
    -56.89, 82.17, 
    -48.18, 82.15, 
    -42.08, 82.74, 
    -38.02, 83.54, 
    -23.96, 82.94, 
    -25.97, 81.97, 
    -25.99, 80.64, 
    -13.57, 80.97, 
    -16.60, 80.16, 
    -19.82, 78.82, 
    -18.80, 77.54, 
    -21.98, 76.46, 
    -20.69, 75.12, 
    -21.78, 74.40, 
    -24.10, 73.69, 
    -26.54, 73.08, 
    -24.63, 72.69, 
    -21.84, 71.69, 
    -24.62, 71.24, 
    -27.16, 70.89, 
    -27.21, 70.00, 
    -24.10, 69.35, 
    -28.35, 68.43, 
    -32.48, 68.56, 
    -35.26, 66.26, 
    -37.90, 65.90, 
    -40.04, 65.00, 
    -40.49, 64.04, 
    -42.01, 63.14, 
    -42.88, 61.15, 
    -43.09, 60.07, 
    -43.56, 59.90
  }
  , {
    -16.26, 66.41, 
    -15.32, 64.29, 
    -20.14, 63.47, 
    -21.76, 64.21, 
    -21.33, 64.97, 
    -23.04, 65.62, 
    -21.76, 66.26, 
    -18.77, 66.12, 
    -16.23, 66.35
  }
  , {
    0.56, 51.47, 
    -1.71, 54.94, 
    -3.41, 57.52, 
    -5.42, 58.14, 
    -5.77, 55.59, 
    -3.48, 54.82, 
    -4.68, 52.88, 
    -2.68, 51.58, 
    -3.80, 50.08, 
    1.26, 51.14, 
    0.65, 51.41
  }
  , {
    -7.17, 54.91, 
    -9.97, 53.47, 
    -8.52, 51.76, 
    -5.69, 54.79, 
    -7.34, 55.25
  }
  , {
    -1.33, 60.66, 
    -1.17, 60.38
  }
  , {
    -6.18, 58.44, 
    -6.09, 58.36
  }
  , {
    -6.47, 57.58, 
    -6.33, 57.54
  }
  , {
    -7.30, 57.54
  }
  , {
    -7.46, 57.05
  }
  , {
    -6.54, 56.94
  }
  , {
    -6.00, 55.94
  }
  , {
    -5.09, 55.55
  }
  , {
    -4.44, 54.38, 
    -4.30, 54.19
  }
  , {
    -8.08, 71.02, 
    -8.21, 70.86
  }
  , {
    16.92, 79.52, 
    22.26, 78.46, 
    16.86, 76.41, 
    16.00, 77.39, 
    16.03, 77.92, 
    16.81, 79.50
  }
  , {
    14.71, 79.40, 
    16.05, 79.12, 
    14.02, 77.80, 
    13.56, 78.46, 
    12.63, 79.26, 
    14.68, 79.40
  }
  , {
    22.01, 78.24, 
    21.86, 78.23
  }
  , {
    21.54, 77.75, 
    23.88, 77.26, 
    21.53, 77.67, 
    22.79, 77.79
  }
  , {
    23.50, 79.97, 
    28.24, 79.54, 
    20.85, 78.94, 
    19.00, 79.34, 
    21.05, 79.88, 
    23.41, 79.96
  }
  , {
    46.98, 80.23, 
    43.13, 79.97, 
    47.18, 80.22
  }
  , {
    50.43, 80.19, 
    50.55, 79.88, 
    47.77, 79.86, 
    50.45, 80.14
  }
  , {
    61.79, 80.18, 
    61.79, 80.18
  }
  , {
    65.08, 80.69, 
    64.27, 80.59, 
    65.13, 80.68
  }
  , {
    -5.13, 35.66, 
    4.06, 36.63, 
    10.40, 37.12, 
    11.36, 33.61, 
    20.10, 30.10, 
    23.49, 32.17, 
    31.65, 30.80, 
    35.76, 23.74, 
    39.75, 14.82, 
    42.93, 11.34, 
    51.52, 11.45, 
    49.82, 6.99, 
    43.13, -0.62, 
    39.15, -7.58, 
    40.37, -13.20, 
    37.74, -18.17, 
    35.33, -22.71, 
    32.84, -28.15, 
    26.50, -34.39, 
    19.55, -35.51, 
    17.50, -30.88, 
    12.24, -18.75, 
    13.89, -12.81, 
    12.05, -5.55, 
    9.67, 0.14, 
    7.19, 3.79, 
    1.74, 5.39, 
    -4.77, 4.59, 
    -12.00, 6.75, 
    -15.54, 10.98, 
    -16.33, 15.50, 
    -16.10, 22.29, 
    -12.90, 27.12, 
    -9.52, 31.09, 
    -5.41, 35.58
  }
  , {
    33.71, 0.00, 
    33.48, -3.42, 
    33.34, -0.20, 
    33.71, 0.00
  }
  , {
    49.30, -12.50, 
    49.28, -18.79, 
    43.95, -25.50, 
    44.37, -20.08, 
    46.34, -16.31, 
    47.91, -14.08, 
    49.30, -12.50
  }
  , {
    178.88, 69.10, 
    181.20, 68.42, 
    183.52, 67.78, 
    188.87, 66.38, 
    186.54, 64.74, 
    182.87, 65.63, 
    180.13, 65.14, 
    179.48, 64.88, 
    178.20, 64.29, 
    177.46, 62.62, 
    170.42, 60.17, 
    164.48, 59.89, 
    162.92, 57.34, 
    161.82, 54.88, 
    156.42, 51.09, 
    156.40, 57.76, 
    163.79, 61.73, 
    159.90, 60.73, 
    156.81, 61.68, 
    153.83, 59.10, 
    148.57, 59.46, 
    140.77, 58.39, 
    137.10, 54.07, 
    140.72, 52.43, 
    138.77, 47.30, 
    129.92, 42.04, 
    128.33, 38.46, 
    126.15, 35.18, 
    125.12, 39.08, 
    121.62, 40.15, 
    117.58, 38.21, 
    121.77, 36.90, 
    120.73, 32.65, 
    121.28, 30.25, 
    118.83, 24.93, 
    112.69, 21.81, 
    108.53, 21.73, 
    107.55, 16.34, 
    107.32, 10.45, 
    104.39, 10.37, 
    100.01, 13.52, 
    100.26, 8.30, 
    103.22, 1.56, 
    98.21, 9.17, 
    97.66, 15.36, 
    94.21, 17.79, 
    90.05, 21.74, 
    90.06, 21.03, 
    82.06, 15.95, 
    80.05, 11.72, 
    76.41, 8.60, 
    72.79, 17.43, 
    72.02, 20.00, 
    68.98, 21.99, 
    64.62, 24.41, 
    57.83, 24.77, 
    53.11, 26.20, 
    49.67, 29.41, 
    50.96, 25.15, 
    54.33, 23.44, 
    59.03, 22.57, 
    57.87, 18.86, 
    52.95, 15.74, 
    47.26, 12.96, 
    42.75, 14.68, 
    39.93, 19.61, 
    36.92, 25.78, 
    33.30, 28.46, 
    32.60, 30.63, 
    32.18, 30.58, 
    36.08, 35.03, 
    32.53, 36.17, 
    27.77, 36.94, 
    26.51, 39.18, 
    31.54, 40.82, 
    38.53, 40.48, 
    40.35, 43.17, 
    39.88, 46.45, 
    35.18, 44.99, 
    33.50, 44.96, 
    30.24, 45.14, 
    28.70, 41.48, 
    26.55, 39.84, 
    23.62, 39.67, 
    23.80, 37.34, 
    21.90, 36.92, 
    18.79, 42.02, 
    14.52, 44.31, 
    14.58, 42.25, 
    18.32, 39.57, 
    16.05, 39.35, 
    11.52, 42.36, 
    6.87, 43.08, 
    2.80, 41.09, 
    -1.11, 37.14, 
    -6.24, 36.70, 
    -8.67, 39.57, 
    -6.51, 43.13, 
    -0.84, 45.55, 
    -3.93, 48.40, 
    0.48, 49.09, 
    4.20, 51.29, 
    6.44, 52.92, 
    8.42, 55.94, 
    11.72, 55.49, 
    11.73, 53.66, 
    16.78, 54.14, 
    21.40, 56.32, 
    24.67, 57.20, 
    28.94, 59.18, 
    24.16, 59.52, 
    22.07, 62.66, 
    23.76, 65.35, 
    18.70, 62.54, 
    19.11, 59.67, 
    18.40, 58.54, 
    15.34, 55.73, 
    11.74, 58.08, 
    8.37, 57.68, 
    5.80, 59.20, 
    7.38, 60.86, 
    7.51, 61.86, 
    9.62, 62.99, 
    13.37, 65.46, 
    15.46, 67.12, 
    18.54, 68.62, 
    22.32, 69.64, 
    24.77, 70.17, 
    25.93, 69.79, 
    28.56, 70.46, 
    29.75, 69.76, 
    33.83, 69.11, 
    41.90, 66.85, 
    35.14, 66.25, 
    33.30, 66.07, 
    35.46, 64.15, 
    37.68, 64.03, 
    41.71, 64.09, 
    44.80, 65.58, 
    44.87, 68.16, 
    45.92, 66.83, 
    51.79, 67.85, 
    53.70, 67.89, 
    59.68, 68.09, 
    65.07, 69.08, 
    68.56, 69.19, 
    68.38, 70.97, 
    73.03, 71.62, 
    73.80, 68.29, 
    69.42, 66.45, 
    73.43, 66.36, 
    77.51, 68.36, 
    80.74, 66.74, 
    75.27, 68.67, 
    75.11, 71.80, 
    78.62, 70.56, 
    78.43, 71.90, 
    82.72, 71.23, 
    84.25, 70.03, 
    81.40, 72.76, 
    86.50, 74.01, 
    87.68, 74.78, 
    90.25, 75.23, 
    89.68, 75.57, 
    95.12, 75.95, 
    99.69, 76.09, 
    104.10, 77.52, 
    106.34, 76.40, 
    112.99, 75.60, 
    107.88, 73.72, 
    110.43, 73.71, 
    113.34, 73.37, 
    123.10, 73.28, 
    128.94, 73.02, 
    126.10, 72.24, 
    130.53, 70.86, 
    135.49, 71.51, 
    139.60, 72.23, 
    146.04, 72.39, 
    146.92, 72.21, 
    150.77, 71.28, 
    159.92, 70.14, 
    167.68, 69.63, 
    170.20, 69.99, 
    178.88, 69.10
  }
  , {
    68.33, 76.71, 
    66.03, 75.62, 
    59.10, 74.11, 
    54.92, 73.03, 
    56.67, 74.10, 
    58.56, 75.09, 
    63.86, 75.87, 
    68.19, 76.70
  }
  , {
    53.04, 72.57, 
    58.29, 70.39, 
    55.03, 70.78, 
    53.44, 72.26, 
    53.63, 72.61
  }
  , {
    52.22, 46.50, 
    51.73, 44.73, 
    52.56, 41.80, 
    53.43, 40.40, 
    54.22, 37.86, 
    49.04, 38.45, 
    48.17, 42.76, 
    49.33, 45.64, 
    52.22, 46.50
  }
  , {
    62.32, 46.32, 
    60.32, 43.06, 
    59.57, 45.58, 
    61.94, 46.33
  }
  , {
    79.55, 46.12, 
    74.30, 44.44, 
    78.62, 45.79, 
    79.66, 46.07
  }
  , {
    76.81, 41.96, 
    76.73, 41.86
  }
  , {
    35.15, 35.15, 
    34.61, 34.84, 
    35.18, 35.17
  }
  , {
    23.84, 35.33, 
    24.30, 34.91, 
    24.09, 35.39
  }
  , {
    15.54, 37.89, 
    13.47, 37.89, 
    15.54, 37.89
  }
  , {
    9.56, 40.95, 
    8.46, 39.99, 
    9.12, 40.69
  }
  , {
    9.72, 42.60, 
    9.54, 42.35
  }
  , {
    80.60, 8.95, 
    79.73, 5.96, 
    80.10, 8.30
  }
  , {
    11.04, 57.44, 
    10.67, 57.25
  }
  , {
    -77.92, 24.67, 
    -77.98, 24.22
  }
  , {
    -77.61, 23.62, 
    -77.18, 23.64
  }
  , {
    -75.55, 24.13, 
    -75.41, 24.31
  }
  , {
    -91.40, -0.17, 
    -91.52, -0.26
  }
  , {
    -60.25, 46.68, 
    -60.71, 46.33
  }
  , {
    -63.89, 49.47, 
    -63.45, 49.43
  }
  , {
    142.53, -10.60, 
    145.62, -16.34, 
    149.79, -22.09, 
    153.21, -26.82, 
    150.52, -35.19, 
    145.60, -38.53, 
    140.13, -37.69, 
    137.34, -34.77, 
    135.76, -34.56, 
    131.50, -31.34, 
    121.72, -33.65, 
    115.62, -33.25, 
    114.09, -26.01, 
    114.88, -21.27, 
    122.34, -18.13, 
    125.32, -14.53, 
    128.39, -14.90, 
    132.35, -11.42, 
    136.16, -12.43, 
    138.07, -16.45, 
    142.25, -10.78
  }
  , {
    144.72, -40.68, 
    148.32, -42.14, 
    145.57, -42.77, 
    146.47, -41.19
  }
  , {
    172.86, -34.23, 
    176.10, -37.52, 
    177.06, -39.49, 
    174.77, -38.03, 
    172.83, -34.27
  }
  , {
    172.36, -40.53, 
    172.92, -43.81, 
    168.41, -46.13, 
    170.26, -43.21, 
    173.69, -40.94
  }
  , {
    150.74, -10.18, 
    143.04, -8.26, 
    138.48, -6.97, 
    131.95, -2.94, 
    130.91, -1.35, 
    134.38, -2.64, 
    141.24, -2.62, 
    148.19, -8.15, 
    150.75, -10.27
  }
  , {
    117.24, 7.01, 
    117.90, 0.76, 
    113.89, -3.50, 
    109.44, -0.82, 
    113.13, 3.38, 
    117.24, 7.01
  }
  , {
    95.31, 5.75, 
    102.32, 1.40, 
    106.03, -2.98, 
    101.46, -2.81, 
    95.20, 5.73
  }
  , {
    140.91, 41.53, 
    140.79, 35.75, 
    136.82, 34.56, 
    133.56, 34.72, 
    132.49, 35.41, 
    136.73, 37.20, 
    139.82, 40.00, 
    140.68, 41.43
  }
  , {
    133.71, 34.30, 
    131.41, 31.58, 
    129.38, 33.10, 
    133.90, 34.37
  }
  , {
    141.89, 45.50, 
    144.12, 42.92, 
    140.30, 41.64, 
    141.53, 45.30, 
    141.89, 45.53
  }
  , {
    142.57, 54.36, 
    143.64, 49.19, 
    141.99, 45.88, 
    141.92, 50.85, 
    142.60, 54.34
  }
  , {
    121.92, 25.48, 
    120.53, 24.70, 
    121.70, 25.51
  }
  , {
    110.81, 20.07, 
    109.20, 19.66, 
    110.81, 20.07
  }
  , {
    106.51, -6.16, 
    114.15, -7.72, 
    108.71, -7.89, 
    106.51, -6.16
  }
  , {
    164.27, -20.01, 
    164.16, -20.27
  }
  , {
    178.61, -17.04, 
    178.61, -17.04
  }
  , {
    179.45, -16.43, 
    179.35, -16.43
  }
  , {
    -172.55, -13.39, 
    -172.61, -13.78
  }
  , {
    122.26, 18.67, 
    123.05, 13.86, 
    120.73, 13.80, 
    120.43, 16.43, 
    121.72, 18.40
  }
  , {
    125.34, 9.79, 
    125.56, 6.28, 
    122.38, 7.00, 
    125.10, 9.38
  }
  , {
    119.64, 11.35, 
    118.81, 10.16, 
    119.59, 10.86, 
    119.64, 11.35
  }
  , {
    -179.87, 65.14, 
    -177.13, 65.63, 
    -173.46, 64.74, 
    -171.13, 66.38, 
    -176.48, 67.78, 
    -178.80, 68.42
  }
  , {
    101.96, 79.08, 
    101.31, 77.86, 
    101.22, 79.04
  }
  , {
    94.29, 79.29, 
    95.31, 78.68, 
    100.02, 79.43, 
    97.26, 79.62, 
    95.44, 79.65
  }
  , {
    95.46, 80.62, 
    92.39, 79.66, 
    95.07, 80.54
  }
  , {
    138.54, 76.05, 
    144.93, 75.45, 
    140.30, 74.99, 
    137.27, 75.44, 
    138.29, 75.98
  }
  , {
    146.08, 75.29, 
    147.75, 74.73, 
    145.85, 75.06
  }
  , {
    141.44, 73.88, 
    141.48, 73.84
  }
  , {
    0.01, -71.68, 
    6.57, -70.57, 
    15.04, -70.44, 
    25.10, -70.75, 
    33.37, -69.10, 
    38.46, -69.77, 
    42.85, -68.16, 
    46.59, -67.23, 
    49.35, -66.96, 
    52.90, -65.97, 
    58.46, -67.20, 
    63.60, -67.58, 
    70.63, -68.41, 
    69.24, -70.36, 
    76.20, -69.44, 
    88.08, -66.64, 
    94.98, -66.52, 
    101.53, -66.09, 
    111.31, -65.91, 
    118.64, -66.87, 
    126.24, -66.24, 
    133.09, -66.18, 
    139.85, -66.72, 
    146.86, -67.96, 
    153.65, -68.82, 
    159.94, -69.57, 
    164.10, -70.67, 
    170.19, -71.94, 
    165.68, -74.64, 
    163.82, -77.60, 
    162.10, -78.95, 
    166.72, -82.84, 
    175.58, -83.86
  }
  , {
    -178.56, -84.37, 
    -147.96, -85.40, 
    -152.96, -81.12, 
    -153.95, -79.50, 
    -151.24, -77.48, 
    -146.74, -76.44, 
    -137.68, -75.16, 
    -131.63, -74.63, 
    -123.05, -74.41, 
    -114.76, -73.97, 
    -111.91, -75.41, 
    -105.05, -74.77, 
    -100.90, -74.21, 
    -101.04, -73.18, 
    -100.28, -73.06, 
    -93.06, -73.33, 
    -85.40, -73.18, 
    -79.82, -73.04, 
    -78.21, -72.52, 
    -71.90, -73.41, 
    -67.51, -71.10, 
    -67.57, -68.92, 
    -66.65, -66.83, 
    -64.30, -65.28, 
    -59.14, -63.74, 
    -59.58, -64.37, 
    -62.50, -65.94, 
    -62.48, -66.66, 
    -65.64, -68.02, 
    -63.85, -69.07, 
    -61.69, -70.87, 
    -60.89, -72.71, 
    -61.07, -74.30, 
    -63.33, -75.88, 
    -76.05, -77.06, 
    -83.04, -77.12, 
    -74.30, -80.83, 
    -56.40, -82.14, 
    -42.46, -81.65, 
    -31.60, -80.17, 
    -34.01, -79.20, 
    -32.48, -77.28, 
    -26.28, -76.18, 
    -17.18, -73.45, 
    -11.20, -72.01, 
    -8.67, -71.98, 
    -5.45, -71.45, 
    -0.82, -71.74, 
    0.07, -71.68
  }
  , {
    164.65, -77.89, 
    170.95, -77.37, 
    179.67, -78.25
  }
  , {
    -178.74, -78.24, 
    -165.76, -78.47, 
    -158.42, -77.73
  }
  , {
    -58.98, -64.63, 
    -60.99, -68.62, 
    -61.02, -71.70
  }
  , {
    -62.01, -74.94, 
    -52.00, -77.07, 
    -42.23, -77.80, 
    -36.22, -78.03
  }
  , {
    -35.03, -77.81, 
    -26.13, -75.54, 
    -19.35, -73.04, 
    -12.16, -71.86, 
    -6.15, -70.65, 
    -0.57, -69.14, 
    4.93, -70.25, 
    10.91, -69.99, 
    16.52, -69.87, 
    25.41, -70.22, 
    32.13, -69.29, 
    33.62, -69.58
  }
  , {
    70.56, -68.53, 
    73.91, -69.51
  }
  , {
    81.42, -67.87, 
    84.67, -66.41, 
    89.07, -66.73
  }
  , {
    -135.79, -74.67, 
    -124.34, -73.22, 
    -116.65, -74.08, 
    -109.93, -74.64, 
    -105.36, -74.56, 
    -105.83, -74.77
  }
  , {
    -69.30, -70.06, 
    -71.33, -72.68, 
    -71.42, -71.85, 
    -75.10, -71.46, 
    -71.79, -70.55, 
    -70.34, -69.26, 
    -69.34, -70.13
  }
  , {
    -49.20, -77.83, 
    -44.59, -78.79, 
    -44.14, -80.13, 
    -59.04, -79.95, 
    -49.28, -77.84, 
    -48.24, -77.81
  }
  , {
    -58.13, -80.12, 
    -63.25, -80.20, 
    -58.32, -80.12
  }
  , {
    -163.64, -78.74, 
    -161.20, -79.93, 
    -163.62, -78.74
  }
  , {
    66.82, 66.82, 
    66.82, 66.82
  }
};

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
    return asin(cos(c) * sin(this.phi_prime) + ((y*sin(c)*cos(this.phi_prime))/rho));
  }

  public float lambda(float x, float y) {
    float rho = this._rho(x, y);
    float c = this._c(x, y);
    return this.lambda_prime + atan2((x*sin(c)),(rho*cos(phi_prime)*cos(c)-y*sin(phi_prime)*sin(c)));
  }
}


