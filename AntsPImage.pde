//Please read the accompanying README_Variables.txt to get an explanation for this code

PImage img;

int number = 100000;
float v = 1;
float randomAngle = 0.1; //0.2
float fov = 0.3;
float viewDistance = 8;
int fovSize = 2;
float pheromoneFade = 0.99;
float cavePheromoneCounterFalloff = 0.9965;
float foodPheromoneCounterFalloff = 0.998;
float turningSpeed = 0.3;
int baseBrightness = 30;
float foodUsage = 0.95;
int showFrames = 1;
int skipFrames = 1;
int border = 50;

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
  //size(1920,1080);
  fullScreen();
  setCanvas();
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
    background(50);
    showBackground();
    showPheromonesFoodCavesAnts();
    //tga is fastest to save but takes ages to render out
    //png is fastest to render and takes less space but is saved very slowly
    //tif takes most space but is somewhat fast to render and fairly save
    saveFrame("G:/VideoEditing/ProcessingVideo/(Unpublished) Ants PImage/output100k0_2/frame######.tif");  
    stroke(200);
    fill(200);
    text(frameRate, 0, 10);
    text(frameCount, 10, 20);
  }
  
}




void setCanvas(){
  img = createImage(width, height, RGB);
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
  for(int x=border; x<width-border; x++){
    for(int y=border; y<height-border; y++){
      if(noise(float(x)/100, float(y)/100) > 0.65){
        food[x][y] = 1;
      }
    }
  }
  
  
  for(int x=border; x<width-border; x++){
    for(int y=border; y<height-border; y++){
      if(noise(float(x)/100, float(y)/100) < 0.2){
        caves[x][y] = 1;
      }
    }
  }
  /*caveCenterX = width/2;//random(caveRadius, width-caveRadius-1);
  caveCenterY = height/2;//random(caveRadius, height-caveRadius-1);*/
}



void setPositions(){
  int correctPosition;
  for(int i=0; i<number; i++){
    correctPosition = 0;
    while(correctPosition == 0){
      x[i] = random(0,width);
      y[i] = random(0,height);
      if(caves[int(x[i])][int(y[i])] == 0 && food[int(x[i])][int(y[i])] == 0){
        correctPosition = 1;
      }
    }
    //x[i] = caveCenterX+random(-0.9*caveRadius, 0.9*caveRadius);
    //y[i] = caveCenterY+random(-0.9*caveRadius, 0.9*caveRadius);
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
    
    float[] foodTrail = new float[3];
    float[] caveTrail = new float[3];
    float[] foodDirect = new float[3];
    float[] caveDirect = new float[3];
    int xTemp;
    int yTemp;
    for(int setoffX = -fovSize; setoffX<fovSize; setoffX++){
      for(int setoffY = -fovSize; setoffY<fovSize; setoffY++){
        for(int j = 0; j<3; j++){
          xTemp = (lookingX[j]+setoffX+width-1)%(width-1);
          yTemp = (lookingY[j]+setoffY+height-1)%(height-1);
          foodTrail[j] += foodPheromone[xTemp][yTemp];
          caveTrail[j] += cavePheromone[xTemp][yTemp];
          foodDirect[j] += food[xTemp][yTemp];
          caveDirect[j] += caves[xTemp][yTemp];
        }
      }
    }
    
    int moved = 0;
    //###################################################################################################
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
    x[i] = (x[i]+v*sin(angle[i])+width-1.035)%(width-1);
    y[i] = (y[i]+v*cos(angle[i])+height-1.035)%(height-1);
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
      if(state[i] != 1){
        state[i] = 1;
        angle[i] += random(PI-PI/8, PI+PI/8);
      }
    }
    if(food[round(x[i])][round(y[i])] > 0.1 && state[i] != 2){
      foodPheromoneCounter[i] = 1;
      state[i] = 2;
      angle[i] += PI;
      food[round(x[i])][round(y[i])] *= foodUsage;
    }
  }
}




void showBackground(){
  img.loadPixels();
  for(int x=0; x<width; x++){
    for(int y=0; y<height; y++){
      img.pixels[int(x)+int(y)*width] = color(baseBrightness);
    }
  }
  img.updatePixels();
}





void showPheromonesFoodCavesAnts(){ 
  img.loadPixels();
  for(int x=0; x<width; x++){
    for(int y=0; y<height; y++){
      if(cavePheromone[x][y] > 0.1 || foodPheromone[x][y] > 0.1){
        img.pixels[int(x)+int(y)*width] = color(baseBrightness+(255-baseBrightness)*foodPheromone[x][y],baseBrightness+0.4*(255-baseBrightness)*cavePheromone[x][y],baseBrightness+(255-baseBrightness)*cavePheromone[x][y]);
      }
      if(food[x][y] > 0.1){
        //float factor = map(noise(float(x)/400, float(y)/400), 0,1, 0.2,1);
        img.pixels[int(x)+int(y)*width] = color(100*food[x][y],200*food[x][y],0);
        //img.pixels[int(x)+int(y)*width] = color(100*food[x][y]*factor,50*food[x][y]*factor,10*food[x][y]*factor);
      }
      if(caves[x][y] == 1){
        img.pixels[int(x)+int(y)*width] = color(20);
      }
    }
  }
  /*for(int i=0; i<number; i++){
    img.pixels[int(x[i])+int(y[i])*width] = color(255);
  }*/
  img.updatePixels();
  image(img, 0,0);
}
