ArrayList <Peg>      pegs     = new ArrayList<Peg>();    // array of pegs
ArrayList <Board>    boards   = new ArrayList<Board>();  // array of boards
int levelNumber  = 1;             // used for "switch"
int numPick = 1;                  // not used yet
int numPlayerGuess = 1;           // number of guesses
int numComputerGuess = 1;         // not used yet
int numPegs = 0;                  // number of Pegs (objects)
int numPegsLength = 0;            // size of "pegs" array
float w = 0;                      // size of phasing white circle
boolean changeSize = true;        // circle should get bigger/smaller
boolean pick = true;              // mouse click counts once
boolean win  = false;             // whether you won or not
boolean developer = false;        // shows computer pegs
boolean showComputerPegs = false; // shows answer after game over
boolean drawComputerPegs = true;  // only draws pegs once
int circleX = 50;                 // circle X placement
int circleY = 45;                 // circle Y placement
int s    = 1;                     // seconds
int time = millis();              // time
int wait = 1000;                  // time between seconds
color[] pegColor = new color[6];  // contains the 6 peg colors
int[] playerPegs   = new int[4];  // not used yet
int[] computerPegs = new int[4];  // contains the computer answers
int board = 0;                    // not used yet
int[] playerGuesses   = new int[48];  // contains player guesses
int[] computerGuesses = new int[48];  // not used yet
int[] blackPegs       = new int[12];  // # of black pegs per guess
int[] whitePegs       = new int[12];  // # of white pegs per guess
int game = 0;                         // determines game number


void setup() {
  size(500, 750);
  rectMode(CENTER);           // draws rectangles from the center
  textSize(25);               // text size
  textAlign(CENTER, CENTER);  // text alignment
  frameRate(60);
  smooth();
  pegColor[0] = color(pink);      // first color is pink
  pegColor[1] = color(blueL);     // second color is light blue
  pegColor[2] = color(purpleB);   // third color is purple
  pegColor[3] = color(red);       // red
  pegColor[4] = color(yellowD);   // yellow
  pegColor[5] = color(green);     // green
  
  // draws player and computer boards
  for(int i = 0; i < 2; i++) {
    boards.add(new Board());
  }
  
  // creates + chooses the computer's peg colors and placement
  for(int j = 0; j < 4; j++) {
    computerPegs[j] = int(random(5.999));
    pegs.add(new Peg(pegColor[computerPegs[j]],100*j+50,650,20));
    numPegsLength++;
    numPegs++;
  }
}

void draw() {
  background(brownL);
  
  // draws the player board
  boards.get(board).drawBoard();
  timer();
  
  // determines what mode you're in
  switch(levelNumber) {
//    case 0:              // startup mode
//      startup();         // not used
//      break;
    case 1:              // game mode             
      play();
      break;
    case 2:              // game over mode             
      gameOver();
      break;
  }
  
  // determines whether to show computer pegs or not
  if(showComputerPegs && drawComputerPegs
  || developer        && drawComputerPegs) {
    for(int i = 0; i < numPegs; i++) {
      pegs.get(i).drawPeg();
    }
  }
  else {
    for(int i = 4; i < numPegs; i++) {
      pegs.get(i).drawPeg();
    }
  }
  
  // draws the clickable pegs on the right from top to bottom
  fill(pegColor[0]);
  ellipse(475,250,20,20);
  fill(pegColor[1]);
  ellipse(475,275,20,20);
  fill(pegColor[2]);
  ellipse(475,300,20,20);
  fill(pegColor[3]);
  ellipse(475,325,20,20);
  fill(pegColor[4]);
  ellipse(475,350,20,20);
  fill(pegColor[5]);
  ellipse(475,375,20,20);
  
  // if the mouse is on one of the 6 dots on the right
  // draw a bigger circle over it
  for(int i = 0; i < 6; i++) {
    // if mouse is on the circle, draw a bigger one over if
    if(dist(mouseX, mouseY, 475, 250+i*25) < 10) {
      fill(pegColor[i]);            // circle color
      ellipse(475,250+i*25,25,25);  // circle
    }
  }
  
  // If the mouse is on the "undo" button, change the colors
  if(mouseX > width - 70 &&  mouseX < width
  && mouseY < 40 &&  mouseY > 0
  && boards.get(0).numPegs2 > 0) {
    fill(black);
    rect(width-35, 20, 70, 40);
    fill(white);
    text("Undo", width-35, 20);
    
    // If it's clicked and you can undo, remove the last guess
    if(mousePressed && boards.get(0).numPegs2%4 != 0 
    && pick == true) {
      pick = false;              // can't click until mouse released
      numPlayerGuess--;          // lowers the guess number by 1
      playerGuesses[boards.get(0).numPegs2-1] = 0;  // removes guess from the array
      boards.get(0).numPegs2--;  // number of pegs is dropped
      circleX -= 100;            // move circle back
    }
  }
  else {
    noFill();
    rect(width-35, 20, 70, 40);
    fill(black);
    text("Undo", width-35, 20);
  }
  
  // If backspace or left arrow is pressed undo
  if(keyPressed && boards.get(0).numPegs2%4 != 0 
  && pick == true && boards.get(0).numPegs2 > 0) {
    if(keyCode == BACKSPACE || keyCode == LEFT) {
      pick = false;
      numPlayerGuess--;
      playerGuesses[boards.get(0).numPegs2-1] = 0;
      boards.get(0).numPegs2--;
      circleX -= 100;
    }
  }
}

