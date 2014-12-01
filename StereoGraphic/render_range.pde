void render_range_smooth() {
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
      stroke(result);
      point(x + width/2, y + height/2);
    }
  }
}

void render_range_fast() {
  float phi, lambda;
  for (float x = -width/2; x < width/2; x++) {
    for (float y = -height/2; y < height/2; y++) {
      phi = clean_angle(degrees(proj.phi(x, y)));
      lambda = clean_angle(degrees(proj.lambda(x, y)));

      int lx = int(map(lambda, 0, 359, 0, img.width-1));
      int ly = int(map(phi, 0, 359, 0, img.height-1));
      color f00 = img.get(lx, ly);
      stroke(f00);
      point(x + width/2, y + height/2);
    }
  }
}

