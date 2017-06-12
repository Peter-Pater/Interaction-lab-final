//Smart Chair V2.0---Interaction lab final project //<>// //<>//
/*
By Peter and Sam, with reference to the communication example SerialCallResponse.
 Smart Chair V2.0 has two modes:
 Mode 1: Detecting whether the user is sitting straight while working, which is by 
 research a relatively healthy sitting posture while working. Activates sensoring 
 system and alarming system, and deactivates interface.
 Mode 2: When user is tired of working, mode 2 provides a way for resting. Play Flappy
 bird with the smart chair! Activates sensoring system and interface, disactivates
 alarming system.
 */

import processing.sound.*;      // import the Processing sound library
import processing.serial.*;     // import the Processing serial library
Serial myPort;                  // The serial port1
Birdy flappyBird;               
Birdy flappyBirdmama;
SoundFile file;
SoundFile file1;

//ArrayList os obstacles
ArrayList<Obstacle> pipes = new ArrayList<Obstacle>();
//import images
PImage bird1, bird2, pipe1, pipe2, BIRD1, BIRD2, heart; //Images
PImage WaitUserSit, heightSelection, modeSelection, workMode, gameOver, restart, youWin;
PImage mainMenu, preGame, gameStart;
//counters and sitting parameters
int i = 0, j;
int D = 9, t1;
float d1;      // Distance sensor: 4-30cm ;a0
float d2;      // Distance sensor: 10-80;a1
float p = 200;       // pressure sensor
//game related variables
int heartY = 690, tGame = 60;
int bird2X = 845;
int bird2Y = 300;
float ySpeed;
float y = 300;
float flyParameter;
//time related variables
float k = 0, k1 = 0, t;
//variables that controls functions
Boolean play = true, win = false, game = false;
Boolean start = false, mode2 = false, startgame = false;
Boolean soundPlay1 = true, soundPlay2 = true;
//variables for tint
int sit, chooseHeight, mode1, workMode1, gameOver1, win1, preGame1;
//the byte that controls arduino
char mode = 'c';

void setup() {
  key = '0'; //initailize key
  size(800, 600);
  // loading Images
  bird1 = loadImage("bird1.png");
  bird2 = loadImage("bird2.png");
  BIRD1 = loadImage("BIRD_1.png");
  BIRD2 = loadImage("BIRD_2.png");  
  pipe1 = loadImage("pipe1.png");
  pipe2 = loadImage("pipe2.png");
  heart = loadImage("heart.png");
  WaitUserSit = loadImage("waitingForUserToSit.png");
  heightSelection = loadImage("heightSelection.png");
  modeSelection = loadImage("modeSelection.png");
  workMode = loadImage("Focus, dont look at me.png");
  mainMenu = loadImage("MENU.png");
  gameOver = loadImage("gameOver.png");
  restart = loadImage("RESTART.png");
  youWin = loadImage("youWin.png");
  preGame = loadImage("gameStart.png");
  gameStart = loadImage("start.png");
  //decalaring objects
  flappyBird = new Birdy();
  flappyBirdmama = new Birdy();
  pipes.add(new Obstacle(int(random(50, 450)), int(random(50, 150)), 0, 2, 200));
  file = new SoundFile(this, "gameMusic.mp3"); //import music from Pokemon
  file1 = new SoundFile(this, "GameOver.mp3"); //music from Super Mario
  //Serial communication (refered to example SerialCallResponse)
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[2], 9600);
  myPort.bufferUntil('\n');
  smooth();
}