// allows you to click/press a key again
void mouseReleased() {
  pick = true;
}
void keyReleased() {
  pick = true;
}

// the mode where you play the game
void play() {
  
  // draws the phasing circle
  fill(255,255,255,175);
  ellipse(circleX,circleY,w,w);
  
  // gets bigger
  if(w <= 0) {
    changeSize = true;
  }
  
  // gets smaller
  if(w >= 40) {
    changeSize = false;
  }
  if(changeSize) {
    w += .75;
  }
  else {
    w -= .75;
  }
  
  //  makes us a new guess
  for(int i = 0; i < 6; i++) {
    
    // if mouse is on a peg on the right
    if(dist(mouseX, mouseY, 475, 250+i*25) < 10) {
      if(mousePressed && pick == true) {
        circleX += 100;                        // move circle
        playerGuesses[numPlayerGuess-1] = i;   // put guess in array                        
        boards.get(0).numPegs2++;              // adds # of pegs
        // put color in the board color array
        boards.get(0).pegsC[numPlayerGuess-1] = pegColor[i];
        numPlayerGuess++;                // adds number of guesses
        pick = false;                    // can't click until released
        
        // moves circle down if row is done
        if(numPlayerGuess%4-1 == 0) {
          circleX = 50;
          circleY += 45;
          
          // if you lose go to "gameOver()"
          if(numPlayerGuess-1 == 48) {
            levelNumber++;
          }
          calculate();  // determines # of black/white pegs
        }
      }
    }
  }
}

void calculate() {
  int[] answer = new int[4];  // contains the answers
  int[] guess  = new int[4];  // contains the row's guesses
  int sameSpot  = 0;          // # of black pegs
  int sameColor = 0;          // # of white pegs
  int timeAround = int((numPlayerGuess-1)/4);  // row #
  
  // Plugs in the guesses and answers
  // Also determines # of black pegs
  for(int i = 0; i < 4; i++) {
    // plugs in the computer's answers
    answer[i] = computerPegs[i];
    // plugs in the row's guesses
    guess[i]  = playerGuesses[(timeAround-1)*4 + i];
    
    // Determines the # of black pegs
    if(answer[i] == guess[i]) {
      sameSpot++;      // one more black peg
      answer[i] = -1;  // this number won't be used again
      guess[i]  = -2;  // this number won't be used again
    }
  }
  
  // determines number of white pegs
  // first row
  for(int i = 0; i < 4; i++) {
    // second row
    for(int j = 0; j < 4; j++) {
      if(answer[i] == guess[j]) {
        sameColor++;    // one more white peg
        guess[j] = -3;  // this number won't be used again
        j = 4;          // this number won't be used again 
      }
    }
  }
  blackPegs[timeAround-1] = sameSpot;   // plugs in # of black pegs
  whitePegs[timeAround-1] = sameColor;  // plugs in # of white pegs
  boards.get(0).numBlack += sameSpot;   // sends # black to Board
  boards.get(0).numWhite += sameColor;  // sends # white to Board
  boards.get(0).calculate = true;       // can have Board draw pegs
  boards.get(0).numGuessPegs += sameSpot+sameColor;  // num of pegs
  // prints the num of black/white pegs
  println("Black: " + sameSpot + ", " + "White: " + sameColor);
  
  // if all black pegs, call gameOver() and win
  if(sameSpot == 4) {
    if(levelNumber < 2) {
      levelNumber++; // game over
    }
      win = true;    // allows win screen
  }
}

