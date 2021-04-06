//Please read the accompanying README_Variables.txt to get an explanation for this code

int number = 20000;
float v = 1;
float randomAngle = 0.1;
float antSize = 1;
float foodAmount = 2000;
float fov = 0.3;
float viewDistance = 8;
int fovSize = 2;
float pheromoneFade = 0.997;
float cavePheromoneCounterFalloff = 0.9965;
float foodPheromoneCounterFalloff = 0.998;
float turningSpeed = 0.3;
int gridDisplay = 5;
int baseBrightness = 30;
float foodUsage = 0.6;
int showFrames = 1;
int skipFrames = 1;

float[] x = new float[number];
float[] y = new float[number];
float[] angle = new float[number];
float[] state = new float[number];
float[][] caves;
float[][] food;
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

float caveRadius = random(3,9);
float caveCenterX;
float caveCenterY;


void setup(){
  size(1920,1080);
  //fullScreen();
  setGrids();
  setPositions();
}


void draw(){
  for(int frames = 0; frames<skipFrames; frames++){
    updateAngles();
    moveAnts();
    updatePheromones();
    checkCollisions();
  }
  
  if(frameCount%showFrames == 0){
    background(baseBrightness);
    showPheromones();
    showCave();
    showFood();
    showAnts();
    //saveFrame("output/frame######.png");
    stroke(0);
    fill(0);
    text(frameRate, 0, 10);
    text(frameCount, 10, 20);
  }
}


void setGrids(){
  caves = new float[width][height];
  food = new float[width][height];
  cavePheromone = new float[width][height];
  foodPheromone = new float[width][height];
  for(int x=0; x<width; x++){
    for(int y=0; y<height; y++){
      caves[x][y] = 0;
      food[x][y] = 0;
      cavePheromone[x][y] = 0;
      foodPheromone[x][y] = 0;
    }
  }
  float foodChunks = round(random(12,16));
  for(int chunk = 0; chunk<foodChunks; chunk++){
    float foodRadius = sqrt(foodAmount*random(10,30)/foodChunks);
    float foodCenterX = random(foodRadius, width-foodRadius-1);
    float foodCenterY = random(foodRadius, height-foodRadius-1);
    for(int x=round(foodCenterX-foodRadius); x<foodCenterX+foodRadius-1; x++){
      for(int y=round(foodCenterY-foodRadius); y<foodCenterY+foodRadius-1; y++){
        food[x][y] = 1;
      }
    }
  }
  caveCenterX = width/2;//random(caveRadius, width-caveRadius-1);
  caveCenterY = height/2;//random(caveRadius, height-caveRadius-1);
  for(int x=round(caveCenterX-caveRadius); x<caveCenterX+caveRadius; x++){
    for(int y=round(caveCenterY-caveRadius); y<caveCenterY+caveRadius; y++){
      caves[x][y] = 1;
      food[x][y] = 0;
    }
  }
}



void setPositions(){
  for(int i=0; i<number; i++){
    //x[i] = random(0,width);
    //y[i] = random(0,height);
    x[i] = caveCenterX+random(-0.9*caveRadius, 0.9*caveRadius);
    y[i] = caveCenterY+random(-0.9*caveRadius, 0.9*caveRadius);
    angle[i] = random(0,2*PI);
    state[i] = 0;
  }
}