void draw() {
  //print(k, " ", k1, " ", t, " "); //decomment to debug
  println(mode);
  println();
  //interface1: waiting for user to sit down(detecting sitting(pressure))
  if (p <= 20) {
    Sit();
  } else
  {
    sit = 0;
    //interface2: height height (selecting different parameters for postures)
    if (start == false && p >= 10)
    {
      chooseHeight();
    }
    //interface3:choosing mode 1.working mode 2.game mode
    if (mode2 == true)
    {
      mode();//interface4: no interface
    }
    if (key == 'a')
    {
      workMode();//send a byte 'a' to activate alarming system
    } else if (key == 'b')
    {
      //send a byte 'b' to deactivate alarming system
      //game = true;
      startgame = true;
      key = 'c';//reset key
    }

    if (startgame == true)
    {
      preGame();//interface5: game introduction
    }

    if (game == true)
    {
      background(255);
      k = millis()/1000 - k1;
      game();//interface6: game
    }
  }
}
//serial communication(referred to example SerialCallResonse, with editting)
void serialEvent(Serial myPort) {
  // if there is a serial event, nothing happens in draw.
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  // if you got any bytes other than the linefeed:
  myString = trim(myString);
  // split the string at the commas
  // and convert the sections into integers:
  int sensors[] = int(split(myString, ','));
  // print out the values you got:
  for (int sensorNum = 0; sensorNum < sensors.length; sensorNum++) {
    print("Sensor " + sensorNum + ": " + sensors[sensorNum] + "\t");
  }
  // add a linefeed after all the sensor values are printed:
  println();
  if (sensors.length > 1) {
    d1 = sensors[0];
    d2 = sensors[1];
    p =  sensors[2];
  }
  // send a byte to ask for more data:
  myPort.write(mode);
}

//delare class 
class Birdy
{
  void display1()
  {  
    //tint bird to full colour scale in order to prevent the influence from interface
    //shifting
    tint(255, 255);
    //set image mode as center
    imageMode(CENTER);
    //two pictures makeing the bird's wing move up and down
    if (frameCount%10 == 0 ||frameCount%10 == 1 ||frameCount%10 == 2 ||frameCount%10 == 3 ||frameCount%10 == 4) {
      noStroke();
      image(bird1, 220, y, 90, 72);
    } else if (frameCount%10 == 5 ||frameCount%10 == 6 ||frameCount%10 == 7 ||frameCount%10 == 8 ||frameCount%10 == 9) {
      noStroke();
      image(bird2, 220, y, 90, 72);
    }
  }

  void display11()
  {  
    //the bird for interface game introduction
    //tint(255,255);
    imageMode(CENTER);
    if (frameCount%10 == 0 ||frameCount%10 == 1 ||frameCount%10 == 2 ||frameCount%10 == 3 ||frameCount%10 == 4) {
      noStroke();
      image(bird1, 180, 100, 90, 72);
    } else if (frameCount%10 == 5 ||frameCount%10 == 6 ||frameCount%10 == 7 ||frameCount%10 == 8 ||frameCount%10 == 9) {
      noStroke();
      image(bird2, 180, 100, 90, 72);
    }
  }
  void display2()
  {
    //bird for winning scene
    tint(255, 255);
    imageMode(CENTER);
    if (frameCount%10 == 0 ||frameCount%10 == 1 ||frameCount%10 == 2 ||frameCount%10 == 3 ||frameCount%10 == 4) {
      noStroke();
      image(BIRD1, bird2X, bird2Y, 90, 72);
    } else if (frameCount%10 == 5 ||frameCount%10 == 6 ||frameCount%10 == 7 ||frameCount%10 == 8 ||frameCount%10 == 9) {
      noStroke();
      image(BIRD2, bird2X, bird2Y, 90, 72);
    }
  }

