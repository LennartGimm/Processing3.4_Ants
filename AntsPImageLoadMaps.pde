//Please read the accompanying README_Variables.txt to get an explanation for this code

PImage img;
PImage map;

int number = 10000;
float v = 1.4; //1
float randomAngle = 0.2; //0.1
float fov = 0.3;
float viewDistance = 8;
int fovSize = 2;
float pheromoneFade = 0.997; //0.99
float cavePheromoneCounterFalloff = 0.999; //0.9965
float foodPheromoneCounterFalloff = 0.999; //0.998
float turningSpeed = 0.25; //0.3
int baseBrightness = 30;
float foodUsage = 0.4; //0.25 //0.95
int showFrames = 1;
int skipFrames = 16;
int border = 0;

float[] x = new float[number];
float[] y = new float[number];
float[] angle = new float[number];
float[] state = new float[number];
float[][] caves;
float[][] food;
float[][] obstacles;
float[][] cavePheromone;
float[] cavePheromoneCounter = new float[number];
float[] foodPheromoneCounter = new float[number];
float[][] foodPheromone;
float valueLeft;
float valueCenter;
float valueRight;
int[] lookingX = new int[3];
int[] lookingY = new int[3];
float stateLeft, stateCentre, stateRight;



void setup() {
  //size(1920,1080);
  fullScreen();
  map = loadImage("Map8.png");
  setCanvas();
  setGrids();
  setPositions();
}


void draw() {
  for (int frames = 0; frames<skipFrames; frames++) {
    updateAngles();
    moveAnts();
    updatePheromones();
    checkCollisions();
  }

  if (frameCount%showFrames == 0) {
    background(50);
    showBackground();
    showPheromonesFoodCavesAntsObstacles();
    //tga is fastest to save but takes ages to render out
    //png is fastest to render and takes less space but is saved very slowly
    //tif takes most space but is somewhat fast to render and fairly to save
    saveFrame("outputObstaclesNewMap2/frame######.png");  
    stroke(200);
    fill(200);
    text(frameRate, 0, 10);
    text(frameCount, 10, 20);
  }
}




void setCanvas() {
  img = createImage(width, height, RGB);
}






void setGrids() {
  caves = new float[width][height];
  food = new float[width][height];
  obstacles = new float[width][height];
  cavePheromone = new float[width][height];
  foodPheromone = new float[width][height];
  for (int x=0; x<width; x++) {
    for (int y=0; y<height; y++) {
      caves[x][y] = 0;
      food[x][y] = 0;
      obstacles[x][y] = 0;
      cavePheromone[x][y] = 0;
      foodPheromone[x][y] = 0;
    }
  }


  for (int x=border; x<width-border; x++) {
    for (int y=border; y<height-border; y++) {
      if (red(map.pixels[x+y*width]) < 20 && green(map.pixels[x+y*width]) > 200 && blue(map.pixels[x+y*width]) < 20) {
        food[x][y] = 1;
      }
    }
  }
  for (int x=border; x<width-border; x++) {
    for (int y=border; y<height-border; y++) {
      if (red(map.pixels[x+y*width]) < 20 && green(map.pixels[x+y*width]) < 20 && blue(map.pixels[x+y*width]) < 20) {
        caves[x][y] = 1;
      }
    }
  }
  for (int x=border; x<width-border; x++) {
    for (int y=border; y<height-border; y++) {
      if (red(map.pixels[x+y*width]) > 200 && green(map.pixels[x+y*width]) < 20 && blue(map.pixels[x+y*width]) < 20) {
        obstacles[x][y] = 1;
      }
    }
  }
}



void setPositions() {
  int correctPosition;
  for (int i=0; i<number; i++) {
    correctPosition = 0;
    while (correctPosition == 0) {
      x[i] = random(0, width);
      y[i] = random(0, height);
      if (caves[int(x[i])][int(y[i])] == 0 && food[int(x[i])][int(y[i])] == 0 && obstacles[int(x[i])][int(y[i])] == 0) {
        correctPosition = 1;
      }
    }
    angle[i] = random(0, 2*PI);
    state[i] = 0;
  }
}