void updateAngles(){
  //Check three areas
  for(int i=0; i<number; i++){
    lookingX[0] = round((x[i]+viewDistance*v*sin(angle[i]-fov)+width-1)%(width-1));
    lookingY[0] = round((y[i]+viewDistance*v*cos(angle[i]-fov)+height-1)%(height-1));
    lookingX[1] = round((x[i]+viewDistance*v*sin(angle[i])+width-1)%(width-1));
    lookingY[1] = round((y[i]+viewDistance*v*cos(angle[i])+height-1)%(height-1));
    lookingX[2] = round((x[i]+viewDistance*v*sin(angle[i]+fov)+width-1)%(width-1));
    lookingY[2] = round((y[i]+viewDistance*v*cos(angle[i]+fov)+height-1)%(height-1));
    
    /*
    stateLeft += caves[lookingX[0]][lookingY[0]] + 2*food[lookingX[0]][lookingY[0]];
    stateCentre += caves[lookingX[1]][lookingY[1]] + 2*food[lookingX[1]][lookingY[1]];
    stateRight += caves[lookingX[2]][lookingY[2]] + 2*food[lookingX[2]][lookingY[2]];
    */
    
    /*
    //Move towards food if the ant has no food
    if(state[i] == 0 || state[i] == 1){
      if(food[centreX][centreY] < 0.1){
        if(food[leftX][leftY] > 0.1){
          angle[i] -= fov;
        }
        if(food[rightX][rightY] > 0.1){
          angle[i] += fov;
        }
      }
    }
    //Move towards caves if the ant is carrying food
    if(state[i] == 2){
      if(caves[centreX][centreY] < 0.1){
        if(food[leftX][leftY] > 0.1){
          angle[i] -= fov;
        }
        if(caves[rightX][rightY] > 0.1){
          angle[i] += fov;
        }
      }
    }
    */
    
    float[] foodTrail = new float[3];
    float[] caveTrail = new float[3];
    float[] foodDirect = new float[3];
    float[] caveDirect = new float[3];
    for(int j = 0; j<3; j++){
      foodTrail[j] = 0;
      caveTrail[j] = 0;
      foodDirect[j] = 0;
      caveDirect[j] = 0;
    }
    for(int setoffX = -fovSize; setoffX<fovSize; setoffX++){
      for(int setoffY = -fovSize; setoffY<fovSize; setoffY++){
        for(int j = 0; j<3; j++){
          int xTemp = (lookingX[j]+setoffX+width-1)%(width-1);
          int yTemp = (lookingY[j]+setoffY+height-1)%(height-1);
          foodTrail[j] += foodPheromone[xTemp][yTemp];
          caveTrail[j] += cavePheromone[xTemp][yTemp];
          foodDirect[j] += food[xTemp][yTemp];
          caveDirect[j] += caves[xTemp][yTemp];
        }
      }
    }
    
    int moved = 0;
    
    //Move towards food if the ant has no food
    if(state[i] == 0 || state[i] == 1){
      if(max(foodDirect) > 0){
        if(foodDirect[0] == max(foodDirect)){
          angle[i] -= fov*turningSpeed;
          moved = 1;
        }
        if(foodDirect[2] == max(foodDirect)){
          angle[i] += fov*turningSpeed;
          moved = 1;
        }
      }
    }
    //Move towards caves if the ant is carrying food
    if(state[i] == 2 && max(caveDirect) > 0){
      if(caveDirect[0] == max(caveDirect)){
        angle[i] -= fov*turningSpeed;
        moved = 1;
      }
      if(caveDirect[2] == max(caveDirect)){
        angle[i] += fov*turningSpeed;
        moved = 1;
      }
    }
    
    //Move towards food pheromones if the ant has no food
    if(state[i] == 0 || state[i] == 1){
      if(moved == 0){
        if(max(foodTrail) > 0.1){
          cavePheromoneCounter[i] /= sqrt(cavePheromoneCounterFalloff);
        }
        if(foodTrail[0] == max(foodTrail)){
          angle[i] -= fov*turningSpeed;
        }
        if(foodTrail[2] == max(foodTrail)){
          angle[i] += fov*turningSpeed;
        }
      }
    }
    //Move towards cave pheromones if the ant is carrying food
    if(state[i] == 2 && moved == 0){
      if(max(caveTrail) > 0.1){
        foodPheromoneCounter[i] /= sqrt(foodPheromoneCounterFalloff);
      }
      if(caveTrail[0] == max(caveTrail)){
        angle[i] -= fov*turningSpeed;
      }
      if(caveTrail[2] == max(caveTrail)){
        angle[i] += fov*turningSpeed;
      }
    }
    
  }
  for(int i=0; i<number; i++){
    angle[i] += random(-randomAngle,randomAngle);
  }
}


void moveAnts(){
  for(int i=0; i<number; i++){
    x[i] = (x[i]+v*sin(angle[i])+width-1)%(width-1);
    y[i] = (y[i]+v*cos(angle[i])+height-1)%(height-1);
  }
}