  void display22()
  {
    //another bird for interface game introduction
    imageMode(CENTER);
    if (frameCount%10 == 0 ||frameCount%10 == 1 ||frameCount%10 == 2 ||frameCount%10 == 3 ||frameCount%10 == 4) {
      noStroke();
      image(BIRD1, 600, 100, 90, 72);
    } else if (frameCount%10 == 5 ||frameCount%10 == 6 ||frameCount%10 == 7 ||frameCount%10 == 8 ||frameCount%10 == 9) {
      noStroke();
      image(BIRD2, 600, 100, 90, 72);
    }
  }
  //flay the bird
  void fly1()
  {
    //set image mode as center
    imageMode(CENTER);
    if (keyPressed)
    {
     y = y + ySpeed;
     ySpeed = ySpeed - 0.08;
    } else
    {
     y = y + ySpeed;
     ySpeed = ySpeed + 0.1;
    }
    //set flyparamter with data from distance sensors
    //flyParameter = d2 - d1;
    //if (flyParameter <= D-1 && keyPressed == false)
    //{
    // //play up
    // y = y - 2;
    // //ySpeed = ySpeed + 0.01;//for accelerating originally, abandoned for playablility
    //} else if (flyParameter > D && keyPressed == false)
    //{
    // //fly down
    // y = y + 2;
    // //ySpeed = ySpeed + 0.01;
    //} else if (keyPressed == true)
    //{
    // //press any key to let the bird fly straight, new design for playablility, again
    //}
  }
  void fly2()
  {
    //fly the second bird for the winning scene
    if (bird2X >= 580)
    {
      bird2X = bird2X - 2;
    }
    bird2Y = 300;
  }
}
//declare class obstacle
class Obstacle
{
  int pipe1Len, pipe2Len, pipeWidth, pipex, pipeSpeed, space, px;
  //setting parameters for obstacle
  Obstacle(int tempLen1, int tempWidth, int tempx, int tempSpeed, int tempSpace) {
    pipe1Len = tempLen1;
    pipe2Len = 600 - space - pipe1Len;
    pipeWidth = tempWidth;
    pipex = tempx;
    pipeSpeed = tempSpeed;
    space = tempSpace;
  }
  //display obstacles  
  void display()
  {
    //tint obstacles to full black scale
    tint(255, 255);
    //set image mode as corner
    imageMode(CORNER);
    px = 800 - pipex;
    //imort the images
    image(pipe2, px, 0, pipeWidth, pipe1Len);
    image(pipe1, px, pipe1Len + space, pipeWidth, pipe2Len);
  }

  void move()
  {
    //move the obstacles
    pipex = pipex + pipeSpeed;
  }
  //testing whether the bird hits the obstacles
  void test()
  {
    if ((px>265||(px+pipeWidth)<175||((pipe1Len<y-36)&&(pipe1Len + space)>y+36))&& (y-36>0 && y+36<600))
    {//the area that is safe
    } else
    {//if hit, end the game
      play = false;
      file.stop();
      //reset soundPlay1
      soundPlay1 = true;
      //play gameover music(Mario)
      if (soundPlay2 == true)//only play once
      {
        file1.play();
        //reseting soundPlay2
        soundPlay2 = false;
      }
    }
  }
}