void updateAngles() {

  //Check three areas
  for (int i=0; i<number; i++) {
    lookingX[0] = round((x[i]+viewDistance*v*sin(angle[i]-fov)+width-1)%(width-1));
    lookingY[0] = round((y[i]+viewDistance*v*cos(angle[i]-fov)+height-1)%(height-1));
    lookingX[1] = round((x[i]+viewDistance*v*sin(angle[i])+width-1)%(width-1));
    lookingY[1] = round((y[i]+viewDistance*v*cos(angle[i])+height-1)%(height-1));
    lookingX[2] = round((x[i]+viewDistance*v*sin(angle[i]+fov)+width-1)%(width-1));
    lookingY[2] = round((y[i]+viewDistance*v*cos(angle[i]+fov)+height-1)%(height-1));

    float[] foodTrail = new float[3];
    float[] caveTrail = new float[3];
    float[] foodDirect = new float[3];
    float[] caveDirect = new float[3];
    float[] obstacleDirect = new float[3];
    int xTemp;
    int yTemp;
    for (int setoffX = -fovSize; setoffX<fovSize; setoffX++) {
      for (int setoffY = -fovSize; setoffY<fovSize; setoffY++) {
        for (int j = 0; j<3; j++) {
          xTemp = (lookingX[j]+setoffX+width-1)%(width-1);
          yTemp = (lookingY[j]+setoffY+height-1)%(height-1);
          foodTrail[j] += foodPheromone[xTemp][yTemp];
          caveTrail[j] += cavePheromone[xTemp][yTemp];
          foodDirect[j] += food[xTemp][yTemp];
          caveDirect[j] += caves[xTemp][yTemp];
          obstacleDirect[j] += obstacles[xTemp][yTemp];
        }
      }
    }

    boolean moved = false;
    //###################################################################################################
    //Move away from obstacles 
    if (max(obstacleDirect) > 0) {
      if (obstacleDirect[0] == max(foodDirect)) {
        angle[i] -= 4*fov*turningSpeed;
        moved = true;
      }
      if (obstacleDirect[2] == max(foodDirect)) {
        angle[i] += 4*fov*turningSpeed;
        moved = true;
      }
      if (obstacleDirect[1] == max(foodDirect) && !moved) {
        angle[i] += 6*random(-fov*turningSpeed, fov*turningSpeed);
        moved = true;
      }
    }

    if (!moved) {
      //Move towards food if the ant has no food
      if (state[i] == 0 || state[i] == 1) {
        if (max(foodDirect) > 0) {
          if (foodDirect[0] == max(foodDirect)) {
            angle[i] -= fov*turningSpeed;
            moved = true;
          }
          if (foodDirect[2] == max(foodDirect)) {
            angle[i] += fov*turningSpeed;
            moved = true;
          }
        }
      }
      //Move towards caves if the ant is carrying food
      if (state[i] == 2 && max(caveDirect) > 0) {
        if (caveDirect[0] == max(caveDirect)) {
          angle[i] -= fov*turningSpeed;
          moved = true;
        }
        if (caveDirect[2] == max(caveDirect)) {
          angle[i] += fov*turningSpeed;
          moved = true;
        }
      }
    }

    //Move towards food pheromones if the ant has no food
    if (state[i] == 0 || state[i] == 1) {
      if (!moved) {
        if (max(foodTrail) > 0.1) {
          //cavePheromoneCounter[i] /= sqrt(cavePheromoneCounterFalloff);
          cavePheromoneCounter[i] += 0.001;
        }
        if (foodTrail[0] == max(foodTrail)) {
          angle[i] -= fov*turningSpeed;
        }
        if (foodTrail[2] == max(foodTrail)) {
          angle[i] += fov*turningSpeed;
        }
      }
    }
    //Move towards cave pheromones if the ant is carrying food
    if (state[i] == 2 && !moved) {
      if (max(caveTrail) > 0.1) {
        //foodPheromoneCounter[i] /= sqrt(foodPheromoneCounterFalloff);
        foodPheromoneCounter[i] += 0.001;
      }
      if (caveTrail[0] == max(caveTrail)) {
        angle[i] -= fov*turningSpeed;
      }
      if (caveTrail[2] == max(caveTrail)) {
        angle[i] += fov*turningSpeed;
      }
    }


    if (moved) {
      angle[i] += 2*random(-randomAngle, randomAngle);
    } 
    else {
      angle[i] += random(-randomAngle, randomAngle);
    }
  }
}