// when the game is over
void gameOver() {
  fill(black);
  
  // if you win
  if(win) {
    showComputerPegs = true;  // shows the answer
    text("You Win!",width/2, height/2+5);
    text("Click to Play Again",width/2, height/2+50);
  }
  
  //if you lose
  else {
    showComputerPegs = true;  // shows the answer
    text("You Couldn't Guess in Time",width/2, height/2+5);
    text("Click to Play Again",width/2+2, height/2+50);
  }
  
  // if mouse is clicked restart the game
  if(mousePressed && pick == true) {
    showComputerPegs = false;  // don't show pegs anymore
    drawComputerPegs = true;   // if in dev mode, redraws new pegs
    pick = false;              // can't click until released
    win  = false;              // resets if you win
    game++;                    // increases game number
    numPegs = 0;               // doesn't draw the Pegs
    numPlayerGuess = 1;        // back to first guess
    boards.get(0).numPegs2 = 0;  // no guess pegs
    // puts the phasing circle back at the first spot
    circleX = 50;
    circleY = 45;
    levelNumber = 1;  // can play() the game again
   
    // computer makes new guesses
    for(int j = 0; j < 4; j++) {
      computerPegs[j] = int(random(5.999));
      pegs.get(j).c = pegColor[computerPegs[j]];
      numPegs++;
    }
  }
}

// keeps a timer going
void timer() {
  //  a second is up
  if(millis() - time >= wait) {
    s++;                         // increases # of seconds
    time = millis();             // also update the stored times
  }
}

// color variables
color red     = color(255,0,0);          // red
color redD    = color(200,0,0);          // dark red
color redDD   = color(100,0,0);          // really dark red
color orangeL = color(255,175,30);       // light orange
color orange  = color(255,120,0);        // orange
color orangeD = color(204,100,0);        // dark orange
color yellow  = color(255,255,0);        // yellow
color yellowD = color(230,230,0);        // dark yellow
color yellowDD= color(200,200,0);        // really dark yellow
color greenB  = color(0,255,0);          // bright green
color green   = color(0,200,0);          // green
color greenD  = color(0,125,0);          // dark green
color blueL   = color(0,255,255);        // light blue
color blue    = color(0,0,235);          // blue
color blueD   = color(0,0,150);          // dark blue
color pink    = color(255,0,255);        // pink
color purpleB = color(180,0,255);        // bright purple
color purple  = color(100,0,150);        // purple
color purpleD = color(50,0,100);         // dark purple
color brownL  = color(150,75,0);         // light brown
color brown   = color(100,50,0);         // brown
color brownD  = color(60,30,0);          // dark brown
color black   = color(0);                // black
color white   = color(255);              // white
color grayB   = color(200);              // light gray
color gray    = color(150);              // gray
color grayD   = color(50);               // dark gray
color random  = color(random(5,255),random(5,255),random(5,255));