void game()
{
  //  println(20 - k);
  //win1 = 0;
  //sit = 0;//decomment for debugging
  //reset variables for tinting
  chooseHeight = 0;
  mode1 = 0;
  workMode1 = 0;
  //gameOver1 = 0;
  //play the game
  if (play == true && win == false) {
    flappyBird.display1();
    flappyBird.fly1();
    //println(60-k);
    //adding obsatacles
    for (i = 0; i<pipes.size(); i++) {
      Obstacle pipe;
      pipe = pipes.get(i);
      pipe.display();
      pipe.move();
      pipe.test();
    }
    //adding obstacles periodically
    if (millis()/1000 - t1 - t >= 5 && tGame-k>=12 && play == true)
    {
      pipes.add(new Obstacle(int(random(20, 470)), int(random(100, 200)), 0, 2, int(random(150, 180+tGame-k))));
      t = millis()/1000 - t1;
    } else if (tGame-k<=7 && play == true)
    {
      //the play wins,play the winning scene
      flappyBirdmama.display2();
      flappyBirdmama.fly2();
      y = 300;
      if (tGame-k<=4 && play == true)
      {
        if (heartY > 300) 
        { 
          imageMode(CENTER);
          image(heart, 400, heartY, 150, 150);
          heartY = heartY - 2;
        } else
        {
          image(heart, 400, 300, 150, 150);
        }
      }
    }
  } else if (tGame-k>=0 && play==false && win == false)
  {
    //the player loses, end the game, interface 6: gameover
    gameOver();
    win = false;
    //print(2);
  }
  if (tGame-k<=0 && play==true && win == false) {
    play = false;
    win = true;
    println("win");//print win when win
  }
  if (win == true)
  {
    win();//win scene
  }
}
//interface one: waiting for user to sit down
void Sit()
{
  //reset the tinting parameters of other interfaces
  preGame1 = 0;
  win1 = 0;
  chooseHeight = 0;
  mode1 = 0;
  workMode1 = 0;
  gameOver1 = 0;
  //set imagemode as corner
  imageMode(CORNER);
  //smoothly shifting interfaces
  tint(255, sit);
  if (sit<255) {
    sit = sit + 1;
  }
  image(WaitUserSit, 0, 0, 800, 600);
}
//interface2: choose height range
void chooseHeight()
{
  //reset the tinting parameters of other interfaces
  preGame1 = 0;
  sit = 0;
  win1 = 0;
  mode1 = 0;
  workMode1 = 0;
  gameOver1 = 0;
  //set imagemode as corner
  imageMode(CORNER);
  //smoothly shifting interfaces
  tint(255, chooseHeight);
  if (chooseHeight <= 255);
  {
    chooseHeight = chooseHeight + 6;
  }
  image(heightSelection, 0, 0);
  //choosing height range, setting D accordingly
  if (keyPressed) {
    if (key =='1'||key == '2')
    {
      D=9;
      mode2 = true;
      start = true;
    } else if (key =='3'||key == '4')
    {
      D=10;
      start = true;
      mode2 = true;
    } else if (key =='5')
    {
      D=11;
      start = true;
      mode2 = true;
    }
  }
}
//interface3: mode selection
void mode()
{
  //reset the tinting parameters of other interfaces
  preGame1 = 0;
  sit = 0;
  chooseHeight = 0;
  workMode1 = 0;
  gameOver1 = 0;
  win1 = 0;
  //set imagemode as corner
  imageMode(CORNER);
  //smoothly shifting interfaces
  tint(255, mode1);
  if (mode1<255) {
    mode1 = mode1 + 6;
  }
  image(modeSelection, 0, 0, 800, 600);
  if (keyPressed) {
    if (key == 'a')
    {
      //send 'A' by serial port
      mode = 'A';
      mode2 = false;
    } else if (key == 'b')
    {
      //send 'B' by serial port
      mode = 'B';
      mode2 = false;
    }
  }
}
//interface4: workMode
void workMode()
{
  //reset the tinting parameters of other interfaces
  preGame1 = 0;
  win1 = 0;
  sit = 0;
  chooseHeight = 0;
  mode1 = 0;
  gameOver1 = 0;
  //set imagemode as corner
  imageMode(CORNER);
  //smoothly shifting interfaces
  tint(255, workMode1);
  if (workMode1<255) {
    workMode1 = workMode1 + 6;
  }
  //shift interface to interface3: mode selection
  image(workMode, 0, 0, 800, 600);
  image(mainMenu, 661, 540, 139, 60);
  mainMenuClick();
}
//shift interface when clicking the icon "main menu"
void mainMenuClick()
{
  if (mousePressed) {
    if (mouseX>=661 && mouseX<=800 && mouseY<=600 && mouseY>=540) {//icon location
      key = 'c';
      game = false;
      mode = 'c';
      mode2 = true;
      refresh1();
      //print("click");
      win = false;
      pipes.add(new Obstacle(int(random(50, 450)), int(random(50, 150)), 0, 2, 200));
      file.stop();
      soundPlay1 = true;
      soundPlay2 = true;
    }
  }
}
//interface6: gameOver
void gameOver()
{
  //reset the tinting parameters of other interfaces
  refresh1();
  preGame1 = 0;
  sit = 0;
  chooseHeight = 0;
  mode1 = 0;
  workMode1 = 0;
  win1 = 0;
  //set imagemode as corner
  imageMode(CORNER);
  //smoothly shifting interfaces
  tint(255, gameOver1);
  if (gameOver1<255) {
    gameOver1 = gameOver1 + 6;
  }
  image(gameOver, 0, 0, 800, 600);
  image(mainMenu, 661, 540, 139, 60);  
  image(restart, 0, 540, 139, 60);
  //click icon "main menu" to go to interface3: mode
  mainMenuClick();
  //click icon "restart" to go to mainmenu
  restartClick();
}
//function of reseting initial game settings
void refresh1()
{
  ySpeed = 0;
  k1 = millis()/1000;
  y = 300;
  heartY = 690;
  bird2X = 845;
  bird2Y = 300;
  for (j = 0; j<=pipes.size()-1; j++)
  {
    pipes.remove(j);
  }
}
//function of reseting initial game settings(only used for restart)
void refresh2()
{
  ySpeed = 0;
  k1 = millis()/1000;
  y = 300;
  play = true;
  heartY = 690;
  bird2X = 845;
  bird2Y = 300;
  for (j = 0; j<=pipes.size()-1; j++)
  {
    pipes.remove(j);
  }
}
//resart icon
void restartClick() {
  if (mousePressed) {
    if (mouseX>=0 && mouseX<=139 && mouseY>=540 && mouseY<=600) {
      key = 'c';
      game = true;
      refresh2();
      gameOver1 = 0;
      win1 = 0;
      mode2 = false;
      win = false;
      t1 = millis()/1000;
      t = 0;
      file.stop();
      //add the fisrt pipe(obstacle)
      pipes.add(new Obstacle(int(random(50, 450)), int(random(50, 150)), 0, 2, 200));
      //play the game music(Pokeymon)
      soundPlay2 = true;
      file.play();
      soundPlay1 = false;//only play once
    }
  }
}
//interface7: you win!
void win()
{
  //reset the tinting parameters of other interfaces
  refresh1();
  preGame1 = 0;
  sit = 0;
  chooseHeight = 0;
  mode1 = 0;
  workMode1 = 0;
  gameOver1 = 0;
  //set imagemode as corner
  imageMode(CORNER);
  //smoothly shifting interfaces
  tint(255, win1);
  if (win1<255) {
    win1 = win1 + 6;
  }
  image(youWin, 0, 0, 800, 600);
  image(mainMenu, 661, 540, 139, 60);  
  image(restart, 0, 540, 139, 60);
  //click icon "main menu" to go to interface3: mode
  mainMenuClick();
  //click icon "restart" to go to mainmenu
  restartClick();
}
//interface: game introduction
void preGame()
{
  //reset the tinting parameters of other interfaces
  win1 = 0;
  sit = 0;
  chooseHeight = 0;
  mode1 = 0;
  workMode1 = 0;
  gameOver1 = 0;
  //set imagemode as corner
  imageMode(CORNER);
  //smoothly shifting interfaces
  tint(255, preGame1);
  if (preGame1<255) {
    preGame1 = preGame1 + 6;
  }
  image(preGame, 0, 0);
  image(gameStart, 400-35, 310-12.5, 70, 25);
  //display two birds
  flappyBirdmama.display22();
  flappyBird.display11();
  //the start icon
  if (mousePressed) {
    //the location of the start icon
    if (mouseX>=400-35 && mouseX<=400+35 && mouseY>=310-12.5 && mouseY<=310+12.5)
    {
      //start the game if clicked
      game = true;
      play = true;
      startgame = false;
      preGame1 = 0;
      //reset the game time
      k1 = millis()/1000;
      t1 = millis()/1000;
      t = 0;
      if (soundPlay1 == true)
      {   
        //play the game music(Pokymon)
        file.play();
        soundPlay1 = false;//only play for once
      }
    }
  }
}