void moveAnts() {
  float xTemp, yTemp;
  float rounding = 4;
  for (int i=0; i<number; i++) {
    //Wrap Around
    //xTemp = (x[i]+v*sin(angle[i])+width-1.035)%(width-1);
    //yTemp = (y[i]+v*cos(angle[i])+height-1.035)%(height-1);
    //Computerized
    //xTemp = round(x[i]+v*sin(angle[i]));
    //yTemp = round(y[i]+v*cos(angle[i]));
    //Normal
    xTemp = float(round(rounding*(x[i]+v*sin(angle[i]))))/rounding+0.02;
    yTemp = float(round(rounding*(y[i]+v*cos(angle[i]))))/rounding+0.02;
    if (obstacles[int(xTemp)][int(yTemp)] == 0) {
      x[i] = xTemp;
      y[i] = yTemp;
    } 
    else {
      angle[i] = random(0, 2*PI);
    }
    //x[i] = (x[i]+v*sin(angle[i])+width-1.035)%(width-1);
    //y[i] = (y[i]+v*cos(angle[i])+height-1.035)%(height-1);
  }
}


void updatePheromones() {
  for (int i=0; i<number; i++) {
    if (state[i] == 1) {// && random(1) > 0.6){
      cavePheromone[round(x[i])][round(y[i])] += cavePheromoneCounter[i];
    }
    if (state[i] == 2) {// && random(1) > 0.6){
      foodPheromone[round(x[i])][round(y[i])] += foodPheromoneCounter[i];
    }
    cavePheromoneCounter[i] *= cavePheromoneCounterFalloff;
    foodPheromoneCounter[i] *= foodPheromoneCounterFalloff;
  }
  for (int x=0; x<width; x++) {
    for (int y=0; y<height; y++) {
      foodPheromone[x][y] *= pheromoneFade;
      cavePheromone[x][y] *= pheromoneFade;
      if (foodPheromone[x][y] < 0.06) {
        foodPheromone[x][y] = 0;
      }
      if (cavePheromone[x][y] < 0.06) {
        cavePheromone[x][y] = 0;
      }
    }
  }
}


void checkCollisions() {
  for (int i=0; i<number; i++) {
    if (caves[round(x[i])][round(y[i])] > 0.1) {
      cavePheromoneCounter[i] = 1;
      if (state[i] != 1) {
        state[i] = 1;
        angle[i] += random(PI-PI/8, PI+PI/8);
      }
    }
    if (food[round(x[i])][round(y[i])] > 0.1 && state[i] != 2) {
      foodPheromoneCounter[i] = 1;
      state[i] = 2;
      angle[i] += PI;
      food[round(x[i])][round(y[i])] *= foodUsage;
    }
  }
}




void showBackground() {
  img.loadPixels();
  for (int x=0; x<width; x++) {
    for (int y=0; y<height; y++) {
      img.pixels[int(x)+int(y)*width] = color(baseBrightness);
    }
  }
  img.updatePixels();
}





void showPheromonesFoodCavesAntsObstacles() { 
  img.loadPixels();
  for (int x=0; x<width; x++) {
    for (int y=0; y<height; y++) {
      if (cavePheromone[x][y] > 0.1 || foodPheromone[x][y] > 0.1) {
        img.pixels[int(x)+int(y)*width] = color(baseBrightness+(255-baseBrightness)*foodPheromone[x][y], baseBrightness+0.4*(255-baseBrightness)*cavePheromone[x][y], baseBrightness+(255-baseBrightness)*cavePheromone[x][y]);
      }
      if (food[x][y] > 0.1) {
        //float factor = map(noise(float(x)/400, float(y)/400), 0,1, 0.2,1);
        img.pixels[int(x)+int(y)*width] = color(100*food[x][y], 200*food[x][y], 0);
        //img.pixels[int(x)+int(y)*width] = color(100*food[x][y]*factor,50*food[x][y]*factor,10*food[x][y]*factor);
      }
      if (caves[x][y] == 1) {
        img.pixels[int(x)+int(y)*width] = color(20);
      }
      if (obstacles[x][y] == 1) {
        img.pixels[int(x)+int(y)*width] = color(160);
      }
    }
  }
  /*for(int i=0; i<number; i++){
   img.pixels[int(x[i])+int(y[i])*width] = color(255);
   }*/
  img.updatePixels();
  image(img, 0, 0);
}