void updatePheromones(){
  for(int i=0; i<number; i++){
    if(state[i] == 1){// && random(1) > 0.6){
      cavePheromone[round(x[i])][round(y[i])] += cavePheromoneCounter[i];
    }
    if(state[i] == 2){// && random(1) > 0.6){
      foodPheromone[round(x[i])][round(y[i])] += foodPheromoneCounter[i];
    }
    cavePheromoneCounter[i] *= cavePheromoneCounterFalloff;
    foodPheromoneCounter[i] *= foodPheromoneCounterFalloff;
  }
  for(int x=0; x<width; x++){
    for(int y=0; y<height; y++){
      foodPheromone[x][y] *= pheromoneFade;
      cavePheromone[x][y] *= pheromoneFade;
      if(foodPheromone[x][y] < 0.02){
        foodPheromone[x][y] = 0;
      }
      if(cavePheromone[x][y] < 0.02){
        cavePheromone[x][y] = 0;
      }
    }
  }
}


void checkCollisions(){
  for(int i=0; i<number; i++){
    if(caves[round(x[i])][round(y[i])] > 0.1){
      cavePheromoneCounter[i] = 1;
      //if(state[i] != 1){
        state[i] = 1;
        angle[i] += random(PI-PI/4, PI+PI/4);
      //}
    }
    if(food[round(x[i])][round(y[i])] > 0.1 && state[i] != 2){
      foodPheromoneCounter[i] = 1;
      state[i] = 2;
      angle[i] += PI;
      food[round(x[i])][round(y[i])] *= foodUsage;
    }
  }
}


void showPheromones(){
  if(gridDisplay == 1){
    for(int x=0; x<width; x++){
      for(int y=0; y<height; y++){
        if(cavePheromone[x][y] > 0.1 || foodPheromone[x][y] > 0.1){
          if(abs(x-caveCenterX)>caveRadius || abs(y-caveCenterY)>caveRadius){
            stroke(baseBrightness+(255-baseBrightness)*foodPheromone[x][y],baseBrightness,baseBrightness+(255-baseBrightness)*cavePheromone[x][y]);
            point(x,y);
          }
        }
      }
    }
  }
  else{
    rectMode(CENTER);
    for(int x=0; x<width; x+=gridDisplay){
      for(int y=0; y<height; y+=gridDisplay){
        if(cavePheromone[x][y] > 0.1 || foodPheromone[x][y] > 0.1){
          if(abs(x-caveCenterX)>caveRadius || abs(y-caveCenterY)>caveRadius){
            stroke(255-255*cavePheromone[x][y],255-255*foodPheromone[x][y]-255*cavePheromone[x][y],255);
            fill(255-255*cavePheromone[x][y],255-255*foodPheromone[x][y]-255*cavePheromone[x][y],255);
            rect(x,y,gridDisplay,gridDisplay);
          }
        }
      }
    }
  }
}

void showCave(){
  stroke(20);
  fill(20);
  rectMode(CENTER);
  rect(caveCenterX,caveCenterY, 2*caveRadius, 2*caveRadius);
}

void showFood(){
  if(gridDisplay == 1){
    for(int x=0; x<width; x++){
      for(int y=0; y<height; y++){
        if(food[x][y] > 0.1){
          stroke(100*food[x][y],200*food[x][y],0);
          point(x,y);
        }
      }
    }
  }
  else{
    rectMode(CENTER);
    for(int x=0; x<width; x+=gridDisplay){
      for(int y=0; y<height; y+=gridDisplay){
        if(food[x][y] > 0.1){
          stroke(100*food[x][y],200*food[x][y],0);
          fill(100*food[x][y],200*food[x][y],0);
          rect(x,y,gridDisplay,gridDisplay);
        }
      }
    }
  }
}


void showAnts(){
  for(int i=0; i<number; i++){
    if(abs(x[i]-caveCenterX)>caveRadius || abs(y[i]-caveCenterY)>caveRadius){
      if(state[i] == 2){
        stroke(50,100,0);
        fill(100,150,0);
      }
      else{
        stroke(150);
        fill(150);
      }
      if(antSize == 1){
        point(x[i],y[i]);
      }
      else{
        rect(x[i],y[i], antSize, antSize);
      }
    }
  }
}