class Board {
  int[] holesX         = new int[4];      // x positions of holes
  int[] holesY         = new int[13];     // y positions of holes
  // positions of black/white peg holes
  int[] guessHolesX    = new int[2];
  int[] guessHolesY    = new int[24];
  // determines where to draw holes
  boolean yArray       = true;
  color[] pegsC        = new color[48];  // colors of guess pegs
  int numPegs2         = 0;              // # of guess pegs
  color[] guessPegs    = new color[48];  // black or white pegs 
  int numGuessPegs     = 0;              // num of b/w pegs
  int testNumGuessPegs = 0;              // doesn't draw all 4 pegs
  int numBlack;                          // num of black pegs
  int numWhite;                          // num of black pegs
  boolean calculate = false;             // whether it draws pegs
  
  Board() {
    
  }
  
  // draws the board
  void drawBoard() {
    
    // draws the physical board
    fill(purple);
    rect(225,300,450,600);
    
    // draws the holes
    for(int i = 1; i <= holesX.length; i++) {
      // determines x positions of holes
      holesX[i-1] = 100*i-50;
      fill(black);
      holesY[12] = 650;
      ellipse(holesX[i-1], holesY[12],10,10);
      // determines y positions of holes and draws them
      for(int j = 1; j <= holesY.length-1; j++) {
        holesY[j-1] = 45*j;                       // y positions
        fill(black);
        ellipse(holesX[i-1], holesY[j-1],10,10);  // draws holes
      }
    }
    
    // draws the holes for black/white pegs
    for(int i = 1; i <= guessHolesX.length; i++) {
      // determines x positions of holes guess holes
      guessHolesX[i-1] = holesX[3] + 25 +20*i;
      // determines y positions of holes guess holes
      for(int j = 1; j <= guessHolesY.length; j++) {
        // first column
        if(yArray) {
          guessHolesY[j-1] = 45*(j/2)+35;
          yArray = false;
        }
        // second column
        else {
          guessHolesY[j-1] = guessHolesY[j-2] + 20;
          yArray = true;
        }
        // draws the guess holes
        ellipse(guessHolesX[i-1],guessHolesY[j-1],5,5);
      }
    }
    // draws the colored guess pegs
    for(int i = 0; i < numPegs2; i++) {
      fill(pegsC[i]);
      ellipse(holesX[int(i%4)], holesY[int(i/4)],20,20);
    }
    // If it's sent the # of black/white pegs
    if(calculate) {
      // Draw new Pegs
      for(int i = 0; i < 4; i++) {
        // allow another "black" peg
        if(numBlack > 0) {
          guessPegs[numPegs2-4+i] = color(black);
          numBlack--;
        }
        // allow another "white" peg
        else if(numWhite > 0) {
          guessPegs[numPegs2-4+i] = color(white);
          numWhite--;
        }
        // draws the Pegs
        if(testNumGuessPegs < numGuessPegs) {
          // if it's the first game,  make new Pegs
          if(numPegs == numPegsLength) {
            // new Peg
            pegs.add(new Peg(guessPegs[numPegs2-4+i],
            guessHolesX[int(i%2)], 
            guessHolesY[int(int(numPegs2-4+i)/2)],10));
            numPegsLength++;  // add another to the peg.length
            numPegs++;        // recognize another peg
            testNumGuessPegs++;  // make sure it draws the pegs
          }
          // if it's the not first game, only change Peg colors
          else if(numPegs < numPegsLength) {
            // refill color of the Peg 
            pegs.get(numPegs).c = guessPegs[numPegs2-4+i];
            // refills the position of the Peg
            pegs.get(numPegs).x = guessHolesX[int(i%2)];
            pegs.get(numPegs).y = guessHolesY[int(int(numPegs2-4+i)/2)];
            numPegs++;        // recognize another peg
            testNumGuessPegs++;  // make sure it draws the pegs
          }
        }
        // if there's no more pegs to draw
        else {
          testNumGuessPegs = 0;
          numGuessPegs = 0;
          calculate = false;
        }
      }
    }
  }
}


class Computer {
  
  Computer() {
    
  }
  
}


class Peg {
  color c;
  int x,y,size;
  
  Peg(color c_, int x_, int y_, int size_) {
    c = c_;
    x = x_;
    y = y_;
    size = size_;
  }
  
  void drawPeg() {
    fill(c);
    ellipse(x,y,size,size);
  }
}




